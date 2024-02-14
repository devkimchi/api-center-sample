# Azure API Center Sample

This provides sample Bicep files, ASP.NET Core Minimal API as server-side API app and Blazor Web app.

## Prerequisites

- .NET SDK 8 or later
- Azure Developer CLI
- Azure CLI with API Center extension

## Getting Started

### Check the list of available locations

1. Run the following command to check the list of available locations for API Center.

    ```bash
    az provider show \
        -n Microsoft.ApiCenter \
        --query "sort(resourceTypes[?resourceType=='services'] | [0].locations[? !(ends_with(@, 'EUAP'))])" | \
        jq '[.[] | ascii_downcase | sub(" "; ""; "i")]'
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

### Provision Resources to Azure

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
