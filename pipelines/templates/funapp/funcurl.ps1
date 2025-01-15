param(
    [string]$FunctionsJson,
    [string]$KeyVaultName,
    [string]$FunctionAppName,
    [string]$ResourceGroupName
)

# Get the Function App details
$FunctionApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName
if ($null -eq $FunctionApp) {
    Write-Output "Failed to retrieve Function App: $FunctionAppName"
    exit 1
}
$FunctionAppId = $FunctionApp.Id
$DefaultHostName = $FunctionApp.DefaultHostName

Write-Output "Function App ID: $FunctionAppId"
Write-Output "Default Host Name: $DefaultHostName"

# Read the functions JSON from the file
$FunctionsJsonContent = Get-Content $FunctionsJson | ConvertFrom-Json

if ($FunctionsJsonContent.Count -eq 0) {
    Write-Output "No functions found in the Function App."
    exit 1
}

# Initialize an array to store all function URLs
$FunctionUrls = @()

# Loop through each function and get the trigger URL
foreach ($function in $FunctionsJsonContent) {
    # Extract the trigger name from the function name
    $TriggerName = ($function.Name -split '/')[1]
    Write-Output "Processing trigger: $TriggerName"
    
    # Get the function key
    $FunctionKey = (Invoke-AzResourceAction -ResourceId "$FunctionAppId/functions/$TriggerName" -Action listkeys -Force).default
    if ($null -eq $FunctionKey) {
        Write-Output "Failed to retrieve key for trigger: $TriggerName"
        continue
    }

    # Build the function URL
    $FunctionURL = "https://${DefaultHostName}/api/${TriggerName}?code=${FunctionKey}"
    # Add the URL to the array
    $FunctionUrls += $FunctionURL
}

$FunctionAppUrlsSecretName = "$FunctionAppName-urls"
$FunctionAppUrlsJsonString = $FunctionUrls | ConvertTo-Json
$FunctionAppUrlsSecureString = ConvertTo-SecureString $FunctionAppUrlsJsonString -AsPlainText -Force

# Check if the secret already exists
$existingSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $FunctionAppUrlsSecretName -ErrorAction SilentlyContinue

if ($existingSecret) {
    # Convert the existing secret's value from SecureString to plain text for comparison
    $existingSecretValue = $existingSecret.SecretValue | ConvertFrom-SecureString -AsPlainText
    
    # Compare the existing secret value with the new value
    if ($existingSecretValue -eq $FunctionAppUrlsJsonString) {
        Write-Output "The secret already exists in Key Vault and the values are identical. No update needed."
    } else {
        # Update the secret if values are different
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $FunctionAppUrlsSecretName -SecretValue $FunctionAppUrlsSecureString
        Write-Output "The secret value has changed and was updated in Key Vault."
    }
} else {
    # Create the secret if it does not exist
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $FunctionAppUrlsSecretName -SecretValue $FunctionAppUrlsSecureString
    Write-Output "The secret was created in Key Vault."
}
