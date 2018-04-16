# A set of helper functions designed to ease the use of BCD and minimize the need to use the core BCD module functions.

function Get-BCDBootManager {
<#
.SYNOPSIS

Returns the Windows boot manager BCD object instance.

.DESCRIPTION

Get-BCDBootManager returns the BCD object instance representing the Windows boot manager. This is a helper function designed to ease the process of obtaining boot entries for BCD module functions that apply solely to the boot manager (e.g. early boot debugging).

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER BCDStore

Specifies the BCDStore object returned from the Get-BCDStore function. If -BCDStore is not specified, the system BCD store will be used.

.PARAMETER CimSession

Specifies the CIM session to use for this function. Enter a variable that contains the CIM session or a command that creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see about_CimSessions.

.EXAMPLE

Get-BCDBootManager

Returns the boot manager.

.EXAMPLE

Get-BCDBootManager | Get-BCDElement

Inspects all defined elements for the boot manager.

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore

Accepts a single BCD store element from the pipeline.

Microsoft.Management.Infrastructure.CimSession

Accepts a single CIM session instance from the pipeline.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Outputs one or more Windows boot applications in the form of BCD object instances.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
    [CmdletBinding(DefaultParameterSetName = 'BCDStore')]
    param (
        [Parameter(ValueFromPipeline, ParameterSetName = 'BCDStore')]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore,

        [Parameter(ParameterSetName = 'CIMSession')]
        [Alias('Session')]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    $CimMethodArgs = @{}

    if ($CimSession) { $CimMethodArgs['CimSession'] = $CimSession }

    $BCDStoreToUse = $null

    if ($BCDStore) {
        $BCDStoreToUse = $BCDStore
    } else {
        # Use the system BCD store.
        $BCDStoreToUse = Get-BCDStore @CimMethodArgs
    }

    Get-BCDObject -BCDStore $BCDStoreToUse -WellKnownId BootMgr
}

function Get-BCDBootApplication {
<#
.SYNOPSIS

Returns one or more BCD boot application instances.

.DESCRIPTION

Get-BCDBootApplication returns one or more BCD object instances representing Windows boot applications. This is a helper function designed to ease the process of obtaining boot entries for BCD module functions that apply solely to boot applications (e.g. test signing, kernel debugging, etc.).

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER Type

Specifies a specific type of boot application to return: Current or Default.

.PARAMETER BCDStore

Specifies the BCDStore object returned from the Get-BCDStore function. If -BCDStore is not specified, the system BCD store will be used.

.PARAMETER CimSession

Specifies the CIM session to use for this function. Enter a variable that contains the CIM session or a command that creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see about_CimSessions.

.EXAMPLE

Get-BCDBootApplication

Returns all boot applications.

.EXAMPLE

Get-BCDBootApplication -Type Current

Returns the current boot application - i.e. the OS loader object representing the currently running operating system.

.EXAMPLE

Get-BCDBootApplication -Type Default | Get-BCDElement

Returns the default boot application and inspects its defined elements - i.e. the OS loader object representing the operating system that will load by default at boot.

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore

Accepts a single BCD store element from the pipeline.

Microsoft.Management.Infrastructure.CimSession

Accepts a single CIM session instance from the pipeline.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Outputs one or more Windows boot applications in the form of BCD object instances.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
    [CmdletBinding(DefaultParameterSetName = 'BCDStore')]
    param (
        [String]
        [ValidateSet('Current', 'Default')]
        $Type,

        [Parameter(ValueFromPipeline, ParameterSetName = 'BCDStore')]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore,

        [Parameter(ParameterSetName = 'CIMSession')]
        [Alias('Session')]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    $CimMethodArgs = @{}

    if ($CimSession) { $CimMethodArgs['CimSession'] = $CimSession }

    $BCDStoreToUse = $null

    if ($BCDStore) {
        $BCDStoreToUse = $BCDStore
    } else {
        # Use the system BCD store.
        $BCDStoreToUse = Get-BCDStore @CimMethodArgs
    }

    if ($Type) {
        Get-BCDObject -BCDStore $BCDStoreToUse -WellKnownId $Type
    } else {
        Get-BCDObject -BCDStore $BCDStoreToUse | Where-Object { $_.ApplicationImageType -eq 'WindowsBootApp' }
    }
}

Export-ModuleMember -Function 'Get-BCDBootApplication',
                              'Get-BCDBootManager'