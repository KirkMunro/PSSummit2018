. .\classdemo1.ps1
New-IBWebSession -Gridmaster "$gridmastername`.$location`.cloudapp.azure.com" -Credential $IBCred
#authentication
$IBSession
$IBGridmaster
$IBWapiVersion

#show static overloads
[ib_dnsarecord]::get
[ib_dnsarecord]::Create

$Record = [ib_dnsarecord]::get($IBGridmaster, $IBSession, $IBWapiVersion, 'server1', $Null, $Null, $Null, $Null, $Null, $Null, 1)
$record
$Record | get-member

#show set and delete overloads
$record.set
$record[0].set
$record[0].delete

#inheritance
. .\ClassDemoInheritance2.ps1
. .\ClassDemo2.ps1

$Record2 = [ib_dnsarecord]::get($IBGridmaster, $IBSession, $IBWapiVersion, 'server1', $Null, $Null, $Null, $Null, $Null, $Null, 1)
$RefRecord = [ib_ReferenceObject]::get($IBGridmaster, $IBSession, $IBWapiVersion, $($Record2._ref))

$RefRecord
$RefRecord | get-member

$record2
$record2 | gm
$record2[0].ToString()
$record[0].ToString()




#cmdlets
Get-IBDNSARecord -Name Server1

get-ibdnsarecord -name server1 -comment 'the other one'

New-IBDNSARecord -name server3.domain.com -comment 'newrecord' -IPAddress 10.0.0.3

Get-ibdnsarecord -name server1 | Remove-IBDNSARecord
get-ibdnsarecord -name server2 | Set-IBDNSARecord -Comment 'updated comment'





#
#azure
#
login-azurermaccount -subscription "msdn platforms"
$secPassword = 'NeverPutYourPasswordInSourceControl!' | ConvertTo-SecureString -AsPlainText -Force
$App = New-AzureRmADApplication -DisplayName "infoblox api automation account22" -IdentifierUris https://git6hub.com/infobloxcmdletsTest -Password $secPassword
#
$azurecred = new-object -typename pscredential -argumentlist $app.ApplicationId.Guid, $secPassword
$tenantID = Get-AzureRmSubscription | where-object{$_.name -eq 'MSDN Platforms'} | Select-Object -ExpandProperty TenantID
Login-AzureRmAccount -Credential $Azurecred -ServicePrincipal -TenantId $TenantID