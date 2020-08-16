function Get-BCDDebugSettings {
<#
.SYNOPSIS

Retrieves global kernel/boot debugger settings.

.DESCRIPTION

Get-BCDDebugSettings retrieves global kernel/boot debugger settings.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER BCDStore

Specifies the BCDStore object returned from the Get-BCDStore function. If -BCDStore is not specified, the system BCD store will be used.

.EXAMPLE

Get-BCDDebugSettings

Retrieves kernel/boot debug settings locally.

.EXAMPLE

Get-BCDDebugSettings -BCDStore $BCDStore

Retrieves kernel/boot debug settings remotely.

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore

Accepts a single BCD store element from the pipeline.

.OUTPUTS

BCD.DbgSettings

Outputs and object representing global debugger settings as well as the BCD object where kernel/boot debugging is enabled/disabled.
#>

    [CmdletBinding(DefaultParameterSetName)]
    param (
        [Parameter(ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore = (Get-BCDStore)
    )

    $PSComputerName=$BCDStore.PSComputerName

    $DbgSettingsObject = Get-BCDObject -BCDStore $BCDStore -WellKnownId DbgSettings

    $DebugType  = $null
    $DebugPort  = $null
    $BaudRate   = $null
    $Key        = $null
    $HostIP     = $null
    $Port       = $null
    $DHCP       = $null
    $Channel    = $null
    $TargetName = $null
    $BusParams  = $null
    $NoUMEx     = $null
    $DebugStart = $null

    $DebugTypeValue  = Get-BCDElement -BCDObject $DbgSettingsObject -Name DebugType
    $DebugPortValue  = Get-BCDElement -BCDObject $DbgSettingsObject -Name DebugPort
    $BaudRateValue   = Get-BCDElement -BCDObject $DbgSettingsObject -Name BaudRate
    $KeyValue        = Get-BCDElement -BCDObject $DbgSettingsObject -Name Key
    $HostIPValue     = Get-BCDElement -BCDObject $DbgSettingsObject -Name HostIP
    $PortValue       = Get-BCDElement -BCDObject $DbgSettingsObject -Name Port
    $DHCPValue       = Get-BCDElement -BCDObject $DbgSettingsObject -Name DHCP
    $ChannelValue    = Get-BCDElement -BCDObject $DbgSettingsObject -Name Channel
    $TargetNameValue = Get-BCDElement -BCDObject $DbgSettingsObject -Name TargetName
    $BusParamsValue  = Get-BCDElement -BCDObject $DbgSettingsObject -Name BusParams
    $NoUMExValue     = Get-BCDElement -BCDObject $DbgSettingsObject -Name NoUMEx
    $DebugStartValue = Get-BCDElement -BCDObject $DbgSettingsObject -Name DebugStart

    if ($DebugTypeValue) {
        $DebugType = @{
            0 = 'Serial'
            1 = '1394'
            2 = 'USB'
            3 = 'Net'
            4 = 'Local'
        }[[Int]$DebugTypeValue.Integer]
    }

    if ($DebugPortValue) { $DebugPort = $DebugPortValue.Integer }
    if ($BaudRateValue) { $BaudRate = $BaudRateValue.Integer }
    if ($KeyValue) { $Key = $KeyValue.String }
    if ($PortValue) { $Port = $PortValue.Integer }
    if ($DHCPValue) { $DHCP = $DHCPValue.Boolean }
    if ($ChannelValue) { $Channel = $ChannelValue.Integer }
    if ($TargetNameValue) { $TargetName = $TargetNameValue.String }
    if ($BusParamsValue) { $BusParams = $BusParamsValue.String }
    if ($NoUMExValue) { $NoUMEx = $NoUMExValue.Boolean }

    if ($HostIPValue) {
        # Only accounting for IPv4. I'm not sure if IPv6 debugging is possible.
        $HostIPBytes = [BitConverter]::GetBytes([UInt32] $HostIPValue.Integer)
        [Array]::Reverse($HostIPBytes)
        $HostIP = ([Net.IPAddress] $HostIPBytes).IPAddressToString
    }

    if ($DebugStartValue) {
        $DebugStart = @{
            0 = 'Active'
            1 = 'AutoEnable'
            2 = 'Disable'
        }[[Int]$DebugStartValue.Integer]
    }

    $KernelDebuggerSet = Get-BCDObject -BCDStore $BCDStore | Get-BCDElement -Name KernelDebuggerEnabled
    $BootDebugSet = Get-BCDObject -BCDStore $BCDStore | Get-BCDElement -Name BootDebug

    $KernelDebuggerEnabledObjects = $KernelDebuggerSet | Where-Object { $_.Boolean } | Select-Object -ExpandProperty ObjectId
    $KernelDebuggerDisabledObjects = $KernelDebuggerSet | Where-Object { -not $_.Boolean } | Select-Object -ExpandProperty ObjectId
    $BootDebugEnabledObjects = $BootDebugSet | Where-Object { $_.Boolean } | Select-Object -ExpandProperty ObjectId
    $BootDebugDisabledObjects = $BootDebugSet | Where-Object { -not $_.Boolean } | Select-Object -ExpandProperty ObjectId

    $DbgSettingsProperties = [Ordered] @{
        PSTypeName = 'BCD.DbgSettings'
        KernelDebuggerEnabled = $KernelDebuggerEnabledObjects
        KernelDebuggerDisabled = $KernelDebuggerDisabledObjects
        BootDebugEnabled = $BootDebugEnabledObjects
        BootDebugDisabled = $BootDebugDisabledObjects
        DebugType = $DebugType
        SerialDebugPort = $DebugPort
        SerialBaudRate = $BaudRate
        NetKey = $Key
        NetHostIP = $HostIP
        NetPort = $Port
        NetDHCP = $DHCP
        '1394Channel' = $Channel
        USBTargetName = $TargetName
        BusParams = $BusParams
        NoUserModeExceptions = $NoUMEx
        DebugStart = $DebugStart
    }

    if ($PSComputerName) { $DbgSettingsProperties['PSComputerName'] = $PSComputerName }

    New-Object -TypeName PSObject -Property $DbgSettingsProperties
}

function Remove-BCDDebugSettings {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDStore.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDStore.GetCimSessionInstanceId() }

    $BCDStoreToUse = $null

    if ($BCDStore) {
        $BCDStoreToUse = $BCDStore
    } else {
        # Use the system BCD store.
        $BCDStoreToUse = Get-BCDStore @CimMethodArgs
    }

    $DbgSettingsObject = Get-BCDObject -BCDStore $BCDStoreToUse -WellKnownId DbgSettings

    $DebugTypeValue  = Get-BCDElement -BCDObject $DbgSettingsObject -Name DebugType
    $DebugPortValue  = Get-BCDElement -BCDObject $DbgSettingsObject -Name DebugPort
    $BaudRateValue   = Get-BCDElement -BCDObject $DbgSettingsObject -Name BaudRate
    $KeyValue        = Get-BCDElement -BCDObject $DbgSettingsObject -Name Key
    $HostIPValue     = Get-BCDElement -BCDObject $DbgSettingsObject -Name HostIP
    $PortValue       = Get-BCDElement -BCDObject $DbgSettingsObject -Name Port
    $DHCPValue       = Get-BCDElement -BCDObject $DbgSettingsObject -Name DHCP
    $ChannelValue    = Get-BCDElement -BCDObject $DbgSettingsObject -Name Channel
    $TargetNameValue = Get-BCDElement -BCDObject $DbgSettingsObject -Name TargetName
    $BusParamsValue  = Get-BCDElement -BCDObject $DbgSettingsObject -Name BusParams
    $NoUMExValue     = Get-BCDElement -BCDObject $DbgSettingsObject -Name NoUMEx
    $DebugStartValue = Get-BCDElement -BCDObject $DbgSettingsObject -Name DebugStart

    if ($DebugTypeValue)  { Remove-BCDElement -BCDElement $DebugTypeValue }
    if ($DebugPortValue)  { Remove-BCDElement -BCDElement $DebugPortValue }
    if ($BaudRateValue)   { Remove-BCDElement -BCDElement $BaudRateValue }
    if ($KeyValue)        { Remove-BCDElement -BCDElement $KeyValue }
    if ($PortValue)       { Remove-BCDElement -BCDElement $PortValue }
    if ($DHCPValue)       { Remove-BCDElement -BCDElement $DHCPValue }
    if ($ChannelValue)    { Remove-BCDElement -BCDElement $ChannelValue }
    if ($TargetNameValue) { Remove-BCDElement -BCDElement $TargetNameValue }
    if ($BusParamsValue)  { Remove-BCDElement -BCDElement $BusParamsValue }
    if ($NoUMExValue)     { Remove-BCDElement -BCDElement $NoUMExValue }
    if ($HostIPValue)     { Remove-BCDElement -BCDElement $HostIPValue }
    if ($DebugStartValue) { Remove-BCDElement -BCDElement $DebugStartValue }
}


function Set-BCDDebugSettings {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Local')]
        [Switch]
        $Local,

        [Parameter(ParameterSetName = 'Net')]
        [String]
        [ValidatePattern('^[a-z0-9]{1,13}\.[a-z0-9]{1,13}\.[a-z0-9]{1,13}\.[a-z0-9]{1,13}$')]
        $Key,

        [Parameter(Mandatory, ParameterSetName = 'Net')]
        [Net.IPAddress]
        $HostIP,

        [Parameter(Mandatory, ParameterSetName = 'Net')]
        [UInt16]
        $Port,

        [Parameter(Mandatory, ParameterSetName = 'Serial')]
        [UInt32]
        $DebugPort,

        [Parameter(Mandatory, ParameterSetName = 'Serial')]
        [UInt32]
        $BaudRate,

        [Parameter(Mandatory, ParameterSetName = '1394')]
        [UInt32]
        $Channel,

        [Parameter(Mandatory, ParameterSetName = 'USB')]
        [String]
        [ValidateNotNullOrEmpty()]
        $TargetName,

        [String]
        [ValidateNotNullOrEmpty()]
        $BusParams,

        [Switch]
        $NoUserModeExceptions,

        [String]
        [ValidateSet('Active', 'AutoEnable', 'Disable')]
        $DebugStart,

        [Parameter(ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore,

        [Switch]
        $PassThru
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDStore.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDStore.GetCimSessionInstanceId() }

    $BCDStoreToUse = $null

    if ($BCDStore) {
        $BCDStoreToUse = $BCDStore
    } else {
        # Use the system BCD store.
        $BCDStoreToUse = Get-BCDStore @CimMethodArgs
    }

    # First remove all dbgsettings elements - this is what bcdedit.exe does.
    Remove-BCDDebugSettings -BCDStore $BCDStoreToUse

    $DbgSettingsObject = Get-BCDObject -BCDStore $BCDStoreToUse -WellKnownId DbgSettings

    if ($DebugTypeValue) {
        $DebugType = @{
            0 = 'Serial'
            1 = '1394'
            2 = 'USB'
            3 = 'Net'
            4 = 'Local'
        }[[Int]$DebugTypeValue.Integer]
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Local' {
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name DebugType -Integer 4
        }

        'Net' {
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name DebugType -Integer 3
            
            if ($Key) {
                $NewKey = $Key
            } else {
                # Derive a random key like how bcdedit.exe does
                $NewKey = (1..4 | ForEach-Object { (1..13 | ForEach-Object { $KeyChars[(Get-Random -Minimum 0 -Maximum $KeyChars.Length)] }) -join '' }) -join '.'
            }

            $HostIPBytes = $HostIP.GetAddressBytes()

            [Array]::Reverse($HostIPBytes)

            $HostIPInteger = [BitConverter]::ToUInt32($HostIPBytes, 0)

            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name Key -String $NewKey
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name HostIP -Integer $HostIPInteger
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name Port -Integer $Port
        }

        'Serial' {
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name DebugType -Integer 0
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name DebugPort -Integer $DebugPort
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name BaudRate -Integer $BaudRate
        }

        '1394' {
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name DebugType -Integer 1
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name Channel -Integer $Channel
        }

        'USB' {
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name DebugType -Integer 2
            $null = New-BCDElement -BCDObject $DbgSettingsObject -Name TargetName -String $TargetName
        }
    }

    if ($BusParams)            { $null = New-BCDElement -BCDObject $DbgSettingsObject -Name BusParams -String $BusParams }
    if ($NoUserModeExceptions) { $null = New-BCDElement -BCDObject $DbgSettingsObject -Name NoUMEx -Boolean $True }
    if ($DebugStart)           {
        $DebugStartValue = @{
            Active     = [UInt32] 0
            AutoEnable = [UInt32] 1
            Disable    = [UInt32] 2
        }[$DebugStart]

        $null = New-BCDElement -BCDObject $DbgSettingsObject -Name DebugStart -Integer $DebugStartValue
    }
}

function Enable-BCDKernelDebugging {
<#
.SYNOPSIS

Enables kernel debugging.

.DESCRIPTION

Enable-BCDKernelDebugging enables kernel debugging for the specified OS loader. If no OS loader is specified, kernel debugging is enabled on the current OS loader. Enabling kernel debugging will fail in case where Secure Boot policy is in effect.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER BCDObject

Specifies a specific OS loader other than the current OS loader. An alternate OS loader can be obtained with the following BCD module function:

Get-BCDObject -BCDStore $BCDStore -WellKnownId OSLoader

.PARAMETER BCDStore

Specifies the BCDStore object returned from the Get-BCDStore function. If -BCDStore is not specified, the system BCD store will be used.

Specifying a BcdStore instance implies that kernel debugging will be enabled for the current OS loader in the specified BCD store. -BCDObject should be used to set kernel debugging on an OS loader other than the current OS loader.

.EXAMPLE

Enable-BCDKernelDebugging

Enables kernel debugging locally on the current OS loader (i.e. the currently running OS configuration).

.EXAMPLE

Enable-BCDKernelDebugging -BCDStore $BCDStore

Enables kernel debugging on the current OS loader remotely over an established CIM session. $BCDStore was obtained via Get-BCDStore.

.EXAMPLE

$OSLoader = Get-BCDStore | Get-BCDObject -WellKnownId Default
Enable-BCDKernelDebugging -BCDObject $OSLoader

Enables kernel debugging on the default OS loader.

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore

Accepts a single BCD store element from the pipeline.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement

Outputs a BCD element instance upon successfully setting kernel debugging.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'BCDStore')]
    param (
        [Parameter(ParameterSetName = 'BCDObject')]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
        [Microsoft.Management.Infrastructure.CimInstance]
        [ValidateScript({$_.ApplicationType -eq 'OSLoader'})]
        $BCDObject,

        [Parameter(ValueFromPipeline, ParameterSetName = 'BCDStore')]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDStore.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDStore.GetCimSessionInstanceId() }

    $BCDStoreToUse = $null

    if ($BCDStore) {
        $BCDStoreToUse = $BCDStore
    } else {
        # Use the system BCD store.
        $BCDStoreToUse = Get-BCDStore @CimMethodArgs
    }

    $BCDObjectToUse = $null
    
    if ($BCDObject) {
        $BCDObjectToUse = $BCDObject
    } else {
        # Default to the current OS loader - i.e. the running OS
        $BCDObjectToUse = Get-BCDObject -BCDStore $BCDStoreToUse -WellKnownId Current
    }
    
    $KernelDebuggerEnabled = Get-BCDElement -BCDObject $BCDObjectToUse -Name KernelDebuggerEnabled

    if ($KernelDebuggerEnabled) {
        # The element exists and it needs to be set.
        Set-BCDElement -BCDElement $KernelDebuggerEnabled -Boolean $True -PassThru
    } else {
        # The element does not exist and it needs to be created.
        New-BCDElement -BCDObject $BCDObjectToUse -Name KernelDebuggerEnabled -Boolean $True
    }
}

Export-ModuleMember -Function 'Get-BCDDebugSettings',
                              'Set-BCDDebugSettings',
                              'Remove-BCDDebugSettings',
                              'Enable-BCDKernelDebugging'