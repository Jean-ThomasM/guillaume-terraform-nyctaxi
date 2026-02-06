# NYC Taxi Pipeline sur Azure déployé avec Terraform

## Prérequis
Ce projet nécessite :
- Azure CLI : https://learn.microsoft.com/fr-fr/cli/azure/install-azure-cli?view=azure-cli-latest
- Terraform : https://developer.hashicorp.com/terraform/install
- Docker : https://docs.docker.com/engine/install/
- psql : https://dev.to/tigerdata/how-to-install-psql-on-mac-ubuntu-debian-windows-am

## Fonctionnement du projet

Ce projet déploie l’infrastructure Azure à l'aided Terraform et exécute un pipeline de données NYC Taxi dans une Azure Container App.


# AZURE
Azure est le service de Cloud de Microsoft. Il permets d'utiliser des ressources en lignes (vm, stockage, monitoring, data warehouse, etc.) strictement adaptées à nos besoins.

# TERRAFORM
Terraform est un système Iac (Infrastructure as Code) qui permets de configurer une infrastructure uniquement avec des lignes de codes, permettant de gagner en vitesse, reproductabilité, automatisation et réduire les erreurs humaines.

**Flux principal du pipeline ELT - en python & SQL**
1) **Download** : télécharge les fichiers Parquet NYC TLC et les stocke dans le container Blob `raw`.
2) **Load (DuckDB)** : récupère les Parquet depuis Blob, les copie dans `data/raw` du conteneur, puis charge vers PostgreSQL via DuckDB.
3) **Transform** : exécute les scripts SQL pour créer le modèle en étoile (DIM/FACT).

# Ressources Azure déployées

Pour lancer le pipeline, nous devons déployer des ressources dans le cloud Azure.

**Services déployés**
- **Ressource Group** : permets de lier toutes les ressources déployées à un compte, rattaché à un utilisateur. Dans notre cas, nous ne le créons pas, mais nous le récupérons puisqu'il existe déjà.
- **Storage Account** : service de stockage de fichier. C'est la porte d'entrée du stockage, permets ensuite de créer des containers (au sens d'espace de stockage)
- **Containers** : comme des dossiers pour stocker des données, containers `raw` (et `processed` si besoin)
- **Container Registry (ACR)** : registre privé d’images Docker (équivalent de Docker Hub version Azure)
- **Cosmos DB for PostgreSQL** : entrepôt de données (Data Warehouse) à base de PostgreSQL, mais géré par CosmosDB (Azure), peut évoluer vers une architecture distribuée pour gagner en performances
- **Log Analytics Workspace** : entrepôt de logs et métriques pour Azure Monitor
- **Container Apps Environment** : environnement d'exécution des Container Apps, fait le lien avec réseaux et logs
- **Container Apps** : ressource permettant de faire tourner une image docker (plus simple qu'une VM)

## Organisation du code Terraform : modules et variables
Le code Terraform est organisé en modules réutilisables. Tous les modules sont appelés par le main.tf à la racine du dossier terraform.
Toutes les variables sont fournies par le fichier terraform.tfvars. Ce fichier ne doit PAS être versionné.
Le fichier terraform.tfvars.example contient une version sans secrets.


## Variables a renseigner (tfvars.example)


**Nommage et contexte**
- `project_name` : nom court du projet. Sert a nommer les ressources Azure.
- `user_prefix` : petit prefix pour eviter les collisions de noms dans Azure.
- `environment` : environnement cible (`dev`, `staging`, `prod`). Sert au nommage.
- `location` : region Azure (ex: `francecentral`). Toutes les ressources seront creees la-bas.
- `azure_resource_group` : nom du Resource Group existant dans lequel on deploye.

**Storage (Azure Blob)**
- `blob_containers_list` : liste des containers Blob a creer (ex: `["raw", "processed"]`).
- `account_tier` : tier de storage (ex: `Standard`).
- `account_replication_type` : type de replication (ex: `LRS`).
- `storage_kind` : type de compte Storage (ex: `StorageV2`).

**ACR (Azure Container Registry)**
- `acr_sku` : taille du registry (ex: `Basic`).
- `acr_admin_enabled` : active l'auth admin (utile pour le push d'image).
- `container_image_name` : nom de l'image Docker (ex: `nyc-taxi-pipeline`).
- `container_image_tag` : version de l'image. Change-le pour forcer une nouvelle revision.

**Cosmos DB for PostgreSQL**
- `cosmosdb_password` : mot de passe admin (garde-le secret).
- `cosmosdb_storage_mb` : taille disque (ex: `32768` = 32 GB).
- `cosmosdb_vcore_count` : puissance CPU (ex: `1`).
- `cosmosdb_node_count` : nombre de noeuds (ex: `0` pour single-node).
- `cosmosdb_server_edition` : edition (ex: `BurstableMemoryOptimized`).
- `cosmosdb_firewall_name` : nom de la regle firewall.
- `allowed_ips` : liste d'IPs autorisees a se connecter (ex: `["0.0.0.0"]` pour Azure services + ton IP si besoin de `psql`).

**Container Apps**
- `aca_cpu` : CPU allouee au container (ex: `0.5`).
- `aca_memory` : RAM allouee (ex: `1Gi`).
- `aca_min_replicas` : nombre minimum d'instances (ex: `0` pour arreter quand inactif).
- `aca_max_replicas` : nombre maximum d'instances.
- `azure_container_name` : nom du container Blob utilise par l'app (ex: `raw`).
- `start_date` : debut des donnees a charger (format `YYYY-MM`).
- `end_date` : fin des donnees a charger (format `YYYY-MM`).

**Log Analytics**
- `log_an_wsp_sku` : SKU du workspace (ex: `PerGB2018`).
- `log_an_wsp_retention` : retention des logs en jours (ex: `30`).
- `aca_env_logs_destination` : destination des logs (`log-analytics`).

**Notes utiles**
- `postgres_db` et `postgres_port` ont des valeurs par defaut (`citus`, `5432`).
- Le user PostgreSQL utilisé par l'app est `citus`.

## Sécurité & authentification
Ce projet ne propose pas de sécurisation avancée des secrets. Pour minimiser les risques de fuites, il convient de ne surtout pas versionner les fichiers suivants :
- terraform.tfvars
- terraform.tfstate

L'authentification se fait avec Azure CLI préalablement au lancement des commandes Terraform.

## Commandes de déploiement

> ⚠️ **Attention**
> Il ne faut pas déployer toute l'infra terraform d'un coup.
> Il faut d'abord déployer l'Azure Container Registry, pousser l'image puis déployer le reste de l'infra.

**Terraform**
```bash
cd terraform
terraform fmt
terraform validate
terraform plan
```

**Déploiement ACR puis infra**
```bash
cd terraform
terraform apply -target=module.acr_module -target=module.storage_module
```

**Build + push image**
> ⚠️ **Attention**
> Les commandes terraform sont à exécuter dans le DOSSIER TERRAFORM, les commandes docker sont à exécuter dans
> le DOSSIER RACINE du projet.

```bash
ACR_NAME=$(terraform output -raw container_registry_name)
ACR_URL=$(terraform output -raw container_registry_login_server)
az acr login --name $ACR_NAME
cd ..
docker build -t nyc-taxi-pipeline:v2 .
docker tag nyc-taxi-pipeline:v2 $ACR_URL/nyc-taxi-pipeline:v2
docker push $ACR_URL/nyc-taxi-pipeline:v2
```

**Appliquer l’infra complète**
```bash
cd terraform
terraform apply
```

**Logs Container App**
```bash
az containerapp logs show --name ca-nyctaxi-pipeline-dev --resource-group jmiquelotRG --follow
```

**Validation SQL**
```bash
HOST=$(terraform output -raw cosmosdb_host)
PGPASSWORD="$(terraform output -raw cosmosdb_admin_password)" \
psql "postgresql://citus@${HOST}:5432/citus?sslmode=require"
```
```sql
SELECT COUNT(*) FROM staging_taxi_trips;
SELECT COUNT(*) FROM fact_trips;
SELECT * FROM staging_taxi_trips LIMIT 10;
SELECT * FROM fact_trips LIMIT 10;
```
> ⚠️ **Attention**
> Il faut détruire l'infrastructure chaque soir, sinon on consomme des ressources pour rien !
**Détruire l'infrastructure**
```bash
cd terraform
terraform destroy
```

## Difficultés rencontrées (et solutions)

- **Provider Azure trop ancien** : certaines ressources n’étaient pas reconnues sous 3.100.0 → mise à jour `azurerm` vers 4.57
- **Auth ACR** : push impossible sans login → `az acr login` ou credentials admin.
- **Cosmos DB – username** : l’admin est `citus` (pas personnalisable avec certains providers).
- **Cosmos DB – firewall** : timeout depuis Container Apps → autoriser l’IP sortante du CA Environment et/ou `0.0.0.0` (Azure services) selon le brief.
- **Pipeline 2 vs Blob** : le code python du pipeline lisait `data/raw` en local (dans le conteneur), mais les données étaient écrites dans le blob storage  → ajout d’un download Blob → local avant DuckDB.

## Ressources
- terraform_azurerm : https://registry.terraform.io/providers/hashicorp/azurerm/latest
- secrets : 
  - https://spacelift.io/blog/terraform-secrets#what-are-terraform-secrets  
  - https://developer.hashicorp.com/terraform/tutorials/secrets  
- env : https://spacelift.io/blog/terraform-environment-variables  
- backend (remote state) : https://developer.hashicorp.com/terraform/language/backend/azurerm
- storage_account : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account  
- key vault : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
- container app : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app
container_app_environment : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment
- log analytics workspace : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
- .tfvars : https://spacelift.io/blog/terraform-tfvars
- azure/terraform by microsoft : https://learn.microsoft.com/fr-fr/azure/developer/terraform/
- vidéo best practices : https://www.youtube.com/watch?v=gxPykhPxRW0
