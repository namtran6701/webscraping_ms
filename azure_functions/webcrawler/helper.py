"""Helper for crawler."""

import re
from urllib.parse import urlparse

from bs4 import BeautifulSoup

from scrapy.link import Link

from webcrawler.config import CrawlerConfig
from webcrawler.summary import CrawlerSummary


class WebCrawlerHelper:
    """Web crawler helper"""

    def __init__(self, configuration: CrawlerConfig, crawler_summary: CrawlerSummary):

        self.configuration: CrawlerConfig = configuration
        self.crawler_summary: CrawlerSummary = crawler_summary

    def extract_links(self, response):
        """
        Extracts links from the page and follows same-domain links recursively.
        """
        _return_list = []
        soup = BeautifulSoup(response.text, "html.parser")
        # Extract all links (a href) and follow the ones
        # belonging to the same domain
        for a_tag in soup.find_all("a", href=True):
            href = a_tag["href"]
            full_url = response.urljoin(href)
            if self.is_valid_link(
                href=href,
                full_url=full_url,
            ):
                _parsed_url = self._parse_url(full_url)

                # Check if the link belongs to the same domain
                if _parsed_url not in self.crawler_summary.visited_urls:
                    self.crawler_summary.visited_urls.append(
                        _parsed_url
                    )  # Mark as visited:
                    _return_list.append(Link(url=_parsed_url))
        return _return_list

    def _parse_url(self, url):
        _url = urlparse(url)
        # drop any parameters and other aspects
        _url_scheme = _url.scheme
        if _url_scheme == "http":
            _url_scheme = "https"
        _url_to_crawl = _url_scheme + "://" + _url.netloc + _url.path
        return _url_to_crawl

    def is_valid_link(self, href, full_url):
        """
        Check if a link is valid based on prefixes.

        Args:
            href (str): The URL of the link.

        Returns:
            bool: True if the link is valid, False otherwise.
        """
        # Check if the link starts with any of the invalid prefixes
        if any(
            href.startswith(prefix)
            for prefix in self.configuration.crawl.invalid_link_prefixes
        ):
            return False  # Invalid if it starts with any invalid prefix
        # Check if the URL matches any of the blacklist patterns
        for blacklist_pattern in self.configuration.crawl.blacklist:
            if re.search(blacklist_pattern, href):
                return False  # Invalid if it matches any blacklist pattern

        # Check if the URL matches any of the whitelist patterns
        for whitelist_pattern in self.configuration.crawl.whitelist:
            if re.search(whitelist_pattern, href):
                return True  # Valid if it matches any whitelist pattern
        if urlparse(full_url).netloc not in self.configuration.crawl.domains:
            return False
        return True

    def process_value(self, value):
        """
        Process the value and return the URL to crawl.

        Args:
            value (str): The value to process.

        Returns:
            str: The URL to crawl.
        """
        _value = value
        if any(
            _value.startswith(prefix)
            for prefix in self.configuration.crawl.invalid_link_prefixes
        ):
            return None
        if urlparse(value).netloc not in self.configuration.crawl.domains:
            return None
        _value = self._parse_url(_value)
        if _value not in self.crawler_summary.visited_urls:
            self.crawler_summary.visited_urls.append(_value)
        return _value
