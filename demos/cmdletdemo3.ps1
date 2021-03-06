Function Set-IBDNSARecord{
    [CmdletBinding(DefaultParameterSetName='byObject',SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
		[String]$Gridmaster,

        [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ParameterSetName='byRef')]
        [ValidateNotNullorEmpty()]
        [String]$_Ref,
        
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ParameterSetName='byObject')]
        [IB_DNSARecord[]]$Record,

		[IPAddress]$IPAddress = '0.0.0.0',

        [String]$Comment = "unspecified",

        [uint32]$TTL = 4294967295,

        [Switch]$ClearTTL,

		[Switch]$Passthru

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
		write-verbose "$FunctionName`:  Beginning Function"
		If (! $script:IBSession){
			write-verbose "Existing session to infoblox gridmaster does not exist."
			If ($gridmaster -and $Credential){
				write-verbose "Creating session to $gridmaster with user $($credential.username)"
				New-IBWebSession -gridmaster $Gridmaster -Credential $Credential -erroraction Stop  | out-null
			} else {
				write-error "Missing required parameters to connect to Gridmaster" -ea Stop
			}
		} else {
			write-verbose "Existing session to $script:IBGridmaster found"
		}
   }

    PROCESS{
            If ($pscmdlet.ParameterSetName -eq 'byRef'){
			
            $Record = [IB_DNSARecord]::Get($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$_Ref)
            If ($Record){
                $Record | Set-IBDNSARecord -IPAddress $IPAddress -Comment $Comment -TTL $TTL -ClearTTL:$ClearTTL -Passthru:$Passthru
            }
			
        }else {
			Foreach ($DNSRecord in $Record){
				If ($pscmdlet.ShouldProcess($DNSRecord)) {
					If ($IPAddress -ne '0.0.0.0'){
						write-verbose "$FunctionName`:  Setting IPAddress to $IPAddress"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$IPAddress, $DNSRecord.Comment, $DNSRecord.TTL, $DNSRecord.Use_TTL)
					}
					If ($Comment -ne "unspecified"){
						write-verbose "$FunctionName`:  Setting comment to $comment"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSRecord.IPAddress, $Comment, $DNSRecord.TTL, $DNSRecord.Use_TTL)
					}
					If ($ClearTTL){
						write-verbose "$FunctionName`:  Setting TTL to 0 and Use_TTL to false"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSRecord.IPAddress, $DNSRecord.comment, $Null, $False)
					} elseIf ($TTL -ne 4294967295){
						write-verbose "$FunctionName`:  Setting TTL to $TTL and Use_TTL to True"
						$DNSRecord.Set($Script:IBGridmaster,$Script:IBSession,$Script:IBWapiVersion,$DNSRecord.IPAddress, $DNSRecord.Comment, $TTL, $True)
					}
					If ($Passthru) {
						Write-Verbose "$FunctionName`:  Passthru specified, returning dns object as output"
						return $DNSRecord
					}

				}
			}
		}
	}
    END{}
}
