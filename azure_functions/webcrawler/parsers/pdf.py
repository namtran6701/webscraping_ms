import base64
import fitz
from webcrawler.config import CrawlerConfig


class PdfParser:

    def __init__(self, *args, **kwargs):
        self.configuration: CrawlerConfig = kwargs.get("configuration")
        self._logger = kwargs.get("logger")

    def clean_pdf(self, content: bytes):
        """
        This function must return a list of dictionaries,
        where each dictionary contains the content and
        metadata for the page. The metadata must be complaint with
        HTTP header rules.
        The content must be a byte array encoded in UTF-8.

        Args:
            content (bytes): The raw PDF content.

        Returns:
            list: A list of dictionaries containing the content and title of the page. The content must be a byte array encoded in UTF-8.
        """
        # Load the PDF from the content bytes
        pdf_document = fitz.open(stream=content, filetype="pdf")

        # Extract metadata and get the title
        metadata = pdf_document.metadata
        _page_title = metadata.get("title", "No Title")  # Default to "No Title" if not found
        self._logger.debug("Page title is: %s", _page_title)
        _title = base64.b64encode(_page_title.encode("utf-8")).decode(
            "utf-8"
        )  # encode as the title may contain special characters
        self._logger.debug("Page title after base64encoding is: %s", _title)

        _metadata = {
            "title": _title,
        }
        return [
            {
                "content": content,
                "metadata": _metadata,
            },
        ]
