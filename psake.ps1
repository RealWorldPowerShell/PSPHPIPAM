# Set Properties Here

Properties {
    $lines = '----------------------------------------------------------------------'
    # Find the build folder based on build system
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) {
        $ProjectRoot = $PSScriptRoot
    }
    $ProjectRoot = Convert-Path $ProjectRoot
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'
    
    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
    
    try {
        $script:IsWindows = (-not (Get-Variable -Name IsWindows -ErrorAction Ignore)) -or $IsWindows
        $script:IsLinux = (Get-Variable -Name IsLinux -ErrorAction Ignore) -and $IsLinux
        $script:IsMacOS = (Get-Variable -Name IsMacOS -ErrorAction Ignore) -and $IsMacOS
        $script:IsCoreCLR = $PSVersionTable.ContainsKey('PSEdition') -and $PSVersionTable.PSEdition -eq 'Core'
    } catch { }
}

Task Default -depends Deploy


Task Init {
    $lines
   
}

Task Test -depends Init,Pester {
    $lines

}
Task Pester {
    $Lines
    "`nSTATUS: Testing with PowerShell $PSVersion"
    $TestResults = Invoke-Pester -Tag "Project","API" -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"
    If($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/${env:APPVEYOR_JOB_ID}", "$ProjectRoot\$TestFile")
    }
    
    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
        exit 1
    }
    "`n"
}

Task Build -depends Test {
    $lines
    #Set-ModuleFunctions

    # Bump the module version
    Update-Metadata -Path $env:BHPSModuleManifest
}

Task Deploy -depends Build {
    $lines
    $Params = @{
        Path = $ProjectRoot
        Force = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    Invoke-PSDeploy @Verbose @Params
}

