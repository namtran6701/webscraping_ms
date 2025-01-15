"""WebCrawler module to run the web crawler
"""

import os
import json
import logging
import multiprocessing
from datetime import datetime

from azure.core.exceptions import ResourceNotFoundError

from webcrawler.config import ConfigurationHandler
from webcrawler.manager import WebCrawlerManager


class WebCrawler:
    """WebCrawler class to run the crawler"""

    def __init__(self) -> None:
        """Initialize the WebCrawler class"""

        self._logger = logging.getLogger(__name__)
        self._logger.setLevel(os.environ.get("CRAWLER_LOG_LEVEL", "INFO"))

    def crawl(self):
        _config_names = ConfigurationHandler().get_config_names()
        _run_start_time = datetime.utcnow()
        for _config in _config_names:
            _name = _config["name"]
            _schedule = _config["schedule"]
            # Update the environment variable CRAWLER_RUN_SCHEDULE
            os.environ["CRAWLER_RUN_SCHEDULE"] = _schedule            
            self._process(config_name=_name, run_start_time=_run_start_time)
                
    def prioritycrawl(self):
        _priority_config, _priority_config_name = ConfigurationHandler().get_priority_config()
        _run_start_time = datetime.utcnow()
        if _priority_config and _priority_config.documents.urls:
            self._process(config_name=_priority_config_name, run_start_time=_run_start_time)
            ConfigurationHandler().delete_urls(_priority_config_name)
              

    def _process(
        self,
        config_name: str,
        run_start_time: datetime,
    ):
        """Run the web crawler in a separate process"""
        _build_id = os.getenv("BUILD_ID", "Local Build")
        _config_name = config_name

        _manager = multiprocessing.Manager()
        _return_dict = _manager.dict()

        p = multiprocessing.Process(
            target=self._run_crawler_process,
            args=(_config_name, run_start_time, _return_dict),
        )
        p.start()
        p.join()  # the script will block here until the crawling is finished
        p.close()

        _crawl_summary = _return_dict["crawler_summary"]
        self._logger.info(
            json.dumps(_crawl_summary),
        )
        self._logger.info(
            "Crawl completed for build id %s for %s",
            _build_id,
            config_name,
        )

    def _run_crawler_process(
        self,
        config_name: str,
        run_start_time: datetime,
        return_dict: dict,
    ):

        from scrapy.crawler import (
            CrawlerProcess,
        )  # pylint: disable=import-outside-toplevel
        from scrapy.utils.project import (
            get_project_settings,
        )  # pylint: disable=import-outside-toplevel
        from webcrawler.spider import (
            SpiderFone,
        )  # # pylint: disable=import-outside-toplevel

        _web_crawler_manager = WebCrawlerManager(
            config_name=config_name,
            logger=self._logger,
        )
        _scrapy_settings = get_project_settings()
        _download_folder = _scrapy_settings.get("FILES_STORE")
        _web_crawler_manager.set_local_download_folder(_download_folder)
        _configuration = _web_crawler_manager.configuration
        if _configuration.crawl:
            _scrapy_settings["DEPTH_LIMIT"] = _configuration.crawl.depth

        _scrapy_settings["LOG_LEVEL"] = os.getenv("CRAWLER_LOG_LEVEL", "INFO")
        _install_root_handler = False
        if _scrapy_settings["LOG_LEVEL"] == "DEBUG":
            _install_root_handler = True
        _process = CrawlerProcess(
            settings=_scrapy_settings,
            install_root_handler=_install_root_handler,
        )
        _process.crawl(
            SpiderFone,
            web_crawler_manager=_web_crawler_manager,
        )
        _process.start(
            install_signal_handlers=False,
        )
        _process.stop()
        return_dict["crawler_summary"] = _web_crawler_manager.save_summary(
            run_start_time=run_start_time,
        )

    def delete(self):
        try:
            _delete_config = ConfigurationHandler().get_delete_config()
        except ResourceNotFoundError as e:
            self._logger.info(
                "No delete configuration found",
            )  # pylint: unused-variable
            return
        for _delete_config_name in _delete_config.keys():
            _config_name = _delete_config[_delete_config_name]["name"]
            _urls_to_delete = _delete_config[_delete_config_name]["urls"]

            self._logger.info(
                "Processing config for deletion %s with name %s",
                _delete_config_name,
                _config_name,
            )
            self._delete(
                config_name=_config_name,
                urls_to_delete=_urls_to_delete,
            )
        ConfigurationHandler().delete_config()

    def _delete(self, config_name, urls_to_delete):
        """Mark a file for deletion"""

        _build_id = os.getenv("BUILD_ID", "Local Build")

        self._logger.info(
            "In the delete for build id %s for config %s",
            _build_id,
            config_name,
        )

        _config_name = config_name
        _urls_to_delete = urls_to_delete

        _web_crawler_manager = WebCrawlerManager(
            config_name=_config_name,
            logger=self._logger,
        )

        _return_dict = _web_crawler_manager.delete_files(_urls_to_delete)

        _return_dict["activity"] = "delete"
        _return_dict["build_id"] = _build_id
        _return_dict["config_name"] = _config_name
        _return_dict["urls_to_delete"] = _urls_to_delete

        self._logger.info(
            "Deletion completed for build id %s",
            _build_id,
        )
        self._logger.info(
            json.dumps(_return_dict),
        )
        return _return_dict
