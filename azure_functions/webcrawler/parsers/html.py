"""HTML Parser for crawler."""

import re

import base64
from bs4 import BeautifulSoup
from langchain.text_splitter import MarkdownTextSplitter
from webcrawler.config import CrawlerConfig


class HtmlParser:
    """
    HTML parser for the crawler.
    """

    def __init__(self, *args, **kwargs):
        self.configuration: CrawlerConfig = kwargs.get("configuration")
        self._logger = kwargs.get("logger")

    @classmethod
    def store_html(cls, *args, **kwargs):
        """
        Store the HTML content in Azure Blob Storage.
        """
        # Store the content in Azure Blob Storage
        _web_crawler_manager = kwargs.get("web_crawler_manager")
        _response = kwargs.get("response")
        _logger = kwargs.get("logger")
        _html_parser = HtmlParser(
            configuration=_web_crawler_manager.configuration,
            logger=_logger,
        )
        _contents = _html_parser.clean_html(_response.text)
        _web_crawler_manager.store_in_blob(
            url=_response.url,
            contents=_contents,
            content_type=_response.headers.get("Content-Type").decode("utf-8"),
        )

    def clean_html(self, content: str):
        """
        This function cleans the HTML content by removing extra whitespace
        and special characters.
        This function must return a list of dictionaries,
        where each dictionary contains the content and
        metadata for the page. The metadata must be complaint with
        HTTP header rules.
        The content must be a byte array encoded in UTF-8.
        """
        # Parse HTML content
        soup = BeautifulSoup(content, "html.parser")

        # Extract title for the page
        _page_title = soup.title.string if soup.title else "No Title"

        # Extract text content from the page
        if self.configuration.html.striptags:
            _page_text = self._clean_text(soup)
        else:
            _page_text = content

        self._logger.debug("Page title is: %s", _page_title)
        _title = base64.b64encode(_page_title.encode("utf-8")).decode(
            "utf-8"
        )  # encode as the title may contain special characters
        self._logger.debug("Page title after base64encoding is: %s", _title)

        # Perform chunking using the custom_markdown_chunking method
        chunks = self.custom_markdown_chunking(_page_text)
        # Generate metadata for each chunk using a list comprehension
        return [
            {
                "content": chunk.encode("utf-8"),
                "metadata": {"title": _title},
            }
            for chunk in chunks
        ]

    def _clean_text(self, soup):
        """
        Cleans text by removing extra whitespace and special characters.

        Args:
            text (str): The raw text content.

        Returns:
            str: The cleaned text.
        """
        # Get the list of CSS classes to remove from the config
        classes_to_remove = self.configuration.html.parser.ignored_classes

        # Iterate over all tags and remove specific classes
        for tag in soup.find_all(True):  # finds all HTML tags
            if "class" in tag.attrs:
                # Filter out the specific classes from the class list
                tag["class"] = [
                    cls for cls in tag["class"] if cls not in classes_to_remove
                ]

                # If the class attribute is now empty, remove it completely
                if not tag["class"]:
                    tag.attrs.pop("class")

        # Serialize the modified HTML back to a string
        page_text = re.sub(r"[\n\r\t]", "", soup.get_text()).strip()

        # Remove common date formats (e.g., YYYY-MM-DD, MM/DD/YYYY, etc.)
        content = re.sub(
            r"\b\d{4}[-/]\d{2}[-/]\d{2}\b", "", page_text
        )  # e.g., '2023-09-29' or '09/29/2023'

        # Remove common time formats (e.g., HH:MM:SS, HH:MM AM/PM, etc.)
        content = re.sub(
            r"\b\d{1,2}:\d{2}(?::\d{2})?\s?(AM|PM|am|pm)?\b", "", page_text
        )  # e.g., 12:34 PM or 12:34:56

        return content

    def custom_markdown_chunking(self, content):
        """
        Split content using MarkdownTextSplitter from LangChain.
        Falls back to size-based chunking if input isn't markdown-like.
        """
        # Process the contentindexdata HTML content
        soup = BeautifulSoup(content, "html.parser")
        html = str(soup)
        splitter = MarkdownTextSplitter()
        chunks = splitter.split_text(html)
        if chunks:
            return chunks