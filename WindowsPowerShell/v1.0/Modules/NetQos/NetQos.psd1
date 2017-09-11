@{
    GUID = '743692b7-a227-4389-b082-2b47de1d0d2d'
    Author = "Microsoft Corporation"
    CompanyName = "Microsoft Corporation"
    Copyright = "© Microsoft Corporation. All rights reserved."
    ModuleVersion = '2.0.0.0'
    PowerShellVersion = '3.0'
    NestedModules = @('MSFT_NetQosPolicy.cdxml')
    FormatsToProcess = @('MSFT_NetQosPolicy.format.ps1xml')
    TypesToProcess = @('MSFT_NetQosPolicy.types.ps1xml')
    HelpInfoUri = "http://go.microsoft.com/fwlink/?linkid=285555"
    FunctionsToExport = @(
        'Get-NetQosPolicy',
        'Set-NetQosPolicy',
        'Remove-NetQosPolicy',
        'New-NetQosPolicy')
}
