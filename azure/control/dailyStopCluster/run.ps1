# Input bindings are passed in via param block.
param($Timer)

Write-Host "Sending the cluster to sleep..."
Set-AzContext -Subscription $env:ARM_SUBSCRIPTION_ID
Stop-AzAksCluster -Name cluster -ResourceGroupName cluster -NoWait
Write-Host "Successfully sent the cluster to sleep!"