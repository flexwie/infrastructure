# Input bindings are passed in via param block.
param($Timer)

Write-Host "Waking up the cluster..."
Set-AzContext -Subscription $env:ARM_SUBSCRIPTION_ID
Start-AzAksCluster -Name cluster -ResourceGroupName cluster -NoWait
Write-Host "Successfully woke the cluster up!"