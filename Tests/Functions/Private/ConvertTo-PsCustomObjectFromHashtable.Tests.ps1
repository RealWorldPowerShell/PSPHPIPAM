$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

$ModuleName="PSPHPIPAM"
$ModuleFileFolder=$here -replace '/Tests/',"/$ModuleName/"

. "$ModuleFileFolder\$sut"

Describe "ConvertTo-PsCustomObjectFromHashtable" {
    It "ConvertTo-PsCustomObjectFromHashtable function test" {
        $cusObj=ConvertTo-PsCustomObjectFromHashtable -hashtable @{a = 1; b = 2 }
        $cusObj |Should -BeOfType PSCustomObject
        $cusObj.a |Should -be 1
        $cusObj.b |Should -be 2
    }
}