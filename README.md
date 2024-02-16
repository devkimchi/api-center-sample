# Azure API Center Sample

This provides sample Bicep files, ASP.NET Core Minimal API as server-side API app and Blazor Web app.

## Prerequisites

- [.NET SDK 8](https://dotnet.microsoft.com/download/dotnet/8.0) or later
- [Visual Studio Code](https://code.visualstudio.com/) with the extensions:
  - [API Center](https://marketplace.visualstudio.com/items?itemName=apidev.azure-api-center)
  - [Rest Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)
  - [Kiota](https://marketplace.visualstudio.com/items?itemName=ms-graph.kiota)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview)
- [Azure CLI](https://learn.microsoft.com/cli/azure/what-is-azure-cli) with the extensions:
  - [API Center](https://github.com/Azure/azure-cli-extensions/tree/main/src/apic-extension)

## Getting Started

### Check the list of available locations

1. Run the following command to check the list of available locations for API Center.

    ```bash
    # Bash
    az provider show \
        -n Microsoft.ApiCenter \
        --query "sort(resourceTypes[?resourceType=='services'] | [0].locations[? !(ends_with(@, 'EUAP'))])" | \
        jq '[.[] | ascii_downcase | sub(" "; ""; "i")]'

    # PowerShell
    az provider show `
        -n Microsoft.ApiCenter `
        --query "sort(resourceTypes[?resourceType=='services'] | [0].locations[? !(ends_with(@, 'EUAP'))])" | `
        ConvertFrom-Json | ForEach-Object { $_.ToLowerInvariant().Replace(" ", "") } | ConvertTo-Json
    ```

1. Open `./infra/main.bicep` and update the `location` parameter with the desired locations.

    ```bicep
    // Update the list of locations if necessary, after comparing to the result above.
    @allowed([
      'australiaeast'
      'centralindia'
      'eastus'
      'uksouth'
      'westeurope'
    ])
    param location string
    ```

### Provision resources to Azure

1. Fork this repository to your GitHub account.
1. Run the commands below to set up a resource names:

    ```bash
    # Bash
    AZURE_ENV_NAME="sample$RANDOM"
 
    # PowerShell
    $AZURE_ENV_NAME="sample$(Get-Random -Min 1000 -Max 9999)"
    ```

1. Run the commands below to provision Azure resources:

    ```bash
    azd auth login
    azd init -e $AZURE_ENV_NAME
    azd up
    ```

   > **Note:** You may be asked to enter your Azure subscription and desired location to provision resources.

1. Add the [USPTO API](https://developer.uspto.gov/api-catalog) to API Management.

    ```bash
    # Bash
    az apim api import \
        -g "rg-$AZURE_ENV_NAME" \
        -n "apim-$AZURE_ENV_NAME" \
        --path uspto \
        --specification-format OpenAPI \
        --specification-path ./infra/uspto.yaml \
        --api-id uspto \
        --api-type http \
        --display-name "USPTO Dataset API"
    
    az apim product api add \
        -g "rg-$AZURE_ENV_NAME" \
        -n "apim-$AZURE_ENV_NAME" \
        --product-id default \
        --api-id uspto
    
    # PowerShell
    az apim api import `
        -g "rg-$AZURE_ENV_NAME" `
        -n "apim-$AZURE_ENV_NAME" `
        --path uspto `
        --specification-format OpenAPI `
        --specification-path ./infra/uspto.yaml `
        --api-id uspto `
        --api-type http `
        --display-name "USPTO Dataset API"
    
    az apim product api add `
        -g "rg-$AZURE_ENV_NAME" `
        -n "apim-$AZURE_ENV_NAME" `
        --product-id default `
        --api-id uspto
    ```

### Register APIs to API Center

1. Register Weather Forecast API to API Center via Azure CLI.

    ```bash
    # Bash
    az apic api register \
        -g "rg-$AZURE_ENV_NAME" \
        -s "apic-$AZURE_ENV_NAME" \
        --api-location ./infra/weather-forecast.json
    
    # PowerShell
    az apic api register `
        -g "rg-$AZURE_ENV_NAME" `
        -s "apic-$AZURE_ENV_NAME" `
        --api-location ./infra/weather-forecast.json
    ```

1. Register [Pet Store API](https://editor.swagger.io/) to API Center via Azure Portal by following this document: [Register API](https://learn.microsoft.com/azure/api-center/register-apis)
1. Import the USPTO API from APIM to API Center via Azure CLI.

    ```bash
    # Bash
    APIC_PRINCIPAL_ID=$(az apic service show \
        -g "rg-$AZURE_ENV_NAME" \
        -s "apic-$AZURE_ENV_NAME" \
        --query "identity.principalId" -o tsv)
    
    APIM_RESOURCE_ID=$(az apim show \
        -g "rg-$AZURE_ENV_NAME" \
        -n "apim-$AZURE_ENV_NAME" \
        --query "id" -o tsv)
    
    az role assignment create \
        --role "API Management Service Reader Role" \
        --assignee-object-id $APIC_PRINCIPAL_ID \
        --assignee-principal-type ServicePrincipal \
        --scope $APIM_RESOURCE_ID
    
    az apic service import-from-apim \
        -g "rg-$AZURE_ENV_NAME" \
        -s "apic-$AZURE_ENV_NAME" \
        --source-resource-ids "$APIM_RESOURCE_ID/apis/*"
    
    # PowerShell
    $APIC_PRINCIPAL_ID = az apic service show `
        -g "rg-$AZURE_ENV_NAME" `
        -s "apic-$AZURE_ENV_NAME" `
        --query "identity.principalId" -o tsv
    
    $APIM_RESOURCE_ID = az apim show `
        -g "rg-$AZURE_ENV_NAME" `
        -n "apim-$AZURE_ENV_NAME" `
        --query "id" -o tsv
    
    az role assignment create `
        --role "API Management Service Reader Role" `
        --assignee-object-id $APIC_PRINCIPAL_ID `
        --assignee-principal-type ServicePrincipal `
        --scope $APIM_RESOURCE_ID
    
    az apic service import-from-apim `
        -g "rg-$AZURE_ENV_NAME" `
        -s "apic-$AZURE_ENV_NAME" `
        --source-resource-ids "$APIM_RESOURCE_ID/apis/*"
    ```

### Export API Client from API Center via VS Code

TBD

## Resources

- [Azure API Center](https://learn.microsoft.com/azure/api-center/overview)
- [Create the first API Center](https://learn.microsoft.com/azure/api-center/set-up-api-center)
- [Playlist: Azure API Center](https://www.youtube.com/playlist?list=PLI7iePan8aH75Qz8h4yQBEC-uS339CUyi)
- [Azure API Center Feedback](https://github.com/Azure/api-center-preview)
