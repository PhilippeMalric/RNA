############################
#
# Copyright (c) Microsoft Corporation
#
# Abstract:
#   SMAPI script cmdlets
#
############################

import-module Storage\StorageHealth.cdxml
import-module Storage\StorageSubSystem.cdxml

$StorageNamespace = 'root\microsoft\windows\storage'
$WmiNamespace     = 'root\wmi'
$ClusterNamespace = 'root\mscluster'

function CreateErrorRecord
{
    param
    (
        [String]
        $ErrorId,

        [String]
        $ErrorMessage,

        [System.Management.Automation.ErrorCategory]
        $ErrorCategory,

        [Exception]
        $Exception,

        [Object]
        $TargetObject
    )

    if($Exception -eq $null)
    {
        $Exception = New-Object System.Management.Automation.RuntimeException $ErrorMessage
    }

    $errorRecord = New-Object System.Management.Automation.ErrorRecord @($Exception, $ErrorId, $ErrorCategory, $TargetObject)
    return $errorRecord
}


function Get-PhysicalDisk {

    [CmdletBinding( DefaultParameterSetName = "ByUniqueId" )]
    param
    (
        #### -------------------- Parameter sets -------------------------------------####

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByUniqueId',
            ValueFromPipeline = $true,
            Mandatory         = $false)]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        $UniqueId,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByObjectId',
            ValueFromPipeline = $true,
            Mandatory         = $false)]
        [ValidateNotNullOrEmpty()]
        [Alias("PhysicalDiskObjectId")]
        $ObjectId,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByName',
            ValueFromPipeline = $true,
            Mandatory         = $false,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $FriendlyName,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByName',
            ValueFromPipeline = $true,
            Mandatory         = $false,
            Position          = 1)]
        [ValidateNotNullOrEmpty()]
        $SerialNumber,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByInputObject',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageSubsystem")]
        [Parameter(
            ParameterSetName  = 'ByStorageSubsystem',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StorageSubsystem,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageEnclosure")]
        [Parameter(
            ParameterSetName  = 'ByStorageEnclosure',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StorageEnclosure,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageNode")]
        [Parameter(
            ParameterSetName  = 'ByStorageNode',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StorageNode,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StoragePool")]
        [Parameter(
            ParameterSetName  = 'ByStoragePool',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StoragePool,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_VirtualDisk")]
        [Parameter(
            ParameterSetName  = 'ByVirtualDisk',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $VirtualDisk,

        #### ------------------ VirtualDisk association parameters -------------------####

        [System.UInt64]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $VirtualRangeMin,

        [System.UInt64]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $VirtualRangeMax,

        [System.Boolean]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $HasAllocations,

        [System.Boolean]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $SelectedForUse,

        [Switch]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $NoRedundancy,

        #### ------------------ StorageNode association parameters -------------------####

        [Switch]
        [Parameter(
            ParameterSetName = 'ByStorageNode',
            Mandatory        = $false)]
        $PhysicallyConnected,

        #### ------------------------- Common parameters -----------------------------####

        [PhysicalDiskUsage]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByObjectId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageEnclosure',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageNode',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $Usage,

        [System.String]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByObjectId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageEnclosure',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageNode',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $Description,

        [System.String]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByObjectId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageEnclosure',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageNode',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $Manufacturer,

        [System.String]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByObjectId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageEnclosure',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageNode',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $Model,

        [System.Boolean]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByObjectId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageEnclosure',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageNode',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $CanPool,

        [PhysicalDiskHealthStatus]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByObjectId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageEnclosure',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageNode',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByVirtualDisk',
            Mandatory        = $false)]
        $HealthStatus,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    Begin
    {
        [flagsattribute()]
        Enum PhysicalDiskUsage
        {
            Unknown      = 0
            AutoSelect   = 1
            ManualSelect = 2
            HotSpare     = 3
            Retired      = 4
            Journal      = 5
        }

        [flagsattribute()]
        Enum PhysicalDiskHealthStatus
        {
            Healthy   = 0
            Warning   = 1
            Unhealthy = 2
            Unknown   = 5
        }
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        ## Gather the instance objects.

        $options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions

        switch -regex ($psCmdlet.ParameterSetName)
        {
            { @("ByInputObject" `
                ) -contains $_  `
            }
            {
                $cimInstance = New-Object Microsoft.Management.Infrastructure.CimInstance("MSFT_PhysicalDisk")

                $cimInstance.CimInstanceProperties.Add([Microsoft.Management.Infrastructure.CimProperty]::Create("ObjectId", $InputObject.ObjectId, "String", "Key"))

                $instance = $CimSession.GetInstance($StorageNamespace,
                                                    $cimInstance);
                break;
            }

            { @("ByObjectId"
                "ByUniqueId",  `
                "ByName"       `
                ) -contains $_ `
            }
            {
                $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                          "MSFT_PhysicalDisk");
                break;
            }

            { @(
                "ByStorageSubsystem", `
                "ByStoragePool",      `
                "ByStorageEnclosure", `
                "ByStorageNode",      `
                "ByVirtualDisk"       `
                ) -contains $_        `
            }
            {
                if ($PSBoundParameters.ContainsKey("StorageSubsystem"))
                {
                    $subsystem = $StorageSubsystem
                }
                elseif ($PSBoundParameters.ContainsKey("StoragePool"))
                {
                    $subsystem = $StoragePool | get-storagesubsystem -CimSession $CimSession
                }
                elseif ($PSBoundParameters.ContainsKey("StorageEnclosure"))
                {
                    $subsystem = $StorageEnclosure | get-storagesubsystem -CimSession $CimSession
                }
                elseif ($PSBoundParameters.ContainsKey("StorageNode"))
                {
                    $subsystem = $StorageNode | get-storagesubsystem -CimSession $CimSession
                }
                elseif ($PSBoundParameters.ContainsKey("VirtualDisk"))
                {
                    $subsystem = $VirtualDisk | get-storagesubsystem -CimSession $CimSession
                }

                # If the subsystem model is "Windows Storage",
                # perform associations using enumeration

                if ($PSBoundParameters.ContainsKey("StorageSubsystem"))
                {
                    $options.SetCustomOption("InputClassName", "MSFT_StorageSubsystem", $false)
                    $options.SetCustomOption("InputObjectId", $StorageSubsystem.ObjectId, $false)

                    if ($subsystem.Model -like "*Windows Storage*")
                    {
                        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                                  "MSFT_PhysicalDisk",
                                                                  $options)
                    }
                    else
                    {
                        $results = $CimSession.EnumerateAssociatedInstances($StorageNamespace,
                                                                            $StorageSubsystem,
                                                                            "MSFT_StorageSubsystemToPhysicalDisk",
                                                                            "MSFT_PhysicalDisk",
                                                                            "StorageSubsystem",
                                                                            "PhysicalDisk",
                                                                            $options)
                    }
                }
                elseif ($PSBoundParameters.ContainsKey("StoragePool"))
                {
                    $options.SetCustomOption("InputClassName", "MSFT_StoragePool", $false)
                    $options.SetCustomOption("InputObjectId", $StoragePool.ObjectId, $false)

                    if ($subsystem.Model -like "*Windows Storage*")
                    {
                        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                                  "MSFT_PhysicalDisk",
                                                                  $options)
                    }
                    else
                    {
                        $results = $CimSession.EnumerateAssociatedInstances($StorageNamespace,
                                                                            $StoragePool,
                                                                            "MSFT_StoragePoolToPhysicalDisk",
                                                                            "MSFT_PhysicalDisk",
                                                                            "StoragePool",
                                                                            "PhysicalDisk",
                                                                            $options)
                    }
                }
                elseif ($PSBoundParameters.ContainsKey("StorageEnclosure"))
                {
                    $options.SetCustomOption("InputClassName", "MSFT_StorageEnclosure", $false)
                    $options.SetCustomOption("InputObjectId", $StorageEnclosure.ObjectId, $false)

                    if ($subsystem.Model -like "*Windows Storage*")
                    {
                        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                                  "MSFT_PhysicalDisk",
                                                                  $options);
                    }
                    else
                    {
                        $results = $CimSession.EnumerateAssociatedInstances($StorageNamespace,
                                                                            $StorageEnclosure,
                                                                            "MSFT_StorageEnclosureToPhysicalDisk",
                                                                            "MSFT_PhysicalDisk",
                                                                            "StorageEnclosure",
                                                                            "PhysicalDisk",
                                                                            $options);
                    }
                }
                elseif ($PSBoundParameters.ContainsKey("StorageNode"))
                {
                    $options.SetCustomOption("InputClassName", "MSFT_StorageNode", $false)
                    $options.SetCustomOption("InputObjectId", $StorageNode.ObjectId, $false)

                    if ($PSBoundParameters.ContainsKey("PhysicallyConnected"))
                    {
                        $options.SetCustomOption("PhysicallyConnected", $true, $false)
                    }

                    if ($subsystem.Model -like "*Windows Storage*")
                    {
                        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                                  "MSFT_PhysicalDisk",
                                                                  $options);
                    }
                    else
                    {
                        $results = $CimSession.EnumerateAssociatedInstances($StorageNamespace,
                                                                            $StorageNode,
                                                                            "MSFT_StorageNodeToPhysicalDisk",
                                                                            "MSFT_PhysicalDisk",
                                                                            "StorageNode",
                                                                            "PhysicalDisk",
                                                                            $options);
                    }
                }
                elseif ($PSBoundParameters.ContainsKey("VirtualDisk"))
                {
                    $options.SetCustomOption("InputClassName", "MSFT_VirtualDisk", $false)
                    $options.SetCustomOption("InputObjectId", $VirtualDisk.ObjectId, $false)

                    if ($PSBoundParameters.ContainsKey("VirtualRangeMin"))
                    {
                        $options.SetCustomOption("VirtualRangeMin", $VirtualRangeMin, [Microsoft.Management.Infrastructure.CimType]::UInt64, $false)
                    }

                    if ($PSBoundParameters.ContainsKey("VirtualRangeMax"))
                    {
                        $options.SetCustomOption("VirtualRangeMax", $VirtualRangeMax, [Microsoft.Management.Infrastructure.CimType]::UInt64, $false)
                    }

                    if ($PSBoundParameters.ContainsKey("HasAllocations"))
                    {
                        $options.SetCustomOption("HasAllocations", $HasAllocations, $false)
                    }

                    if ($PSBoundParameters.ContainsKey("SelectedForUse"))
                    {
                        $options.SetCustomOption("SelectedForUse", $SelectedForUse, $false)
                    }

                    if ($PSBoundParameters.ContainsKey("NoRedundancy"))
                    {
                        $options.SetCustomOption("NoRedundancy", $true, $false)
                    }

                    if ($subsystem.Model -like "*Windows Storage*")
                    {
                        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                                  "MSFT_PhysicalDisk",
                                                                  $options);
                    }
                    else
                    {
                        $results = $CimSession.EnumerateAssociatedInstances($StorageNamespace,
                                                                            $VirtualDisk,
                                                                            "MSFT_VirtualDiskToPhysicalDisk",
                                                                            "MSFT_PhysicalDisk",
                                                                            "VirtualDisk",
                                                                            "PhysicalDisk",
                                                                            $options);
                    }
                }

                break;
            }
        }

        $instances  = @()

        if ($psCmdlet.ParameterSetName -eq "ByInputObject")
        {
            $instances += $instance
        }
        else
        {
            $enumerator = $results.GetEnumerator()

            while ($enumerator.MoveNext())
            {
                $instance = $enumerator.Current

                ## Filter by optional input parameters

                if (($PSBoundParameters.ContainsKey("ObjectId")) -and
                    ($instance.ObjectId -notlike $ObjectId))
                {
                    continue
                }

                if (($PSBoundParameters.ContainsKey("UniqueId")) -and
                    ($instance.UniqueId -notlike $UniqueId))
                {
                    continue
                }

                if (($PSBoundParameters.ContainsKey("FriendlyName")) -and
                    ($instance.FriendlyName -notlike $FriendlyName))
                {
                    continue
                }

                if (($PSBoundParameters.ContainsKey("SerialNumber")) -and
                    ($instance.SerialNumber -notlike $SerialNumber))
                {
                    continue
                }

                if ($PSBoundParameters.ContainsKey("Usage"))
                {
                    $matchFound = $true

                    switch -regex ($Usage)
                    {
                        { @(               `
                            "Unknown",     `
                            "Retired",     `
                            "Journal"      `
                            ) -contains $_ `
                        }
                        {
                            if ( $instance.Usage -ne $Usage )
                            {
                                $matchFound = $false
                                break
                            }
                        }

                        { @(               `
                            "AutoSelect"   `
                            ) -contains $_ `
                        }
                        {
                            if ( $instance.Usage -ne "Auto-Select" )
                            {
                                $matchFound = $false
                                break
                            }
                        }

                        { @(               `
                            "ManualSelect" `
                            ) -contains $_ `
                        }
                        {
                            if ( $instance.Usage -ne "Manual-Select" )
                            {
                                $matchFound = $false
                                break
                            }
                        }

                        { @(               `
                            "HotSpare"     `
                            ) -contains $_ `
                        }
                        {
                            if ( $instance.Usage -ne "Hot Spare" )
                            {
                                $matchFound = $false
                                break
                            }
                        }
                    }

                    if ( $matchFound -eq $false )
                    {
                        continue
                    }
                }

                if (($PSBoundParameters.ContainsKey("Description")) -and
                    ($instance.Description -notlike $Description))
                {
                    continue
                }

                if (($PSBoundParameters.ContainsKey("Manufacturer")) -and
                    ($instance.Manufacturer -ne $Manufacturer))
                {
                    continue
                }

                if (($PSBoundParameters.ContainsKey("Model")) -and
                    ($instance.Model -ne $Model))
                {
                    continue
                }

                if (($PSBoundParameters.ContainsKey("CanPool")) -and
                    ($instance.CanPool -ne $CanPool))
                {
                    continue
                }

                if (($PSBoundParameters.ContainsKey("HealthStatus")) -and
                    ($instance.HealthStatus -ne $HealthStatus))
                {
                    continue
                }

                $instances += $instance
            }
        }

        $instances
    }
}


function Get-PhysicalExtent
{
    param(
        #### -------------------- Parameter sets -------------------------------------####

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_VirtualDisk")]
        [Parameter(
            ParameterSetName  = 'ByVirtualDisk',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $VirtualDisk,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageTier")]
        [Parameter(
            ParameterSetName  = 'ByStorageTier',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StorageTier,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByPhysicalDisk',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $PhysicalDisk,

        #### -------------------- Powershell parameters ------------------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        ## Gather the instance objects

        switch ($psCmdlet.ParameterSetName)
        {
            "ByVirtualDisk"  { $inputObject = $VirtualDisk;  break; }
            "ByStorageTier"  { $inputObject = $StorageTier;  break; }
            "ByPhysicalDisk" { $inputObject = $PhysicalDisk; break; }
        }

        $instances = @()

        try
        {
            $output     = Invoke-CimMethod -CimSession $CimSession -InputObject $inputObject -MethodName "GetPhysicalExtent" -ErrorAction Stop
            $enumerator = $output.PhysicalExtents.GetEnumerator()

            while ($enumerator.MoveNext())
            {
                $instance = $enumerator.Current
                $instance.PSObject.TypeNames.Insert(0, "Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalExtent")

                $instances += $instance
            }
        }
        catch
        {
            $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                             -ErrorMessage $null `
                                             -ErrorCategory $_.CategoryInfo.Category `
                                             -Exception $_.Exception `
                                             -TargetObject $_.TargetObject

            $psCmdlet.WriteError($errorObject)
        }

        $instances
    }
}


function Get-PhysicalExtentAssociation
{
    param(
        #### -------------------- Parameter sets -------------------------------------####

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalExtent")]
        [Parameter(
            ParameterSetName  = 'ByInputObject',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        #### -------------------- Powershell parameters ------------------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        $virtualDisk = Get-VirtualDisk -CimSession $CimSession -UniqueId $InputObject.VirtualDiskUniqueId -ErrorAction Stop

        if ($InputObject.StorageTierUniqueId -ne $null)
        {
            $storageTier = Get-StorageTier -CimSession $CimSession -UniqueId $InputObject.StorageTierUniqueId -ErrorAction Stop
        }

        $physicalDisk = Get-PhysicalDisk -CimSession $CimSession -UniqueId $InputObject.PhysicalDiskUniqueId -ErrorAction Stop

        $associations = [pscustomobject]@{
            VirtualDisk  = $virtualDisk;
            StorageTier  = $storageTier;
            PhysicalDisk = $physicalDisk;
        }

        $associations
    }
}


function Enable-PhysicalDiskIdentification
{
    [CmdletBinding( DefaultParameterSetName = "ByName", ConfirmImpact="Low" )]
    [Alias("Enable-PhysicalDiskIndication")]
    param
    (
        #### -------------------- Parameter sets -------------------------------------####

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByUniqueId',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        $UniqueId,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByName',
            ValueFromPipeline = $true,
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $FriendlyName,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByInputObject',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        #### ------------------------- Common method parameters ----------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin
    {
        $SourceCaller = "Microsoft.PowerShell"
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            Write-Progress -Activity "Enable-PhysicalDiskIdentification" -PercentComplete 0 -CurrentOperation "Gathering objects" -Status "0/2"
        }

        ## Gather the instance objects

        switch ($psCmdlet.ParameterSetName)
        {
            "ByInputObject" { $Instances = $InputObject; break; }
            "ByUniqueId"    { $Instances = Get-PhysicalDisk -UniqueId $UniqueId -CimSession $CimSession -ErrorAction Stop; break; }
            "ByName"        { $Instances = Get-PhysicalDisk -FriendlyName $FriendlyName -CimSession $CimSession -ErrorAction Stop; break; }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $methodblock = {
            param($session, $asjob, $instances)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $arguments = @{ "EnableIndication" = $true }
            $errorObject = $null

            if (-not $asjob)
            {
                Write-Progress -Activity "Enable-PhysicalDiskIdentification" -PercentComplete 30 -CurrentOperation "Executing method" -Status "1/2"
            }

            ForEach ( $instance in $instances )
            {
                try
                {
                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $instance -MethodName Maintenance -Arguments $arguments -ErrorAction Stop

                    $progressPreference = "Continue"
                }
                catch
                {
                    $progressPreference = "Continue"

                    $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                     -ErrorMessage $null `
                                                     -ErrorCategory $_.CategoryInfo.Category `
                                                     -Exception $_.Exception `
                                                     -TargetObject $_.TargetObject

                    $psCmdlet.WriteError($errorObject)
                }
            }

            if (-not $asjob)
            {
                Write-Progress -Activity "Enable-PhysicalDiskIdentification" -Completed -Status "2/2"
            }
        }

        if ($asjob)
        {
            $p = $true

            Start-Job -Name EnablePhysicalDiskIdentification -ScriptBlock $methodblock -ArgumentList @($CimSession, $p, $Instances)
        }
        else
        {
            &$methodblock $CimSession $p $Instances
        }
    }
}


function Disable-PhysicalDiskIdentification
{
    [CmdletBinding( DefaultParameterSetName = "ByName", ConfirmImpact="Low" )]
    [Alias("Disable-PhysicalDiskIndication")]
    param
    (
        #### -------------------- Parameter sets -------------------------------------####

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByUniqueId',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        $UniqueId,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByName',
            ValueFromPipeline = $true,
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $FriendlyName,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByInputObject',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        #### ------------------------- Common method parameters ----------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin
    {
        $SourceCaller = "Microsoft.PowerShell"
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            Write-Progress -Activity "Disable-PhysicalDiskIdentification" -PercentComplete 0 -CurrentOperation "Gathering objects" -Status "0/2"
        }

        ## Gather the instance objects

        switch ($psCmdlet.ParameterSetName)
        {
            "ByInputObject" { $Instances = $InputObject; break; }
            "ByUniqueId"    { $Instances = Get-PhysicalDisk -UniqueId $UniqueId -CimSession $CimSession -ErrorAction Stop; break; }
            "ByName"        { $Instances = Get-PhysicalDisk -FriendlyName $FriendlyName -CimSession $CimSession -ErrorAction Stop; break; }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $methodblock = {
            param($session, $asjob, $instances)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $arguments = @{ "EnableIndication" = $false }
            $errorObject = $null

            if (-not $asjob)
            {
                Write-Progress -Activity "Disable-PhysicalDiskIdentification" -PercentComplete 30 -CurrentOperation "Executing method" -Status "1/2"
            }

            ForEach ( $instance in $instances )
            {
                try
                {
                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $instance -MethodName Maintenance -Arguments $arguments -ErrorAction Stop

                    $progressPreference = "Continue"
                }
                catch
                {
                    $progressPreference = "Continue"

                    $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                     -ErrorMessage $null `
                                                     -ErrorCategory $_.CategoryInfo.Category `
                                                     -Exception $_.Exception `
                                                     -TargetObject $_.TargetObject

                    $psCmdlet.WriteError($errorObject)
                }
            }

            if (-not $asjob)
            {
                Write-Progress -Activity "Disable-PhysicalDiskIdentification" -Completed -Status "2/2"
            }
        }

        if ($asjob)
        {
            $p = $true

            Start-Job -Name DisablePhysicalDiskIdentification -ScriptBlock $methodblock -ArgumentList @($CimSession, $p, $Instances)
        }
        else
        {
            &$methodblock $CimSession $p $Instances
        }
    }
}


function Reset-PhysicalDisk
{
    [CmdletBinding( DefaultParameterSetName = "ByName", ConfirmImpact="Medium" )]
    param
    (
        #### -------------------- Parameter sets -------------------------------------####

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByUniqueId',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        $UniqueId,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByName',
            ValueFromPipeline = $true,
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $FriendlyName,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByInputObject',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        #### ------------------------- Common method parameters ----------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin
    {
        $SourceCaller = "Microsoft.PowerShell"
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            Write-Progress -Activity "Reset-PhysicalDisk" -PercentComplete 0 -CurrentOperation "Gathering objects" -Status "0/2"
        }

        ## Gather the instance objects

        switch ($psCmdlet.ParameterSetName)
        {
            "ByInputObject" { $Instances = $InputObject; break; }
            "ByUniqueId"    { $Instances = Get-PhysicalDisk -UniqueId $UniqueId -CimSession $CimSession -ErrorAction Stop; break; }
            "ByName"        { $Instances = Get-PhysicalDisk -FriendlyName $FriendlyName -CimSession $CimSession -ErrorAction Stop; break; }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $methodblock = {
            param($session, $asjob, $instances)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $errorObject = $null

            if (-not $asjob)
            {
                Write-Progress -Activity "Reset-PhysicalDisk" -PercentComplete 30 -CurrentOperation "Executing method" -Status "1/2"
            }

            ForEach ( $instance in $instances )
            {
                try
                {
                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $instance -MethodName Reset -ErrorAction Stop

                    $progressPreference = "Continue"
                }
                catch
                {
                    $progressPreference = "Continue"

                    $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                     -ErrorMessage $null `
                                                     -ErrorCategory $_.CategoryInfo.Category `
                                                     -Exception $_.Exception `
                                                     -TargetObject $_.TargetObject

                    $psCmdlet.WriteError($errorObject)
                }
            }

            if (-not $asjob)
            {
                Write-Progress -Activity "Reset-PhysicalDisk" -Completed -Status "2/2"
            }
        }

        if ($asjob)
        {
            $p = $true

            Start-Job -Name ResetPhysicalDisk -ScriptBlock $methodblock -ArgumentList @($CimSession, $p, $Instances)
        }
        else
        {
            &$methodblock $CimSession $p $Instances
        }
    }
}


function Get-StorageFirmwareInformation
{
    [CmdletBinding( DefaultParameterSetName = "ByName", ConfirmImpact="None" )]
    param
    (
        #### -------------------- Parameter sets -------------------------------------####

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByUniqueId',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        $UniqueId,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByName',
            ValueFromPipeline = $true,
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $FriendlyName,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByInputObject',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        #### ------------------------- Common method parameters ----------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin
    {
        $SourceCaller = "Microsoft.PowerShell"
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            Write-Progress -Activity "Get-StorageFirmwareInformation" -PercentComplete 0 -CurrentOperation "Gathering objects" -Status "0/2"
        }

        ## Gather the instance objects

        switch ($psCmdlet.ParameterSetName)
        {
            "ByInputObject" { $Instances = $InputObject; break; }
            "ByUniqueId"    { $Instances = Get-PhysicalDisk -UniqueId $UniqueId -CimSession $CimSession -ErrorAction Stop; break; }
            "ByName"        { $Instances = Get-PhysicalDisk -FriendlyName $FriendlyName -CimSession $CimSession -ErrorAction Stop; break; }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $methodblock = {
            param($session, $asjob, $instances)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $errorObject = $null

            if (-not $asjob)
            {
                Write-Progress -Activity "Get-StorageFirmwareInformation" -PercentComplete 30 -CurrentOperation "Executing method" -Status "1/2"
            }

            ForEach ( $instance in $instances )
            {
                try
                {
                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $instance -MethodName GetFirmwareInformation -ErrorAction Stop

                    $progressPreference = "Continue"

                    $firmwareInformation = [pscustomobject]@{
                        PhysicalDisk          = $instance;
                        SupportsUpdate        = $output.SupportsUpdate;
                        NumberOfSlots         = $output.NumberOfSlots;
                        ActiveSlotNumber      = $output.ActiveSlotNumber;
                        SlotNumber            = $output.SlotNumber;
                        IsSlotWritable        = $output.IsSlotWritable;
                        FirmwareVersionInSlot = $output.FirmwareVersionInSlot;
                    }

                    $psCmdlet.WriteObject($firmwareInformation);
                }
                catch
                {
                    $progressPreference = "Continue"

                    $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                     -ErrorMessage $null `
                                                     -ErrorCategory $_.CategoryInfo.Category `
                                                     -Exception $_.Exception `
                                                     -TargetObject $_.TargetObject

                    $psCmdlet.WriteError($errorObject)
                }
            }

            if (-not $asjob)
            {
                Write-Progress -Activity "Get-StorageFirmwareInformation" -Completed -Status "2/2"
            }
        }

        if ($asjob)
        {
            $p = $true

            Start-Job -Name GetStorageFirmwareInformation -ScriptBlock $methodblock -ArgumentList @($CimSession, $p, $Instances)
        }
        else
        {
            &$methodblock $CimSession $p $Instances
        }
    }
}


function Update-StorageFirmware
{
    [CmdletBinding( DefaultParameterSetName = "ByName", ConfirmImpact="Medium" )]
    param
    (
        #### -------------------- Parameter sets -------------------------------------####

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByUniqueId',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        $UniqueId,

        [System.String]
        [Parameter(
            ParameterSetName  = 'ByName',
            ValueFromPipeline = $true,
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $FriendlyName,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByInputObject',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        #### ------------------------- Common method parameters ----------------------####

        [System.String]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByInputObject',
            Mandatory        = $false)]
        $ImagePath,

        [System.UInt16]
        [Parameter(
            ParameterSetName = 'ByUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByInputObject',
            Mandatory        = $false)]
        $SlotNumber,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin
    {
        $SourceCaller = "Microsoft.PowerShell"
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            Write-Progress -Activity "Update-StorageFirmware" -PercentComplete 0 -CurrentOperation "Gathering objects" -Status "0/2"
        }

        ## Gather the instance objects

        switch ($psCmdlet.ParameterSetName)
        {
            "ByInputObject" { $Instances = $InputObject; break; }
            "ByUniqueId"    { $Instances = Get-PhysicalDisk -UniqueId $UniqueId -CimSession $CimSession -ErrorAction Stop; break; }
            "ByName"        { $Instances = Get-PhysicalDisk -FriendlyName $FriendlyName -CimSession $CimSession -ErrorAction Stop; break; }
        }

        ## Populate arguments list

        $arguments = @{}

        if ($PSBoundParameters.ContainsKey("ImagePath"))
        {
            $arguments.Add("ImagePath", $ImagePath)
        }

        if ($PSBoundParameters.ContainsKey("SlotNumber"))
        {
            $arguments.Add("SlotNumber", $SlotNumber)
        }

        # Would use a closure here, but jobs are run in their own session state.
        $methodblock = {
            param($session, $asjob, $instances, $arguments)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $errorObject = $null

            if (-not $asjob)
            {
                Write-Progress -Activity "Update-StorageFirmware" -PercentComplete 30 -CurrentOperation "Executing method" -Status "1/2"
            }

            ForEach ( $instance in $instances )
            {
                try
                {
                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $instance -MethodName UpdateFirmware -Arguments $arguments -ErrorAction Stop

                    $progressPreference = "Continue"
                }
                catch
                {
                    $progressPreference = "Continue"

                    $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                     -ErrorMessage $null `
                                                     -ErrorCategory $_.CategoryInfo.Category `
                                                     -Exception $_.Exception `
                                                     -TargetObject $_.TargetObject

                    $psCmdlet.WriteError($errorObject)
                }
            }

            if (-not $asjob)
            {
                Write-Progress -Activity "Update-StorageFirmware" -Completed -Status "2/2"
            }
        }

        if ($asjob)
        {
            $p = $true

            Start-Job -Name UpdateStorageFirmware -ScriptBlock $methodblock -ArgumentList @($CimSession, $p, $Instances, $arguments)
        }
        else
        {
            &$methodblock $CimSession $p $Instances $arguments
        }
    }
}


function Get-PhysicalDiskStorageNodeView {

    [CmdletBinding()]
    param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageNode")]
        [Parameter(
            ValueFromPipeline = $true)]
        $StorageNode,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ValueFromPipeline = $true)]
        $PhysicalDisk,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        ## Gather the association objects
        $options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions

        if ($PSBoundParameters.ContainsKey("StorageNode"))
        {
            $options.SetCustomOption("InputClassName", "MSFT_StorageNode", $false)
            $options.SetCustomOption("InputObjectId", $StorageNode.ObjectId, $false)
        }
        elseif ($PSBoundParameters.ContainsKey("PhysicalDisk"))
        {
            $options.SetCustomOption("InputClassName", "MSFT_PhysicalDisk", $false)
            $options.SetCustomOption("InputObjectId", $PhysicalDisk.ObjectId, $false)
        }

        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                  "MSFT_StorageNodeToPhysicalDisk",
                                                  $options
                                                  )

        $enumerator = $results.GetEnumerator()
        $instances  = @()

        while ($enumerator.MoveNext())
        {
            $instance = $enumerator.Current

            if ($PSBoundParameters.ContainsKey("StorageNode"))
            {
                if ($instance.StorageNodeObjectId -ne $StorageNode.ObjectId)
                {
                    continue
                }
            }
            elseif ($PSBoundParameters.ContainsKey("PhysicalDisk"))
            {
                if ($instance.PhysicalDiskObjectId -ne $PhysicalDisk.ObjectId)
                {
                    continue
                }
            }

            $instances += $instance
        }

        $instances
    }
}


function Get-DiskStorageNodeView {

    [CmdletBinding()]
    param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageNode")]
        [Parameter(
            ValueFromPipeline = $true)]
        $StorageNode,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Disk")]
        [Parameter(
            ValueFromPipeline = $true)]
        $Disk,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        ## Gather the association objects
        $options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions

        if ($PSBoundParameters.ContainsKey("StorageNode"))
        {
            $options.SetCustomOption("InputClassName", "MSFT_StorageNode", $false)
            $options.SetCustomOption("InputObjectId", $StorageNode.ObjectId, $false)
        }
        elseif ($PSBoundParameters.ContainsKey("Disk"))
        {
            $options.SetCustomOption("InputClassName", "MSFT_Disk", $false)
            $options.SetCustomOption("InputObjectId", $Disk.ObjectId, $false)
        }

        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                  "MSFT_StorageNodeToDisk",
                                                  $options
                                                  )

        $enumerator = $results.GetEnumerator()
        $instances  = @()

        while ($enumerator.MoveNext())
        {
            $instance = $enumerator.Current

            if ($PSBoundParameters.ContainsKey("StorageNode"))
            {
                if ($instance.StorageNodeObjectId -ne $StorageNode.ObjectId)
                {
                    continue
                }
            }
            elseif ($PSBoundParameters.ContainsKey("Disk"))
            {
                if ($instance.DiskObjectId -ne $Disk.ObjectId)
                {
                    continue
                }
            }

            $instances += $instance
        }

        $instances
    }
}


function Get-StorageEnclosureStorageNodeView {
    [CmdletBinding()]
    param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageNode")]
        [Parameter(
            ValueFromPipeline = $true)]
        $StorageNode,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageEnclosure")]
        [Parameter(
            ValueFromPipeline = $true)]
        $StorageEnclosure,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        ## Gather the association objects
        $options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions

        if ($PSBoundParameters.ContainsKey("StorageNode"))
        {
            $options.SetCustomOption("InputClassName", "MSFT_StorageNode", $false)
            $options.SetCustomOption("InputObjectId", $StorageNode.ObjectId, $false)
        }
        elseif ($PSBoundParameters.ContainsKey("StorageEnclosure"))
        {
            $options.SetCustomOption("InputClassName", "MSFT_StorageEnclosure", $false)
            $options.SetCustomOption("InputObjectId", $StorageEnclosure.ObjectId, $false)
        }

        $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                  "MSFT_StorageNodeToStorageEnclosure",
                                                  $options
                                                  )

        $enumerator = $results.GetEnumerator()
        $instances  = @()

        while ($enumerator.MoveNext())
        {
            $instance = $enumerator.Current

            if ($PSBoundParameters.ContainsKey("StorageNode"))
            {
                if ($instance.StorageNodeObjectId -ne $StorageNode.ObjectId)
                {
                    continue
                }
            }
            elseif ($PSBoundParameters.ContainsKey("StorageEnclosure"))
            {
                if ($instance.StorageEnclosureObjectId -ne $StorageEnclosure.ObjectId)
                {
                    continue
                }
            }

            $instances += $instance
        }

        $instances
    }
}


function Get-StorageHealthAction
{
    [CmdletBinding()]
    Param
    (
        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByUniqueId")]
         $UniqueId,

        [CimInstance]
        [Parameter(
            Mandatory         = $false,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null
        $methodName = "GetActions"

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if ($UniqueId)
        {
            # Would use a closure here, but jobs are run in their own session state.
            $block = {
                param($session, $asjob, $ns, $id)

                # Start-Job serializes/deserializes the CimSession,
                # which means it shows up here as having type Deserialized.CimSession.
                # Must recreate or cast the object in order to pass it to Get-CimInstance.
                if ($asjob)
                {
                    $session = $session | New-CimSession
                }

                Get-CimInstance -CimSession $session -Query "Select * From MSFT_HealthAction Where UniqueId='$id'" -Namespace $ns

            }

            if ($asjob)
            {
                $p = $true
                Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $StorageNamespace, $UniqueId)
            }
            else
            {
                if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
                {
                    &$block $CimSession $p $StorageNamespace $UniqueId
                }
            }
        }
        elseif ($InputObject.CimClass.CimClassName -eq "MSFT_HealthAction")
        {
            # Would use a closure here, but jobs are run in their own session state.
            $block = {
                param($session, $asjob, $io)

                # Start-Job serializes/deserializes the CimSession,
                # which means it shows up here as having type Deserialized.CimSession.
                # Must recreate or cast the object in order to pass it to Get-CimInstance.
                if ($asjob)
                {
                    $session = $session | New-CimSession
                }

                $io | Get-CimInstance -CimSession $session

            }

            if ($asjob)
            {
                $p = $true
                Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $InputObject)
            }
            else
            {
                if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
                {
                    &$block $CimSession $p $InputObject
                }
            }
        }
        elseif (-not $InputObject -or ( $InputObject.CimClass.CimClassName -eq "MSFT_StorageHealth" ))
        {
            $className = "MSFT_HealthAction"
            $block = {
                param($session, $ns, $asjob, $cn)

                # Start-Job serializes/deserializes the CimSession,
                # which means it shows up here as having type Deserialized.CimSession.
                # Must recreate or cast the object in order to pass it to Get-CimInstance.
                if ($asjob)
                {
                    $session = $session | New-CimSession
                }

                Get-CimInstance -CimSession $session -Namespace $ns -ClassName $cn
            }

            if ($asjob)
            {
                $p = $true
                Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $StorageNamespace, $p, $className)
            }
            else
            {
                if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
                {
                    &$block $CimSession $StorageNamespace $p $className
                }
            }
        }
        else
        {
            # Would use a closure here, but jobs are run in their own session state.
            $block = {
                param($session, $ns, $asjob, $mn, $io)

                # Start-Job serializes/deserializes the CimSession,
                # which means it shows up here as having type Deserialized.CimSession.
                # Must recreate or cast the object in order to pass it to Get-CimInstance.
                if ($asjob)
                {
                    $session = $session | New-CimSession
                }

                $r = Invoke-CimMethod -CimSession $session -InputObject $io -MethodName $mn -Confirm:$false

                for($i = 0; $i -lt $r.Count - 1; $i++)
                {
                    $r[$i].ItemValue
                }
            }

            if ($asjob)
            {
                $p = $true
                Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $StorageNamespace, $p, $methodName, $InputObject)
            }
            else
            {
                if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
                {
                    &$block $CimSession $StorageNamespace $p $methodName $InputObject
                }
            }
        }
    }
}


function Get-StorageFaultDomain {

    [CmdletBinding( DefaultParameterSetName = "EnumerateFaultDomains" )]
    param
    (
        [StorageFaultDomainType]
        [Parameter(
            ParameterSetName = 'EnumerateFaultDomains',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageFaultDomain',
            Mandatory        = $false)]
        $Type,

        [System.String]
        [Parameter(
            ParameterSetName = 'EnumerateFaultDomains',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubsystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageFaultDomain',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $PhysicalLocation,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageSubsystem")]
        [Parameter(
            ParameterSetName  = 'ByStorageSubsystem',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StorageSubsystem,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageFaultDomain")]
        [Parameter(
            ParameterSetName  = 'ByStorageFaultDomain',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StorageFaultDomain,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    Begin
    {
        [flagsattribute()]
        Enum StorageFaultDomainType
        {
            PhysicalDisk     = 1
            StorageEnclosure = 2
            StorageScaleUnit = 3
            StorageChassis   = 4
            StorageRack      = 5
            StorageSite      = 6
        }

        $className = "MSFT_StorageFaultDomain"

        switch ($Type)
        {
            PhysicalDisk     { $className = "MSFT_PhysicalDisk" }
            StorageEnclosure { $className = "MSFT_StorageEnclosure" }
            StorageScaleUnit { $className = "MSFT_StorageScaleUnit" }
            StorageChassis   { $className = "MSFT_StorageChassis" }
            StorageRack      { $className = "MSFT_StorageRack" }
            StorageSite      { $className = "MSFT_StorageSite" }
        }
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        ## Gather the instance objects.

        $options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions

        if ($PSBoundParameters.ContainsKey("Type"))
        {
            $options.SetCustomOption("ResultObject", $className, $false)
        }

        switch ($psCmdlet.ParameterSetName)
        {
            "ByStorageSubsystem"
            {
                $results = $CimSession.EnumerateAssociatedInstances($StorageNamespace,
                                                                    $StorageSubsystem,
                                                                    "MSFT_StorageSubsystemToStorageFaultDomain",
                                                                    $className,
                                                                    "StorageSubSystem",
                                                                    "StorageFaultDomain",
                                                                    $options);
                break;
            }

            "ByStorageFaultDomain"
            {
                $results = $CimSession.EnumerateAssociatedInstances($StorageNamespace,
                                                                    $StorageFaultDomain,
                                                                    "MSFT_StorageFaultDomainToStorageFaultDomain",
                                                                    $className,
                                                                    "SourceStorageFaultDomain",
                                                                    "TargetStorageFaultDomain",
                                                                    $options);
                break;
            }

            "EnumerateFaultDomains"
            {
                $results = $CimSession.EnumerateInstances($StorageNamespace,
                                                          $className);
                break;
            }
        }

        $enumerator = $results.GetEnumerator()
        $instances  = @()

        while ($enumerator.MoveNext())
        {
            $instance = $enumerator.Current

            ## Filter by physical location if required and ensure
            ## the formatting selected is for MSFT_StorageFaultDomain

            if (($PSBoundParameters.ContainsKey("PhysicalLocation")) -and
                ($instance.PhysicalLocation -notlike $PhysicalLocation))
            {
                continue
            }

            $typename = $instance.PSObject.TypeNames.GetEnumerator()
            $index = 0;

            while ($typename.MoveNext())
            {
                if ($typename.Current.Equals("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageObject",
                                             [System.StringComparison]::OrdinalIgnoreCase) -eq $true)
                {
                    break
                }

                $index++
            }

            $instance.PSObject.TypeNames.Insert($index + 1, "Microsoft.Management.Infrastructure.CimInstance#MSFT_StorageFaultDomain")
            $instances += $instance
        }

        $instances
    }
}


function New-Volume
{
    [CmdletBinding()]
    Param(

        #### -------------------- Parameter sets -------------------------------------####

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StoragePool")]
        [Parameter(
            ParameterSetName  = "ByStoragePool",
            ValueFromPipeline = $true,
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $StoragePool,

        [String]
        [Parameter(
            ParameterSetName  = "ByStoragePoolFriendlyName",
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StoragePoolFriendlyName,

        [String]
        [Parameter(
            ParameterSetName  = "ByStoragePoolName",
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StoragePoolName,

        [String]
        [Parameter(
            ParameterSetName  = "ByStoragePoolUniqueId",
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StoragePoolUniqueId,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Disk")]
        [Parameter(
            ParameterSetName  = "ByDisk",
            ValueFromPipeline = $true,
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $Disk,

        [UInt32]
        [Parameter(
            ParameterSetName  = "ByDiskNumber",
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $DiskNumber,

        [String]
        [Parameter(
            ParameterSetName  = "ByDiskPath",
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $DiskPath,

        [String]
        [Parameter(
            ParameterSetName  = "ByDiskUniqueId",
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $DiskUniqueId,

        #### -------------------- Common method parameters ---------------------------####

        [String]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByDisk',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByDiskNumber',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByDiskPath',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByDiskUniqueId',
            Mandatory        = $true)]
        [ValidateNotNullOrEmpty()]
        $FriendlyName,

        [FileSystemType]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDisk',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskNumber',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskPath',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $FileSystem,

        [String]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDisk',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskNumber',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskPath',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $AccessPath,

        [Char]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDisk',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskNumber',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskPath',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $DriveLetter,

        [UInt32]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDisk',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskNumber',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskPath',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByDiskUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $AllocationUnitSize,

        #### -------------------- Storage pool parameters ----------------------------####

        [UInt64]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $Size,

        [String]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $ResiliencySettingName,

        [ProvisioningType]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $ProvisioningType,

        [MediaType]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $MediaType,

        [UInt16]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $PhysicalDiskRedundancy,

        [UInt16]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $NumberOfColumns,

        [UInt16]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $NumberOfGroups,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageTier")]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $StorageTiers,

        [String[]]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $StorageTierFriendlyNames,

        [UInt64[]]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $StorageTierSizes,

        [UInt64]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $WriteCacheSize,

        [UInt64]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        [ValidateNotNullOrEmpty()]
        $ReadCacheSize,

        [Switch]
        [Parameter(
            ParameterSetName = 'ByStoragePool',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStoragePoolUniqueId',
            Mandatory        = $false)]
        $UseMaximumSize  = $false,

        #### -------------------- Disk parameters ------------------------------------####


        #### -------------------- Powershell parameters ------------------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin
    {
        $SourceCaller = "Microsoft.PowerShell"

        [flagsattribute()]
        Enum FileSystemType
        {
            NTFS       = 14
            ReFS       = 15
            CSVFS_NTFS = 32768
            CSVFS_ReFS = 32769
        }

        [flagsattribute()]
        Enum ProvisioningType
        {
            Unknown = 0
            Thin    = 1
            Fixed   = 2
        }

        [flagsattribute()]
        Enum MediaType
        {
            HDD = 3
            SSD = 4
            SCM = 5
        }
    }

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            if ($PoolInstance)
            {
                Write-Progress -Activity "New-Volume" -PercentComplete 0 -CurrentOperation "Validating parameters" -Status "0/3"
            }
            elseif ($DiskInstance)
            {
                Write-Progress -Activity "New-Volume" -PercentComplete 0 -CurrentOperation "Validating parameters" -Status "0/2"
            }
        }

        ## Gather the instance object

        switch ($psCmdlet.ParameterSetName)
        {
            "ByStoragePool"             { $PoolInstance = $StoragePool; break; }
            "ByStoragePoolFriendlyName" { $PoolInstance = Get-StoragePool -FriendlyName $StoragePoolFriendlyName -CimSession $CimSession -ErrorAction Stop; break; }
            "ByStoragePoolName"         { $PoolInstance = Get-StoragePool -Name $StoragePoolName -CimSession $CimSession -ErrorAction Stop; break; }
            "ByStoragePoolUniqueId"     { $PoolInstance = Get-StoragePool -UniqueId $StoragePoolUniqueId -CimSession $CimSession -ErrorAction Stop; break; }

            "ByDisk"                    { $DiskInstance = $Disk; break; }
            "ByDiskNumber"              { $DiskInstance = Get-Disk -Number $DiskNumber -CimSession $CimSession -ErrorAction Stop; break; }
            "ByDiskPath"                { $DiskInstance = Get-Disk -Path $DiskPath -CimSession $CimSession -ErrorAction Stop; break; }
            "ByDiskUniqueId"            { $DiskInstance = Get-Disk -UniqueId $DiskUniqueId -CimSession $CimSession -ErrorAction Stop; break; }
        }

        ## Populate arguments list

        $arguments = @{}

        if ($PSBoundParameters.ContainsKey("FriendlyName"))
        {
            $arguments.Add("FriendlyName", $FriendlyName)
        }

        if ($PSBoundParameters.ContainsKey("FileSystem"))
        {
            $arguments.Add("FileSystem", [System.UInt16]$FileSystem)
        }

        if ($PSBoundParameters.ContainsKey("AccessPath") -and
            $PSBoundParameters.ContainsKey("DriveLetter"))
        {
            $errorObject = CreateErrorRecord -ErrorId "InvalidArgument" `
                                             -ErrorMessage "Use either 'AccessPath' or 'DriveLetter' parameter" `
                                             -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) `
                                             -Exception $null `
                                             -TargetObject $null

            $psCmdlet.WriteError($errorObject)
            return
        }

        if ($PSBoundParameters.ContainsKey("AccessPath"))
        {
            $arguments.Add("AccessPath", $AccessPath)
        }
        elseif ($PSBoundParameters.ContainsKey("DriveLetter"))
        {
            $arguments.Add("AccessPath", $DriveLetter + ":")
        }

        if ($PSBoundParameters.ContainsKey("AllocationUnitSize"))
        {
            $arguments.Add("AllocationUnitSize", $AllocationUnitSize)
        }

        if ($PoolInstance)
        {
            if ($PSBoundParameters.ContainsKey("Size"))
            {
                $arguments.Add("Size", $Size)
            }

            if ($PSBoundParameters.ContainsKey("ResiliencySettingName"))
            {
                $arguments.Add("ResiliencySettingName", $ResiliencySettingName)
            }

            if ($PSBoundParameters.ContainsKey("ProvisioningType"))
            {
                $arguments.Add("ProvisioningType", [System.UInt16]$ProvisioningType)
            }

            if ($PSBoundParameters.ContainsKey("MediaType"))
            {
                $arguments.Add("MediaType", [System.UInt16]$MediaType)
            }

            if ($PSBoundParameters.ContainsKey("PhysicalDiskRedundancy"))
            {
                $arguments.Add("PhysicalDiskRedundancy", $PhysicalDiskRedundancy)
            }

            if ($PSBoundParameters.ContainsKey("NumberOfColumns"))
            {
                $arguments.Add("NumberOfColumns", $NumberOfColumns)
            }

            if ($PSBoundParameters.ContainsKey("NumberOfGroups"))
            {
                $arguments.Add("NumberOfGroups", $NumberOfGroups)
            }

            if ($PSBoundParameters.ContainsKey("StorageTiers") -and
                $PSBoundParameters.ContainsKey("StorageTierFriendlyNames"))
            {
                $errorObject = CreateErrorRecord -ErrorId "InvalidArgument" `
                                                 -ErrorMessage "Use either 'StorageTiers' or 'StorageTierFriendlyNames' parameter" `
                                                 -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) `
                                                 -Exception $null `
                                                 -TargetObject $null

                $psCmdlet.WriteError($errorObject)
                return
            }

            if ($PSBoundParameters.ContainsKey("StorageTiers"))
            {
                $arguments.Add("StorageTiers", $StorageTiers)
            }
            elseif ($PSBoundParameters.ContainsKey("StorageTierFriendlyNames"))
            {
                [Microsoft.Management.Infrastructure.CimInstance[]] $tiers = @()

                $poolTiers = Get-CimAssociatedInstance -InputObject $PoolInstance -Association MSFT_StoragePoolToStorageTier -ResultClassName MSFT_StorageTier -CimSession $CimSession -ErrorAction Stop

                for ($i = 0; $i -lt $StorageTierFriendlyNames.Count; $i++)
                {
                    $found = $false

                    foreach ($tier in $poolTiers)
                    {
                        if ($tier.FriendlyName -eq $StorageTierFriendlyNames[$i])
                        {
                            $tiers += $tier
                            $found = $true
                            break
                        }
                    }

                    if ($found -eq $false)
                    {
                        $errorObject = CreateErrorRecord -ErrorId "InvalidArgument" `
                                                         -ErrorMessage "Could not find storage tier with the friendly name '"+ $StorageTierFriendlyNames[$i] + "' in the storage pool" `
                                                         -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) `
                                                         -Exception $null `
                                                         -TargetObject $null

                        $psCmdlet.WriteError($errorObject)
                        return
                    }
                }

                $arguments.Add("StorageTiers", $tiers)
            }

            if ($PSBoundParameters.ContainsKey("StorageTierSizes"))
            {
                $arguments.Add("StorageTierSizes", $StorageTierSizes)
            }

            if ($PSBoundParameters.ContainsKey("WriteCacheSize"))
            {
                $arguments.Add("WriteCacheSize", $WriteCacheSize)
            }

            if ($PSBoundParameters.ContainsKey("ReadCacheSize"))
            {
                $arguments.Add("ReadCacheSize", $ReadCacheSize)
            }

            if ($PSBoundParameters.ContainsKey("UseMaximumSize"))
            {
                $arguments.Add("UseMaximumSize", $UseMaximumSize.ToBool())
            }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $poolblock = {
            param($session, $asjob, $pool, $arguments)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $errorObject = $null
            $output      = $null
            $virtualdisk = $null
            $volume      = $null

            $subsystem = $pool | get-storagesubsystem -CimSession $session

            # If the subsystem model is "Windows Storage",
            # perform the individual steps
            if ($subsystem.Model -like "*Windows Storage*")
            {
                $volCreateParams = @{}

                if ($arguments.ContainsKey("FriendlyName"))
                {
                    $volCreateParams.Add("FriendlyName", $arguments["FriendlyName"])
                }

                if ($arguments.ContainsKey("FileSystem"))
                {
                    $volCreateParams.Add("FileSystem", $arguments["FileSystem"])
                    $arguments.Remove("FileSystem")
                }

                if ($arguments.ContainsKey("AccessPath"))
                {
                    $volCreateParams.Add("AccessPath", $arguments["AccessPath"])
                    $arguments.Remove("AccessPath")
                }

                if ($arguments.ContainsKey("AllocationUnitSize"))
                {
                    $volCreateParams.Add("AllocationUnitSize", $arguments["AllocationUnitSize"])
                    $arguments.Remove("AllocationUnitSize")
                }

                try
                {
                    if (-not $asjob)
                    {
                        Write-Progress -Activity "New-Volume" -PercentComplete 10 -CurrentOperation "Creating virtual disk" -Status "1/3"
                    }

                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $pool -MethodName CreateVirtualDisk -Arguments $arguments -ErrorAction Stop

                    $progressPreference = "Continue"

                    $virtualdisk = $output.CreatedVirtualDisk
                    $disk = $output.CreatedVirtualDisk | get-disk -CimSession $session

                    if ($disk -eq $null)
                    {
                        $errorObject = CreateErrorRecord -ErrorId "ObjectNotFound" `
                                                         -ErrorMessage "The disk associated with the virtual disk created could not be found." `
                                                         -ErrorCategory ([System.Management.Automation.ErrorCategory]::ObjectNotFound) `
                                                         -Exception $null `
                                                         -TargetObject $null

                        $psCmdlet.WriteError($errorObject)
                        return
                    }

                    if (-not $asjob)
                    {
                        Write-Progress -Activity "New-Volume" -PercentComplete 70 -CurrentOperation "Creating volume" -Status "2/3"
                    }

                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $disk -MethodName CreateVolume -Arguments $volCreateParams -ErrorAction Stop

                    $progressPreference = "Continue"

                    $volume = $output.CreatedVolume
                }
                catch
                {
                    $progressPreference = "Continue"

                    if (-not $asjob)
                    {
                        Write-Progress -Activity "New-Volume" -PercentComplete 90 -CurrentOperation "Error encountered. Checking if cleanup is required." -Status "2/3"
                    }

                    $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                     -ErrorMessage $null `
                                                     -ErrorCategory $_.CategoryInfo.Category `
                                                     -Exception $_.Exception `
                                                     -TargetObject $_.TargetObject

                    # If virtual disk was created and volume was formatted, but
                    # adding to cluster failed or the cluster resource did not
                    # come online after successful addition, do not revert.

                    if (($virtualdisk) -and
                        ($_.FullyQualifiedErrorId -notmatch "46008") -and
                        ($_.FullyQualifiedErrorId -notmatch "46011"))
                    {
                        $progressPreference = "silentlyContinue"

                        $virtualdisk | Remove-VirtualDisk -CimSession $session -Confirm:$false

                        $progressPreference = "Continue"
                    }
                }
                finally
                {
                    if (-not $asjob)
                    {
                        Write-Progress -Activity "New-Volume" -Completed -Status "3/3"
                    }
                }
            }
            # Else fallback to the API on the storage pool
            else
            {
                try
                {
                    if (-not $asjob)
                    {
                        Write-Progress -Activity "New-Volume" -PercentComplete 10 -CurrentOperation "Creating volume" -Status "1/2"
                    }

                    $progressPreference = "silentlyContinue"

                    $output = Invoke-CimMethod -CimSession $session -InputObject $pool -MethodName CreateVolume -Arguments $arguments -ErrorAction Stop

                    $progressPreference = "Continue"

                    $volume = $output.CreatedVolume
                }
                catch
                {
                    $progressPreference = "Continue"

                    $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                     -ErrorMessage $null `
                                                     -ErrorCategory $_.CategoryInfo.Category `
                                                     -Exception $_.Exception `
                                                     -TargetObject $_.TargetObject
                }
                finally
                {
                    if (-not $asjob)
                    {
                        Write-Progress -Activity "New-Volume" -Completed -Status "3/3"
                    }
                }
            }

            if ($errorObject)
            {
                $psCmdlet.WriteError($errorObject)
            }
            else
            {
                $volume
            }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $diskblock = {
            param($session, $asjob, $disk, $arguments)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $errorObject = $null
            $output      = $null
            $volume      = $null

            try
            {
                if (-not $asjob)
                {
                    Write-Progress -Activity "New-Volume" -PercentComplete 10 -CurrentOperation "Creating volume" -Status "1/2"
                }

                $progressPreference = "silentlyContinue"

                $output = Invoke-CimMethod -CimSession $session -InputObject $disk -MethodName CreateVolume -Arguments $arguments -ErrorAction Stop

                $progressPreference = "Continue"

                $volume = $output.CreatedVolume
            }
            catch
            {
                $progressPreference = "Continue"

                $errorObject = CreateErrorRecord -ErrorId $_.FullyQualifiedErrorId `
                                                 -ErrorMessage $null `
                                                 -ErrorCategory $_.CategoryInfo.Category `
                                                 -Exception $_.Exception `
                                                 -TargetObject $_.TargetObject
            }
            finally
            {
                if (-not $asjob)
                {
                    Write-Progress -Activity "New-Volume" -Completed -Status "3/3"
                }
            }

            if ($errorObject)
            {
                $psCmdlet.WriteError($errorObject)
            }
            else
            {
                $volume
            }
        }

        if ($asjob)
        {
            $p = $true

            if ($PoolInstance)
            {
                Start-Job -Name CreateVolume -ScriptBlock $poolblock -ArgumentList @($CimSession, $p, $PoolInstance, $arguments)
            }
            elseif ($DiskInstance)
            {
                Start-Job -Name CreateVolume -ScriptBlock $diskblock -ArgumentList @($CimSession, $p, $DiskInstance, $arguments)
            }
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                if ($PoolInstance)
                {
                    &$poolblock $CimSession $p $PoolInstance $arguments
                }
                elseif ($DiskInstance)
                {
                    &$diskblock $CimSession $p $DiskInstance $arguments
                }
            }
        }
    }
}


function Get-StorageAdvancedProperty {
    [CmdletBinding()]
    param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByPhysicalDisk',
            Mandatory         = $true,
            ValueFromPipeline = $true)]
        $PhysicalDisk
    )

    Process
    {
        if ( $PhysicalDisk ) {

            $isDeviceCacheEnabled = $null
            $isPowerProtected     = $null

            $deviceCacheOutput    = Invoke-CimMethod -MethodName IsDeviceCacheEnabled -InputObject $PhysicalDisk -ErrorAction SilentlyContinue
            $powerProtectedOutput = Invoke-CimMethod -MethodName IsPowerProtected     -InputObject $PhysicalDisk -ErrorAction SilentlyContinue

            # DeviceCache error handling
            if ( $deviceCacheOutput -and $deviceCacheOutput.ReturnValue -ne 0 ) {

                Write-Warning "Retrieving IsDeviceCacheEnabled failed with ErrorCode $( $deviceCacheOutput.ReturnValue )."
            }
            else {
                $isDeviceCacheEnabled = $deviceCacheOutput.IsDeviceCacheEnabled
            }

            # PowerProtected error handling
            if ( $powerProtectedOutput -and $powerProtectedOutput.ReturnValue -ne 0 ) {

                Write-Warning "Retrieving IsPowerProtected failed with ErrorCode $( $powerProtectedOutput.ReturnValue )."
            }
            else {
                $isPowerProtected = $powerProtectedOutput.IsPowerProtected
            }

            $customDrive = [pscustomobject]@{
                PhysicalDisk         = $PhysicalDisk;
                IsPowerProtected     = $isPowerProtected;
                IsDeviceCacheEnabled = $isDeviceCacheEnabled;
            }

            $customDrive.PSObject.TypeNames.Insert( 0, "Microsoft.Windows.StorageManagement.PhysicalDiskAdvancedProperties" )

            $customDrive
        }
    }
}

function Get-StorageHealthReport
{
    [CmdletBinding()]
    Param
    (
        [CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageObject")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [Int32]
        $Count = 1,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null
        $methodName = "GetReport"

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if ($InputObject.CimClass.CimClassName -ne "MSFT_StoragesubSystem" -and
            $InputObject.CimClass.CimClassName -ne "MSFT_StorageNode" -and
            $InputObject.CimClass.CimClassName -ne "MSFT_Volume" -and
            $InputObject.CimClass.CimClassName -ne "MSFT_FileShare")
        {
            $errorObject = CreateErrorRecord -ErrorId "InvalidArgument" `
                                             -ErrorMessage "The input object must be a StorageSubSystem, StorageNode, Volume or FileShare" `
                                             -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) `
                                             -Exception $null `
                                             -TargetObject $null

            $psCmdlet.WriteError($errorObject)
            return
        }

        if($InputObject.CimSystemProperties.ClassName.Equals("MSFT_FileShare"))
        {
            $InputObject = $InputObject | Get-Volume -CimSession $CimSession -ErrorAction Stop
        }

        $storageSubSystem = $InputObject | Get-StorageSubSystem -CimSession $CimSession -ErrorAction Stop

        $StorageHealth = Get-CimAssociatedInstance -ResultClassName MSFT_StorageHealth -InputObject $storageSubSystem -CimSession $CimSession -ErrorAction Stop

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $ns, $asjob, $mn, $sh, $io, $co)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            Invoke-CimMethod -CimSession $session -InputObject $sh -MethodName $mn -Arguments @{TargetObject=$io;Count=[uint32]$co} -Confirm:$false
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $StorageNamespace, $p, $methodName, $StorageHealth, $InputObject, $Count)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $StorageNamespace $p $methodName $StorageHealth $InputObject $Count
            }
        }
    }
}

function Get-StorageHealthSetting
{
    [CmdletBinding()]
    Param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageSubSystem")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [String]
        $Name,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        $StorageHealth = $InputObject | Get-StorageHealth -CimSession $CimSession -ErrorAction Stop

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $sh, $na)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                # We need to load the module or it fails with CMDLET Not Found
                import-module Storage\StorageHealth.cdxml
                $session = $session | New-CimSession
            }

            $sh | Get-StorageHealthSettingInternal -Name $na -CimSession $session
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $StorageHealth, $Name)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $StorageHealth $Name
            }
        }
    }
}

function Set-StorageHealthSetting
{
    [CmdletBinding()]
    Param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageSubSystem")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [String]
        [Parameter(
            Mandatory = $true)]
        $Name,

        [String]
        [Parameter(
            Mandatory = $true)]
        $Value,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        $StorageHealth = $InputObject | Get-StorageHealth -CimSession $CimSession -ErrorAction Stop

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $sh, $na, $va)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                # We need to load the module or it fails with CMDLET Not Found
                import-module Storage\StorageHealth.cdxml
                $session = $session | New-CimSession
            }

            $sh | Set-StorageHealthSettingInternal -Name $na -Value $va -CimSession $session
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $StorageHealth, $Name, $Value)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $StorageHealth $Name $Value
            }
        }
    }
}

function Remove-StorageHealthSetting
{
    [CmdletBinding()]
    Param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageSubSystem")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [String]
        [Parameter(
            Mandatory = $true)]
        $Name,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        $StorageHealth = $InputObject | Get-StorageHealth -CimSession $CimSession -ErrorAction Stop

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $sh, $na)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                import-module Storage\StorageHealth.cdxml
                $session = $session | New-CimSession
            }

            $sh | Remove-StorageHealthSettingInternal -Name $na -CimSession $session
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $StorageHealth, $Name)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $StorageHealth $Name
            }
        }
    }
}

function Debug-StorageSubSystem
{
    [CmdletBinding(
        DefaultParameterSetName="ByFriendlyName")]
    Param
    (
        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByFriendlyName",
            Position          = 0)]
        $StorageSubSystemFriendlyName,

        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByUniqueId")]
        $StorageSubSystemUniqueId,

        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByName")]
        $StorageSubSystemName,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageSubSystem")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "ByName"         { $InputObject = Get-StorageSubSystem -Name $StorageSubSystemName -CimSession $CimSession; break; }
            "ByUniqueId"     { $InputObject = Get-StorageSubSystem -UniqueId $StorageSubSystemUniqueId -CimSession $CimSession; break; }
            "ByFriendlyName" { $InputObject = Get-StorageSubSystem -FriendlyName $StorageSubSystemFriendlyName -CimSession $CimSession; break; }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $io)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $result = @()
            $output = Invoke-CimMethod -MethodName Diagnose -InputObject $io -CimSession $session
            foreach($i in $output){$result += $i.ItemValue}
            $result | Sort-Object -Property PerceivedSeverity
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $InputObject)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $InputObject
            }
        }
    }
}

function Debug-FileShare
{
    [CmdletBinding(DefaultParameterSetName="ByName")]

    Param
    (
        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByName",
            Position          = 0 )]
        $Name,

        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByUniqueId")]
        $UniqueId,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_FileShare")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "ByName"     { $InputObject = Get-FileShare -Name $Name -CimSession $CimSession -ErrorAction stop; break; }
            "ByUniqueId" { $InputObject = Get-FileShare -UniqueId $UniqueId -CimSession $CimSession -ErrorAction stop; break; }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $io)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $result = @()
            $output = Invoke-CimMethod -MethodName Diagnose -InputObject $io -CimSession $session
            foreach($i in $output){$result += $i.ItemValue}
            $result | Sort-Object -Property PerceivedSeverity
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $InputObject)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $InputObject
            }
        }
    }
}

function Debug-Volume
{
    [CmdletBinding(DefaultParameterSetName="ByDriveLetter")]

    Param
    (
        [char[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByDriveLetter",
            Position          = 0)]
        $DriveLetter,

        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ById")]
        $ObjectId,

        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByPaths")]
        $Path,

        [string[]]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "ByLabel")]
        $FileSystemLabel,

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_Volume")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        switch ($PsCmdlet.ParameterSetName)
        {
            "ByDriveLetter" { $io = Get-Volume -CimSession $CimSession -DriveLetter $DriveLetter -ErrorAction stop; break;}
            "ById"          { $io = Get-Volume -CimSession $CimSession -ObjectId $ObjectId -ErrorAction stop; break; }
            "ByPaths"       { $io = Get-Volume -CimSession $CimSession -Path $Path -ErrorAction stop; break;}
            "ByLabel"       { $io = Get-Volume -CimSession $CimSession -FileSystemLabel $FileSystemLabel -ErrorAction stop; break;}
        }

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $io)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $result = @()
            $output = Invoke-CimMethod -MethodName Diagnose -InputObject $io -CimSession $session
            foreach($i in $output){$result += $i.ItemValue}
            $result | Sort-Object -Property PerceivedSeverity
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $InputObject)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $InputObject
            }
        }
    }
}

function Enable-StorageMaintenanceMode
{
    [CmdletBinding()]
    Param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageFaultDomain")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
         $InputObject,

        [Switch]
        $IgnoreDetachedVirtualDisks,

        [System.Nullable[Bool]]
        $ValidateVirtualDisksHealthy,

        [String]
        $Model,

        [String]
        $Manufacturer,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        [Switch]
        $AsJob
    )

    Begin
    {
        [flagsattribute()]
        Enum ValidationFlags
        {
            None                  = 0
            VirtualDisksHealthy   = 1
        }
    }

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if ($InputObject.CimClass.CimClassName -ne "MSFT_PhysicalDisk" -and
            $InputObject.CimClass.CimClassName -ne "MSFT_StorageEnclosure" -and
            $InputObject.CimClass.CimClassName -ne "MSFT_StorageScaleUnit")
        {
            $errorObject = CreateErrorRecord -ErrorId "InvalidArgument" `
                                             -ErrorMessage "The input object must be a PhysicalDisk, StorageEnclosure or StorageScaleUnit" `
                                             -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) `
                                             -Exception $null `
                                             -TargetObject $null

            $psCmdlet.WriteError($errorObject)
            return
        }

        $arguments = @{}

        $arguments.Add("EnableMaintenanceMode", $true)
        $arguments.Add("IgnoreDetachedVirtualDisks", $IgnoreDetachedVirtualDisks.IsPresent)
        if ($InputObject.CimClass.CimClassName -ne "MSFT_PhysicalDisk")
        {
            if ($PSBoundParameters.ContainsKey("Model"))
            {
                $arguments.Add("Model", $Model)
            }

            if ($PSBoundParameters.ContainsKey("Manufacturer"))
            {
                $arguments.Add("Manufacturer", $Manufacturer)
            }
        }

        $includeValidationFlags = $false
        if ($ValidateVirtualDisksHealthy -ne $null)
        {
            $includeValidationFlags = $true
            if($ValidateVirtualDisksHealthy)
            {
                $validationFlags += [ValidationFlags]::VirtualDisksHealthy
            }
            else
            {
                $validationFlags += [ValidationFlags]::None
            }
        }

        if ($includeValidationFlags)
        {
          $arguments.Add("ValidationFlags", $validationFlags)
        }

        $storageSubSystem = $InputObject | Get-StorageSubSystem -CimSession $CimSession

        if ($storageSubSystem.Model -eq "Clustered Windows Storage")
        {
            $storageHealth = Get-CimAssociatedInstance -ResultClassName MSFT_StorageHealth -InputObject $storageSubSystem -CimSession $CimSession

            $arguments.Add("TargetObject", $InputObject)
        }
        else
        {
            if ($arguments["ValidationFlags"] -ne $null)
            {
                $errorObject = CreateErrorRecord -ErrorId "InvalidArgument" `
                                                 -ErrorMessage "The parameter 'ValidateVirtualDisksHealthy' is not supported in this subsystem. Invoke again without this parameter." `
                                                 -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) `
                                                 -Exception $null `
                                                 -TargetObject $null

                $psCmdlet.WriteError($errorObject)
                return
            }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $io, $arg, $ss, $sh)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            if ($ss.Model -eq "Clustered Windows Storage")
            {
                Invoke-CimMethod -MethodName "Maintenance" -Arguments $arg -InputObject $sh -CimSession $session | Out-Null
            }
            else
            {
                Invoke-CimMethod -MethodName "Maintenance" -Arguments $arg -InputObject $io -CimSession $session | Out-Null
            }
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $InputObject, $arguments, $storageSubSystem, $storageHealth)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $InputObject $arguments $storageSubSystem $storageHealth
            }
        }
    }
}

function Disable-StorageMaintenanceMode
{
    [CmdletBinding()]

    Param
    (
        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageFaultDomain")]
        [Parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true,
            ParameterSetName  = "InputObject")]
        $InputObject,

        [string]
        $Model,

        [string]
        $Manufacturer,

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        [Switch]
        $AsJob
    )

    Begin{}

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if ($InputObject.CimClass.CimClassName -ne "MSFT_PhysicalDisk" -and
            $InputObject.CimClass.CimClassName -ne "MSFT_StorageEnclosure" -and
            $InputObject.CimClass.CimClassName -ne "MSFT_StorageScaleUnit")
        {
            $errorObject = CreateErrorRecord -ErrorId "InvalidArgument" `
                                             -ErrorMessage "The input object must be a PhysicalDisk, StorageEnclosure or StorageScaleUnit" `
                                             -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidArgument) `
                                             -Exception $null `
                                             -TargetObject $null

            $psCmdlet.WriteError($errorObject)
            return
        }

        $arguments = @{}

        $arguments.Add("EnableMaintenanceMode", $false)

        if($InputObject.CimClass.CimClassName -ne "MSFT_PhysicalDisk")
        {
            if ($PSBoundParameters.ContainsKey("Model"))
            {
                $arguments.Add("Model", $Model)
            }

            if ($PSBoundParameters.ContainsKey("Manufacturer"))
            {
                $arguments.Add("Manufacturer", $Manufacturer)
            }
        }

        $storageSubSystem = $InputObject | Get-StorageSubSystem -CimSession $CimSession

        if ($storageSubSystem.Model -eq "Clustered Windows Storage")
        {
            $arguments.Add("TargetObject", $InputObject)

            $storageHealth = Get-CimAssociatedInstance -ResultClassName MSFT_StorageHealth -InputObject $storageSubSystem -CimSession $CimSession
        }

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $asjob, $io, $arg, $ss, $sh)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            if ($ss.Model -eq "Clustered Windows Storage")
            {
                Invoke-CimMethod -MethodName "Maintenance" -Arguments $arg -InputObject $sh -CimSession $session | Out-Null
            }
            else
            {
                Invoke-CimMethod -MethodName "Maintenance" -Arguments $arg -InputObject $io -CimSession $session | Out-Null
            }
        }

        if ($asjob)
        {
            $p = $true
            Start-Job -ScriptBlock $block -ArgumentList @($CimSession, $p, $InputObject, $arguments, $storageSubSystem, $storageHealth)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $CimSession $p $InputObject $arguments $storageSubSystem $storageHealth
            }
        }
    }
}


function Get-StorageDiagnosticInfo
{
    [CmdletBinding()]
    Param(

        #### -------------------- Parameter sets -------------------------------------####

        [Microsoft.Management.Infrastructure.CimInstance]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_StorageSubSystem")]
        [Parameter(
            ParameterSetName  = "ByStorageSubSystem",
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [String]
        [Parameter(
            ParameterSetName  = "ByStorageSubSystemFriendlyName",
            Mandatory         = $true,
            Position          = 0)]
        [ValidateNotNullOrEmpty()]
        $StorageSubSystemFriendlyName,

        [String]
        [Parameter(
            ParameterSetName  = "ByStorageSubSystemName",
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $StorageSubSystemName,

        [String]
        [Parameter(
            ParameterSetName  = "ByStorageSubSystemUniqueId",
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("StorageSubSystemId")]
        $StorageSubSystemUniqueId,

        #### -------------------- Method parameters ----------------------------------####

        [String]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystem',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemFriendlyName',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemName',
            Mandatory        = $true)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemUniqueId',
            Mandatory        = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Path")]
        $DestinationPath,

        [UInt32]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemUniqueId',
            Mandatory        = $false)]
        $TimeSpan,

        [String]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemUniqueId',
            Mandatory        = $false)]
        $ActivityId,

        [System.Management.Automation.SwitchParameter]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemUniqueId',
            Mandatory        = $false)]
        $ExcludeOperationalLog = $false,

        [System.Management.Automation.SwitchParameter]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemUniqueId',
            Mandatory        = $false)]
        $ExcludeDiagnosticLog = $false,

        [System.Management.Automation.SwitchParameter]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystem',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemFriendlyName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemName',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByStorageSubSystemUniqueId',
            Mandatory        = $false)]
        $IncludeLiveDump = $false,

        #### -------------------- Powershell parameters ------------------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Process
    {
        $info = $resources.info
        $p = $null

        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            Write-Progress -Activity "Get-StorageDiagnosticInfo" -Id 0 -PercentComplete 0 -CurrentOperation "Validating parameters" -Status "0/3"
        }

        ## Gather the instance object

        switch ($psCmdlet.ParameterSetName)
        {
            "ByStorageSubSystem"             { $SubsystemInstance = $InputObject; break; }
            "ByStorageSubSystemFriendlyName" { $SubsystemInstance = Get-StorageSubsystem -FriendlyName $StorageSubSystemFriendlyName -CimSession $CimSession -ErrorAction Stop; break; }
            "ByStorageSubSystemName"         { $SubsystemInstance = Get-StorageSubsystem -Name $StorageSubSystemName -CimSession $CimSession -ErrorAction Stop; break; }
            "ByStorageSubSystemUniqueId"     { $SubsystemInstance = Get-StorageSubsystem -UniqueId $StorageSubSystemUniqueId -CimSession $CimSession -ErrorAction Stop; break; }
        }

        # Would use a closure here, but jobs are run in their own session state.
        $methodblock = {
            param($session, $asjob, $uniqueId, $arguments)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                # We need to load the module or it fails with CMDLET Not Found
                import-module Storage\StorageSubSystem.cdxml

                $session = $session | New-CimSession
            }

            ############################################################################################
            ##
            ## Gather storage diagnostic logs
            ##
            ############################################################################################

            $parameters = @{}

            $parameters.Add("CimSession", $session )
            $parameters.Add("StorageSubSystemUniqueId", $uniqueId )
            $parameters.Add("DestinationPath", $arguments["DestinationPath"] )

            if ($arguments.ContainsKey("TimeSpan"))
            {
                $parameters.Add("TimeSpan", $arguments["TimeSpan"])
            }

            if ($arguments.ContainsKey("ActivityId"))
            {
                $parameters.Add("ActivityId", $arguments["ActivityId"])
            }

            if ($arguments.ContainsKey("ExcludeOperationalLog"))
            {
                $parameters.Add("ExcludeOperationalLog", $arguments["ExcludeOperationalLog"])
            }

            if ($arguments.ContainsKey("ExcludeDiagnosticLog"))
            {
                $parameters.Add("ExcludeDiagnosticLog", $arguments["ExcludeDiagnosticLog"])
            }

            if ($arguments.ContainsKey("IncludeLiveDump"))
            {
                $parameters.Add("IncludeLiveDump", $arguments["IncludeLiveDump"])
            }

            if (-not $asjob)
            {
                Write-Progress -Activity "Get-StorageDiagnosticInfo" -Id 0 -PercentComplete 10 -CurrentOperation "Gathering storage diagnostic logs" -Status "1/3"
            }

            Get-StorageDiagnosticInfoInternal @parameters

            ############################################################################################
            ##
            ## Gather storage objects
            ##
            ############################################################################################

            if (-not $asjob)
            {
                Write-Progress -Activity "Get-StorageDiagnosticInfo" -Id 0 -PercentComplete 60 -CurrentOperation "Gathering storage objects. This may take time depending on the information being gathered." -Status "2/3"
            }

            $globalDatabaseObject = New-Object -TypeName PsObject

            $subsystem = Get-StorageSubsystem -UniqueId $uniqueId -CimSession $CimSession -ErrorAction Stop
            $globalDatabaseObject | Add-Member -NotePropertyName 'Subsystem' -NotePropertyValue $subsystem

            ##
            ## Enumerations via Storage Subsystem
            ##

            $subsystemAssociatedClasses = @{'MSFT_Disk'             = 'MSFT_StorageSubSystemToDisk'; `
                                            'MSFT_FileServer'       = 'MSFT_StorageSubSystemToFileServer'; `
                                            'MSFT_FileShare'        = 'MSFT_StorageSubSystemToFileShare'; `
                                            'MSFT_Partition'        = 'MSFT_StorageSubSystemToPartition'; `
                                            'MSFT_PhysicalDisk'     = 'MSFT_StorageSubSystemToStorageFaultDomain'; `
                                            'MSFT_StorageChassis'   = 'MSFT_StorageSubSystemToStorageFaultDomain'; `
                                            'MSFT_StorageEnclosure' = 'MSFT_StorageSubSystemToStorageFaultDomain'; `
                                            'MSFT_StorageNode'      = 'MSFT_StorageSubSystemToStorageNode'; `
                                            'MSFT_StoragePool'      = 'MSFT_StorageSubSystemToStoragePool'; `
                                            'MSFT_StorageRack'      = 'MSFT_StorageSubSystemToStorageFaultDomain'; `
                                            'MSFT_StorageScaleUnit' = 'MSFT_StorageSubSystemToStorageFaultDomain'; `
                                            'MSFT_StorageSite'      = 'MSFT_StorageSubSystemToStorageFaultDomain'; `
                                            'MSFT_VirtualDisk'      = 'MSFT_StorageSubSystemToVirtualDisk'; `
                                            'MSFT_Volume'           = 'MSFT_StorageSubSystemToVolume' `
                                            }

            ForEach ($class in $subsystemAssociatedClasses.Keys)
            {
                if (-not $asjob)
                {
                    Write-Progress -Activity "Gathering storage objects of type $class" -Id 1 -ParentId 0
                }

                $objectTable = @{}

                $objects = Get-CimAssociatedInstance -InputObject $subsystem -Association $subsystemAssociatedClasses[$class] -ResultClassName $class -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $objectTable.Add($object.ObjectId, $object)
                }

                $propertyName = $class.Replace('MSFT_','') + 'Table'
                $globalDatabaseObject | Add-Member -NotePropertyName $propertyName -NotePropertyValue $objectTable
            }

            ##
            ## Storage node views for Disk, Physical Disk and Storage Enclosure
            ##

            $storagenodeViewTypes = @{'Disk'             = 'Get-DiskStorageNodeView'; `
                                      'PhysicalDisk'     = 'Get-PhysicalDiskStorageNodeView'; `
                                      'StorageEnclosure' = 'Get-StorageEnclosureStorageNodeView' `
                                      }

            ForEach ($type in $storagenodeViewTypes.Keys)
            {
                if (-not $asjob)
                {
                    Write-Progress -Activity "Gathering $type storage node view objects" -Id 1 -ParentId 0
                }

                $nodeViewTable = @{}

                $propertyName = $type + 'Table'

                ForEach ($instance in $globalDatabaseObject.$propertyName.Values)
                {
                    $objects = $instance | &$storagenodeViewTypes[$type] -CimSession $CimSession
                    $nodeViewTable.Add($instance.ObjectId, $objects)
                }

                $propertyName = $type + 'StorageNodeViewTable'
                $globalDatabaseObject | Add-Member -NotePropertyName $propertyName -NotePropertyValue $nodeViewTable
            }

            ##
            ## Associated storage nodes for Storage Pool, Virtual Disk and Volume
            ##

            $associatedStorageNodeTypes = @{'StoragePool' = 'MSFT_StorageNodeToStoragePool'; `
                                            'VirtualDisk' = 'MSFT_StorageNodeToVirtualDisk'; `
                                            'Volume'      = 'MSFT_StorageNodeToVolume' `
                                            }

            ForEach ($type in $associatedStorageNodeTypes.Keys)
            {
                if (-not $asjob)
                {
                    Write-Progress -Activity "Gathering $type associated storage node objects" -Id 1 -ParentId 0
                }

                $associatedNodeTable = @{}

                $propertyName = $type + 'Table'

                ForEach ($instance in $globalDatabaseObject.$propertyName.Values)
                {
                    $associatedNodeList = @()

                    $objects = Get-CimAssociatedInstance -InputObject $instance -Association $storagenodeViewTypes[$type] -ResultClassName 'MSFT_StorageNode' -CimSession $CimSession -ErrorAction Ignore

                    ForEach ($object in $objects)
                    {
                        $associatedNodeList += $object.ObjectId
                    }

                    $associatedNodeTable.Add($instance.ObjectId, $associatedNodeList)
                }

                $propertyName = $type + 'AssociatedStorageNodeList'
                $globalDatabaseObject | Add-Member -NotePropertyName $propertyName -NotePropertyValue $associatedNodeTable
            }

            ##
            ## Physical disk associated objects - Storage Fault Domain, Storage Reliability Counter
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Gathering Physical Disk associated objects" -Id 1 -ParentId 0
            }

            $physicaldiskTable = @{}

            ForEach ($physicaldisk in $globalDatabaseObject.PhysicalDiskTable.Values)
            {
                $associatedObject = New-Object -TypeName PsObject

                $objects = Get-StorageFaultDomain -StorageFaultDomain $physicaldisk -CimSession $CimSession

                ForEach ($object in $objects)
                {
                    $type = $object.PSObject.TypeNames[0]
                    $type = $type.SubString($type.LastIndexOf('MSFT_'))
                    $type = $type.Replace('MSFT_','')
                    $associatedObject | Add-Member -NotePropertyName $type -NotePropertyValue $object.ObjectId
                }

                $object = Get-CimAssociatedInstance -InputObject $physicaldisk -Association 'MSFT_PhysicalDiskToStorageReliabilityCounter' -ResultClassName 'MSFT_StorageReliabilityCounter' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'StorageReliabilityCounter' -NotePropertyValue $object

                $physicaldiskTable.Add($physicaldisk.ObjectId, $associatedObject)
            }

            $globalDatabaseObject | Add-Member -NotePropertyName 'PhysicalDiskAssociationTable' -NotePropertyValue $physicaldiskTable

            ##
            ## Storage pool associated objects - Physical Disk, Virtual Disk, Resiliency Setting, Storage Tier, Storage Job
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Gathering Storage Pool associated objects" -Id 1 -ParentId 0
            }

            $storagepoolTable = @{}

            ForEach ($storagepool in $globalDatabaseObject.StoragePoolTable.Values)
            {
                $associatedObject = New-Object -TypeName PsObject

                $physicaldiskList = @()

                $objects = Get-CimAssociatedInstance -InputObject $storagepool -Association 'MSFT_StoragePoolToPhysicalDisk' -ResultClassName 'MSFT_PhysicalDisk' -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $physicaldiskList += $object.ObjectId
                }

                $associatedObject | Add-Member -NotePropertyName 'PhysicalDiskList' -NotePropertyValue $physicaldiskList

                $virtualdiskList = @()

                $objects = Get-CimAssociatedInstance -InputObject $storagepool -Association 'MSFT_StoragePoolToVirtualDisk' -ResultClassName 'MSFT_VirtualDisk' -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $virtualdiskList += $object.ObjectId
                }

                $associatedObject | Add-Member -NotePropertyName 'VirtualDiskList' -NotePropertyValue $virtualdiskList

                $objects = Get-CimAssociatedInstance -InputObject $storagepool -Association 'MSFT_StoragePoolToResiliencySetting' -ResultClassName 'MSFT_ResiliencySetting' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'ResiliencySetting' -NotePropertyValue $objects

                $objects = Get-CimAssociatedInstance -InputObject $storagepool -Association 'MSFT_StoragePoolToStorageTier' -ResultClassName 'MSFT_StorageTier' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'StorageTier' -NotePropertyValue $objects

                $objects = Get-CimAssociatedInstance -InputObject $storagepool -Association 'MSFT_StorageJobToAffectedStorageObject' -ResultClassName 'MSFT_StorageJob' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'StorageJob' -NotePropertyValue $objects

                $storagepoolTable.Add($storagepool.ObjectId, $associatedObject)
            }

            $globalDatabaseObject | Add-Member -NotePropertyName 'StoragePoolAssociationTable' -NotePropertyValue $storagepoolTable

            ##
            ## Virtual disk associated objects - Physical Disk, Disk, Storage Tier, Storage Job
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Gathering Virtual Disk associated objects" -Id 1 -ParentId 0
            }

            $virtualdiskTable = @{}

            ForEach ($virtualdisk in $globalDatabaseObject.VirtualDiskTable.Values)
            {
                $associatedObject = New-Object -TypeName PsObject

                $physicaldiskList = @()

                $objects = Get-CimAssociatedInstance -InputObject $virtualdisk -Association 'MSFT_VirtualDiskToPhysicalDisk' -ResultClassName 'MSFT_PhysicalDisk' -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $physicaldiskList += $object.ObjectId
                }

                $associatedObject | Add-Member -NotePropertyName 'PhysicalDiskList' -NotePropertyValue $physicaldiskList

                $object = Get-CimAssociatedInstance -InputObject $virtualdisk -Association 'MSFT_VirtualDiskToDisk' -ResultClassName 'MSFT_Disk' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'Disk' -NotePropertyValue $object.ObjectId

                $objects = Get-CimAssociatedInstance -InputObject $virtualdisk -Association 'MSFT_VirtualDiskToStorageTier' -ResultClassName 'MSFT_StorageTier' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'StorageTier' -NotePropertyValue $objects

                $objects = Get-CimAssociatedInstance -InputObject $virtualdisk -Association 'MSFT_StorageJobToAffectedStorageObject' -ResultClassName 'MSFT_StorageJob' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'StorageJob' -NotePropertyValue $objects

                $virtualdiskTable.Add($virtualdisk.ObjectId, $associatedObject)
            }

            $globalDatabaseObject | Add-Member -NotePropertyName 'VirtualDiskAssociationTable' -NotePropertyValue $virtualdiskTable

            ##
            ## Disk associated objects - Partition
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Gathering Disk associated objects" -Id 1 -ParentId 0
            }

            $diskTable = @{}

            ForEach ($disk in $globalDatabaseObject.DiskTable.Values)
            {
                $associatedObject = New-Object -TypeName PsObject

                $partitionList = @()

                $objects = Get-CimAssociatedInstance -InputObject $disk -Association 'MSFT_DiskToPartition' -ResultClassName 'MSFT_Partition' -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $partitionList += $object.ObjectId
                }

                $associatedObject | Add-Member -NotePropertyName 'PartitionList' -NotePropertyValue $partitionList

                $objects = Get-CimAssociatedInstance -InputObject $disk -Association 'MSFT_DiskToStorageReliabilityCounter' -ResultClassName 'MSFT_StorageReliabilityCounter' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'StorageReliabilityCounter' -NotePropertyValue $objects

                $diskTable.Add($disk.ObjectId, $associatedObject)
            }

            $globalDatabaseObject | Add-Member -NotePropertyName 'DiskAssociationTable' -NotePropertyValue $diskTable

            ##
            ## Partition associated objects - Volume
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Gathering Partition associated objects" -Id 1 -ParentId 0
            }

            $partitionTable = @{}

            ForEach ($partition in $globalDatabaseObject.PartitionTable.Values)
            {
                $associatedObject = New-Object -TypeName PsObject

                $object = Get-CimAssociatedInstance -InputObject $partition -Association 'MSFT_PartitionToVolume' -ResultClassName 'MSFT_Volume' -CimSession $CimSession -ErrorAction Ignore
                $associatedObject | Add-Member -NotePropertyName 'Volume' -NotePropertyValue $object.ObjectId

                $partitionTable.Add($partition.ObjectId, $associatedObject)
            }

            $globalDatabaseObject | Add-Member -NotePropertyName 'PartitionAssociationTable' -NotePropertyValue $partitionTable

            ##
            ## Volume associated objects - File share
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Gathering Volume associated objects" -Id 1 -ParentId 0
            }

            $volumeTable = @{}

            ForEach ($volume in $globalDatabaseObject.VolumeTable.Values)
            {
                $associatedObject = New-Object -TypeName PsObject

                $fileshareList = @()

                $objects = Get-CimAssociatedInstance -InputObject $volume -Association 'MSFT_VolumeToFileShare' -ResultClassName 'MSFT_FileShare' -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $fileshareList += $object.ObjectId
                }

                $associatedObject | Add-Member -NotePropertyName 'FileShareList' -NotePropertyValue $fileshareList

                $volumeTable.Add($volume.ObjectId, $associatedObject)
            }

            $globalDatabaseObject | Add-Member -NotePropertyName 'VolumeAssociationTable' -NotePropertyValue $volumeTable

            ##
            ## File Server associated objects - File share, Volume
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Gathering File Server associated objects" -Id 1 -ParentId 0
            }

            $fileserverTable = @{}

            ForEach ($fileserver in $globalDatabaseObject.FileServerTable.Values)
            {
                $associatedObject = New-Object -TypeName PsObject

                $fileshareList = @()

                $objects = Get-CimAssociatedInstance -InputObject $fileserver -Association 'MSFT_FileServerToFileShare' -ResultClassName 'MSFT_FileShare' -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $fileshareList += $object.ObjectId
                }

                $associatedObject | Add-Member -NotePropertyName 'FileShareList' -NotePropertyValue $fileshareList

                $associatedObject = New-Object -TypeName PsObject

                $volumeList = @()

                $objects = Get-CimAssociatedInstance -InputObject $fileserver -Association 'MSFT_FileServerToVolume' -ResultClassName 'MSFT_Volume' -CimSession $CimSession -ErrorAction Ignore

                ForEach ($object in $objects)
                {
                    $volumeList += $object.ObjectId
                }

                $associatedObject | Add-Member -NotePropertyName 'VolumeList' -NotePropertyValue $volumeList

                $fileserverTable.Add($fileserver.ObjectId, $associatedObject)
            }

            ##
            ## Cluster device information
            ##

            if ( $subsystem.Model -eq 'Clustered Windows Storage' )
            {
                $clusterType = @('ClusPortDeviceInformation', `
                                 'ClusBfltDeviceInformation' `
                                 )

                ForEach ($type in $clusterType)
                {
                    if (-not $asjob)
                    {
                        Write-Progress -Activity "Gathering cluster objects of type $type" -Id 1 -ParentId 0
                    }

                    $nodeTable = @{}

                    $propertyName = $type + 'Table'

                    ForEach ($instance in $globalDatabaseObject.StorageNodeTable.Values)
                    {
                        $objects = Get-CimInstance -Namespace $WmiNamespace -ClassName $type -ComputerName $instance.Name -ErrorAction Ignore
                        $nodeTable.Add($instance.Name, $objects)
                    }

                    $propertyName = $type + 'Table'
                    $globalDatabaseObject | Add-Member -NotePropertyName $propertyName -NotePropertyValue $nodeTable
                }
            }

            ##
            ## Write to xml database file
            ##

            if (-not $asjob)
            {
                Write-Progress -Activity "Get-StorageDiagnosticInfo" -Id 0 -PercentComplete 95 -CurrentOperation "Saving storage objects" -Status "3/3"
            }

            $databaseFilePath = $arguments["DestinationPath"] +'\StorageObjects.xml'
            $globalDatabaseObject | Export-Clixml -Depth 999 -Path $databaseFilePath

            if (-not $asjob)
            {
                Write-Progress -Activity "Get-StorageDiagnosticInfo" -Completed -Status "3/3"
            }
        }

        if ($asjob)
        {
            $p = $true

            Start-Job -Name GetDiagnosticInfo `
                      -ScriptBlock $methodblock `
                      -ArgumentList @($CimSession, $p, $SubsystemInstance.UniqueId, $PSBoundParameters)
        }
        else
        {
            &$methodblock $CimSession $p $SubsystemInstance.UniqueId $PSBoundParameters
        }
    }
}

New-Alias Get-PhysicalDiskSNV Get-PhysicalDiskStorageNodeView
New-Alias Get-DiskSNV Get-DiskStorageNodeView
New-Alias Get-StorageEnclosureSNV Get-StorageEnclosureStorageNodeView

Export-ModuleMember -Alias * -Function *
