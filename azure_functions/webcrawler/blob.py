from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient


class BlobHandler:

    @classmethod
    def upload(
        cls,
        storage_account_url: str,
        container_name: str,
        blob_path: str,
        content: bytes,
        metadata: dict = None,
        overwrite: bool = False,
        credential=None,
    ):
        """Upload blob

        Args:
            storage_account_url (_type_): storage account url
            container_name (_type_): container name
            blob_path (_type_): blob path
            content (_type_): content
            metadata (_type_): metadata
            overwrite (_type_): overwrite

        Raises:
            Exception: exception in case of failure

        Returns:
            None
        """
        _credential = DefaultAzureCredential()
        if credential:
            _credential = credential
        _blob_service_client = BlobServiceClient(
            account_url=storage_account_url,
            credential=_credential,
        )
        _container_client = _blob_service_client.get_container_client(
            container=container_name
        )

        _blob_client = _container_client.upload_blob(
            name=blob_path,
            data=content,
            overwrite=overwrite,
            metadata=metadata,
        )

    @classmethod
    def download(
        cls,
        storage_account_url: str,
        container_name: str,
        blob_path: str,
        credential=None,
    ):
        """Download blob

        Args:
            storage_account_url (_type_): storage account url
            container_name (_type_): container name
            blob_path (_type_): blob path

        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        _credential = DefaultAzureCredential()
        if credential:
            _credential = credential

        _blob_service_client = BlobServiceClient(
            account_url=storage_account_url,
            credential=_credential,
        )
        _container_client = _blob_service_client.get_container_client(
            container=container_name
        )
        _blob_client = _container_client.get_blob_client(blob=blob_path)
        _blob = _blob_client.download_blob().readall()
        return _blob

    @classmethod
    def ensure_container_exists(
        cls,
        storage_account_url: str,
        container_name: str,
        credential=None,
    ):
        """Ensure container exists

        Args:
            storage_account_url (_type_): storage account url
            container_name (_type_): container name
            credential (_type_): credential
        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        _credential = DefaultAzureCredential()
        if credential:
            _credential = credential
        _blob_service_client = BlobServiceClient(
            account_url=storage_account_url,
            credential=_credential,
        )
        _container_client = _blob_service_client.get_container_client(
            container=container_name
        )
        if not _container_client.exists():
            _container_client.create_container()

    @classmethod
    def get_properties(
        cls,
        storage_account_url: str,
        container_name: str,
        blob_path: str,
    ):
        """Get properties

        Args:
            storage_account_url (_type_): storage account url
            container_name (_type_): container name
            blob_path (_type_): blob path

        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        _credential = DefaultAzureCredential()

        _blob_service_client = BlobServiceClient(
            account_url=storage_account_url,
            credential=_credential,
        )
        _container_client = _blob_service_client.get_container_client(
            container=container_name
        )
        _blob_client = _container_client.get_blob_client(blob=blob_path)
        _properties = _blob_client.get_blob_properties()
        return _properties

    @classmethod
    def list(
        cls,
        storage_account_url: str,
        container_name: str,
        blob_path: str,
    ):
        """List blobs

        Args:
            blob_path (_type_): blob path

        Raises:
            Exception: exception in case of failure

        Returns:
            _type_: response
        """
        _credential = DefaultAzureCredential()

        _blob_service_client = BlobServiceClient(
            account_url=storage_account_url,
            credential=_credential,
        )
        _container_client = _blob_service_client.get_container_client(
            container=container_name
        )
        _blobs = _container_client.list_blobs(name_starts_with=blob_path)
        return _blobs

    @classmethod
    def delete(
        cls,
        storage_account_url: str,
        container_name: str,
        blob_path: str,
    ):
        """Delete blob

        Args:
            storage_account_url (_type_): storage account url
            container_name (_type_): container name
            blob_path (_type_): blob path

        Raises:
            Exception: exception in case of failure

        Returns:
            None
        """
        _credential = DefaultAzureCredential()

        _blob_service_client = BlobServiceClient(
            account_url=storage_account_url,
            credential=_credential,
        )
        _container_client = _blob_service_client.get_container_client(
            container=container_name
        )
        _blob_client = _container_client.get_blob_client(blob=blob_path)
        _blob_client.delete_blob()
