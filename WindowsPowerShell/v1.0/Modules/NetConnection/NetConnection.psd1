
@{
    ModuleVersion = '1.0.0.0'
    NestedModules = @("MSFT_NetConnectionProfile.cdxml")
    FormatsToProcess = @("MSFT_NetConnectionProfile.format.ps1xml")
    TypesToProcess = @("MSFT_NetConnectionProfile.types.ps1xml")
    HelpInfoUri = "http://go.microsoft.com/fwlink/?linkid=390795"
    GUID = '{CE4FF86E-9416-4f2d-A869-C860AC543B5E}'
    Author = 'Microsoft Corporation'
    CompanyName = 'Microsoft Corporation'
    PowerShellVersion = '3.0'
    Copyright = '© Microsoft Corporation. All rights reserved.'
    FunctionsToExport = @("Get-NetConnectionProfile", "Set-NetConnectionProfile")    
}

