import os

from scrapy.pipelines.files import FilesPipeline
from scrapy.exceptions import DropItem

from webcrawler.parsers.pdf import PdfParser
from webcrawler.parsers.text import TextParser
from webcrawler.parsers.html import HtmlParser


class CrawlerFilePipeline(FilesPipeline):

    def process_item(self, item, spider):
        if os.getenv("STORE_DOWNLOADS_LOCALLY", "True") == "True":
            # this is the default behaviour unless overridden
            return super().process_item(item, spider)
        else:
            # when testing locally we don't want to download the files
            # so we capture the URLs and return the item
            _url = item["file_urls"][0]
            if _url not in spider.crawler_summary.success_pages:
                spider.crawler_summary.success_pages.append(_url)
            return item

    def item_completed(self, results, item, info):
        _logger = item["logger"]
        _logger.debug("Results: %s", results)
        _logger.debug("Item: %s", item)
        _logger.debug("Info: %s", info)
        _web_crawler_manager = item["web_crawler_manager"]
        _configuration = _web_crawler_manager.configuration
        _download_folder = _web_crawler_manager.local_download_folder
        _content_type = item["content_type"]
        _logger.debug("Content type: %s", _content_type)
        for success, file_info in results:
            if success:
                _logger.debug("File downloaded: %s", file_info)
                _file_path = os.path.join(_download_folder, file_info["path"])
                with open(_file_path, "rb") as _file:
                    _content = _file.read()
                if "application/pdf" in _content_type:
                    # if the file is a PDF, use the PDF parser
                    _pdf_parser = PdfParser(
                        configuration=_configuration,
                        logger=_logger,
                    )
                    _contents = _pdf_parser.clean_pdf(_content)
                    _web_crawler_manager.store_in_blob(
                        url=file_info["url"],
                        contents=_contents,
                        content_type=_content_type,
                    )
                elif "text/html" in _content_type:
                    # if the file is a HTML file, use the HTML parser
                    _html_parser = HtmlParser(
                        configuration=_configuration,
                        logger=_logger,
                    )
                    _contents = _html_parser.clean_html(_content)
                    _web_crawler_manager.store_in_blob(
                        url=file_info["url"],
                        contents=_contents,
                        content_type=_content_type,
                    )
                elif "text/plain" in _content_type:
                    # if the file is a Text file, use the Text parser
                    _pdf_parser = TextParser(
                        configuration=_configuration,
                        logger=_logger,
                    )
                    _contents = _pdf_parser.clean_text(_content)
                    _web_crawler_manager.store_in_blob(
                        url=file_info["url"],
                        contents=_contents,
                        content_type=_content_type,
                    )
                else:
                    # Fall back to the default implementation
                    _contents = [
                        {
                            "title": "No title",
                            "content": _content,
                        }
                    ]
            if (
                file_info["url"]
                not in _web_crawler_manager.crawler_summary.success_pages
            ):
                _web_crawler_manager.crawler_summary.success_pages.append(
                    file_info["url"]
                )
            else:
                _logger.error("File download failed: %s", file_info)
                _web_crawler_manager.crawler_summary.failure_pages.append(
                    file_info["url"]
                )
                raise DropItem("File download failed")
        return item
