import logging
import argparse

from azure.search.documents.indexes.models import (
    SplitSkill,
    InputFieldMappingEntry,
    OutputFieldMappingEntry,
    AzureOpenAIEmbeddingSkill,
    OcrSkill,
    SearchIndexerIndexProjection,
    SearchIndexerIndexProjectionSelector,
    SearchIndexerIndexProjectionsParameters,
    IndexProjectionMode,
    SearchIndexerSkillset,
    CognitiveServicesAccountKey,
)

from azure.identity import AzureCliCredential

from azure.search.documents.indexes import SearchIndexerClient


class AISearchSkillset:
    def __init__(self, args):
        self.args = args

    def create_skillset(
        self,
    ):
        _args = self.args
        _index_name = _args.index_name
        _azure_openai_endpoint = _args.azure_openai_endpoint
        _azure_openai_embedding_deployment_name = (
            _args.azure_openai_embedding_deployment_name
        )
        _azure_openai_model_name = _args.azure_openai_model_name
        _azure_openai_model_dimensions = _args.azure_openai_model_dimensions
        _azure_ai_services_key = _args.azure_ai_services_key
        _use_ocr = _args.use_ocr
        _page_numbers = _args.page_numbers

        _skillset_name = f"{_index_name}-skillset"

        _ocr_skill = None
        _split_skill = None
        _embedding_skill = None
        _search_indexer_index_projection_selector = None
        if _use_ocr:
            logging.info("Using OCR skillset")
            _ocr_skill = OcrSkill(
                description="OCR skill to scan PDFs and other images with text",
                context="/document/normalized_images/*",
                line_ending="Space",
                default_language_code="en",
                should_detect_orientation=True,
                inputs=[
                    InputFieldMappingEntry(
                        name="image", source="/document/normalized_images/*"
                    )
                ],
                outputs=[
                    OutputFieldMappingEntry(name="text", target_name="text"),
                    OutputFieldMappingEntry(
                        name="layoutText", target_name="layoutText"
                    ),
                ],
            )
            logging.info("Using OCR split skill")
            _split_skill = SplitSkill(
                description="Split skill to chunk documents",
                text_split_mode="pages",
                context="/document/normalized_images/*",
                maximum_page_length=2000,
                page_overlap_length=500,
                inputs=[
                    InputFieldMappingEntry(
                        name="text", source="/document/normalized_images/*/text"
                    ),
                ],
                outputs=[
                    OutputFieldMappingEntry(name="textItems", target_name="pages")
                ],
            )
            _embedding_skill = AzureOpenAIEmbeddingSkill(
                description="Skill to generate embeddings via Azure OpenAI",
                context="/document/normalized_images/*/pages/*",
                resource_url=_azure_openai_endpoint,
                deployment_name=_azure_openai_embedding_deployment_name,
                model_name=_azure_openai_model_name,
                dimensions=_azure_openai_model_dimensions,
                inputs=[
                    InputFieldMappingEntry(
                        name="text", source="/document/normalized_images/*/pages/*"
                    ),
                ],
                outputs=[
                    OutputFieldMappingEntry(name="embedding", target_name="vector")
                ],
            )
            _search_indexer_index_projection_selector = (
                SearchIndexerIndexProjectionSelector(
                    target_index_name=_index_name,
                    parent_key_field_name="parent_id",
                    source_context="/document/normalized_images/*/pages/*",
                    mappings=[
                        InputFieldMappingEntry(
                            name="chunk", source="/document/normalized_images/*/pages/*"
                        ),
                        InputFieldMappingEntry(
                            name="vector",
                            source="/document/normalized_images/*/pages/*/vector",
                        ),
                        InputFieldMappingEntry(name="title", source="/document/title"),
                    ],
                )
            )
        else:
            logging.info("Using Text split skill")
            _split_skill = SplitSkill(
                description="Split skill to chunk documents",
                text_split_mode="pages",
                context="/document",
                maximum_page_length=2000,
                page_overlap_length=500,
                inputs=[
                    InputFieldMappingEntry(name="text", source="/document/content"),
                ],
                outputs=[
                    OutputFieldMappingEntry(name="textItems", target_name="pages")
                ],
            )
            _embedding_skill = AzureOpenAIEmbeddingSkill(
                description="Skill to generate embeddings via Azure OpenAI",
                context="/document/pages/*",
                resource_url=_azure_openai_endpoint,
                deployment_name=_azure_openai_embedding_deployment_name,
                model_name=_azure_openai_model_name,
                dimensions=_azure_openai_model_dimensions,
                inputs=[
                    InputFieldMappingEntry(name="text", source="/document/pages/*"),
                ],
                outputs=[
                    OutputFieldMappingEntry(name="embedding", target_name="vector")
                ],
            )

            _search_indexer_index_projection_selector = (
                SearchIndexerIndexProjectionSelector(
                    target_index_name=_index_name,
                    parent_key_field_name="parent_id",
                    source_context="/document/pages/*",
                    mappings=[
                        InputFieldMappingEntry(
                            name="chunk", source="/document/pages/*"
                        ),
                        InputFieldMappingEntry(
                            name="vector", source="/document/pages/*/vector"
                        ),
                        InputFieldMappingEntry(name="title", source="/document/title"),
                        InputFieldMappingEntry(
                            name="blob_path",
                            source="/document/metadata_storage_path",
                        ),
                        InputFieldMappingEntry(
                            name="source_address", source="/document/source_address"
                        ),
                    ],
                )
            )

        if _page_numbers:
            logging.info("Adding page numbers to the index")
            _search_indexer_index_projection_selector.mappings.append(
                InputFieldMappingEntry(
                    name="page_number",
                    source="/document/normalized_images/*/pageNumber",
                ),
            )
        else:
            logging.info("Not adding page numbers to the index")

        _index_projections = SearchIndexerIndexProjection(
            selectors=[
                _search_indexer_index_projection_selector,
            ],
            parameters=SearchIndexerIndexProjectionsParameters(
                projection_mode=IndexProjectionMode.SKIP_INDEXING_PARENT_DOCUMENTS
            ),
        )
        cognitive_services_account = None
        if _use_ocr:
            cognitive_services_account = (
                CognitiveServicesAccountKey(key=_azure_ai_services_key)
                if _use_ocr
                else None
            )

        _skills = []
        if _use_ocr:
            logging.info("Appending OCR skill to skillset")
            _skills.append(_ocr_skill)
        else:
            logging.info("Not appending OCR skill to skillset")

        _skills.append(_split_skill)
        _skills.append(_embedding_skill)

        _skill_set = SearchIndexerSkillset(
            name=_skillset_name,
            description="Skillset to chunk documents and generating embeddings",
            skills=_skills,
            index_projection=_index_projections,
            cognitive_services_account=cognitive_services_account,
        )

        _credential = AzureCliCredential()
        _search_endpoint = _args.search_endpoint

        _client = SearchIndexerClient(_search_endpoint, _credential)
        _client.create_or_update_skillset(_skill_set)
        logging.info("Skillset %s created", _skill_set.name)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--search-endpoint",
        required=True,
        help="Azure Cognitive Search endpoint",
    )
    parser.add_argument(
        "--index-name",
        required=True,
        help="Azure Cognitive Search index name",
    )
    parser.add_argument(
        "--use-ocr",
        action="store_true",
        help="Use OCR skillset",
        required=False,
        default=False,
    )
    parser.add_argument(
        "--azure-openai-endpoint",
        required=True,
        help="Azure OpenAI endpoint",
    )
    parser.add_argument(
        "--azure-openai-embedding-deployment-name",
        required=True,
        help="Azure OpenAI embedding deployment",
    )
    parser.add_argument(
        "--azure-openai-model-name",
        required=True,
        help="Azure OpenAI model name",
    )
    parser.add_argument(
        "--azure-openai-model-dimensions",
        required=False,
        type=int,
        help="Azure OpenAI model dimensions",
        default=1536,
    )
    parser.add_argument(
        "--azure-ai-services-key",
        required=False,
        type=str,
        help="Azure AI services key",
    )
    parser.add_argument(
        "--page-numbers",
        action="store_true",
        help="Add page numbers to the index",
        required=False,
        default=False,
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Increase output verbosity",
        required=False,
        default=False,
    )
    _args = parser.parse_args()

    if _args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    logging.debug("Search endpoint: %s", _args.search_endpoint)
    logging.debug("Index name: %s", _args.index_name)
    logging.debug("Use OCR: %s", _args.use_ocr)
    logging.debug("Azure OpenAI endpoint: %s", _args.azure_openai_endpoint)
    logging.debug(
        "Azure OpenAI embedding deployment name: %s",
        _args.azure_openai_embedding_deployment_name,
    )
    logging.debug("Azure OpenAI model name: %s", _args.azure_openai_model_name)
    logging.debug(
        "Azure OpenAI model dimensions: %s", _args.azure_openai_model_dimensions
    )
    logging.debug("Azure AI services key: %s", _args.azure_ai_services_key)
    logging.debug("Page numbers: %s", _args.page_numbers)

    _skillset = AISearchSkillset(_args)
    _skillset.create_skillset()


if __name__ == "__main__":
    main()
