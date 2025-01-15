import logging
import argparse


from azure.search.documents.indexes.models import (
    SearchIndexer,
    IndexingParameters,
    IndexingParametersConfiguration,
    BlobIndexerImageAction,
    IndexerExecutionEnvironment,
)

from azure.identity import AzureCliCredential

from azure.search.documents.indexes import SearchIndexerClient


class AISearchIndexer:

    def __init__(self, args):
        self.args = args

    def create_indexer(self):
        _args = self.args
        _credential = AzureCliCredential()
        _search_endpoint = _args.search_endpoint
        _index_name = _args.index_name
        _use_ocr = _args.use_ocr

        _indexer_name = f"{_index_name}-indexer"
        _skillset_name = f"{_index_name}-skillset"
        _data_source_name = f"{_index_name}-blob"

        _indexer_parameters = IndexingParameters(
            configuration=IndexingParametersConfiguration(
                query_timeout=None,
            )
        )
        if _args.use_private_endpoint:
            _indexer_parameters.configuration.execution_environment = (
                IndexerExecutionEnvironment.PRIVATE
            )
        if _use_ocr:
            _indexer_parameters.configuration.image_action = (
                BlobIndexerImageAction.GENERATE_NORMALIZED_IMAGE_PER_PAGE
            )

        _indexer = SearchIndexer(
            name=_indexer_name,
            description="Indexer to index documents and generate embeddings",
            skillset_name=_skillset_name,
            target_index_name=_index_name,
            data_source_name=_data_source_name,
            parameters=_indexer_parameters,
            schedule={
                "interval": _args.interval,
                "startTime": _args.start_time,
            },
            field_mappings=[
                {
                    "sourceFieldName": "title",
                    "targetFieldName": "title",
                    "mappingFunction": {
                        "name": "base64Decode",
                        "parameters": {
                            "useHttpServerUtilityUrlTokenDecode": False,
                        },
                    },
                }
            ],
        )

        _indexer_client = SearchIndexerClient(_search_endpoint, _credential)
        _indexer_result = _indexer_client.create_or_update_indexer(_indexer)

        _indexer_client.run_indexer(_indexer_name)
        logging.info(
            " %s is created and running. If queries return no results, please wait a bit and try again.",
            _indexer_result.name,
        )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--search-endpoint",
        type=str,
        required=True,
        help="Search endpoint",
    )
    parser.add_argument(
        "--index-name",
        type=str,
        required=True,
        help="Index name",
    )
    parser.add_argument(
        "--use-ocr",
        action="store_true",
        help="Use OCR to extract text from images",
        required=False,
        default=False,
    )
    parser.add_argument(
        "--interval",
        type=str,
        help="Indexer interval",
        required=False,
        default="PT8H",
    )
    parser.add_argument(
        "--start-time",
        type=str,
        help="Indexer start time",
        required=False,
        default="2024-10-01T00:00:00Z",
    )
    parser.add_argument(
        "--use-private-endpoint",
        action="store_true",
        help="Use private endpoint",
        required=False,
        default=False,
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Increase output verbosity",
        required=False,
        default=False,
    )
    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    logging.debug("Search endpoint %s", args.search_endpoint)
    logging.debug("Index name %s", args.index_name)
    logging.debug("Use OCR %s", args.use_ocr)
    logging.debug("Interval %s", args.interval)

    _ai_search_indexer = AISearchIndexer(args)
    _ai_search_indexer.create_indexer()


if __name__ == "__main__":
    main()
