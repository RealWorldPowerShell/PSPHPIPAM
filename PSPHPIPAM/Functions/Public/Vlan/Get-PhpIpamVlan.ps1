function Get-PhpIpamVlan{
    [cmdletBinding(DefaultParameterSetName="ByID")]
    Param(
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0,ParameterSetName="ByVLAN")]
         [string]$Vlan,
         [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,position=0,ParameterSetName="ByID")]
         [int]$ID
    )

    begin{

    }
    process{
            if ($PsCmdlet.ParameterSetName -eq "ByVLAN"){
                $r=Invoke-PhpIpamExecute -method get -controller vlans -identifiers @("search",$Vlan)
            }

            if($PsCmdlet.ParameterSetName -eq 'ByID'){
                $r=Invoke-PhpIpamExecute -method get -controller vlans -identifiers @($ID)
            }

            Resolve-PhpIpamExecuteResult -result $r
    }

    end{

    }
}
New-Alias -Name Get-PhpIpamVlanByID -Value Get-PhpIpamVlan
New-Alias -Name Get-PhpIpamVlanByIP -Value Get-PhpIpamVlan
Export-ModuleMember -Function Get-PhpIpamVlan -Alias "Get-PhpIpamVlanByID","Get-PhpIpamVlanByIP"
