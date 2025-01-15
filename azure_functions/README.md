



### To run locally without downloading the files. Useful for testing the crawler.

```powershell

$env:CRAWLER_LOG_LEVEL="INFO"
$env:PYTHONPATH+=";."
$env:STORE_DOWNLOADS_LOCALLY="False"

scrapy runspider ./webcrawler/test/local.py `
-a local_file_path=./webcrawler/config/dev/crawlers/crawltest.yaml `
-a download_folder=./temp/downloads/ `
-s DEPTH_LIMIT=1

```

### To debug the crawler

```powershell

$env:CRAWLER_LOG_LEVEL="DEBUG"
$env:PYTHONPATH+=";."
$env:STORE_DOWNLOADS_LOCALLY="False"

scrapy runspider ./webcrawler/test/local.py `
-a local_file_path=./webcrawler/config/dev/crawlers/crawltest.yaml `
-a download_folder=./temp/downloads/ `
-s DEPTH_LIMIT=1 `
-s LOG_ENABLE=True `
-s LOG_LEVE=DEBUG `
-s LOG_FILE=scrapy.log `
-s LOG_FILE_APPEND=True `
-s LOG_ENCODING=utf-8
```


### Compare against known_list

```powershell

python .\webcrawler\test\compare.py `
--reference-file <path to known list yaml configuration> `
--crawler-summary-file <path to crawler summary json file> `
--output-file <path to output file with comparison. The output is a json file.>

```

### To run the function app locally

```powershell

$env:CRAWLER_CONFIGURATION_STORAGE_ACCOUNT_URL="https://<storage account name>.blob.core.windows.net/"
$env:CRAWLER_CONFIGURATION_CONTAINER_NAME="<container name>"
$env:CRAWLER_CONFIG_NAME="testcrawlers.yaml"
$env:CRAWLER_LOG_LEVEL="INFO"
$env:CRAWLER_RUN_SCHEDULE="0 */5 * * * *"
$env:PRIORITY_CRAWLER_RUN_SCHEDULE="0 */5 * * * *"
$env:CRAWLER_DELETE_SCHEDULE="0 */5 * * * *"
$env:PYTHONPATH+=";."

func start
```


### To debug the function app locally

```powershell

$env:CRAWLER_CONFIGURATION_STORAGE_ACCOUNT_URL="https://<storage account name>.blob.core.windows.net/"
$env:CRAWLER_CONFIGURATION_CONTAINER_NAME="<container name>"
$env:CRAWLER_CONFIG_NAME="testcrawlers.yaml"
$env:CRAWLER_LOG_LEVEL="DEBUG"
$env:CRAWLER_RUN_SCHEDULE="0 */5 * * * *"
$env:PRIORITY_CRAWLER_RUN_SCHEDULE="0 */5 * * * *"
$env:CRAWLER_DELETE_SCHEDULE="0 */5 * * * *"
$env:PYTHONPATH+=";."

func start
```
