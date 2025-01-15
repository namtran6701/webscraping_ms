import base64

from webcrawler.config import CrawlerConfig


class TextParser:

    def __init__(self, *args, **kwargs):
        self.configuration: CrawlerConfig = kwargs.get("configuration")
        self._logger = kwargs.get("logger")

    def clean_text(self, content: bytes):
        """
        This function must return a list of dictionaries,
        where each dictionary contains the content and title of the page.
        The content must be a byte array encoded in UTF-8.

        Args:
            response (requests.models.Response): The raw text content.

        Returns:
            list: A list of dictionaries containing the content and
            metadata for the page. The metadata must be complaint with
            HTTP header rules.
            The content must be a byte array encoded in UTF-8.
        """
        lines = content.splitlines()
        for line in lines:
            stripped_line = line.strip()
        if stripped_line:  # Return the first non-empty line
            _page_title = stripped_line
        else:            
            _page_title = "No Title"
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
