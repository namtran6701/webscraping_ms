"""Configuration used within the solution
"""

import os
import argparse
import yaml

from typing import List, Optional
from pydantic import BaseModel

from azure.identity import AzureCliCredential

from webcrawler.blob import BlobHandler


class HtmlParser(BaseModel):
    ignored_classes: List[str]


class Html(BaseModel):
    striptags: bool
    parser: HtmlParser


class Crawl(BaseModel):
    follow: bool
    depth: int
    domains: List[str]
    whitelist: List[str]
    blacklist: List[str]
    deny_extensions: Optional[List[str]] = None
    invalid_link_prefixes: List[str]


class Storage(BaseModel):
    account: str
    container: str


class Document(BaseModel):
    storage: Optional[Storage]= None
    urls: List[str]
    
class Logs(BaseModel):
    storage: Storage


class Crawler(BaseModel):
    name: str
    schedule: str

class CrawlerYamlConfig(BaseModel):
    crawlers: List[Crawler]


class CrawlerConfig(BaseModel):
    documents: Document
    crawl: Optional[Crawl] = None
    html: Optional[Html] = None
    logs: Optional[Logs] = None


# Configuration used within the solution
class ConfigurationHandler:
    """Configuration used within the solution"""

    def __init__(
        self,
        args=None,
        credential=None,
    ):
        _storage_account_url = None
        _container_name = None
        self.args = args
        self.credential = credential
        if args:
            _storage_account_url = args.storage_account_url
            _container_name = args.container_name
        else:

            _storage_account_url = os.getenv(
                "CRAWLER_CONFIGURATION_STORAGE_ACCOUNT_URL",
                None,
            )
            if not _storage_account_url:
                raise ValueError(
                    "Storage account url not provided in the environment variable CRAWLER_CONFIGURATION_STORAGE_ACCOUNT_URL"
                )

            _container_name = os.getenv(
                "CRAWLER_CONFIGURATION_CONTAINER_NAME",
                None,
            )
            if not _container_name:
                raise ValueError(
                    "Container name not provided in the environment variable CRAWLER_CONFIGURATION_CONTAINER_NAME"
                )

        self.configuration_storage_account_url = _storage_account_url
        self.configuration_container_name = _container_name

        BlobHandler.ensure_container_exists(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            credential=self.credential,
        )
        
    def preprocess_crawlers(self, raw_crawlers: dict) -> CrawlerYamlConfig:
        """Preprocess the raw crawlers input into a CrawlerYamlConfig instance."""
        parsed_crawlers = []
        for crawler in raw_crawlers:
            if "name" in crawler and "schedule" in crawler:
                parsed_crawlers.append(Crawler(name=crawler["name"], schedule=crawler["schedule"]))
            else:
                raise ValueError(f"Invalid crawler format: {crawler}")
        
        return CrawlerYamlConfig(crawlers=parsed_crawlers)

    def get_config_names(self):
        """Get configuration names and schedules.

        Returns:
            list: List of crawlers with their configurations and schedules.
        """
        _crawler_config_name = os.getenv(
            "CRAWLER_CONFIG_NAME",
            "crawlers.yaml",
        )
        _configuration = BlobHandler.download(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=_crawler_config_name,
        )
        _configuration = yaml.safe_load(_configuration)
        # Preprocess raw crawlers into the expected dictionary format
        raw_crawlers = _configuration.get("crawlers", [])
        processed_crawlers = self.preprocess_crawlers(raw_crawlers)
    
        # Validate the processed configuration
        crawler_config = CrawlerYamlConfig.model_validate(processed_crawlers)

        # Return as a list of dictionaries containing name and schedule
        return [
            {"name": crawler.name, "schedule": crawler.schedule}
            for crawler in crawler_config.crawlers
        ]

    def delete_urls(self, file_name):
        """Clear URLs from the specified YAML file after processing."""
        # Download the current configuration from the Blob storage
        _configuration = BlobHandler.download(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=file_name,
        )

        # Load the configuration and parse it as YAML
        _configuration = yaml.safe_load(_configuration)

        # Modify the content (in this case, clearing the URLs)
        _configuration["crawler"]["documents"]["urls"] = [] # Clear the URLs list

        # Upload the modified configuration back to the Blob storage
        BlobHandler.upload(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=file_name,
            content=yaml.dump(_configuration),  # Convert the dict back to
            overwrite=True,
        )

    def get_priority_config(self):
        """Load the priority configuration file.

        Returns:
            Priority: Parsed configuration for priority settings.
        """
        _priority_config_name = os.getenv(
            "PRIORITY_CRAWLER_CONFIG_NAME",
            "priority.yaml",
        )
        
        _configuration = BlobHandler.download(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=_priority_config_name,
        )
        _configuration = yaml.safe_load(_configuration)
        validated_priority_config = CrawlerConfig.model_validate(_configuration["crawler"])       
        
        
        return validated_priority_config, _priority_config_name

    def get_delete_config(self):
        """Get configuration names

        Returns:
            list: configuration names
        """
        _delete_config_name = os.getenv(
            "CRAWLER_DELETE_NAME",
            "delete.yaml",
        )
        _configuration = BlobHandler.download(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=_delete_config_name,
        )
        _configuration = yaml.safe_load(_configuration)
        return _configuration

    def delete_config(self):
        """Delete configuration

        Returns:
            list: configuration names
        """
        _delete_config_name = os.getenv(
            "CRAWLER_DELETE_NAME",
            "delete.yaml",
        )
        BlobHandler.delete(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=_delete_config_name,
        )

    def load(
        self,
        name: str,
    ):
        """Load configuration

        Args:
            name (str): configuration name

        Returns:
            object: configuration
        """
        _configuration = BlobHandler.download(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=name,
        )
        _configuration = yaml.safe_load(_configuration)
        _validated_configuration = CrawlerConfig.model_validate(
                _configuration["crawler"]
        )
        return _validated_configuration

    def save(
        self,
        name: str,
        configuration: object,
    ):
        """Save configuration
        This is only meant to be used for loading the configuration
        from a local file to the storage account.
        It is NOT meant to be used for saving configuration from
        the solution to the storage account.

        Args:
            name (str): configuration name
            configuration (object): configuration

        Raises:
            Exception: exception in case of failure
        """

        _configuration = yaml.dump(configuration)
        _configuration = _configuration.encode("utf-8")
        BlobHandler.upload(
            storage_account_url=self.configuration_storage_account_url,
            container_name=self.configuration_container_name,
            blob_path=name,
            content=_configuration,
            overwrite=True,
            credential=self.credential,
        )

    def _load_local(self, name: str):
        """Load configuration from local file
        This is used to load the configuration from a local file
        before uploading it to the storage account.
        """
        with open(name, "r", encoding="utf-8") as file:
            _configuration = yaml.safe_load(file)
            return _configuration

    def upload(
        self,
        file_path: str,
    ):
        """Upload configuration to storage account


        Args:
            name (str): configuration name

        Raises:
            Exception: exception in case of failure
        """
        _configuration = self._load_local(name=file_path)
        if self.args.validate_only:
            CrawlerConfig.model_validate(_configuration["crawler"])
        else:
            if not self.args.no_validate:
                CrawlerConfig.model_validate(_configuration["crawler"])
            _blob_path = os.path.basename(file_path)
            self.save(
                name=_blob_path,
                configuration=_configuration,
            )

    def load_local(self, file_path: str):
        _configuration = self._load_local(name=file_path)
        return CrawlerConfig.model_validate(_configuration["crawler"])


def main():
    parser = argparse.ArgumentParser(description="Configuration")
    parser.add_argument(
        "--storage-account-url",
        type=str,
        help="Storage account url",
        required=True,
    )
    parser.add_argument(
        "--container-name",
        type=str,
        help="Container name",
        required=True,
    )
    parser.add_argument(
        "--file-path",
        type=str,
        help="File path",
        required=True,
    )
    parser.add_argument(
        "--no-validate",
        action="store_true",
        help="File path",
        required=False,
        default=False,
    )
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="File path",
        required=False,
        default=False,
    )
    args = parser.parse_args()

    _configuration = ConfigurationHandler(
        args,
        credential=AzureCliCredential(),
    )
    _configuration.upload(
        file_path=args.file_path,
    )


if __name__ == "__main__":
    main()
