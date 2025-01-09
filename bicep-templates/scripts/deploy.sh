#!/bin/bash

# Variables
RESOURCE_GROUP="myResourceGroup"
TEMPLATE_FILE="main.bicep"
PARAMETERS_FILE="parameters/dev.parameters.json"
LOCATION="eastus"

# Create resource group
az group create --name \$RESOURCE_GROUP --location \$LOCATION

# Deploy Bicep template
az deployment group create --resource-group \$RESOURCE_GROUP --template-file \$TEMPLATE_FILE --parameters @\$PARAMETERS_FILE