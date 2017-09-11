# .Link
# http://go.microsoft.com/fwlink/?LinkID=225298
# .ExternalHelp ISE.psm1-help.xml
function New-IseSnippet
{
    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true, Position=0)]
        [String]
        $Title,
        
        [Parameter(Mandatory=$true, Position=1)]
        [String]
        $Description,
        
        [Parameter(Mandatory=$true, Position=2)]
        [String]
        $Text,

        [String]
        $Author,

        [Int32]
        [ValidateRange(0, [Int32]::MaxValue)]
        $CaretOffset = 0,

        [Switch]
        $Force
    )

    Begin
    {
        $snippetPath = Join-Path (Split-Path $profile.CurrentUserCurrentHost) "Snippets"
        
        if($Text.IndexOf("]]>") -ne -1)
        {
            throw [Microsoft.PowerShell.Host.ISE.SnippetStrings]::SnippetsNoCloseCData -f "Text","]]>"
        }

        if (-not (Test-Path $snippetPath))
        {
            $null = mkdir $snippetPath
        }
    }

    End
    {
        $snippet = @"
<?xml version='1.0' encoding='utf-8' ?>
    <Snippets  xmlns='http://schemas.microsoft.com/PowerShell/Snippets'>
        <Snippet Version='1.0.0'>
            <Header>
                <Title>$([System.Security.SecurityElement]::Escape($Title))</Title>
                <Description>$([System.Security.SecurityElement]::Escape($Description))</Description>
                <Author>$([System.Security.SecurityElement]::Escape($Author))</Author>
                <SnippetTypes>
                    <SnippetType>Expansion</SnippetType>
                </SnippetTypes>
            </Header>

            <Code>
                <Script Language='PowerShell' CaretOffset='$CaretOffset'>
                    <![CDATA[$Text]]>
                </Script>
            </Code>

    </Snippet>
</Snippets>

"@

        $pathCharacters = '/\`*?[]:><"|.';
        $fileName=new-object text.stringBuilder
        for($ix=0; $ix -lt $Title.Length; $ix++)
        {
            $titleChar=$Title[$ix]
            if($pathCharacters.IndexOf($titleChar) -ne -1)
            {
                $titleChar = "_"
            }

            $null = $fileName.Append($titleChar)
        }

        $params = @{
            FilePath = "$snippetPath\$fileName.snippets.ps1xml";
            Encoding = "UTF8"
        }

        if ($Force)
        {
            $params["Force"] = $true
        }
        else
        {
            $params["NoClobber"] = $true
        }

        $snippet | Out-File @params

        $psise.CurrentPowerShellTab.Snippets.Load($params["FilePath"])
    }
}

# .Link
# http://go.microsoft.com/fwlink/?LinkId=242050
# .ExternalHelp ISE.psm1-help.xml
function Import-IseSnippet
{
    [CmdletBinding(DefaultParameterSetName="FromFolder")]
    param(
    
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="FromFolder")]
        [String]
        $Path,

        [Parameter()]
        [Switch]
        $Recurse,
        
        [Parameter(Mandatory=$true, ParameterSetName="FromModule")]
        [String]
        $Module,

        [Parameter(ParameterSetName="FromModule")]
        [Switch]
        $ListAvailable
    )

    End
    {
        if ($Path)
        {
            dir "$Path\*.snippets.ps1xml" -Recurse:$Recurse | 
                    % {$psise.CurrentPowerShellTab.Snippets.Load($_)}
        }
        elseif ($Module)
        {
            if($ListAvailable)
            {
                $m = Get-Module $module -ListAvailable
            }
            else
            {
                $m = Get-Module $module
            }

            if (-not $m)
            {
                Write-Error ([Microsoft.PowerShell.Host.ISE.SnippetStrings]::ModuleNotFound)
            }

            foreach ($x in $m)
            {
                # Get the module path and validate that there is a Snippets folder
                $snipPath = Split-Path ($x.Path) -Parent
                if (Test-Path "$snipPath\Snippets")
                {
                    dir "$snipPath\Snippets\*.snippets.ps1xml" -Recurse:$Recurse | 
                            % {$psise.CurrentPowerShellTab.Snippets.Load($_)}
                }
                else
                {
                    Write-Verbose ([Microsoft.PowerShell.Host.ISE.SnippetStrings]::NoSnippetsInModule -f $x.Name,"Snippets")
                }
            }
        }
    }
}

# .Link
# http://go.microsoft.com/fwlink/?LinkID=238787
# .ExternalHelp ISE.psm1-help.xml
function Get-IseSnippet
{
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param()
    $snippetPath = Join-Path (Split-Path $profile.CurrentUserCurrentHost) "Snippets"
    if (Test-Path $snippetPath)
    {
        dir $snippetPath
    }
}

# SIG # Begin signature block
# MIIXXAYJKoZIhvcNAQcCoIIXTTCCF0kCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUv0M9fHFPOaghmrZBoun/tqPG
# zE6gghIxMIIEYDCCA0ygAwIBAgIKLqsR3FD/XJ3LwDAJBgUrDgMCHQUAMHAxKzAp
# BgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQgQ29ycC4xHjAcBgNV
# BAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFJv
# b3QgQXV0aG9yaXR5MB4XDTA3MDgyMjIyMzEwMloXDTEyMDgyNTA3MDAwMFoweTEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWlj
# cm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQC3eX3WXbNFOag0rDHa+SU1SXfA+x+ex0Vx79FG6NSMw2tMUmL0mQLD
# TdhJbC8kPmW/ziO3C0i3f3XdRb2qjw5QxSUr8qDnDSMf0UEk+mKZzxlFpZNKH5nN
# sy8iw0otfG/ZFR47jDkQOd29KfRmOy0BMv/+J0imtWwBh5z7urJjf4L5XKCBhIWO
# sPK4lKPPOKZQhRcnh07dMPYAPfTG+T2BvobtbDmnLjT2tC6vCn1ikXhmnJhzDYav
# 8sTzILlPEo1jyyzZMkUZ7rtKljtQUxjOZlF5qq2HyFY+n4JQiG4FsTXBeyS9UmY9
# mU7MK34zboRHBtGe0EqGAm6GAKTAh99TAgMBAAGjgfowgfcwEwYDVR0lBAwwCgYI
# KwYBBQUHAwMwgaIGA1UdAQSBmjCBl4AQW9Bw72lyniNRfhSyTY7/y6FyMHAxKzAp
# BgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQgQ29ycC4xHjAcBgNV
# BAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFJv
# b3QgQXV0aG9yaXR5gg8AwQCLPDyIEdE+9mPs30AwDwYDVR0TAQH/BAUwAwEB/zAd
# BgNVHQ4EFgQUzB3OdgBwW6/x2sROmlFELqNEY/AwCwYDVR0PBAQDAgGGMAkGBSsO
# AwIdBQADggEBAHurrn5KJvLOvE50olgndCp1s4b9q0yUeABN6crrGNxpxQ6ifPMC
# Q8bKh8z4U8zCn71Wb/BjRKlEAO6WyJrVHLgLnxkNlNfaHq0pfe/tpnOsj945jj2Y
# arw4bdKIryP93+nWaQmRiL3+4QC7NPP3fPkQEi4F6ymWk0JrKHG3OI/gBw3JXWjN
# vYBBa2aou7e7jjTK8gMQfHr10uBC33v+4eGs/vbf1Q2zcNaS40+2OKJ8LdQ92zQL
# YjcCn4FqI4n2XGOPsFq7OddgjFWEGjP1O5igggyiX4uzLLehpcur2iC2vzAZhSAU
# DSq8UvRB4F4w45IoaYfBcOLzp6vOgEJydg4wggR6MIIDYqADAgECAgphAbKbAAAA
# AAAVMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBMB4X
# DTExMDIyMTIwNTMxMloXDTEyMDUyMTIwNTMxMlowgYMxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIxHjAcBgNVBAMTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAKVxdBjL25wv+vFjGYCjjv/IcIMMoUcq+vpasM5ND7072iHNBdV9fD+1mXYl
# OtygTyDlctNDceb/bBT5n4SyJYe9FLVdvjeJLsWrhWBxhYEnuTMD+a3WkwLutlUR
# AsuDhfbBhWNhGaAUnJ2fnEZjN9gRPFfHSCBTFvfMWP72wBrKtkZsDeg6Bc6mHOOI
# 8N2qwnCDW9Hy8j+42aSdowBuqoHN7joErcBKkiwT4OlBdgmAAWxnILQxsD5r0kAI
# g9VwMI0w576M0C/u1IY/GlqlwGiF6Il8kQNKbllDIEiciP7JRbfoTAQBC2LOouwc
# kyX90LEOxvi2JBp7+3zWXE7RZ+kCAwEAAaOB+DCB9TATBgNVHSUEDDAKBggrBgEF
# BQcDAzAdBgNVHQ4EFgQU2XLUywxiX92jdJ9fDphBqFsTQyYwDgYDVR0PAQH/BAQD
# AgeAMB8GA1UdIwQYMBaAFMwdznYAcFuv8drETppRRC6jRGPwMEQGA1UdHwQ9MDsw
# OaA3oDWGM2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L0NTUENBLmNybDBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAKGLGh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvQ1NQQ0EuY3J0MA0GCSqGSIb3DQEB
# BQUAA4IBAQBgYCfYfDBJEkdBNzxedbTkogA2EUiwLFibmHztoxKhmO4Ys5f2bY7Y
# MBocrSFjQUaT168aKEuXNn1AVGDMYrzp/GmnX3/Fh6aGDHyp4ll924jVd3gFpiTK
# ZPhOUbdEKI4aLFQIKHLFHxg9LM8AJ28T0aVh8tZiOr0ATgUvmWd95WNDPzsMvosH
# euF4QL/feM6HIKIZobxg8J+sUlx2FP0beAXXY3Vrgf2HRq2tWVK/e7+vGaSSsvIL
# LH4wENsxS76EWn/3mxJ46d5+YKsNxjEe9nKaPmfPOO44zjkbc9s72TTfg9KczeGL
# 3hr+ZAhfr/YuuDIldmkl89WNNSPD2yVEMIIEnTCCA4WgAwIBAgIQaguZT8AAJasR
# 20UfWHpnojANBgkqhkiG9w0BAQUFADBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMp
# IDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eTAeFw0wNjA5
# MTYwMTA0NDdaFw0xOTA5MTUwNzAwMDBaMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBUaW1lc3RhbXBpbmcg
# UENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3Ddu+6/IQkpxGMjO
# SD5TwPqrFLosMrsST1LIg+0+M9lJMZIotpFk4B9QhLrCS9F/Bfjvdb6Lx6jVrmlw
# ZngnZui2t++Fuc3uqv0SpAtZIikvz0DZVgQbdrVtZG1KVNvd8d6/n4PHgN9/TAI3
# lPXAnghWHmhHzdnAdlwvfbYlBLRWW2ocY/+AfDzu1QQlTTl3dAddwlzYhjcsdckO
# 6h45CXx2/p1sbnrg7D6Pl55xDl8qTxhiYDKe0oNOKyJcaEWL3i+EEFCy+bUajWzu
# JZsT+MsQ14UO9IJ2czbGlXqizGAG7AWwhjO3+JRbhEGEWIWUbrAfLEjMb5xD4Gro
# fyaOawIDAQABo4IBKDCCASQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwgaIGA1UdAQSB
# mjCBl4AQW9Bw72lyniNRfhSyTY7/y6FyMHAxKzApBgNVBAsTIkNvcHlyaWdodCAo
# YykgMTk5NyBNaWNyb3NvZnQgQ29ycC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFJvb3QgQXV0aG9yaXR5gg8AwQCL
# PDyIEdE+9mPs30AwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFG/oTj+XuTSr
# S4aPvJzqrDtBQ8bQMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBBQUAA4IBAQCUTRExwnxQ
# uxGOoWEHAQ6McEWN73NUvT8JBS3/uFFThRztOZG3o1YL3oy2OxvR+6ynybexUSEb
# bwhpfmsDoiJG7Wy0bXwiuEbThPOND74HijbB637pcF1Fn5LSzM7djsDhvyrNfOzJ
# rjLVh7nLY8Q20Rghv3beO5qzG3OeIYjYtLQSVIz0nMJlSpooJpxgig87xxNleEi7
# z62DOk+wYljeMOnpOR3jifLaOYH5EyGMZIBjBgSW8poCQy97Roi6/wLZZflK3toD
# dJOzBW4MzJ3cKGF8SPEXnBEhOAIch6wGxZYyuOVAxlM9vamJ3uhmN430IpaczLB3
# VFE61nJEsiP2MIIEqjCCA5KgAwIBAgIKYQaULQAAAAAACTANBgkqhkiG9w0BAQUF
# ADB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQD
# ExpNaWNyb3NvZnQgVGltZXN0YW1waW5nIFBDQTAeFw0wODA3MjUxOTAyMTdaFw0x
# MzA3MjUxOTEyMTdaMIGzMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMQ0wCwYDVQQLEwRNT1BSMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBFU046N0E4
# Mi02ODhBLTlGOTIxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZp
# Y2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCVgQogQhhRetmV7Zv9
# 3IfR+w6PE+qqNygSdv5NUKt2lyqTR+CpVmkC5ZR+TYXbf3HvdQDbu0Ns+2+scfAr
# 0XySzpQXnaHFuvn3ft1h4S0wHpwmLXY/5kaWjq7YiTfYzO/zz1vD/Gjg8mSPm+jD
# EvmjvoT81ovOBT29AXZQJwP4hLcWho1gvl0pLDzPpf2YWjUdTxbAONgeYT89NrNW
# FBV3lTsQ+gCwk+JdN6snu2MsSBSBVeNs6qkrlY2IDn6jAKV3JAeYKnADuCokkJre
# xaIiS79MWQZ3VHJDsD5k3ZOECFi2/umHSQk2s7P4M6l+TKJ5fzJZKQ6etfXgPJ4/
# 7EY7AgMBAAGjgfgwgfUwHQYDVR0OBBYEFCiViL8CO+valLp9Rg/6y/R+nf/RMB8G
# A1UdIwQYMBaAFG/oTj+XuTSrS4aPvJzqrDtBQ8bQMEQGA1UdHwQ9MDswOaA3oDWG
# M2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL3RzcGNh
# LmNybDBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUHMAKGLGh0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2kvY2VydHMvdHNwY2EuY3J0MBMGA1UdJQQMMAoGCCsGAQUF
# BwMIMA4GA1UdDwEB/wQEAwIGwDANBgkqhkiG9w0BAQUFAAOCAQEAAO6s/OLSiGbK
# KeNauc0Agn4XXMUkWRK7qPdr14f+jcu1dh8bIvb34cq0uUEBGjetSDeWcPrMM6co
# jLgLtnQTKLezdeEqCeKLT9+YP5e3NBKB6hDdHdy6ZM9OUDtMiv0Z3SWu1ZaH6kvE
# 5fD5QRddAetXiH12euVv/ocgrJOcjJq/XxqgFTAk4KJ+YZEdKSnDSZA6Q4OJ7t7V
# g91PLDU750FBAaoADAvy1kkbzkKNe7DzLY1dKeG+jX+RFXa0YPsUJ6pvEmNCKFg6
# ijuLQOS3xcySVxxGVmuPy5JNVgUAyvgwQEVO3xmIvfUQ8N0a3ygetFHyd+Am47sJ
# gRLcHjrQRTGCBJUwggSRAgEBMIGHMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENB
# AgphAbKbAAAAAAAVMAkGBSsOAwIaBQCggcAwGQYJKoZIhvcNAQkDMQwGCisGAQQB
# gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkE
# MRYEFA1nzecny8D6UdoB0eh8tUKBRsZoMGAGCisGAQQBgjcCAQwxUjBQoCaAJABX
# AGkAbgBkAG8AdwBzACAAUABvAHcAZQByAFMAaABlAGwAbKEmgCRodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcG93ZXJzaGVsbCAwDQYJKoZIhvcNAQEBBQAEggEABafT
# TWnpvw7Gt2WzQdXJ9hZX7APKuI59Z0hWhD/GmbE3waRPga5Gu91HizoR64LIxSv/
# IDRP2hUBoL7OWsnRwcZTRcDIvApzpa+bOjodKkrYzsSnBJsvVlnuwfyQmlmGMj/a
# V29cXbyKCTUYo9ITO4zoLnKE0tB5jZzJrZYP2KHImRi95dA/m5imLf/ZI20iOyyW
# oxaw3UzMFOjyRj4/4XM2hzUJlkByXXtzxDs16FA1Uc4A478yzWJCBCaEfnwzrpWB
# /wCCyqo/ibAMR/tx8W9V3ktUcT1vTdQxKVi0Tgj/vdQiIQWhKsQpoTZB9C8g1qcQ
# GsKrn49r6XVXIAfvcaGCAh8wggIbBgkqhkiG9w0BCQYxggIMMIICCAIBATCBhzB5
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpN
# aWNyb3NvZnQgVGltZXN0YW1waW5nIFBDQQIKYQaULQAAAAAACTAHBgUrDgMCGqBd
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTEyMDMy
# NzE4MjMwNlowIwYJKoZIhvcNAQkEMRYEFD5pfZUAy0ydAW8E+uYyssddg7FxMA0G
# CSqGSIb3DQEBBQUABIIBADGri65gbVLhpPrKjQmChYHMxpKMDsQgXZ0fur69BwYS
# Y244bOSJpwq0da3cr8TPvLU7OJw3/XpEK2ZTlvzhBbyh0aaOIQGMrO3eREmDNP3D
# BPct38hgP4LdshCkXQHpeaAVZ3EcoJ0kS4EFn3cvamco0mwgb9jwuTi8UPXFExCX
# HNHPPQanI9HpDNBxWrVzcH6zIV1vBHSeB/tFtZpOI+beHjx7X3d1cyCg5lfERzyQ
# 3jJyjSbMMbz8Pj/1meM0rlWQ/ZnYYiQAtJYqUN3ctT21Uu3ZVVnw46A8voTnSRMd
# 5mVFLFMeFyJkWgsyqLroBTm4U/G+gZ2BB0ImzSbSfIo=
# SIG # End signature block
