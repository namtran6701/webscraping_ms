"""Web crawler for project."""

import os
import logging
from datetime import datetime

import scrapy
import scrapy.exceptions

from webcrawler.helper import WebCrawlerHelper
from webcrawler.summary import CrawlerSummary
from scrapy.linkextractors import LinkExtractor


class SpiderFone(scrapy.Spider):
    """Spider to crawl the web.

    Args:
        scrapy (_type_): Scrapy spider class.
    """

    name = "spiderfone"

    def __init__(self, *args, **kwargs):
        """Initialize the SpiderFone class."""
        super(SpiderFone, self).__init__(*args, **kwargs)
        self._logger = logging.getLogger(__name__)
        self._logger.setLevel(os.getenv("CRAWLER_LOG_LEVEL", "INFO"))

        self.follow_links = None
        self.crawl_start_time = datetime.utcnow()

        self.web_crawler_manager = kwargs.get("web_crawler_manager")
        self.configuration = self.web_crawler_manager.configuration
        self.crawler_summary: CrawlerSummary = self.web_crawler_manager.crawler_summary

        self.web_crawler_helper = WebCrawlerHelper(
            configuration=self.configuration,
            crawler_summary=self.crawler_summary,
        )

        # Define the domains that will be allowed for crawling
        self.follow_links = False
        if self.configuration.crawl:
            self.allowed_domains = self.configuration.crawl.domains
            self.follow_links = self.configuration.crawl.follow
            self.link_extractor = LinkExtractor(
                allow_domains=self.configuration.crawl.domains,
                deny_extensions=self.configuration.crawl.deny_extensions,
                process_value=self.web_crawler_helper.process_value,
                unique=True,
            )

        self.start_urls = self.configuration.documents.urls

    def start_requests(self):
        """Generates initial requests"""
        for url in self.start_urls:
            # Explicitly set the errback handler
            yield scrapy.Request(
                url,
                dont_filter=True,
                callback=self.parse,
                errback=self.errback,
            )

    def parse(self, response):
        """
        Parse the HTML content of the page, extract useful information,
        store in Azure Blob, and follow same-domain links.
        """
        if response.status >= 400 and response.status <= 599:
            self._logger.error(
                "Failed to download %s with status %s",
                response.url,
                response.status,
            )
            self.crawler_summary.failure_pages.append(
                {
                    "url": response.url,
                    "code": response.status,
                }
            )
            return None

        _content_type = response.headers.get("Content-Type").decode("utf-8")
        # if its an HTML page, then follow links
        if "text/html" in _content_type:

            from webcrawler.parsers.html import HtmlParser

            # prevent duplicate run on the same page.
            if response.url not in self.crawler_summary.success_pages:
                HtmlParser.store_html(
                    web_crawler_manager=self.web_crawler_manager,
                    response=response,
                    logger=self._logger,
                )
                self.crawler_summary.success_pages.append(response.url)
                if self.follow_links:
                    _extractor = None
                    if os.getenv("USE_SCRAPY_LINK_EXTRACTOR", "False") == "True":
                        _extractor = self.link_extractor.extract_links(
                            response,
                        )
                    else:
                        _extractor = self.web_crawler_helper.extract_links(
                            response=response,
                        )
                    for _link in _extractor:
                        yield scrapy.Request(
                            _link.url,
                            callback=self.parse,
                            dont_filter=True,
                            errback=self.errback,
                        )
        else:
            # Let the pipeline handle the file
            yield self._get_item(response)

    def _get_item(self, response):
        return {
            "file_urls": [response.url],
            "web_crawler_manager": self.web_crawler_manager,
            "content_type": response.headers.get("Content-Type").decode("utf-8"),
            "logger": self._logger,
        }

    def closed(self, _reason):
        """Called when the spider is closed."""
        self.crawler_summary.end_time = datetime.utcnow()

    def errback(self, err):
        """Handles an error"""
        import twisted

        _code = None
        if err.check(scrapy.exceptions.IgnoreRequest):
            _code = "IgnoreRequest"
        elif err.check(scrapy.exceptions.NotSupported):
            _code = "NotSupported"
        elif err.check(twisted.internet.error.TimeoutError):
            _code = "TimeoutError"
        else:
            _code = err.value.response.status
        self.crawler_summary.failure_pages.append(
            {
                "url": err.request.url,
                "code": _code,
            }
        )
        self._logger.debug(
            "Error downloading %s",
            err.request.url,
            exc_info=err,
            stack_info=True,
        )
        return None
