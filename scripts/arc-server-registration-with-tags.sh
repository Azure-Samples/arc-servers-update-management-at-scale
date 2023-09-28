# The service principal needs to have arc connected machine onboarding role
$spClientId = "YOUR_SP_CLIENT_ID"

# Ideally this secret can be fetched from a secret store like KV
$spSecret = "YOUR_SP_SECRET"

$subscriptionId = "YOUR_SUBSCRIPTION_ID"
$resourceGroup = "YOUR_RESOURCE_GROUP"
$tenantId = "YOUR_TENANT_ID"
$location = "eastus" # Modify this to your region

#######################################################
# Tags are set in the below line
$tags = "updatePolicy=Default,updateSchedule=Default"
#######################################################

# The machine name to be Arc enabled, Ip of this needs to be resolvable/routable from the machine where this script is run
$vmName = "TestArcOnboard"

# Set VM credentials to invoke remote command
$Credential = Get-Credential

Invoke-Command -ComputerName $vmName -Credential $Credential -ArgumentList $spClientId, $spSecret, $subscriptionId, $resourceGroup, $tenantId, $location, $tags -ScriptBlock {

Param($spClientId, $spSecret, $subscriptionId, $resourceGroup, $tenantId, $location, $tags)

    try {
        $servicePrincipalClientId=$spClientId;
        $servicePrincipalSecret=$spSecret;

        $env:SUBSCRIPTION_ID = $subscriptionId;
        $env:RESOURCE_GROUP = $resourceGroup;
        $env:TENANT_ID = $tenantId;
        $env:LOCATION = $location;
        $env:AUTH_TYPE = "principal";
        $env:CLOUD = "AzureCloud";
        $env:TAGS = $tags;
    

        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;
        Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";
        & "$env:TEMP\install_windows_azcmagent.ps1";
        if ($LASTEXITCODE -ne 0) { exit 1; }
        & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$servicePrincipalClientId" --service-principal-secret "$servicePrincipalSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --tags "$env:TAGS"
    }
    catch {
        $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
        Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
        Write-Host  -ForegroundColor red $_.Exception;
    }

}