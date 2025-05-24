"""Azure Function to run Crawler every 4 hours."""

import logging
import os
import json
from datetime import datetime

import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)


_logger = logging.getLogger(__name__)
logging.getLogger("azure").setLevel(logging.WARNING)


# Heartbeat service to check Azure Function health and build number
@app.route(route="heartbeat", methods=["GET"])
def heartbeat(req: func.HttpRequest) -> func.HttpResponse:
    """Heartbeat API to check the health of the Azure function

    Args:
        req (func.HttpRequest): requesting status

    Returns:
        func.HttpResponse: response with live status
    """

    _build_id = os.getenv("BUILD_ID", "Local Build")
    _logger.info(
        "Build id %s: Heartbeat request received @%s. Time is in UTC.",
        _build_id,
        datetime.utcnow(),
    )
    _json_data = {
        "build_id": _build_id,
        "datetime": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "status": "Function App is running",
    }
    _json_data = json.dumps(_json_data)
    return func.HttpResponse(
        _json_data,
        headers={"Content-Type": "application/json"},
        status_code=200,
    )


@app.function_name(name="crawler")
@app.timer_trigger(
    schedule="%CRAWLER_RUN_SCHEDULE%",
    arg_name="crawlertimer",
    run_on_startup=False,
)
def crawler(crawlertimer: func.TimerRequest) -> None:
    """Crawler timer function.

    Args:
        crawlertimer (func.TimerRequest): timer request

    Raises:
        e: raise exception when failed to run crawler
    """
    _build_id = os.getenv("BUILD_ID", "Local Build")
    _utc_timestamp = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    if crawlertimer.past_due:
        _logger.info("Crawler Run: The timer is past due for build id %s!", _build_id)
    _logger.info(
        "Crawler Run: Python timer trigger function ran at %s for build id %s",
        _utc_timestamp,
        _build_id,
    )
    try:
        from webcrawler import WebCrawler

        _crawler = WebCrawler()
        _crawler.crawl()
        _logger.info(
            "Completed web crawler for build id %s",
            _build_id,
        )
    except Exception as e:
        _logger.error(
            "Failed to run web crawler",
            exc_info=e,
        )
        raise e


@app.function_name(name="prioritycrawler")
@app.timer_trigger(
    schedule="%PRIORITY_CRAWLER_RUN_SCHEDULE%",
    arg_name="crawlertimer",
    run_on_startup=False,
)
def prioritycrawler(crawlertimer: func.TimerRequest) -> None:
    """Crawler timer function.

    Args:
        crawlertimer (func.TimerRequest): timer request

    Raises:
        e: raise exception when failed to run crawler
    """
    _build_id = os.getenv("BUILD_ID", "Local Build")
    _utc_timestamp = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    if crawlertimer.past_due:
        _logger.info("Crawler Run: The timer is past due for build id %s!", _build_id)
    _logger.info(
        "Crawler Run: Python timer trigger function ran at %s for build id %s",
        _utc_timestamp,
        _build_id,
    )
    try:
        from webcrawler import WebCrawler

        _crawler = WebCrawler()
        _crawler.prioritycrawl()
        _logger.info(
            "Completed web crawler for build id %s",
            _build_id,
        )
    except Exception as e:
        _logger.error(
            "Failed to run web crawler",
            exc_info=e,
        )
        raise e