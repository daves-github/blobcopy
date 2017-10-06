Login-AzureRmAccount

# VHD blob to copy #
$originalBlobName = "old.vhd" 
$newBlobName = "new.vhd" 

# Source Storage Account Information #
$sourceStorageAccountName = "oldstorageaccountname"
$sourceResourceGroup = "ResourceGroup"
$sourceContainer = "OldStorageContainer"
$sourceKey = Get-AzureRmStorageAccountKey -Name $sourceStorageAccountName -ResourceGroupName $sourceResourceGroup
$sourceContext = New-AzureStorageContext –StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceKey[0].Value

# Destination Storage Account Information #
$destinationStorageAccountName = "newstorageaccountname"
$destinationResourceGroup = "NewResourceGroup"
$destinationContainerName = "NewStorageContainer"
$destinationKey = Get-AzureRmStorageAccountKey -Name $destinationStorageAccountName -ResourceGroupName $destinationResourceGroup
$destinationContext = New-AzureStorageContext –StorageAccountName $destinationStorageAccountName -StorageAccountKey $destinationKey[0].Value

# Create the destination container #
#$destinationContainerName = "NewStorageContainer"
#New-AzureStorageContainer -Name $destinationContainerName -Context $destinationContext 

# Copy the blob # 
$blobCopy = Start-AzureStorageBlobCopy -DestContainer $destinationContainerName `
                        -DestContext $destinationContext `
                        -SrcBlob $originalBlobName `
                        -DestBlob $newBlobName `
                        -Context $sourceContext `
                        -SrcContainer $sourceContainer


# Display progress #
$CopyStatus = $blobCopy | Get-AzureStorageBlobCopyState
 
While ($CopyStatus.Status -eq 'Pending') {
   $CopyStatus = ($blobCopy | Get-AzureStorageBlobCopyState)
   Write-Progress -Id 1 -Activity "Copying VHD BLOB to Azure Storage" -Status ("{0} bytes of {1} completed" -f $CopyStatus.BytesCopied, $CopyStatus.TotalBytes) -PercentComplete (($CopyStatus.BytesCopied/$CopyStatus.TotalBytes) * 100)
   Start-Sleep -Seconds 30
}
 
"Blob copy completed with status: $($copyStatus.Status)"


