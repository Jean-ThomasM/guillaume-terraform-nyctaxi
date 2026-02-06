import os
from pathlib import Path

from dotenv import load_dotenv
from loguru import logger

from utils.database import (
    execute_sql_file_duckdb,
    execute_sql_file_postgresql,
    get_database_duckdb,
)

load_dotenv()

def _telecharger_blobs_azure(data_path: Path) -> list[Path]:
    from azure.storage.blob import BlobServiceClient

    conn_str = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
    container_name = os.getenv("AZURE_CONTAINER_NAME", "raw")
    if not conn_str:
        return []

    blob_service_client = BlobServiceClient.from_connection_string(conn_str)
    container_client = blob_service_client.get_container_client(container_name)

    blobs = [b for b in container_client.list_blobs() if b.name.endswith(".parquet")]
    if not blobs:
        logger.warning("Aucun fichier trouvé dans Azure Blob Storage")
        return []

    data_path.mkdir(parents=True, exist_ok=True)
    fichiers_locaux = []
    for blob in blobs:
        local_path = data_path / Path(blob.name).name
        if not local_path.exists():
            with open(local_path, "wb") as f:
                f.write(container_client.download_blob(blob.name).readall())
        fichiers_locaux.append(local_path)

    return fichiers_locaux


def charger_avec_duckdb():
    with get_database_duckdb():
        data_path = Path("data/raw")
        fichiers = list(data_path.glob("*.parquet"))

        if not fichiers and os.getenv("AZURE_STORAGE_CONNECTION_STRING"):
            logger.info("Téléchargement des fichiers depuis Azure Blob Storage")
            fichiers = _telecharger_blobs_azure(data_path)

    if not fichiers:
        logger.warning("Aucun fichier trouvé")
        return

    logger.info(f"{len(fichiers)} fichiers détectés")

    try:
        glob_pattern = str(data_path / "*.parquet")
        logger.info(f"Chargement optimisé de TOUS les fichiers : {glob_pattern}")
        execute_sql_file_duckdb("sql/insert_to.sql", params={"glob_pattern": glob_pattern})
        logger.success("insert_to.sql exécuté avec succès")
    except Exception as e:
        logger.error(f"Erreur : {e}")
        raise


if __name__ == "__main__":
    logger.info("Démarrage de la Pipeline DUCKDB")
    execute_sql_file_postgresql("sql/create_staging_table.sql")
    logger.info("TRUNCATE")
    execute_sql_file_postgresql("sql/truncate.sql")
    charger_avec_duckdb()
