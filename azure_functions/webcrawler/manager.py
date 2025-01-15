"""Crawler Manager"""

import os
import json
import shutil
import base64
import hashlib
import yaml
from datetime import datetime
from urllib.parse import urlparse

from azure.core.exceptions import ResourceNotFoundError

from azure.identity import DefaultAzureCredential

from webcrawler.config import ConfigurationHandler, CrawlerConfig
from webcrawler.blob import BlobHandler
from webcrawler.summary import CrawlerSummary


class WebCrawlerManager:
    """Manager for indexing data."""

    def __init__(self, *args, **kwargs) -> None:
        """Initialize the Manger class."""

        _config_name = kwargs.get("config_name")
        self._logger = kwargs.get("logger")

        self.local_download_folder = None

        _configuration = ConfigurationHandler().load(_config_name)

        self.config_name = _config_name
        self.configuration = _configuration

        self._initalize_documents_store()

        self.crawler_summary: CrawlerSummary = CrawlerSummary(
            config_name=self.config_name
        )

    def _initalize_documents_store(
        self,
    ):
        _configuration: CrawlerConfig = self.configuration

        self.documents_storage_account_url = _configuration.documents.storage.account
        self.documents_container_name = _configuration.documents.storage.container

        BlobHandler.ensure_container_exists(
            storage_account_url=self.documents_storage_account_url,
            container_name=self.documents_container_name,
        )

    def store_in_blob(
        self,
        url: str,
        contents: list,
        content_type: str,
    ):
        for _chunk_num, _content in enumerate(contents):
            self._store_in_blob(
                url=url,
                chunk_num=_chunk_num,
                content=_content["content"],
                metadata=_content["metadata"],
                content_type=content_type,
            )

    def _store_in_blob(
        self,
        url: str,
        chunk_num,
        content: bytes,
        metadata: dict,
        content_type: str,
    ):
        """store in blob

        Args:
            content (bytes): content
            url (str): url
        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        _blob_path = self._get_blob_path(url, chunk_num, content_type)
        self._logger.debug("Blob path is: %s", _blob_path)
        _checksum = hashlib.md5(content, usedforsecurity=False).hexdigest()

        _is_same_content = self._is_same_content(_checksum, _blob_path)
        if not _is_same_content:
            if _is_same_content is None:
                self._logger.debug(
                    "Content is not present for %s. Uploading blob...",
                    _blob_path,
                )
                self.crawler_summary.new_pages.append(url)
            else:
                self._logger.debug(
                    "Content is changed for %s. Uploading blob...",
                    _blob_path,
                )
                self.crawler_summary.updated_pages.append(url)
            _metadata = {
                "source_address": url,
                "checksum": _checksum,
            }
            _metadata.update(metadata)
            BlobHandler.upload(
                storage_account_url=self.documents_storage_account_url,
                container_name=self.documents_container_name,
                blob_path=_blob_path,
                content=content,
                metadata=_metadata,
                overwrite=True,
            )
        else:
            self._logger.debug("Content is unchanged for %s.", _blob_path)

    def _get_blob_path(self, url, chunk_num, content_type):
        _parsed_url = urlparse(url)
        _blob_path = f"{_parsed_url.netloc}{_parsed_url.path}"
        _base_name = os.path.basename(_blob_path)
        _file_name, _file_extension = os.path.splitext(_base_name)
        if len(_file_name) == 0:
            if "application/pdf" in content_type:
                _file_name = "default"
                _file_extension = ".pdf"
            elif "text/html" in content_type:
                _file_name = "default"
                _file_extension = ".html"
            else:
                _file_name = "default"
                _file_extension = ".txt"
        self._logger.debug("Blob path is: %s", _blob_path)
        _blob_path = os.path.join(
            f"{_blob_path}", f"{_file_name}_{chunk_num}{_file_extension}"
        )

        return _blob_path

    def _is_same_content(self, checksum: str, blob_path: str):
        """check if the content is same

        Args:
            checksum (_type_): checksum
            content (_type_): content

        Raises:
            Exception: exception in case of failure

        Returns:
            bool: response
        """

        try:
            _blob_data = BlobHandler.download(
                storage_account_url=self.documents_storage_account_url,
                container_name=self.documents_container_name,
                blob_path=blob_path,
            )
            _blob_checksum = hashlib.md5(
                _blob_data,
                usedforsecurity=False,
            ).hexdigest()

            self._logger.debug("Incoming chunk checksum is  %s", checksum)
            self._logger.debug("Stored chunk checksum is  %s", _blob_checksum)

            if checksum == _blob_checksum:
                return True
            else:
                return False
        except ResourceNotFoundError:
            return None

    def delete_files(self, urls: list):
        """Delete files

        Args:
            urls (_type_): urls

        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        _return_dict = {}
        for url in urls:
            self._logger.debug("Processing url %s", url)

            _parsed_url = urlparse(url)
            _blob_path = f"{_parsed_url.netloc}{_parsed_url.path}"
            _base_name = os.path.basename(_blob_path)
            _file_name, _file_extension = os.path.splitext(_base_name)

            # if the file name is empty or the extension is empty
            # then we will mark the default files for deletion
            if len(_file_name) == 0 or len(_file_extension) == 0:
                _blob_path = os.path.join(_blob_path, "default")
            _list_blobs = []
            try:
                _list_blobs = BlobHandler.list(
                    storage_account_url=self.documents_storage_account_url,
                    container_name=self.documents_container_name,
                    blob_path=_blob_path,
                )
            except ResourceNotFoundError:
                self._logger.debug("Blob not found for %s", _blob_path)
                _return_dict[url] = "Not Found"
            for _blob in _list_blobs:
                _filename = _blob["name"]
                self._logger.debug("Marking file %s for deletion", _filename)
                try:
                    self._delete_blob(
                        storage_account_url=self.documents_storage_account_url,
                        container_name=self.documents_container_name,
                        blob_path=_filename,
                    )
                    _return_dict[url] = "Marked for deletion"
                except ResourceNotFoundError:
                    self._logger.debug("File not found for %s", _filename)
                    _return_dict[url] = "Not Found"
        return _return_dict

    def _delete_blob(
        self,
        storage_account_url: str,
        container_name: str,
        blob_path: str,
    ):
        """delete blob

        Args:
            storage_account_name (_type_): storage account name
            container_name (_type_): container name
            blob_path (_type_): blob path

        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        from azure.storage.blob import BlobServiceClient

        _credential = DefaultAzureCredential()

        _blob_service_client = BlobServiceClient(
            account_url=storage_account_url,
            credential=_credential,
        )
        _container_client = _blob_service_client.get_container_client(
            container=container_name
        )

        _blob_client = _container_client.get_blob_client(blob=blob_path)
        _blob_metadata = _blob_client.get_blob_properties().metadata
        _more_blob_metadata = {"Status": "Deleted"}
        _blob_metadata.update(_more_blob_metadata)
        _blob_client.set_blob_metadata(metadata=_blob_metadata)

    def tidy_up(self, download_folder: str):
        """Tidy up the resources"""
        shutil.rmtree(download_folder, ignore_errors=True)

    def set_local_download_folder(self, download_folder):
        self.local_download_folder = download_folder

    def save_summary(
        self,
        run_start_time: datetime,
    ):
        """save crawl summary

        Args:
            summary (_type_): summary

        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        if self.configuration.logs:
            _logs_storage_account_url = self.configuration.logs.storage.account
            _logs_container_name = self.configuration.logs.storage.container

            _activity = self.crawler_summary.activity
            _build_id = self.crawler_summary.build_id
            _config_name = self.crawler_summary.config_name

            _log_time = run_start_time.strftime("%Y%m%d/%H%M%S")
            _file_name = f"{_activity}_{_config_name}_summary.json"
            _blob_path = f"{_log_time}/{_build_id}/{_config_name}/{_file_name}"
            self.crawler_summary.log = _blob_path

            BlobHandler.ensure_container_exists(
                storage_account_url=_logs_storage_account_url,
                container_name=_logs_container_name,
            )

            _crawler_summary_content = json.dumps(
                self.crawler_summary.get_full_log(),
                indent=4,
            )
            BlobHandler.upload(
                storage_account_url=_logs_storage_account_url,
                container_name=_logs_container_name,
                blob_path=_blob_path,
                content=_crawler_summary_content,
                overwrite=True,
            )
        return self.crawler_summary.get_metrics()
