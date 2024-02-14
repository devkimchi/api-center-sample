# Azure API Center Sample

This provides sample Bicep files, ASP.NET Core Minimal API as server-side API app and Blazor Web app.

## Prerequisites

- [.NET SDK 8](https://dotnet.microsoft.com/download/dotnet/8.0) or later
- [Visual Studio Code](https://code.visualstudio.com/) with the [API Center extension](https://marketplace.visualstudio.com/items?itemName=apidev.azure-api-center)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview)
- [Azure CLI](https://learn.microsoft.com/cli/azure/what-is-azure-cli) with the [API Center extension](https://github.com/Azure/azure-cli-extensions/tree/main/src/apic-extension)

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
2. Run the commands below to set up a resource names:

    ```bash
    # Bash
    AZURE_ENV_NAME="sample$RANDOM"
 
    # PowerShell
    $AZURE_ENV_NAME="sample$(Get-Random -Min 1000 -Max 9999)"
    ```

3. Run the commands below to provision Azure resources:

    ```bash
    azd auth login
    azd init -e $AZURE_ENV_NAME
    azd up
    ```

   > **Note:** You may be asked to enter your Azure subscription and desired location to provision resources.

## Resources

- [Azure API Center](https://learn.microsoft.com/azure/api-center/overview)
- [Create the first API Center](https://learn.microsoft.com/azure/api-center/set-up-api-center)
- [Playlist: Azure API Center](https://www.youtube.com/playlist?list=PLI7iePan8aH75Qz8h4yQBEC-uS339CUyi)
- [Azure API Center Feedback](https://github.com/Azure/api-center-preview)
