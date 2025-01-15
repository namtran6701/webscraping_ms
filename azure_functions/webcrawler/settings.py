# Scrapy settings for crawler project
#
# For simplicity, this file contains only settings considered important or
# commonly used. You can find more settings consulting the documentation:
#
#     https://docs.scrapy.org/en/latest/topics/settings.html
#     https://docs.scrapy.org/en/latest/topics/downloader-middleware.html
#     https://docs.scrapy.org/en/latest/topics/spider-middleware.html

BOT_NAME = "webcrawler"

SPIDER_MODULES = ["webcrawler"]
NEWSPIDER_MODULE = "webcrawler"


# Crawl responsibly by identifying yourself (and your website) on the user-agent
USER_AGENT = "Web Crawler (+http://www.google.com)"

# Obey robots.txt rules
ROBOTSTXT_OBEY = True

# Configure maximum concurrent requests performed by Scrapy (default: 16)
CONCURRENT_REQUESTS = 16

# Configure a delay for requests for the same website (default: 0)
# See https://docs.scrapy.org/en/latest/topics/settings.html#download-delay
# See also autothrottle settings and docs
# DOWNLOAD_DELAY = 3

# The amount of time (in secs) that the downloader will wait before timing out.
# https://docs.scrapy.org/en/latest/topics/settings.html#download-timeout
DOWNLOAD_TIMEOUT = 30

# The download delay setting will honor only one of:
# CONCURRENT_REQUESTS_PER_DOMAIN = 16
# CONCURRENT_REQUESTS_PER_IP = 16

# Disable cookies (enabled by default)
COOKIES_ENABLED = False

# Disable Telnet Console (enabled by default)
TELNETCONSOLE_ENABLED = False

# Override the default request headers:
DEFAULT_REQUEST_HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en",
}

# Enable or disable spider middlewares
# See https://docs.scrapy.org/en/latest/topics/spider-middleware.html
# SPIDER_MIDDLEWARES = {
#    "crawler.middlewares.CrawlerSpiderMiddleware": 543,
# }

# Enable or disable downloader middlewares
# See https://docs.scrapy.org/en/latest/topics/downloader-middleware.html
DOWNLOADER_MIDDLEWARES = {
    "scrapy.downloadermiddlewares.retry.RetryMiddleware": None,
}

# Enable or disable extensions
# See https://docs.scrapy.org/en/latest/topics/extensions.html
# EXTENSIONS = {
#    "scrapy.extensions.telnet.TelnetConsole": None,
# }

# Configure item pipelines
# See https://docs.scrapy.org/en/latest/topics/item-pipeline.html
ITEM_PIPELINES = {
    # "scrapy.pipelines.files.FilesPipeline": 1,
    "webcrawler.pipelines.CrawlerFilePipeline": 300,
}
# Folder to store the downloaded files
FILES_STORE = "./temp/downloads"

# Enable and configure the AutoThrottle extension (disabled by default)
# See https://docs.scrapy.org/en/latest/topics/autothrottle.html
AUTOTHROTTLE_ENABLED = True
# The initial download delay
AUTOTHROTTLE_START_DELAY = 5
# The maximum download delay to be set in case of high latencies
AUTOTHROTTLE_MAX_DELAY = 60
# The average number of requests Scrapy should be sending in parallel to
# each remote server
AUTOTHROTTLE_TARGET_CONCURRENCY = 0.5
# Enable showing throttling stats for every response received:
AUTOTHROTTLE_DEBUG = False

# Enable and configure HTTP caching (disabled by default)
# See https://docs.scrapy.org/en/latest/topics/downloader-middleware.html#httpcache-middleware-settings
# HTTPCACHE_ENABLED = True
# HTTPCACHE_EXPIRATION_SECS = 0
# HTTPCACHE_DIR = "httpcache"
# HTTPCACHE_IGNORE_HTTP_CODES = []
# HTTPCACHE_STORAGE = "scrapy.extensions.httpcache.FilesystemCacheStorage"

# Set settings whose default value is deprecated to a future-proof value
REQUEST_FINGERPRINTER_IMPLEMENTATION = "2.7"
TWISTED_REACTOR = "twisted.internet.asyncioreactor.AsyncioSelectorReactor"
FEED_EXPORT_ENCODING = "utf-8"

# Logging settings
# LOG_ENABLED = False

# Set this to append as the log file is initialized in the __init__.py
# LOG_FILE_APPEND = False

# The file to write the log to
# LOG_FILE = "scrapy.log"

# The encoding to use for the log file
# LOG_ENCODING = "utf-8"

# The minimum level to log. Available levels are: CRITICAL, ERROR, WARNING, INFO, DEBUG
# LOG_LEVEL = "DEBUG"

# Log everything to the stdout
# LOG_STDOUT = False

# The format to use for logging
# LOG_FORMAT = (
#     "%(asctime)s [%(name)s] %(levelname)s: %(funcName)s: %(lineno)d: %(message)s"
# )

# https://docs.scrapy.org/en/latest/topics/downloader-middleware.html#retry-enabled
# Disabling retry of downloads
RETRY_ENABED = False

# https://docs.scrapy.org/en/latest/topics/downloader-middleware.html#retry-http-codes
# Which HTTP response codes to retry. Other errors (DNS lookup issues, connections lost, etc) are always retried.
# RETRY_HTTP_CODES = [
#     500,
#     502,
#     503,
#     504,
#     522,
#     524,
#     408,
# ]

# https://docs.scrapy.org/en/latest/topics/downloader-middleware.html#std-setting-RETRY_TIMES
# Maximum number of times to retry, in addition to the first download.
# RETRY_TIMES = 1

# https://docs.scrapy.org/en/latest/topics/settings.html#std-setting-DEPTH_LIMIT
# The maximum depth that will be allowed to crawl for any site. If zero, no limit will be imposed.
DEPTH_LIMIT = 1

# TODO: Find the documentation for this setting
MAX_REQUESTS = 1

# https://docs.scrapy.org/en/latest/topics/settings.html#std-setting-REACTOR_THREADPOOL_MAXSIZE
# The maximum limit for Twisted Reactor thread pool size.
# This is common multi-purpose thread pool used by various Scrapy components.
# Increase this value if you’re experiencing problems with insufficient blocking IO.
REACTOR_THREADPOOL_MAXSIZE = 10

# DNS settings
# https://docs.scrapy.org/en/latest/topics/settings.html#std-setting-DNSCACHE_ENABLED
DNSCACHE_ENABLED = False
DNSCACHE_SIZE = 100
DNS_TIMEOUT = 30
