# Welcome to Sample Code Implementation for Indexer with Azure Storage ! 

## Objective

**Build a knowledgebase , data ingestion solution along with  AI search indexer pipeline ** that enriches your index using the OpenAI service. Scrapy is being used to crawl data from public website given under configuration which is being used within Az function to crawl and upload chunks into Azure blob storage. Indexer purpose is to link with data source blob and upload to Azure AI index.

**Azure Infra Instructions**

## Instructions to Log in to Azure Portal and Set Up Custom Template

Please copy/paste link below within Lab browser, provide the credentials mentioned under resource tab, and follow the steps to create the infrastructure resources for the lab:

[Create Infrastructure Resources for the Lab](https://portal.azure.com/?feature.customportal=false#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FNavpreet-madaan%2FIndexerwithAzureStorageSampleCode%2Frefs%2Fheads%2Fmain%2FBicep%2Fmain%2Fmain.json)


### Step 1: Create Baseline Infrastructure

- Select the Region: Choose the **EAST US2** region while setting up resources.
- Type the Subscription ID from resource tab as an input while setting up the custom template.
- Change the default resource name to avoid conflicts on Global names  
    - For below resources, Replace `<YourInitials>` with your actual initials (e.g., "PP" for Peter Parker).
    - Ensure no spaces are present in the names.

        ## Key Vault (Search Key Vault)
        - **Updated Name:** `<KeyVaultName><YourInitials>`
        ## Azure Function (Search Azure Function)
        - **Updated Name:** `<FunctionAppName><YourInitials>`
        ## AI Service (Search AIservice)
        - **Updated Name:** `<AIServiceName><YourInitials>`
        ## AI Search (Search AIsearch)
        - **Updated Name:** `<AISearchName><YourInitials>`
        ## Log Analytics (Search logAnalytics)
        - **Updated Name:** `<LogAnalyticsName><YourInitials>`
        ## Storage Name (Search StorageName)
        - **Updated Name:** `<StorageName><YourInitials>`
        ## Container name (Search ContainerName)
        - **Updated Name:** `<ContainerName><YourInitials>`

- Review & Create Custom template to create baseline Infra structure

### Step 2: Set RBAC for Azure resources on Azure portal - These are manual task for the sample code prospective, in actual project, DevOps pipeline or Git Hub Actions are being used to setup permissions and all other deployments.
Your base infrastructure is ready, next is to setup RBAC for these resources to work
- Under Storage account. Under Access Control (IAM) > Add > Add role assignments.
Search for **"Storage Blob Data Contributor"** role and select **User, group, or service principal** and add members as your current user from resources tab and assign that as well and hit **Assign**.

- Open Azure AI Search. Under Access Control (IAM) > Add > Add role assignments.
Search for **"Search Index Data Reader"** role and select **User, group, or service principal** and add members as your current user from resources tab and assign that as well.
### Step 3: Create and Deploy Azure AI model
- Open Azure Open AI and launch **Azure AI foundry portal**.
Navigate to deployments and hit "Deploy model" > Deploy base mode > search for **"text-embedding-ada-002"** > Confirm
Please note, select region as "EAST US2"

### Step 4: Setting up Code for deployment in VS studio code
Your base infrastructure & RBAC is set, it is time to deploy the code.

**Update Configuration in VS Code**
- Open Visual studio code in the lab desktop, it will open a code where you can see a structure under AI search of Indexer / azure_function / deployments as well. 
- **Config.YAML**: Fill all variables values in Config.YAML under deployments which includes storage account name/ resource group and many more based on actual values from Azure portal and save it.
- **main.YAML**: Under azure_functions\webcrawler\config\dev\crawlers\main.yaml
    - Update all "account" with your **StorageName**. Also, update all "container"    with `<ContainerName><YourInitials>`

**Deploy Azure AI indexer via Shell script**
- Open terminal with git Bash and run the command as type **az login** and login with credentials mentioned under resource tab and press enter for select default tenant + subscription
- Then final step to deploy Indexer is to run this command  **./deployments/deploy_indexer.sh** This will trigger the deployment of Azure AI indexer in the Azure Portal. 

**Next step is to deploy Azure function.** 
- Next is to run this shell script to deploy function app to Portal to start   crawling **./deployments/deploy_function.sh**
### Step 5: Testing Index on Azure portal
- Open Azure AI search resource and go to Index section.Put this query under the Ai search section to search the index **search=learning.microsoft.com&$filter=substringof('learning.microsoft.com', url) and status eq 'active'&$select=source_address,title,chunk**
- It will display highlighted results in a field.

