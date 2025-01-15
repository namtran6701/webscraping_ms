import os
from datetime import datetime


DATEIME_FORMAT = "%Y-%m-%dT%H:%M:%SZ"


class CrawlerSummary:

    def __init__(
        self,
        config_name,
    ):

        self.activity: str = "crawl"
        self.build_id: str = os.getenv(
            "BUILD_ID",
            "Local Build",
        )
        self.config_name: str = config_name
        self.start_time: datetime = datetime.utcnow()
        self.end_time: datetime = None

        self.success_pages: list[str] = []
        self.failure_pages: list[str] = []
        self.visited_urls: list[str] = []
        self.new_pages: list[str] = []
        self.updated_pages: list[str] = []

        self.closed_reason: str = None
        self.log: str = None

    def get_metrics(
        self,
    ):
        return {
            "build_id": self.build_id,
            "activity": self.activity,
            "config_name": self.config_name,
            "start_time": self.start_time.strftime(DATEIME_FORMAT),
            "end_time": self.end_time.strftime(DATEIME_FORMAT),
            "duration": (self.end_time - self.start_time).total_seconds(),
            "success": len(self.success_pages),
            "failure": len(self.failure_pages),
            "processed": len(self.visited_urls),
            "new": len(self.new_pages),
            "updated": len(self.updated_pages),
            "log": self.log,
        }

    def get_full_log(
        self,
    ):
        _full_log = {}
        _full_log.update(self.get_metrics())
        _full_log.update(
            {
                "success_pages": self.success_pages,
                "failure_pages": self.failure_pages,
                "new_pages": self.new_pages,
                "updated_pages": self.updated_pages,
                "processed_urls": self.visited_urls,
            }
        )
        return _full_log
