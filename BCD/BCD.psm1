#region module-scoped variables

# As new object and element types are added, they will need to be added here.
# Applying symbols to bcdedit.exe will typically get the job done.

# This is a mapping of well-known identifier->identifier (GUID)->type value
$Script:ObjectFriendlyNameMapping = @{
    'EmsSettings' =          @('{0CE4991B-E6B3-4B16-B23C-5E0D9250E5D9}', [UInt32] 0x20100000)
    'ResumeLoaderSettings' = @('{1AFA9C49-16AB-4A5C-901B-212802DA9460}', [UInt32] 0x20200004)
    'Default' =              @('{1CAE1EB7-A0DF-4D4D-9851-4860E34EF535}', [UInt32] 0x10200003)
    'KernelDbgSettings' =    @('{313E8EED-7098-4586-A9BF-309C61F8D449}', [UInt32] 0x20200003)
    'DbgSettings' =          @('{4636856E-540F-4170-A130-A84776F4C654}', [UInt32] 0x20100000)
    'EventSettings' =        @('{4636856E-540F-4170-A130-A84776F4C654}', [UInt32] 0x20100000)
    'Legacy' =               @('{466F5A88-0AF2-4F76-9038-095B170DC21C}', [UInt32] 0x10300006)
    'NtLdr' =                @('{466F5A88-0AF2-4F76-9038-095B170DC21C}', [UInt32] 0x10300006)
    'BadMemory' =            @('{5189B25C-5558-4BF2-BCA4-289B11BD29E2}', [UInt32] 0x20100000)
    'BootloaderSettings' =   @('{6EFB52BF-1766-41DB-A6B3-0EE5EFF72BD7}', [UInt32] 0x20200003)
    'GlobalSettings' =       @('{7EA2E1AC-2E61-4728-AAA3-896D9D0A9F0E}', [UInt32] 0x20100000)
    'HypervisorSettings' =   @('{7FF607E0-4395-11DB-B0DE-0800200C9A66}', [UInt32] 0x20200003)
    'BootMgr' =              @('{9DEA862C-5CDD-4E70-ACC1-F32B344D4795}', [UInt32] 0x10100002)
    'FWBootMgr' =            @('{A5A30FA2-3D06-4E9F-B5F4-A01DF9D1FCBA}', [UInt32] 0x10100001)
    'RamDiskOptions' =       @('{AE5534E0-A924-466C-B836-758539A3EE3A}', [UInt32] 0x30000000)
    'MemDiag' =              @('{B2721D73-1DB4-4C62-BF78-C548A880142D}', [UInt32] 0x10200005)
    'Current' =              @('{FA926493-6F1C-4193-A414-58F0B2456D1E}', [UInt32] 0x10200003)
    'SetupEFI' =             @('{7254A080-1510-4E85-AC0F-E7FB3D444736}', [UInt32] 0x10200003)
    'TargetTemplateEFI' =    @('{B012B84D-C47C-4ED5-B722-C0C42163E569}', [UInt32] 0x10200003)
    'SetupPCAT' =            @('{CBD971BF-B7B8-4885-951A-FA03044F5D71}', [UInt32] 0x10200003)
    'TargetTemplatePCAT' =   @('{A1943BBC-EA85-487C-97C7-C9EDE908A38A}', [UInt32] 0x10200003)
}

$Script:ObjectTypes = @{
    1 = 'Application'
    2 = 'Inherit'
    3 = 'Device'
}

$Script:ImageTypes = @{
    1 = 'Firmware'
    2 = 'WindowsBootApp'
    3 = 'LegacyLoader'
    4 = 'RealMode'
}

# reactos/boot/environ/include/bcd.h
$Script:ApplicationTypes = @{
    1 = 'FWBootMgr'
    2 = 'BootMgr'
    3 = 'OSLoader'
    4 = 'Resume'
    5 = 'MemDiag'
    6 = 'NTLdr'
    7 = 'SetupLdr'
    8 = 'Bootsector'
    9 = 'StartupCom'
    10 = 'BootApp'
}

$Script:InheritableTypes = @{
    1 = 'InheritableByAnyObject'
    2 = 'InheritableByApplicationObject'
    3 = 'InheritableByDeviceObject'
}

$Script:ElementTypes = @{
    1 = 'Library'
    2 = 'Application'
    3 = 'Device'
    4 = 'Template'
    5 = 'OEM'
}

$Script:ElementFormatTypes = @{
    1 = 'Device'   # Will map to the following Set-BCDElement param: -Device
    2 = 'String'   # Will map to the following Set-BCDElement param: -String
    3 = 'Id'       # Will map to the following Set-BCDElement param: -Object
    4 = 'Ids'      # Will map to the following Set-BCDElement param: -ObjectList
    5 = 'Integer'  # Will map to the following Set-BCDElement param: -Integer
    6 = 'Boolean'  # Will map to the following Set-BCDElement param: -Boolean
    7 = 'Integers' # Will map to the following Set-BCDElement param: -IntegerList
}

# Kind of a hack. I don't fully understand how inheritable
# object map properly so I merged all the existing definitions
# together minus collisions (which were removed).
$Script:ElementInheritableNameMapping = @{
    ([UInt32] 0x11000001) = 'Device'
    ([UInt32] 0x12000002) = 'Path'
    ([UInt32] 0x12000004) = 'Description'
    ([UInt32] 0x12000005) = 'Locale'
    ([UInt32] 0x14000006) = 'Inherit'
    ([UInt32] 0x15000007) = 'TruncateMemory'
    ([UInt32] 0x14000008) = 'RecoverySequence'
    ([UInt32] 0x16000009) = 'RecoveryEnabled'
    ([UInt32] 0x1700000A) = 'BadMemoryList'
    ([UInt32] 0x1600000B) = 'BadMemoryAccess'
    ([UInt32] 0x1500000C) = 'FirstMegabytePolicy'
    ([UInt32] 0x1500000D) = 'RelocatePhysical'
    ([UInt32] 0x1500000E) = 'AvoidLowMemory'
    ([UInt32] 0x1600000F) = 'TraditionalKseg'
    ([UInt32] 0x16000010) = 'BootDebug'
    ([UInt32] 0x15000011) = 'DebugType'
    ([UInt32] 0x15000012) = 'DebugAddress'
    ([UInt32] 0x15000013) = 'DebugPort'
    ([UInt32] 0x15000014) = 'BaudRate'
    ([UInt32] 0x15000015) = 'Channel'
    ([UInt32] 0x12000016) = 'TargetName'
    ([UInt32] 0x16000017) = 'NoUMEx'
    ([UInt32] 0x15000018) = 'DebugStart'
    ([UInt32] 0x12000019) = 'BusParams'
    ([UInt32] 0x1500001A) = 'HostIP'
    ([UInt32] 0x1500001B) = 'Port'
    ([UInt32] 0x1600001C) = 'DHCP'
    ([UInt32] 0x1200001D) = 'Key'
    ([UInt32] 0x1600001E) = 'VM'
    ([UInt32] 0x16000020) = 'BootEMS'
    ([UInt32] 0x15000022) = 'EMSPort'
    ([UInt32] 0x15000023) = 'EMSBaudRate'
    ([UInt32] 0x12000030) = 'LoadOptions'
    ([UInt32] 0x16000031) = 'AttemptNonBcdStart' # No actual friendly name defined
    ([UInt32] 0x16000040) = 'AdvancedOptions'
    ([UInt32] 0x16000041) = 'OptionsEdit'
    ([UInt32] 0x15000042) = 'KeyringAddress'
    ([UInt32] 0x11000043) = 'BootStatusDataLogDevice' # No actual friendly name defined
    ([UInt32] 0x12000044) = 'BootStatusDataLogPath' # No actual friendly name defined
    ([UInt32] 0x16000045) = 'PreserveBootStat'
    ([UInt32] 0x16000046) = 'GraphicsModeDisabled'
    ([UInt32] 0x15000047) = 'ConfigAccessPolicy'
    ([UInt32] 0x16000048) = 'NoIntegrityChecks'
    ([UInt32] 0x16000049) = 'TestSigning'
    ([UInt32] 0x1200004A) = 'FontPath'
    ([UInt32] 0x1500004B) = 'IntegrityServices' # BCDE_LIBRARY_TYPE_SI_POLICY
    ([UInt32] 0x1500004C) = 'VolumeBandId'
    ([UInt32] 0x16000050) = 'ExtendedInput'
    ([UInt32] 0x15000051) = 'InitialConsoleInput'
    ([UInt32] 0x15000052) = 'GraphicsResolution'
    ([UInt32] 0x16000053) = 'RestartOnFailure'
    ([UInt32] 0x16000054) = 'HighestMode'
    ([UInt32] 0x16000060) = 'IsolatedContext'
    ([UInt32] 0x15000065) = 'DisplayMessage'
    ([UInt32] 0x15000066) = 'DisplayMessageOverride'
    ([UInt32] 0x16000067) = 'NoBootUxLogo' # No actual friendly name defined
    ([UInt32] 0x16000068) = 'NoBootUxText'
    ([UInt32] 0x16000069) = 'NoBootUxProgress'
    ([UInt32] 0x1600006A) = 'NoBootUxFade'
    ([UInt32] 0x1600006B) = 'BootUxReservePoolDebug' # No actual friendly name defined
    ([UInt32] 0x1600006C) = 'BootUxDisabled'
    ([UInt32] 0x1500006D) = 'BootUxFadeFrames' # No actual friendly name defined
    ([UInt32] 0x1600006E) = 'BootUxDumpStats' # No actual friendly name defined
    ([UInt32] 0x1600006F) = 'BootUxShowStats' # No actual friendly name defined
    ([UInt32] 0x16000071) = 'MultiBootSystem' # No actual friendly name defined
    ([UInt32] 0x16000072) = 'NoKeyboard'
    ([UInt32] 0x15000073) = 'AliasWindowsKey' # No actual friendly name defined
    ([UInt32] 0x16000074) = 'BootShutdownDisabled'
    ([UInt32] 0x15000075) = 'PerformanceFrequency' # No actual friendly name defined
    ([UInt32] 0x15000076) = 'SecurebootRawPolicy'
    ([UInt32] 0x17000077) = 'AllowedInMemorySettings'
    ([UInt32] 0x15000079) = 'BootUxtTransitionTime'
    ([UInt32] 0x1600007A) = 'MobileGraphics'
    ([UInt32] 0x1600007B) = 'ForceFipsCrypto'
    ([UInt32] 0x1500007D) = 'BootErrorUx'
    ([UInt32] 0x1600007E) = 'FlightSigning'
    ([UInt32] 0x1500007F) = 'MeasuredBootLogFormat'
    ([UInt32] 0x25000001) = 'PassCount'
    ([UInt32] 0x25000003) = 'FailureCount'
    ([UInt32] 0x26000202) = 'SkipFFUMode'
    ([UInt32] 0x26000203) = 'ForceFFUMode'
    ([UInt32] 0x25000510) = 'ChargeThreshold'
    ([UInt32] 0x26000512) = 'OffModeCharging'
    ([UInt32] 0x25000AAA) = 'Bootflow'
    ([UInt32] 0x24000001) = 'DisplayOrder'
    ([UInt32] 0x24000002) = 'BootSequence'
    ([UInt32] 0x23000003) = 'Default'
    ([UInt32] 0x25000004) = 'Timeout'
    ([UInt32] 0x26000005) = 'AttemptResume'
    ([UInt32] 0x23000006) = 'ResumeObject'
    ([UInt32] 0x24000010) = 'ToolsDisplayOrder'
    ([UInt32] 0x26000020) = 'DisplayBootMenu'
    ([UInt32] 0x26000021) = 'NoErrorDisplay'
    ([UInt32] 0x21000022) = 'BcdDevice'
    ([UInt32] 0x22000023) = 'BcdFilePath'
    ([UInt32] 0x26000028) = 'ProcessCustomActionsFirst'
    ([UInt32] 0x27000030) = 'CustomActionsList'
    ([UInt32] 0x26000031) = 'PersistBootSequence'
    ([UInt32] 0x21000001) = 'FileDevice'
    ([UInt32] 0x22000002) = 'FilePath'
    ([UInt32] 0x26000006) = 'DebugOptionEnabled'
    ([UInt32] 0x25000008) = 'BootMenuPolicy'
    ([UInt32] 0x26000010) = 'DetectKernelAndHal'
    ([UInt32] 0x22000011) = 'KernelPath'
    ([UInt32] 0x22000012) = 'HalPath'
    ([UInt32] 0x22000013) = 'DbgTransportPath'
    ([UInt32] 0x25000020) = 'NX'
    ([UInt32] 0x25000021) = 'PAEPolicy'
    ([UInt32] 0x26000022) = 'WinPE'
    ([UInt32] 0x26000024) = 'DisableCrashAutoReboot'
    ([UInt32] 0x26000025) = 'UseLastGoodSettings'
    ([UInt32] 0x26000027) = 'AllowPrereleaseSignatures'
    ([UInt32] 0x26000030) = 'NoLowMemory'
    ([UInt32] 0x25000031) = 'RemoveMemory'
    ([UInt32] 0x25000032) = 'IncreaseUserVa'
    ([UInt32] 0x26000040) = 'UseVgaDriver'
    ([UInt32] 0x26000041) = 'DisableBootDisplay'
    ([UInt32] 0x26000042) = 'DisableVesaBios'
    ([UInt32] 0x26000043) = 'DisableVgaMode'
    ([UInt32] 0x25000050) = 'ClusterModeAddressing'
    ([UInt32] 0x26000051) = 'UsePhysicalDestination'
    ([UInt32] 0x25000052) = 'RestrictApicCluster'
    ([UInt32] 0x26000054) = 'UseLegacyApicMode'
    ([UInt32] 0x25000055) = 'X2ApicPolicy'
    ([UInt32] 0x26000060) = 'UseBootProcessorOnly'
    ([UInt32] 0x25000061) = 'NumberOfProcessors'
    ([UInt32] 0x26000062) = 'ForceMaximumProcessors'
    ([UInt32] 0x25000063) = 'ProcessorConfigurationFlags'
    ([UInt32] 0x26000064) = 'MaximizeGroupsCreated'
    ([UInt32] 0x26000065) = 'ForceGroupAwareness'
    ([UInt32] 0x25000066) = 'GroupSize'
    ([UInt32] 0x26000070) = 'UseFirmwarePciSettings'
    ([UInt32] 0x25000071) = 'MsiPolicy'
    ([UInt32] 0x25000080) = 'SafeBoot'
    ([UInt32] 0x26000081) = 'SafeBootAlternateShell'
    ([UInt32] 0x26000090) = 'BootLogInitialization'
    ([UInt32] 0x26000091) = 'VerboseObjectLoadMode'
    ([UInt32] 0x260000a0) = 'KernelDebuggerEnabled'
    ([UInt32] 0x260000a1) = 'DebuggerHalBreakpoint'
    ([UInt32] 0x260000A2) = 'UsePlatformClock'
    ([UInt32] 0x260000A3) = 'ForceLegacyPlatform'
    ([UInt32] 0x250000A6) = 'TscSyncPolicy'
    ([UInt32] 0x260000b0) = 'EmsEnabled'
    ([UInt32] 0x250000c1) = 'DriverLoadFailurePolicy'
    ([UInt32] 0x250000C2) = 'BootMenuPolicy'
    ([UInt32] 0x260000C3) = 'AdvancedOptionsOneTime'
    ([UInt32] 0x250000E0) = 'BootStatusPolicy'
    ([UInt32] 0x260000E1) = 'DisableElamDrivers'
    ([UInt32] 0x250000F0) = 'HypervisorLaunchType'
    ([UInt32] 0x260000F2) = 'HypervisorDebugEnabled'
    ([UInt32] 0x250000F3) = 'HypervisorDebugType'
    ([UInt32] 0x250000F4) = 'HypervisorDebugPort'
    ([UInt32] 0x250000F5) = 'HypervisorBaudrate'
    ([UInt32] 0x250000F6) = 'HypervisorDebug1394Channel'
    ([UInt32] 0x250000F7) = 'BootUxPolicy'
    ([UInt32] 0x220000F9) = 'HypervisorDebugBusParams'
    ([UInt32] 0x250000FA) = 'HypervisorNumProc'
    ([UInt32] 0x250000FB) = 'HypervisorRootProcPerNode'
    ([UInt32] 0x260000FC) = 'HypervisorUseLargeVTlb'
    ([UInt32] 0x250000FD) = 'HypervisorDebugNetHostIp'
    ([UInt32] 0x250000FE) = 'HypervisorDebugNetHostPort'
    ([UInt32] 0x25000100) = 'TpmBootEntropyPolicy'
    ([UInt32] 0x22000110) = 'HypervisorDebugNetKey'
    ([UInt32] 0x26000114) = 'HypervisorDebugNetDhcp'
    ([UInt32] 0x25000115) = 'HypervisorIommuPolicy'
    ([UInt32] 0x2500012b) = 'XSaveDisable'
    ([UInt32] 0x35000001) = 'RamdiskImageOffset'
    ([UInt32] 0x35000002) = 'TftpClientPort'
    ([UInt32] 0x31000003) = 'RamdiskSdiDevice'
    ([UInt32] 0x32000004) = 'RamdiskSdiPath'
    ([UInt32] 0x35000005) = 'RamdiskImageLength'
    ([UInt32] 0x36000006) = 'RamdiskExportAsCd'
    ([UInt32] 0x36000007) = 'RamdiskTftpBlockSize'
    ([UInt32] 0x36000008) = 'RamdiskTftpWindowSize'
    ([UInt32] 0x36000009) = 'RamdiskMulticastEnabled'
    ([UInt32] 0x3600000A) = 'RamdiskMulticastTftpFallback'
    ([UInt32] 0x3600000B) = 'RamdiskTftpVarWindow'
    ([UInt32] 0x45000001) = 'DeviceType' # No actual friendly name defined
    ([UInt32] 0x42000002) = 'ApplicationRelativePath' # No actual friendly name defined
    ([UInt32] 0x42000003) = 'RamdiskDeviceRelativePath' # No actual friendly name defined
    ([UInt32] 0x46000004) = 'OmitOsLoaderElements' # No actual friendly name defined
    ([UInt32] 0x47000006) = 'ElementsToMigrate'
    ([UInt32] 0x46000010) = 'RecoveryOs' # No actual friendly name defined
}

# Taken from https://www.geoffchappell.com/notes/windows/boot/bcd/elements.htm
# These are also all available in bcdedit.exe public symbols
$Script:ElementLibraryNameMapping = @{
    ([UInt32] 0x11000001) = 'Device'
    ([UInt32] 0x12000002) = 'Path'
    ([UInt32] 0x12000004) = 'Description'
    ([UInt32] 0x12000005) = 'Locale'
    ([UInt32] 0x14000006) = 'Inherit'
    ([UInt32] 0x15000007) = 'TruncateMemory'
    ([UInt32] 0x14000008) = 'RecoverySequence'
    ([UInt32] 0x16000009) = 'RecoveryEnabled'
    ([UInt32] 0x1700000A) = 'BadMemoryList'
    ([UInt32] 0x1600000B) = 'BadMemoryAccess'
    ([UInt32] 0x1500000C) = 'FirstMegabytePolicy'
    ([UInt32] 0x1500000D) = 'RelocatePhysical'
    ([UInt32] 0x1500000E) = 'AvoidLowMemory'
    ([UInt32] 0x1600000F) = 'TraditionalKseg'
    ([UInt32] 0x16000010) = 'BootDebug'
    ([UInt32] 0x15000011) = 'DebugType'
    ([UInt32] 0x15000012) = 'DebugAddress'
    ([UInt32] 0x15000013) = 'DebugPort'
    ([UInt32] 0x15000014) = 'BaudRate'
    ([UInt32] 0x15000015) = 'Channel'
    ([UInt32] 0x12000016) = 'TargetName'
    ([UInt32] 0x16000017) = 'NoUMEx'
    ([UInt32] 0x15000018) = 'DebugStart'
    ([UInt32] 0x12000019) = 'BusParams'
    ([UInt32] 0x1500001A) = 'HostIP'
    ([UInt32] 0x1500001B) = 'Port'
    ([UInt32] 0x1600001C) = 'DHCP'
    ([UInt32] 0x1200001D) = 'Key'
    ([UInt32] 0x1600001E) = 'VM'
    ([UInt32] 0x16000020) = 'BootEMS'
    ([UInt32] 0x15000022) = 'EMSPort'
    ([UInt32] 0x15000023) = 'EMSBaudRate'
    ([UInt32] 0x12000030) = 'LoadOptions'
    ([UInt32] 0x16000031) = 'AttemptNonBcdStart' # No actual friendly name defined
    ([UInt32] 0x16000040) = 'AdvancedOptions'
    ([UInt32] 0x16000041) = 'OptionsEdit'
    ([UInt32] 0x15000042) = 'KeyringAddress'
    ([UInt32] 0x11000043) = 'BootStatusDataLogDevice' # No actual friendly name defined
    ([UInt32] 0x12000044) = 'BootStatusDataLogPath' # No actual friendly name defined
    ([UInt32] 0x16000045) = 'PreserveBootStat'
    ([UInt32] 0x16000046) = 'GraphicsModeDisabled'
    ([UInt32] 0x15000047) = 'ConfigAccessPolicy'
    ([UInt32] 0x16000048) = 'NoIntegrityChecks'
    ([UInt32] 0x16000049) = 'TestSigning'
    ([UInt32] 0x1200004A) = 'FontPath'
    ([UInt32] 0x1500004B) = 'IntegrityServices' # BCDE_LIBRARY_TYPE_SI_POLICY
    ([UInt32] 0x1500004C) = 'VolumeBandId'
    ([UInt32] 0x16000050) = 'ExtendedInput'
    ([UInt32] 0x15000051) = 'InitialConsoleInput'
    ([UInt32] 0x15000052) = 'GraphicsResolution'
    ([UInt32] 0x16000053) = 'RestartOnFailure'
    ([UInt32] 0x16000054) = 'HighestMode'
    ([UInt32] 0x16000060) = 'IsolatedContext'
    ([UInt32] 0x15000065) = 'DisplayMessage'
    ([UInt32] 0x15000066) = 'DisplayMessageOverride'
    ([UInt32] 0x16000067) = 'NoBootUxLogo' # No actual friendly name defined
    ([UInt32] 0x16000068) = 'NoBootUxText'
    ([UInt32] 0x16000069) = 'NoBootUxProgress'
    ([UInt32] 0x1600006A) = 'NoBootUxFade'
    ([UInt32] 0x1600006B) = 'BootUxReservePoolDebug' # No actual friendly name defined
    ([UInt32] 0x1600006C) = 'BootUxDisabled'
    ([UInt32] 0x1500006D) = 'BootUxFadeFrames' # No actual friendly name defined
    ([UInt32] 0x1600006E) = 'BootUxDumpStats' # No actual friendly name defined
    ([UInt32] 0x1600006F) = 'BootUxShowStats' # No actual friendly name defined
    ([UInt32] 0x16000071) = 'MultiBootSystem' # No actual friendly name defined
    ([UInt32] 0x16000072) = 'NoKeyboard'
    ([UInt32] 0x15000073) = 'AliasWindowsKey' # No actual friendly name defined
    ([UInt32] 0x16000074) = 'BootShutdownDisabled'
    ([UInt32] 0x15000075) = 'PerformanceFrequency' # No actual friendly name defined
    ([UInt32] 0x15000076) = 'SecurebootRawPolicy'
    ([UInt32] 0x17000077) = 'AllowedInMemorySettings'
    ([UInt32] 0x15000079) = 'BootUxtTransitionTime'
    ([UInt32] 0x1600007A) = 'MobileGraphics'
    ([UInt32] 0x1600007B) = 'ForceFipsCrypto'
    ([UInt32] 0x1500007D) = 'BootErrorUx'
    ([UInt32] 0x1600007E) = 'FlightSigning'
    ([UInt32] 0x1500007F) = 'MeasuredBootLogFormat'
}

$Script:ElementMemDiagNameMapping = @{
    ([UInt32] 0x25000001) = 'PassCount'
    ([UInt32] 0x25000003) = 'FailureCount'
}

$Script:ElementApplicationNameMapping = @{
    ([UInt32] 0x26000202) = 'SkipFFUMode'
    ([UInt32] 0x26000203) = 'ForceFFUMode'
    ([UInt32] 0x25000510) = 'ChargeThreshold'
    ([UInt32] 0x26000512) = 'OffModeCharging'
    ([UInt32] 0x25000AAA) = 'Bootflow'
}

$Script:ElementBootMgrNameMapping = @{
    ([UInt32] 0x24000001) = 'DisplayOrder'
    ([UInt32] 0x24000002) = 'BootSequence'
    ([UInt32] 0x23000003) = 'Default'
    ([UInt32] 0x25000004) = 'Timeout'
    ([UInt32] 0x26000005) = 'AttemptResume'
    ([UInt32] 0x23000006) = 'ResumeObject'
    ([UInt32] 0x24000010) = 'ToolsDisplayOrder'
    ([UInt32] 0x26000020) = 'DisplayBootMenu'
    ([UInt32] 0x26000021) = 'NoErrorDisplay'
    ([UInt32] 0x21000022) = 'BcdDevice'
    ([UInt32] 0x22000023) = 'BcdFilePath'
    ([UInt32] 0x26000028) = 'ProcessCustomActionsFirst'
    ([UInt32] 0x27000030) = 'CustomActionsList'
    ([UInt32] 0x26000031) = 'PersistBootSequence'
    ([UInt32] 0x21000001) = 'FileDevice'
    ([UInt32] 0x22000002) = 'FilePath'
    ([UInt32] 0x26000006) = 'DebugOptionEnabled'
    ([UInt32] 0x25000008) = 'BootMenuPolicy'
}

$Script:ElementOSLoaderNameMapping = @{
    ([UInt32] 0x21000001) = 'OSDevice'
    ([UInt32] 0x22000002) = 'SystemRoot'
    ([UInt32] 0x23000003) = 'ResumeObject'
    ([UInt32] 0x26000010) = 'DetectKernelAndHal'
    ([UInt32] 0x22000011) = 'KernelPath'
    ([UInt32] 0x22000012) = 'HalPath'
    ([UInt32] 0x22000013) = 'DbgTransportPath'
    ([UInt32] 0x25000020) = 'NX'
    ([UInt32] 0x25000021) = 'PAEPolicy'
    ([UInt32] 0x26000022) = 'WinPE'
    ([UInt32] 0x26000024) = 'DisableCrashAutoReboot'
    ([UInt32] 0x26000025) = 'UseLastGoodSettings'
    ([UInt32] 0x26000027) = 'AllowPrereleaseSignatures'
    ([UInt32] 0x26000030) = 'NoLowMemory'
    ([UInt32] 0x25000031) = 'RemoveMemory'
    ([UInt32] 0x25000032) = 'IncreaseUserVa'
    ([UInt32] 0x26000040) = 'UseVgaDriver'
    ([UInt32] 0x26000041) = 'DisableBootDisplay'
    ([UInt32] 0x26000042) = 'DisableVesaBios'
    ([UInt32] 0x26000043) = 'DisableVgaMode'
    ([UInt32] 0x25000050) = 'ClusterModeAddressing'
    ([UInt32] 0x26000051) = 'UsePhysicalDestination'
    ([UInt32] 0x25000052) = 'RestrictApicCluster'
    ([UInt32] 0x26000054) = 'UseLegacyApicMode'
    ([UInt32] 0x25000055) = 'X2ApicPolicy'
    ([UInt32] 0x26000060) = 'UseBootProcessorOnly'
    ([UInt32] 0x25000061) = 'NumberOfProcessors'
    ([UInt32] 0x26000062) = 'ForceMaximumProcessors'
    ([UInt32] 0x25000063) = 'ProcessorConfigurationFlags'
    ([UInt32] 0x26000064) = 'MaximizeGroupsCreated'
    ([UInt32] 0x26000065) = 'ForceGroupAwareness'
    ([UInt32] 0x25000066) = 'GroupSize'
    ([UInt32] 0x26000070) = 'UseFirmwarePciSettings'
    ([UInt32] 0x25000071) = 'MsiPolicy'
    ([UInt32] 0x25000080) = 'SafeBoot'
    ([UInt32] 0x26000081) = 'SafeBootAlternateShell'
    ([UInt32] 0x26000090) = 'BootLogInitialization'
    ([UInt32] 0x26000091) = 'VerboseObjectLoadMode'
    ([UInt32] 0x260000a0) = 'KernelDebuggerEnabled'
    ([UInt32] 0x260000a1) = 'DebuggerHalBreakpoint'
    ([UInt32] 0x260000A2) = 'UsePlatformClock'
    ([UInt32] 0x260000A3) = 'ForceLegacyPlatform'
    ([UInt32] 0x250000A6) = 'TscSyncPolicy'
    ([UInt32] 0x260000b0) = 'EmsEnabled'
    ([UInt32] 0x250000c1) = 'DriverLoadFailurePolicy'
    ([UInt32] 0x250000C2) = 'BootMenuPolicy'
    ([UInt32] 0x260000C3) = 'AdvancedOptionsOneTime'
    ([UInt32] 0x250000E0) = 'BootStatusPolicy'
    ([UInt32] 0x260000E1) = 'DisableElamDrivers'
    ([UInt32] 0x250000F0) = 'HypervisorLaunchType'
    ([UInt32] 0x260000F2) = 'HypervisorDebugEnabled'
    ([UInt32] 0x250000F3) = 'HypervisorDebugType'
    ([UInt32] 0x250000F4) = 'HypervisorDebugPort'
    ([UInt32] 0x250000F5) = 'HypervisorBaudrate'
    ([UInt32] 0x250000F6) = 'HypervisorDebug1394Channel'
    ([UInt32] 0x250000F7) = 'BootUxPolicy'
    ([UInt32] 0x220000F9) = 'HypervisorDebugBusParams'
    ([UInt32] 0x250000FA) = 'HypervisorNumProc'
    ([UInt32] 0x250000FB) = 'HypervisorRootProcPerNode'
    ([UInt32] 0x260000FC) = 'HypervisorUseLargeVTlb'
    ([UInt32] 0x250000FD) = 'HypervisorDebugNetHostIp'
    ([UInt32] 0x250000FE) = 'HypervisorDebugNetHostPort'
    ([UInt32] 0x25000100) = 'TpmBootEntropyPolicy'
    ([UInt32] 0x22000110) = 'HypervisorDebugNetKey'
    ([UInt32] 0x26000114) = 'HypervisorDebugNetDhcp'
    ([UInt32] 0x25000115) = 'HypervisorIommuPolicy'
    ([UInt32] 0x2500012b) = 'XSaveDisable'
}

# http://msdn.microsoft.com/en-us/library/windows/desktop/aa362645(v=vs.85).aspx
$Script:ElementDeviceNameMapping = @{
    ([UInt32] 0x35000001) = 'RamdiskImageOffset'
    ([UInt32] 0x35000002) = 'TftpClientPort'
    ([UInt32] 0x31000003) = 'RamdiskSdiDevice'
    ([UInt32] 0x32000004) = 'RamdiskSdiPath'
    ([UInt32] 0x35000005) = 'RamdiskImageLength'
    ([UInt32] 0x36000006) = 'RamdiskExportAsCd'
    ([UInt32] 0x36000007) = 'RamdiskTftpBlockSize'
    ([UInt32] 0x36000008) = 'RamdiskTftpWindowSize'
    ([UInt32] 0x36000009) = 'RamdiskMulticastEnabled'
    ([UInt32] 0x3600000A) = 'RamdiskMulticastTftpFallback'
    ([UInt32] 0x3600000B) = 'RamdiskTftpVarWindow'
}

$Script:ElementTemplateNameMapping = @{
    ([UInt32] 0x45000001) = 'DeviceType' # No actual friendly name defined
    ([UInt32] 0x42000002) = 'ApplicationRelativePath' # No actual friendly name defined
    ([UInt32] 0x42000003) = 'RamdiskDeviceRelativePath' # No actual friendly name defined
    ([UInt32] 0x46000004) = 'OmitOsLoaderElements' # No actual friendly name defined
    ([UInt32] 0x47000006) = 'ElementsToMigrate'
    ([UInt32] 0x46000010) = 'RecoveryOs' # No actual friendly name defined
}

$Script:ElementNameToValueMapping = @{
    'Device' = ([UInt32] 0x11000001)
    'Path' = ([UInt32] 0x12000002)
    'Description' = ([UInt32] 0x12000004)
    'Locale' = ([UInt32] 0x12000005)
    'Inherit' = ([UInt32] 0x14000006)
    'TruncateMemory' = ([UInt32] 0x15000007)
    'RecoverySequence' = ([UInt32] 0x14000008)
    'RecoveryEnabled' = ([UInt32] 0x16000009)
    'BadMemoryList' = ([UInt32] 0x1700000A)
    'BadMemoryAccess' = ([UInt32] 0x1600000B)
    'FirstMegabytePolicy' = ([UInt32] 0x1500000C)
    'RelocatePhysical' = ([UInt32] 0x1500000D)
    'AvoidLowMemory' = ([UInt32] 0x1500000E)
    'TraditionalKseg' = ([UInt32] 0x1600000F)
    'BootDebug' = ([UInt32] 0x16000010)
    'DebugType' = ([UInt32] 0x15000011)
    'DebugAddress' = ([UInt32] 0x15000012)
    'DebugPort' = ([UInt32] 0x15000013)
    'BaudRate' = ([UInt32] 0x15000014)
    'Channel' = ([UInt32] 0x15000015)
    'TargetName' = ([UInt32] 0x12000016)
    'NoUMEx' = ([UInt32] 0x16000017)
    'DebugStart' = ([UInt32] 0x15000018)
    'BusParams' = ([UInt32] 0x12000019)
    'HostIP' = ([UInt32] 0x1500001A)
    'Port' = ([UInt32] 0x1500001B)
    'DHCP' = ([UInt32] 0x1600001C)
    'Key' = ([UInt32] 0x1200001D)
    'VM' = ([UInt32] 0x1600001E)
    'BootEMS' = ([UInt32] 0x16000020)
    'EMSPort' = ([UInt32] 0x15000022)
    'EMSBaudRate' = ([UInt32] 0x15000023)
    'LoadOptions' = ([UInt32] 0x12000030)
    'AttemptNonBcdStart' = ([UInt32] 0x16000031)
    'AdvancedOptions' = ([UInt32] 0x16000040)
    'OptionsEdit' = ([UInt32] 0x16000041)
    'KeyringAddress' = ([UInt32] 0x15000042)
    'BootStatusDataLogDevice' = ([UInt32] 0x11000043)
    'BootStatusDataLogPath' = ([UInt32] 0x12000044)
    'PreserveBootStat' = ([UInt32] 0x16000045)
    'GraphicsModeDisabled' = ([UInt32] 0x16000046)
    'ConfigAccessPolicy' = ([UInt32] 0x15000047)
    'NoIntegrityChecks' = ([UInt32] 0x16000048)
    'TestSigning' = ([UInt32] 0x16000049)
    'FontPath' = ([UInt32] 0x1200004A)
    'IntegrityServices' = ([UInt32] 0x1500004B)
    'VolumeBandId' = ([UInt32] 0x1500004C)
    'ExtendedInput' = ([UInt32] 0x16000050)
    'InitialConsoleInput' = ([UInt32] 0x15000051)
    'GraphicsResolution' = ([UInt32] 0x15000052)
    'RestartOnFailure' = ([UInt32] 0x16000053)
    'HighestMode' = ([UInt32] 0x16000054)
    'IsolatedContext' = ([UInt32] 0x16000060)
    'DisplayMessage' = ([UInt32] 0x15000065)
    'DisplayMessageOverride' = ([UInt32] 0x15000066)
    'NoBootUxLogo' = ([UInt32] 0x16000067)
    'NoBootUxText' = ([UInt32] 0x16000068)
    'NoBootUxProgress' = ([UInt32] 0x16000069)
    'NoBootUxFade' = ([UInt32] 0x1600006A)
    'BootUxReservePoolDebug' = ([UInt32] 0x1600006B)
    'BootUxDisabled' = ([UInt32] 0x1600006C)
    'BootUxFadeFrames' = ([UInt32] 0x1500006D)
    'BootUxDumpStats' = ([UInt32] 0x1600006E)
    'BootUxShowStats' = ([UInt32] 0x1600006F)
    'MultiBootSystem' = ([UInt32] 0x16000071)
    'NoKeyboard' = ([UInt32] 0x16000072)
    'AliasWindowsKey' = ([UInt32] 0x15000073)
    'BootShutdownDisabled' = ([UInt32] 0x16000074)
    'PerformanceFrequency' = ([UInt32] 0x15000075)
    'SecurebootRawPolicy' = ([UInt32] 0x15000076)
    'AllowedInMemorySettings' = ([UInt32] 0x17000077)
    'BootUxtTransitionTime' = ([UInt32] 0x15000079)
    'MobileGraphics' = ([UInt32] 0x1600007A)
    'ForceFipsCrypto' = ([UInt32] 0x1600007B)
    'BootErrorUx' = ([UInt32] 0x1500007D)
    'FlightSigning' = ([UInt32] 0x1600007E)
    'MeasuredBootLogFormat' = ([UInt32] 0x1500007F)
    'PassCount' = ([UInt32] 0x25000001)
    'FailureCount' = ([UInt32] 0x25000003)
    'SkipFFUMode' = ([UInt32] 0x26000202)
    'ForceFFUMode' = ([UInt32] 0x26000203)
    'ChargeThreshold' = ([UInt32] 0x25000510)
    'OffModeCharging' = ([UInt32] 0x26000512)
    'Bootflow' = ([UInt32] 0x25000AAA)
    'DisplayOrder' = ([UInt32] 0x24000001)
    'BootSequence' = ([UInt32] 0x24000002)
    'Default' = ([UInt32] 0x23000003)
    'Timeout' = ([UInt32] 0x25000004)
    'AttemptResume' = ([UInt32] 0x26000005)
    'ResumeObject' = ([UInt32] 0x23000006)
    'ToolsDisplayOrder' = ([UInt32] 0x24000010)
    'DisplayBootMenu' = ([UInt32] 0x26000020)
    'NoErrorDisplay' = ([UInt32] 0x26000021)
    'BcdDevice' = ([UInt32] 0x21000022)
    'BcdFilePath' = ([UInt32] 0x22000023)
    'ProcessCustomActionsFirst' = ([UInt32] 0x26000028)
    'CustomActionsList' = ([UInt32] 0x27000030)
    'PersistBootSequence' = ([UInt32] 0x26000031)
    'FileDevice' = ([UInt32] 0x21000001)
    'FilePath' = ([UInt32] 0x22000002)
    'DebugOptionEnabled' = ([UInt32] 0x26000006)
    'BootMenuPolicyWinResume' = ([UInt32] 0x25000008)
    'OSDevice' = ([UInt32] 0x21000001)
    'SystemRoot' = ([UInt32] 0x22000002)
    'AssociatedResumeObject' = ([UInt32] 0x23000003)
    'DetectKernelAndHal' = ([UInt32] 0x26000010)
    'KernelPath' = ([UInt32] 0x22000011)
    'HalPath' = ([UInt32] 0x22000012)
    'DbgTransportPath' = ([UInt32] 0x22000013)
    'NX' = ([UInt32] 0x25000020)
    'PAEPolicy' = ([UInt32] 0x25000021)
    'WinPE' = ([UInt32] 0x26000022)
    'DisableCrashAutoReboot' = ([UInt32] 0x26000024)
    'UseLastGoodSettings' = ([UInt32] 0x26000025)
    'AllowPrereleaseSignatures' = ([UInt32] 0x26000027)
    'NoLowMemory' = ([UInt32] 0x26000030)
    'RemoveMemory' = ([UInt32] 0x25000031)
    'IncreaseUserVa' = ([UInt32] 0x25000032)
    'UseVgaDriver' = ([UInt32] 0x26000040)
    'DisableBootDisplay' = ([UInt32] 0x26000041)
    'DisableVesaBios' = ([UInt32] 0x26000042)
    'DisableVgaMode' = ([UInt32] 0x26000043)
    'ClusterModeAddressing' = ([UInt32] 0x25000050)
    'UsePhysicalDestination' = ([UInt32] 0x26000051)
    'RestrictApicCluster' = ([UInt32] 0x25000052)
    'UseLegacyApicMode' = ([UInt32] 0x26000054)
    'X2ApicPolicy' = ([UInt32] 0x25000055)
    'UseBootProcessorOnly' = ([UInt32] 0x26000060)
    'NumberOfProcessors' = ([UInt32] 0x25000061)
    'ForceMaximumProcessors' = ([UInt32] 0x26000062)
    'ProcessorConfigurationFlags' = ([UInt32] 0x25000063)
    'MaximizeGroupsCreated' = ([UInt32] 0x26000064)
    'ForceGroupAwareness' = ([UInt32] 0x26000065)
    'GroupSize' = ([UInt32] 0x25000066)
    'UseFirmwarePciSettings' = ([UInt32] 0x26000070)
    'MsiPolicy' = ([UInt32] 0x25000071)
    'SafeBoot' = ([UInt32] 0x25000080)
    'SafeBootAlternateShell' = ([UInt32] 0x26000081)
    'BootLogInitialization' = ([UInt32] 0x26000090)
    'VerboseObjectLoadMode' = ([UInt32] 0x26000091)
    'KernelDebuggerEnabled' = ([UInt32] 0x260000a0)
    'DebuggerHalBreakpoint' = ([UInt32] 0x260000a1)
    'UsePlatformClock' = ([UInt32] 0x260000A2)
    'ForceLegacyPlatform' = ([UInt32] 0x260000A3)
    'TscSyncPolicy' = ([UInt32] 0x250000A6)
    'EmsEnabled' = ([UInt32] 0x260000b0)
    'DriverLoadFailurePolicy' = ([UInt32] 0x250000c1)
    'BootMenuPolicyWinload' = ([UInt32] 0x250000C2)
    'AdvancedOptionsOneTime' = ([UInt32] 0x260000C3)
    'BootStatusPolicy' = ([UInt32] 0x250000E0)
    'DisableElamDrivers' = ([UInt32] 0x260000E1)
    'HypervisorLaunchType' = ([UInt32] 0x250000F0)
    'HypervisorDebugEnabled' = ([UInt32] 0x260000F2)
    'HypervisorDebugType' = ([UInt32] 0x250000F3)
    'HypervisorDebugPort' = ([UInt32] 0x250000F4)
    'HypervisorBaudrate' = ([UInt32] 0x250000F5)
    'HypervisorDebug1394Channel' = ([UInt32] 0x250000F6)
    'BootUxPolicy' = ([UInt32] 0x250000F7)
    'HypervisorDebugBusParams' = ([UInt32] 0x220000F9)
    'HypervisorNumProc' = ([UInt32] 0x250000FA)
    'HypervisorRootProcPerNode' = ([UInt32] 0x250000FB)
    'HypervisorUseLargeVTlb' = ([UInt32] 0x260000FC)
    'HypervisorDebugNetHostIp' = ([UInt32] 0x250000FD)
    'HypervisorDebugNetHostPort' = ([UInt32] 0x250000FE)
    'TpmBootEntropyPolicy' = ([UInt32] 0x25000100)
    'HypervisorDebugNetKey' = ([UInt32] 0x22000110)
    'HypervisorDebugNetDhcp' = ([UInt32] 0x26000114)
    'HypervisorIommuPolicy' = ([UInt32] 0x25000115)
    'XSaveDisable' = ([UInt32] 0x2500012b)
    'RamdiskImageOffset' = ([UInt32] 0x35000001)
    'TftpClientPort' = ([UInt32] 0x35000002)
    'RamdiskSdiDevice' = ([UInt32] 0x31000003)
    'RamdiskSdiPath' = ([UInt32] 0x32000004)
    'RamdiskImageLength' = ([UInt32] 0x35000005)
    'RamdiskExportAsCd' = ([UInt32] 0x36000006)
    'RamdiskTftpBlockSize' = ([UInt32] 0x36000007)
    'RamdiskTftpWindowSize' = ([UInt32] 0x36000008)
    'RamdiskMulticastEnabled' = ([UInt32] 0x36000009)
    'RamdiskMulticastTftpFallback' = ([UInt32] 0x3600000A)
    'RamdiskTftpVarWindow' = ([UInt32] 0x3600000B)
    'DeviceType' = ([UInt32] 0x45000001)
    'ApplicationRelativePath' = ([UInt32] 0x42000002)
    'RamdiskDeviceRelativePath' = ([UInt32] 0x42000003)
    'OmitOsLoaderElements' = ([UInt32] 0x46000004)
    'ElementsToMigrate' = ([UInt32] 0x47000006)
    'RecoveryOs' = ([UInt32] 0x46000010)
}
#endregion

function New-BCDStore {
<#
.SYNOPSIS

Creates a new BCD store.

.DESCRIPTION

New-BCDStore creates a new BCD store at the file path specified. New-BCDStore has no effect on the system store. Equivalent to the following command:

bcdedit.exe /createstore <filename>

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER FilePath

Specifies the filename of the boot configuration data store. The file path specified can be a full file path or just a filename which will save the specified file to the current directory.

.PARAMETER CimSession

Specifies the CIM session to use for this function. Enter a variable that contains the CIM session or a command that creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see about_CimSessions.

.EXAMPLE

New-BCDStore -FilePath blah.bcd

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore

Outputs a BCD store instance for use with the *-BCDObject functions.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        [ValidateNotNullOrEmpty()]
        $FilePath,

        [Alias('Session')]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    $CimMethodArgs = @{}

    if ($CimSession) { $CimMethodArgs['CimSession'] = $CimSession }

    $ParentPath = Split-Path -Path $FilePath -Parent
    $LeafPath =   Split-Path -Path $FilePath -Leaf

    if (($ParentPath -eq '') -or ($ParentPath -eq '.')) {
        # A relative path was specified.
        $ParentPath = $PWD
    }

    $FullStorePath = Join-Path -Path $ParentPath -ChildPath $LeafPath

    $CreateStoreResult = Invoke-CimMethod -Namespace root/wmi -ClassName BCDStore -MethodName CreateStore -Arguments @{ File = $FullStorePath } @CimMethodArgs

    if ($CreateStoreResult.ReturnValue) {
        $CreateStoreResult.Store
    } else {
        Write-Error "Failed to create a BCD store: $FullStorePath"
    }
}

function Export-BCDStore {
<#
.SYNOPSIS

Exports the system BCD store to a file.

.DESCRIPTION

Export-BCDStore saves a backup of the system BCD store to a file. Equivalent to the following command:

bcdedit.exe /export <filename>

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER FilePath

Specifies the path where the BCD store backup will be saved. The file path specified can be a full file path or just a filename which will save the specified file to the current directory.

.PARAMETER CimSession

Specifies the CIM session to use for this function. Enter a variable that contains the CIM session or a command that creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see about_CimSessions.

.EXAMPLE

Export-BCDStore -FilePath BCDbackup.bcd

Exports the system BCD store to BCDbackup.bcd in the current directory.

.EXAMPLE

Export-BCDStore -FilePath D:\Backups\BCDBackup.bin

Exports the system BCD store to the specified path.

.OUTPUTS

System.IO.FileInfo

Outputs a relevant FileInfo object to indicate that the BCD store backup was created.
#>

    [OutputType([System.IO.FileInfo])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        [ValidateNotNullOrEmpty()]
        $FilePath,

        [Alias('Session')]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    $CimMethodArgs = @{}

    if ($CimSession) { $CimMethodArgs['CimSession'] = $CimSession }

    $ParentPath = Split-Path -Path $FilePath -Parent
    $LeafPath =   Split-Path -Path $FilePath -Leaf

    if (($ParentPath -eq '') -or ($ParentPath -eq '.')) {
        # A relative path was specified.
        $ParentPath = $PWD
    }

    $FullStorePath = Join-Path -Path $ParentPath -ChildPath $LeafPath

    $ExportStoreResult = Invoke-CimMethod -Namespace root/wmi -ClassName BCDStore -MethodName ExportStore -Arguments @{ File = $FullStorePath } @CimMethodArgs

    if ($ExportStoreResult.ReturnValue) {
        Get-Item -Path $FullStorePath
    } else {
        Write-Error "Failed to export the system BCD store to $FullStorePath."
    }
}

function Import-BCDStore {
<#
.SYNOPSIS

Restores the BCD system store from a file.

.DESCRIPTION

Export-BCDStore command restores the state of the system store using a backup data file previously generated using Export-BCDStore. Any existing entries in the system store are deleted before the import takes place.

bcdedit.exe /import <filename> [/clean]

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER FilePath

Specifies the name of the file that is imported into the system store. The file path specified can be a full file path or just a filename which will save the specified file to the current directory.

.PARAMETER Clean

Specifies that all existing firmware boot entries should be deleted (only affects EFI systems).

.PARAMETER CimSession

Specifies the CIM session to use for this function. Enter a variable that contains the CIM session or a command that creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see about_CimSessions.

.EXAMPLE

Import-BCDStore -FilePath BCDbackup.bcd

.EXAMPLE

Import-BCDStore -FilePath D:\Backups\BCDBackup.bcd
#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [String]
        [ValidateNotNullOrEmpty()]
        $FilePath,

        [Switch]
        $Clean,

        [Alias('Session')]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession
    )

    $CimMethodArgs = @{}

    if ($CimSession) { $CimMethodArgs['CimSession'] = $CimSession }

    $FullStorePath = Resolve-Path -Path $FilePath

    $ImportStoreWithFlagsArgs = @{
        File = $FullStorePath.Path
        Flags = [UInt32] 0
    }

    if ($Clean) { $ImportStoreWithFlagsArgs['Flags'] = [UInt32] 1 }

    $ImportStoreWithFlagsResult = Invoke-CimMethod -Namespace root/wmi -ClassName BCDStore -MethodName ImportStoreWithFlags -Arguments $ImportStoreWithFlagsArgs @CimMethodArgs

    if (-not $ImportStoreWithFlagsResult.ReturnValue) {
        if (-not $PSBoundParameters['WhatIf']) {
            Write-Error "Failed to import from the following BCD store backup file: $FullStorePath"
        }
    }
}

function Get-BCDStore {
<#
.SYNOPSIS

Opens a BCD store.

.DESCRIPTION

Get-BCDStore opens the system BCD store or a backup BCD file. All functions in this module that implement a -BCDStore parameter require the output of this function.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER FilePath

Specifies the path to a BCD store backup file. The absense of this argument defaults to opening the system BCD store.

.PARAMETER CimSession

Specifies the CIM session to use for this function. Enter a variable that contains the CIM session or a command that creates or gets the CIM session, such as the New-CimSession or Get-CimSession cmdlets. For more information, see about_CimSessions.

.EXAMPLE

$BCDStore = Get-BCDStore

Opens the system BCD store.

.EXAMPLE

$BCDStore = Get-BCDStore -CimSession $CimSession

Opens a remote system BCD store using an established CIM session.

.EXAMPLE

$BCDStore = Get-BCDStore -FilePath .\exportedstore.bin

Opens a BCD store for a specified file.

.INPUTS

Microsoft.Management.Infrastructure.CimSession

Accepts one of more CIM session objects.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore

Outputs a BcdStore object that is required for all subsequent calls to BCD module functions.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
    [CmdletBinding()]
    param (
        [String]
        [ValidateNotNullOrEmpty()]
        $FilePath,

        [Parameter(ValueFromPipeline = $True)]
        [Alias('Session')]
        [Microsoft.Management.Infrastructure.CimSession[]]
        $CimSession
    )

    BEGIN {
        # If a CIM session is not provided, trick the function into thinking there is one.
        if (-not $PSBoundParameters['CimSession']) {
            $CimSession = ''
        }
    }

    PROCESS {
        foreach ($Session in $CimSession) {
            $CimMethodArgs = @{}

            if ($Session.Id) { $CimMethodArgs['CimSession'] = $Session }

            if ($FilePath) {
                $BCDPath = (Resolve-Path $FilePath).Path
            } else {
                $BCDPath = ''
            }

            $OpenStoreArg = @{
                Namespace = 'ROOT/WMI'
                ClassName = 'BcdStore'
                MethodName = 'OpenStore'
                Arguments = @{ File = $BCDPath }
            }

            $OpenStoreResult = Invoke-CimMethod @OpenStoreArg @CimMethodArgs

            if ($True -eq $OpenStoreResult.ReturnValue) {
                $OpenStoreResult.Store
            } else {
                Write-Error 'Unable to open BCD store. Likely reason: You do not have the required permissions to open the BCD store.'
            }
        }
    }
}

filter Get-BCDObject {
<#
.SYNOPSIS

Retrieves defined BCD objects from a BCD store.

.DESCRIPTION

Get-BCDObject returns defined BCD objects from a previously opened BCD store. Upon retrieving one or more BCD objects, relevant BCD objects can be retrieved.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER WellKnownId

Specifies the well-known BCD object identifier to be retrieved.

.PARAMETER Id

Specifies the BCD object identifier to be retrieved.

.PARAMETER Type

Returns BCD objects based on the specified raw object value. For example, 0x101FFFFF refers to firmware entries, specifically. 0x10200003 would refer to OS loader entries.

.PARAMETER BCDStore

Specifies the BCDStore object returned from the Get-BCDStore function.

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore | Get-BCDElement

Retrieves all defined BCD objects from the specified BCD store. This is equivalent to the following bcdedit command:

bcdedit.exe /enum all

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr | Get-BCDElement

Retrieves all defined boot loader BCD objects from the specified BCD store. This is equivalent to the following bcdedit command:

bcdedit.exe /enum {bootmgr}

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -Type 0x101FFFFF | Get-BCDElement

Retrieves all defined firmware BCD objects from the specified BCD store. This is equivalent to the following bcdedit command:

bcdedit.exe /enum firmware

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -Id b5b5d3df-3847-11e8-a5cf-c49ded12be66 | Get-BCDElement

Retrieves the BCD object for the corresponding GUID. This is equivalent to the following bcdedit command:

bcdedit.exe /enum {b5b5d3df-3847-11e8-a5cf-c49ded12be66}

.INPUTS

Microsoft.Management.Infrastructure.CimSession

Accepts one of more CIM session objects.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Outputs one or more BcdObject objects.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
    [CmdletBinding(DefaultParameterSetName = 'WellKnownId')]
    param (
        [Parameter(ParameterSetName = 'WellKnownId')]
        [ValidateSet(
            'Active',
            'Inherit',
            'Firmware',
            'OSLoader',
            'BootApp',
            'Resume',
            'EmsSettings',
            'ResumeLoaderSettings',
            'Default',
            'KernelDbgSettings',
            'DbgSettings',
            'EventSettings',
            'Legacy',
            'NtLdr',
            'BadMemory',
            'BootloaderSettings',
            'GlobalSettings',
            'HypervisorSettings',
            'BootMgr',
            'FWBootMgr',
            'RamDiskOptions',
            'MemDiag',
            'Current',
            'SetupEFI',
            'TargetTemplateEFI',
            'SetupPCAT',
            'TargetTemplatePCAT')]
        $WellKnownId,

        [Parameter(Mandatory, ParameterSetName = 'Id')]
        [Guid]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'Type')]
        [UInt32]
        $Type,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore
    )

    # These object types will need to be mapped to a raw type value.
    $FriendlyObjectTypes = @('Inherit', 'Firmware', 'OSLoader', 'BootApp', 'Resume')

    $HasFriendlyObjectType = $False
    if ($FriendlyObjectTypes -contains $WellKnownId) { $HasFriendlyObjectType = $True }

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDStore.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDStore.GetCimSessionInstanceId() }

    $GetObjectsResult = $null

    $BCDObjects = $null

    if ($WellKnownId -eq 'Active') {
        # equivalent to: bcdedit.exe /enum ACTIVE
        $BootMgr = Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr

        if ($BootMgr) {
            $BootMgr

            $DisplayOrder = $BootMgr | Get-BCDElement -Name DisplayOrder

            if ($DisplayOrder -and ($DisplayOrder.Ids.Count)) {
                $DisplayOrder.Ids | ForEach-Object { Get-BCDObject -BCDStore $BCDStore -Id $_ }
            }
        }

        return
    } elseif ($WellKnownId -and !$HasFriendlyObjectType) {
        $GetObjectsResult = Invoke-CimMethod -InputObject $BCDStore -MethodName OpenObject -Arguments @{ Id = $ObjectFriendlyNameMapping[$WellKnownId][0] } @CimMethodArgs
    
        if ($True -eq $GetObjectsResult.ReturnValue) { $BCDObjects = $GetObjectsResult.Object }
    } elseif ($Id) {
        $GetObjectsResult = Invoke-CimMethod -InputObject $BCDStore -MethodName OpenObject -Arguments @{ Id = "{$Id}" } @CimMethodArgs
    
        if ($True -eq $GetObjectsResult.ReturnValue) { $BCDObjects = $GetObjectsResult.Object }
    } elseif ($Type -or $HasFriendlyObjectType) {
        if ($HasFriendlyObjectType) {
            switch ($WellKnownId) {
                'Inherit'  { $TypeVal = 0x20000000 }
                'Firmware' { $TypeVal = 0x101FFFFF }
                'OSLoader' { $TypeVal = 0x10200003 }
                'BootApp'  { $TypeVal = 0x10200000 }
                'Resume'   { $TypeVal = 0x10200004 }
            }
        } else {
            $TypeVal = $Type
        }

        # Return all BCD objects of the specified type value.
        $GetObjectsResult = Invoke-CimMethod -InputObject $BCDStore -MethodName EnumerateObjects -Arguments @{ Type = $TypeVal } @CimMethodArgs

        if ($True -eq $GetObjectsResult.ReturnValue) { $BCDObjects = $GetObjectsResult.Objects }
    } else {
        # Return all defined BCD objects.
        $GetObjectsResult = Invoke-CimMethod -InputObject $BCDStore -MethodName EnumerateObjects -Arguments @{ Type = [UInt32] 0 } @CimMethodArgs

        if ($True -eq $GetObjectsResult.ReturnValue) { $BCDObjects = $GetObjectsResult.Objects }
    }

    foreach ($Object in $BCDObjects) {
        # Break out the components of each object type and append them to each BCDObject.
        $ObjectType = $ObjectTypes[[Int] (($Object.Type -band 0xF0000000) -shr 28)]
        $InheritableByValue = [Int] (($Object.Type -band 0x00F00000) -shr 20)
        $InheritableBy = @{
            1 = 'AnyObject'
            2 = 'ApplicationObjects'
            3 = 'DeviceObjects'
        }[$InheritableByValue]

        $ImageType = if ($ObjectType -eq 'Application') { $ImageTypes[$InheritableByValue] }
        $ApplicationTypeValue = [Int] $Object.Type -band 0x000FFFFF
        $ApplicationType = $null

        switch ($ObjectType) {
            'Inherit' { $ApplicationType = $InheritableTypes[$ApplicationTypeValue] }
            'Application' { $ApplicationType = $ApplicationTypes[$ApplicationTypeValue] }
        }

        Add-Member -InputObject $Object -MemberType NoteProperty -Name ObjectType -Value $ObjectType
        Add-Member -InputObject $Object -MemberType NoteProperty -Name InheritableBy -Value $InheritableBy
        Add-Member -InputObject $Object -MemberType NoteProperty -Name ApplicationImageType -Value $ImageType
        Add-Member -InputObject $Object -MemberType NoteProperty -Name ApplicationType -Value $ApplicationType
        Add-Member -InputObject $Object -MemberType NoteProperty -Name Store -Value $BCDStore
    }

    $BCDObjects
}

function New-BCDObject {
<#
.SYNOPSIS

Creates a new object entry in the specified BCD store.

.DESCRIPTION

New-BCDObject creates a new BCD object within the specified BCD store.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER WellKnownId

Specifies the well-known identifier to be used for the new entry.

.PARAMETER Id

Specifies an identifier for the BCD object to be created. It must be used with either -Application or -Inherit.

.PARAMETER Application

Specifies that the new entry must be an application entry.

.PARAMETER Inherit

Specifies that the new entry must be an inherit entry of the specified type.

.PARAMETER Description

Specifies the description element to be applied to the new entry.

.PARAMETER BCDStore

Specifies the BCDStore object returned from the Get-BCDStore function.

.EXAMPLE

Get-BCDStore -FilePath .\newstore.bcd | New-BCDObject -WellKnownId NtLdr -Description 'Earlier Windows OS Loader'

Creates a NTLDR based OS loader entry (Ntldr). This is equivalent to the following bcdedit.exe command:

bcdedit /create {ntldr} /d "Earlier Windows OS Loader"

.EXAMPLE

Get-BCDStore -FilePath .\newstore.bcd | New-BCDObject -WellKnownId RamDiskOptions

Creates a RAM disk additional options entry. This is equivalent to the following bcdedit.exe command:

bcdedit /create {ramdiskoptions}

.EXAMPLE

$BCDStore | New-BCDObject -Application OSLoader -Description 'Windows Vista'

Creates a new operating system boot entry. This is equivalent to the following bcdedit.exe command:

bcdedit /create /d "Windows Vista" /application osloader

.EXAMPLE

$BCDStore | New-BCDObject -WellKnownId DbgSettings

Creates a new debugger settings entry. This is equivalent to the following bcdedit.exe command:

bcdedit /create {dbgsettings}

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore

Accepts a single BCD store instance over the pipeline.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Outputs a BCD object instance.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'WellKnownId')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'WellKnownId')]
        [String]
        [ValidateSet(
            'EmsSettings',
            'ResumeLoaderSettings',
            'Default',
            'KernelDbgSettings',
            'DbgSettings',
            'EventSettings',
            'Legacy',
            'NtLdr',
            'BadMemory',
            'BootloaderSettings',
            'GlobalSettings',
            'HypervisorSettings',
            'BootMgr',
            'FWBootMgr',
            'RamDiskOptions',
            'MemDiag',
            'Current',
            'SetupEFI',
            'TargetTemplateEFI',
            'SetupPCAT',
            'TargetTemplatePCAT')]
        $WellKnownId,

        [Parameter(ParameterSetName = 'Application')]
        [Parameter(ParameterSetName = 'Inherit')]
        [Guid]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'Application')]
        [String]
        [ValidateSet(
            'BootApp',
            'BootSector',
            'OSLoader',
            'Resume',
            'Startup')]
        $Application,

        [Parameter(Mandatory, ParameterSetName = 'Inherit')]
        [ValidateSet(
            'BootSector',
            'FWBootMgr',
            'MemDiag',
            'NtLdr',
            'OSLoader',
            'Resume',
            'Device')]
        $Inherit,

        [String]
        $Description,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdStore')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDStore
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDStore.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDStore.GetCimSessionInstanceId() }

    $ObjectType = $null

    if ($WellKnownId) {
        $ObjectInfo = $ObjectFriendlyNameMapping[$WellKnownId]
        $ObjectGUID = [Guid] $ObjectInfo[0]
        $ObjectType = $ObjectInfo[1]
    } elseif($Id) {
        $ObjectGUID = $Id
    } else {
        # Auto-gen a GUID
        $ObjectGUID = [Guid]::NewGuid()
    }

    # For -Application and -Inherit, I'm striving for feature parity with bcdedit.exe. See bcdedit.exe /create /?
    if ($Application) {
        $ObjectType = @{
            BootApp =    [UInt32] 0x1020000A
            BootSector = [UInt32] 0x10400008
            OSLoader =   [UInt32] 0x10200003
            Resume =     [UInt32] 0x10200004
            Startup =    [UInt32] 0x10400009
        }[$Application]
    } elseif($Inherit) {
        # -Inherit was specified
        $ObjectType = @{
            BootMgr =    [UInt32] 0x20200002
            BootSector = [UInt32] 0x20200008
            FWBootMgr =  [UInt32] 0x20200001
            MemDiag =    [UInt32] 0x20200005
            NtLdr =      [UInt32] 0x20200006
            OSLoader =   [UInt32] 0x20200003
            Resume =     [UInt32] 0x20200004
            Device =     [UInt32] 0x20300000
        }[$Inherit]
    }

    $CreateObjectArgs = @{
        Id = "{$($ObjectGUID.Guid)}"
        Type = $ObjectType
    }

    $CreateObjectResult = Invoke-CimMethod -InputObject $BCDStore -MethodName CreateObject -Arguments $CreateObjectArgs @CimMethodArgs

    # The object was created successfully
    if ($CreateObjectResult -and $CreateObjectResult.ReturnValue) {
        $CreatedBCDObject = Get-BCDObject -BCDStore $BCDStore -Id $CreateObjectResult.Object.Id

        if ($CreatedBCDObject) {
            if ($Description) {
                $DescriptionElement = $CreatedBCDObject | Get-BCDElement -Name Description

                if ($DescriptionElement) {
                    # An existing Description element exists. Set the existing value.
                    $DescriptionElement | Set-BCDElement -String $Description
                } else {
                    # No Description element exists. Create a new one.
                    $null = $CreatedBCDObject | New-BCDElement -Name Description -String $Description
                }
            }

            $CreatedBCDObject
        }
    } else {
        if (-not $PSBoundParameters['WhatIf']) {
            Write-Error "Failed to create BCD object. Object ID: $($ObjectGUID)"
        }
    }
}

function Copy-BCDObject {
<#
.SYNOPSIS

Creates a copy of the specified BCD object.

.DESCRIPTION

Copy-BCDObject creates a copy of the specified BCD object with an optional description element.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER Description

Specifies the description element to be applied to the copied entry.

.PARAMETER BCDObject

Specifies the BCD object to copy from.

.EXAMPLE

Get-BCDStore -FilePath .\newstore.bcd | Get-BCDObject -Id '{59b10ca6-6a57-4884-9d22-4331516f84c9}' | Copy-BCDObject -Description 'Copy of entry'

Creates a copy of the specified operating system boot entry. This is equivalent to the following bcdedit.exe command:

bcdedit /copy {cbd971bf-b7b8-4885-951a-fa03044f5d71} /d "Copy of entry"

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Accepts a single BCD object instance to be copied

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Outputs a BCD object instance.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [String]
        $Description,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDObject
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDStore.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDStore.GetCimSessionInstanceId() }

    $CopyObjectArgs = @{
        SourceStoreFile = $BCDObject.StoreFilePath
        SourceId = $BCDObject.Id
        Flags = [UInt32] 1 # Create a new object ID
    }

    $CopyObjectsResult = Invoke-CimMethod -InputObject $BCDObject.Store -MethodName CopyObject -Arguments $CopyObjectArgs @CimMethodArgs

    # The object copied successfully
    if ($CopyObjectsResult -and $CopyObjectsResult.ReturnValue) {
        $CopiedBCDObject = Get-BCDObject -BCDStore $BCDObject.Store -Id $CopyObjectsResult.Object.Id

        if ($CopiedBCDObject) {
            if ($Description) {
                $DescriptionElement = $CopiedBCDObject | Get-BCDElement -Name Description

                if ($DescriptionElement) {
                    # An existing Description element exists. Set the existing value.
                    $DescriptionElement | Set-BCDElement -String $Description
                } else {
                    # No Description element exists. Create a new one.
                    $null = $CopiedBCDObject | New-BCDElement -Name Description -String $Description
                }
            }

            $CopiedBCDObject
        }
    } else {
        if (-not $PSBoundParameters['WhatIf']) {
            Write-Error "Failed to copy BCD object. Source object ID: $($BCDObject.Id)"
        }
    }
}

filter Remove-BCDObject {
<#
.SYNOPSIS

Removes a BCD object from the specified BCD store.

.DESCRIPTION

Remove-BCDObject deletes a BCD object (along with all of its elements) from a BCD store. Currently, Remove-BCDObject does not support removing entries from the OS loader display order (i.e. the equivalent of the /cleanup bcdedit/exe switch).

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER BCDObject

Specifies the BCD object to remove.

.EXAMPLE

Get-BCDStore -FilePath .\newstore.bcd | Get-BCDObject -Id '{59b10ca6-6a57-4884-9d22-4331516f84c9}' | Remove-BCDObject

Creates a copy of the specified operating system boot entry. This is equivalent to the following bcdedit.exe command:

bcdedit /copy {cbd971bf-b7b8-4885-951a-fa03044f5d71} /d "Copy of entry"

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Accepts a single BCD object instance to be deleted.
#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDObject
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDStore.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDStore.GetCimSessionInstanceId() }

    $Result = Invoke-CimMethod -InputObject $BCDObject.Store -MethodName DeleteObject -Arguments @{ Id = $BCDObject.Id } @CimMethodArgs

    if ((-not $Result) -or (-not $Result.ReturnValue)) {
        if (-not $PSBoundParameters['WhatIf']) {
            Write-Error "Unable to delete the specified object. Object ID: $BCDObject.Id"
        }
    }
}

filter Get-BCDElement {
<#
.SYNOPSIS

Retrieves defined BCD elements from a BCD object.

.DESCRIPTION

Get-BCDElement returns defined BCD elements contained within a BCD object.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER Name

Specifies the name of the BCD element to return.

.PARAMETER Type

Returns BCD elements based on the specified raw element value.

.PARAMETER BCDObject

Specifies one or more BCD objects returned from Get-BCDObject.

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore | Get-BCDElement

Retrieves all BCD elements from within all BCD objects. This is equivalent to the following bcdedit command:

bcdedit.exe /enum ALL

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId OSLoader | Get-BCDElement -Name NX

Retrieves all NX elements from all defined OS loader BCD objects.

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore | Get-BCDElement -Type 0x25000002

Retrieves all instances of BCD elements with the specified element type value. This would be equivalent to suppplying "custom:0x25000002" to bcdedit.exe.

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr | Get-BCDElement

Retrieves all defined boot loader BCD elements from the specified BCD store. This is equivalent to the following bcdedit command:

bcdedit.exe /enum {bootmgr}

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId OSLoader | Get-BCDElement

Retrieves all defined OS loader BCD elements from the specified BCD store. This is equivalent to the following bcdedit command:

bcdedit.exe /enum OSLOADER

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Accepts one of more BCD objects returned from Get-BCDObject.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement

Outputs one or more BcdElement objects.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement')]
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(ParameterSetName = 'Name')]
        [String]
        [ValidateSet(
            'AdvancedOptions',
            'AdvancedOptionsOneTime',
            'AliasWindowsKey',
            'AllowedInMemorySettings',
            'AllowPrereleaseSignatures',
            'ApplicationRelativePath',
            'AttemptNonBcdStart',
            'AttemptResume',
            'AvoidLowMemory',
            'BadMemoryAccess',
            'BadMemoryList',
            'BaudRate',
            'BcdDevice',
            'BcdFilePath',
            'BootDebug',
            'BootEMS',
            'BootErrorUx',
            'Bootflow',
            'BootLogInitialization',
            'BootMenuPolicyWinLoad',
            'BootMenuPolicyWinResume',
            'BootSequence',
            'BootShutdownDisabled',
            'BootStatusDataLogDevice',
            'BootStatusDataLogPath',
            'BootStatusPolicy',
            'BootUxDisabled',
            'BootUxDumpStats',
            'BootUxFadeFrames',
            'BootUxPolicy',
            'BootUxReservePoolDebug',
            'BootUxShowStats',
            'BootUxtTransitionTime',
            'BusParams',
            'Channel',
            'ChargeThreshold',
            'ClusterModeAddressing',
            'ConfigAccessPolicy',
            'CustomActionsList',
            'DbgTransportPath',
            'DebugAddress',
            'DebuggerHalBreakpoint',
            'DebugOptionEnabled',
            'DebugPort',
            'DebugStart',
            'DebugType',
            'Default',
            'Description',
            'DetectKernelAndHal',
            'Device',
            'DeviceType',
            'DHCP',
            'DisableBootDisplay',
            'DisableCrashAutoReboot',
            'DisableElamDrivers',
            'DisableVesaBios',
            'DisableVgaMode',
            'DisplayBootMenu',
            'DisplayMessage',
            'DisplayMessageOverride',
            'DisplayOrder',
            'DriverLoadFailurePolicy',
            'ElementsToMigrate',
            'EMSBaudRate',
            'EmsEnabled',
            'EMSPort',
            'ExtendedInput',
            'FailureCount',
            'FileDevice',
            'FilePath',
            'FirstMegabytePolicy',
            'FlightSigning',
            'FontPath',
            'ForceFFUMode',
            'ForceFipsCrypto',
            'ForceGroupAwareness',
            'ForceLegacyPlatform',
            'ForceMaximumProcessors',
            'GraphicsModeDisabled',
            'GraphicsResolution',
            'GroupSize',
            'HalPath',
            'HighestMode',
            'HostIP',
            'HypervisorDebug1394Channel',
            'HypervisorBaudrate',
            'HypervisorDebugBusParams',
            'HypervisorDebugEnabled',
            'HypervisorDebugNetDhcp',
            'HypervisorDebugNetHostIp',
            'HypervisorDebugNetHostPort',
            'HypervisorDebugNetKey',
            'HypervisorDebugPort',
            'HypervisorDebugType',
            'HypervisorIommuPolicy',
            'HypervisorLaunchType',
            'HypervisorNumProc',
            'HypervisorRootProcPerNode',
            'HypervisorUseLargeVTlb',
            'IncreaseUserVa',
            'Inherit',
            'InitialConsoleInput',
            'IntegrityServices',
            'IsolatedContext',
            'KernelDebuggerEnabled',
            'KernelPath',
            'Key',
            'KeyringAddress',
            'LoadOptions',
            'Locale',
            'MaximizeGroupsCreated',
            'MeasuredBootLogFormat',
            'MobileGraphics',
            'MsiPolicy',
            'MultiBootSystem',
            'NoBootUxFade',
            'NoBootUxLogo',
            'NoBootUxProgress',
            'NoBootUxText',
            'NoErrorDisplay',
            'NoIntegrityChecks',
            'NoKeyboard',
            'NoLowMemory',
            'NoUMEx',
            'NumberOfProcessors',
            'NX',
            'OffModeCharging',
            'OmitOsLoaderElements',
            'OptionsEdit',
            'OSDevice',
            'PAEPolicy',
            'PassCount',
            'Path',
            'PerformanceFrequency',
            'PersistBootSequence',
            'Port',
            'PreserveBootStat',
            'ProcessCustomActionsFirst',
            'ProcessorConfigurationFlags',
            'RamdiskDeviceRelativePath',
            'RamdiskExportAsCd',
            'RamdiskImageLength',
            'RamdiskImageOffset',
            'RamdiskMulticastEnabled',
            'RamdiskMulticastTftpFallback',
            'RamdiskSdiDevice',
            'RamdiskSdiPath',
            'RamdiskTftpBlockSize',
            'RamdiskTftpVarWindow',
            'RamdiskTftpWindowSize',
            'RecoveryEnabled',
            'RecoveryOs',
            'RecoverySequence',
            'RelocatePhysical',
            'RemoveMemory',
            'RestartOnFailure',
            'RestrictApicCluster',
            'ResumeObject',
            'ResumeObject',
            'SafeBoot',
            'SafeBootAlternateShell',
            'SecurebootRawPolicy',
            'SkipFFUMode',
            'SystemRoot',
            'TargetName',
            'TestSigning',
            'TftpClientPort',
            'Timeout',
            'ToolsDisplayOrder',
            'TpmBootEntropyPolicy',
            'TraditionalKseg',
            'TruncateMemory',
            'TscSyncPolicy',
            'UseBootProcessorOnly',
            'UseFirmwarePciSettings',
            'UseLastGoodSettings',
            'UseLegacyApicMode',
            'UsePhysicalDestination',
            'UsePlatformClock',
            'UseVgaDriver',
            'VerboseObjectLoadMode',
            'VM',
            'VolumeBandId',
            'WinPE',
            'X2ApicPolicy',
            'XSaveDisable'
        )]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'Type')]
        [UInt32]
        $Type,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDObject
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDObject.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDObject.GetCimSessionInstanceId() }
    
    $BCDElements = $null

    if ($Name -or $Type) {
        if ($Name) {
            # Map friendly name to element value.
            $ElementType = $ElementNameToValueMapping[$Name]
        } else {
            $ElementType = $Type
        }
        
        $GetElementResult = Invoke-CimMethod -InputObject $BcdObject -MethodName GetElement -Arguments @{ Type = $ElementType } @CimMethodArgs -ErrorAction SilentlyContinue

        if ($True -eq $GetElementResult.ReturnValue) { $BCDElements = $GetElementResult.Element }
    } else {
        # Get all defined BCD elements for the specified BCD objects.
        $EnumerateElementsResult = Invoke-CimMethod -InputObject $BcdObject -MethodName EnumerateElements @CimMethodArgs

        if ($True -eq $EnumerateElementsResult.ReturnValue) { $BCDElements = $EnumerateElementsResult.Elements }
    }

    foreach ($Element in $BCDElements) {
        # Break out the components of each element type and append them to each BCDElement.
        $ElementType = $ElementTypes[[Int] (($Element.Type -band 0xF0000000) -shr 28)]

        $FriendlyName = $null

        switch ($ElementType) {
            'Library' { $FriendlyName = $ElementLibraryNameMapping[$Element.Type] }
            'Application' {
                switch ($BcdObject.ApplicationType) {
                    'OSLoader' { $FriendlyName = $ElementOSLoaderNameMapping[$Element.Type] }
                    'BootMgr' { $FriendlyName = $ElementBootMgrNameMapping[$Element.Type] }
                    'FWBootMgr' { $FriendlyName = $ElementBootMgrNameMapping[$Element.Type] }
                    'MemDiag' { $FriendlyName = $ElementMemDiagNameMapping[$Element.Type] }
                    'Resume' { $FriendlyName = $ElementBootMgrNameMapping[$Element.Type] }
                    # I might need to account for the following separately upon encountering them:
                    # NTLdr, SetupLdr, Bootsector, StartupCom
                    default { $FriendlyName = $ElementInheritableNameMapping[$Element.Type] }
                }
             }
            'Device' { $FriendlyName = $ElementDeviceNameMapping[$Element.Type] }
            'Template' { $FriendlyName = $ElementTemplateNameMapping[$Element.Type] }
        }

        if (-not $FriendlyName) {
            # Emulate the output from bcdedit.exe when an element name cannot be resolved.
            $FriendlyName = "Custom:$($Element.Type.ToString('X8'))"
        }

        Add-Member -InputObject $Element -MemberType NoteProperty -Name ElementType -Value $ElementType
        Add-Member -InputObject $Element -MemberType NoteProperty -Name ElementName -Value $FriendlyName
        Add-Member -InputObject $Element -MemberType NoteProperty -Name Object -Value $BcdObject
    }

    $BCDElements
}

function New-BCDElement {
<#
.SYNOPSIS

Creates a new BCD element within a specified BCD object.

.DESCRIPTION

New-BCDElement creates a new BCD element within a specified BCD object. New-BCDElement will validate that the data type of the value specified matches the data type expected for the supplied element - e.g. if an element expects a string value, you must supply the value via the -String parameter.

New-BCDElement is equivalent to calling "bcdedit.exe /set". New-BCDElement and Set-BCDElement are distinguished in that New-BCDElement creates a new element (with a corresponding value) and Set-BCDElement sets the value of an existing element.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER Name

Specifies the name of the BCD element to create within the specified BCD object.

.PARAMETER Type

Specifies the raw element type value of the BCD element to create within the specified BCD object.

.PARAMETER String

Specifies the value to set the BCD element to as a string. Specifying -Object calls the WMI SetStringElement BCDObject method.

.PARAMETER Integer

Specifies the value to set the BCD element to as a UInt64. Specifying -Object calls the WMI SetIntegerElement BCDObject method.

.PARAMETER IntegerList

Specifies the value to set the BCD element to as a UInt64 array. Specifying -Object calls the WMI SetIntegerListElement BCDObject method.

.PARAMETER Boolean

Specifies the value to set the BCD element to as a boolean. Specifying -Object calls the WMI SetBooleanElement BCDObject method.

.PARAMETER Object

Specifies the value to set the BCD element to as a GUID. Specifying -Object calls the WMI SetObjectElement BCDObject method.

.PARAMETER ObjectList

Specifies the value to set the BCD element to as a GUID array. A common scenario for setting this value would be when altering the OS loader display order in a boot manager. Specifying -Object calls the WMI SetObjectListElement BCDObject method.

.PARAMETER BCDObject

Specifies the BCD object instance returned from Get-BCDObject. The specified object instance is where the new element will reside.

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Current | New-BCDElement -Name NX -Integer 2

Creates and sets the NX setting for the current OS loader to 2 (AlwaysOff). This is equivalent to the following bcdedit.exe command:

bcdedit.exe /set {current} nx AlwaysOff

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Default | New-BCDElement -Name BootMenuPolicyWinLoad -Integer 0

Creates and sets the boot menu policy of the default OS loader to 0 (Legacy). This is equivalent to the following bcdedit.exe command:

bcdedit.exe /set {default} bootmenupolicy legacy

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Current | New-BCDElement -Name TestSigning -Boolean $False

Creates and sets testsigning to off on the current OS loader. This is equivalent to the following bcdedit.exe command:

bcdedit.exe -set TESTSIGNING OFF

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr | New-BCDElement -Name DisplayOrder -ObjectList '{b5b5d3df-3847-11e8-a5cf-c49ded12be66}', '{3a84da2e-ccc6-11e7-b3db-a14e20c7ef3d}'

Creates and sets the OS loader display order for the boot manager. This is equivalent to the following bcdedit.exe command:

bcdedit.exe /displayorder {b5b5d3df-3847-11e8-a5cf-c49ded12be66} {3a84da2e-ccc6-11e7-b3db-a14e20c7ef3d}

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Current | New-BCDElement -Name KernelDebuggerEnabled -Boolean $False

Turns kernel debugging off for the current OS loader. This is equivalent to the following bcdedit.exe command:

bcdedit.exe /debug off

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr | Get-BCDElement -Name BootDebug | Set-BCDElement -Boolean $False -PassThru

Turns early boot debugging off for the boot manager. This is equivalent to the following bcdedit.exe command:

bcdedit.exe /set {bootmgr} bootdebug off

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject

Accepts a single BCD object returned from Get-BCDObject. New-BCDElement will only work when it is supplied with a BCD object instance.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'StringElementName')]
        [Parameter(Mandatory, ParameterSetName = 'IntegerElementName')]
        [Parameter(Mandatory, ParameterSetName = 'IntegerListElementName')]
        [Parameter(Mandatory, ParameterSetName = 'BooleanElementName')]
        [Parameter(Mandatory, ParameterSetName = 'ObjectElementName')]
        [Parameter(Mandatory, ParameterSetName = 'ObjectListElementName')]
        [String]
        [ValidateSet(
            'AdvancedOptions',
            'AdvancedOptionsOneTime',
            'AliasWindowsKey',
            'AllowedInMemorySettings',
            'AllowPrereleaseSignatures',
            'ApplicationRelativePath',
            'AttemptNonBcdStart',
            'AttemptResume',
            'AvoidLowMemory',
            'BadMemoryAccess',
            'BadMemoryList',
            'BaudRate',
            'BcdDevice',
            'BcdFilePath',
            'BootDebug',
            'BootEMS',
            'BootErrorUx',
            'Bootflow',
            'BootLogInitialization',
            'BootMenuPolicyWinLoad',
            'BootMenuPolicyWinResume',
            'BootSequence',
            'BootShutdownDisabled',
            'BootStatusDataLogDevice',
            'BootStatusDataLogPath',
            'BootStatusPolicy',
            'BootUxDisabled',
            'BootUxDumpStats',
            'BootUxFadeFrames',
            'BootUxPolicy',
            'BootUxReservePoolDebug',
            'BootUxShowStats',
            'BootUxtTransitionTime',
            'BusParams',
            'Channel',
            'ChargeThreshold',
            'ClusterModeAddressing',
            'ConfigAccessPolicy',
            'CustomActionsList',
            'DbgTransportPath',
            'DebugAddress',
            'DebuggerHalBreakpoint',
            'DebugOptionEnabled',
            'DebugPort',
            'DebugStart',
            'DebugType',
            'Default',
            'Description',
            'DetectKernelAndHal',
            'Device',
            'DeviceType',
            'DHCP',
            'DisableBootDisplay',
            'DisableCrashAutoReboot',
            'DisableElamDrivers',
            'DisableVesaBios',
            'DisableVgaMode',
            'DisplayBootMenu',
            'DisplayMessage',
            'DisplayMessageOverride',
            'DisplayOrder',
            'DriverLoadFailurePolicy',
            'ElementsToMigrate',
            'EMSBaudRate',
            'EmsEnabled',
            'EMSPort',
            'ExtendedInput',
            'FailureCount',
            'FileDevice',
            'FilePath',
            'FirstMegabytePolicy',
            'FlightSigning',
            'FontPath',
            'ForceFFUMode',
            'ForceFipsCrypto',
            'ForceGroupAwareness',
            'ForceLegacyPlatform',
            'ForceMaximumProcessors',
            'GraphicsModeDisabled',
            'GraphicsResolution',
            'GroupSize',
            'HalPath',
            'HighestMode',
            'HostIP',
            'HypervisorDebug1394Channel',
            'HypervisorBaudrate',
            'HypervisorDebugBusParams',
            'HypervisorDebugEnabled',
            'HypervisorDebugNetDhcp',
            'HypervisorDebugNetHostIp',
            'HypervisorDebugNetHostPort',
            'HypervisorDebugNetKey',
            'HypervisorDebugPort',
            'HypervisorDebugType',
            'HypervisorIommuPolicy',
            'HypervisorLaunchType',
            'HypervisorNumProc',
            'HypervisorRootProcPerNode',
            'HypervisorUseLargeVTlb',
            'IncreaseUserVa',
            'Inherit',
            'InitialConsoleInput',
            'IntegrityServices',
            'IsolatedContext',
            'KernelDebuggerEnabled',
            'KernelPath',
            'Key',
            'KeyringAddress',
            'LoadOptions',
            'Locale',
            'MaximizeGroupsCreated',
            'MeasuredBootLogFormat',
            'MobileGraphics',
            'MsiPolicy',
            'MultiBootSystem',
            'NoBootUxFade',
            'NoBootUxLogo',
            'NoBootUxProgress',
            'NoBootUxText',
            'NoErrorDisplay',
            'NoIntegrityChecks',
            'NoKeyboard',
            'NoLowMemory',
            'NoUMEx',
            'NumberOfProcessors',
            'NX',
            'OffModeCharging',
            'OmitOsLoaderElements',
            'OptionsEdit',
            'OSDevice',
            'PAEPolicy',
            'PassCount',
            'Path',
            'PerformanceFrequency',
            'PersistBootSequence',
            'Port',
            'PreserveBootStat',
            'ProcessCustomActionsFirst',
            'ProcessorConfigurationFlags',
            'RamdiskDeviceRelativePath',
            'RamdiskExportAsCd',
            'RamdiskImageLength',
            'RamdiskImageOffset',
            'RamdiskMulticastEnabled',
            'RamdiskMulticastTftpFallback',
            'RamdiskSdiDevice',
            'RamdiskSdiPath',
            'RamdiskTftpBlockSize',
            'RamdiskTftpVarWindow',
            'RamdiskTftpWindowSize',
            'RecoveryEnabled',
            'RecoveryOs',
            'RecoverySequence',
            'RelocatePhysical',
            'RemoveMemory',
            'RestartOnFailure',
            'RestrictApicCluster',
            'ResumeObject',
            'ResumeObject',
            'SafeBoot',
            'SafeBootAlternateShell',
            'SecurebootRawPolicy',
            'SkipFFUMode',
            'SystemRoot',
            'TargetName',
            'TestSigning',
            'TftpClientPort',
            'Timeout',
            'ToolsDisplayOrder',
            'TpmBootEntropyPolicy',
            'TraditionalKseg',
            'TruncateMemory',
            'TscSyncPolicy',
            'UseBootProcessorOnly',
            'UseFirmwarePciSettings',
            'UseLastGoodSettings',
            'UseLegacyApicMode',
            'UsePhysicalDestination',
            'UsePlatformClock',
            'UseVgaDriver',
            'VerboseObjectLoadMode',
            'VM',
            'VolumeBandId',
            'WinPE',
            'X2ApicPolicy',
            'XSaveDisable'
        )]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'StringElementType')]
        [Parameter(Mandatory, ParameterSetName = 'IntegerElementType')]
        [Parameter(Mandatory, ParameterSetName = 'IntegerListElementType')]
        [Parameter(Mandatory, ParameterSetName = 'BooleanElementType')]
        [Parameter(Mandatory, ParameterSetName = 'ObjectElementType')]
        [Parameter(Mandatory, ParameterSetName = 'ObjectListElementType')]
        [UInt32]
        $Type,

        [Parameter(Mandatory, ParameterSetName = 'StringElementName')]
        [Parameter(Mandatory, ParameterSetName = 'StringElementType')]
        [String]
        $String,

        [Parameter(Mandatory, ParameterSetName = 'IntegerElementName')]
        [Parameter(Mandatory, ParameterSetName = 'IntegerElementType')]
        [UInt64]
        $Integer,

        [Parameter(Mandatory, ParameterSetName = 'IntegerListElementName')]
        [Parameter(Mandatory, ParameterSetName = 'IntegerListElementType')]
        [UInt64[]]
        $IntegerList,

        [Parameter(Mandatory, ParameterSetName = 'BooleanElementName')]
        [Parameter(Mandatory, ParameterSetName = 'BooleanElementType')]
        [Boolean]
        $Boolean,

        [Parameter(Mandatory, ParameterSetName = 'ObjectElementName')]
        [Parameter(Mandatory, ParameterSetName = 'ObjectElementType')]
        [Guid]
        $Object,

        [Parameter(Mandatory, ParameterSetName = 'ObjectListElementName')]
        [Parameter(Mandatory, ParameterSetName = 'ObjectListElementType')]
        [Guid[]]
        $ObjectList,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdObject')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDObject
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDObject.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDObject.GetCimSessionInstanceId() }

    if ($Name) {
        # Map friendly name to element value.
        $ElementType = $ElementNameToValueMapping[$Name]
    } elseif ($Type) {
        # -Type was specified.
        $ElementType = $Type
    }

    # Validate that the element isn't already defined.
    $ExistingElement = Get-BCDElement -BcdObject $BCDObject -Type $ElementType

    # If there is demand, I can implement a -Force switch to force the setting of an existing element value.
    if ($ExistingElement) {
        Write-Error "The element specified already exists. If you want to set the value of an existing element, call Set-BCDElement."
        return
    }

    $ElementFormat = $ElementFormatTypes[[Int32] ((($ElementType) -band 0x0F000000) -shr 24)]

    $ElementFormatMismatch = $False

    switch ($ElementFormat) {
       # To-do: support device objects when it is requested. I honestly don't feel like implementing this right now.
       #'Device'   { if (-not $PSBoundParameters['Device'])      { $ElementFormatMismatch = $True; $ArgToSpecify = 'Device' } }
        'String'   { if (-not $PSBoundParameters.ContainsKey('String'))      { $ElementFormatMismatch = $True; $ArgToSpecify = 'String' } }
        'Id'       { if (-not $PSBoundParameters.ContainsKey('Object'))      { $ElementFormatMismatch = $True; $ArgToSpecify = 'Object' } }
        'Ids'      { if (-not $PSBoundParameters.ContainsKey('ObjectList'))  { $ElementFormatMismatch = $True; $ArgToSpecify = 'ObjectList' } }
        'Integer'  { if (-not $PSBoundParameters.ContainsKey('Integer'))     { $ElementFormatMismatch = $True; $ArgToSpecify = 'Integer' } }
        'Boolean'  { if (-not $PSBoundParameters.ContainsKey('Boolean'))     { $ElementFormatMismatch = $True; $ArgToSpecify = 'Boolean' } }
        'Integers' { if (-not $PSBoundParameters.ContainsKey('IntegerList')) { $ElementFormatMismatch = $True; $ArgToSpecify = 'IntegerList' } }
    }

    if ($ElementFormatMismatch) {
        Write-Error "The data type of the element value specified does not match the expected data type for the specified element. Supply a correct value to -$ArgToSpecify and try again."
    } else {
        if ($PSBoundParameters.ContainsKey('String')) {
            $MethodName = 'SetStringElement'
            $Arguments = @{ String = $String }
        } elseif ($PSBoundParameters.ContainsKey('Object')) {
            $MethodName = 'SetObjectElement'
            # GUID strings must have curly braces upon calling the SetObjectElement method.
            $Arguments = @{ Id = "{$($Object.Guid)}" }
        } elseif ($PSBoundParameters.ContainsKey('ObjectList')) {
            $MethodName = 'SetObjectListElement'
            # GUID strings must have curly braces upon calling the SetObjectListElement method.
            $Arguments = @{ Ids = ([String[]] ($ObjectList.Guid | ForEach-Object { "{$_}" })) }
        } elseif ($PSBoundParameters.ContainsKey('Integer')) {
            $MethodName = 'SetIntegerElement'
            $Arguments = @{ Integer = $Integer }
        } elseif ($PSBoundParameters.ContainsKey('Boolean')) {
            $MethodName = 'SetBooleanElement'
            $Arguments = @{ Boolean = $Boolean }
        } elseif ($PSBoundParameters.ContainsKey('IntegerList')) {
            $MethodName = 'SetIntegerListElement'
            $Arguments = @{ Integers = $IntegerList }
        }

        $Arguments['Type'] = $ElementType

        $Result = Invoke-CimMethod -InputObject $BCDObject -MethodName $MethodName -Arguments $Arguments @CimMethodArgs

        if ($Result -and $Result.ReturnValue) {
            Get-BCDElement -BcdObject $BCDObject -Type $ElementType
        } else {
            if (-not $PSBoundParameters['WhatIf']) {
                Write-Error "Failed to create the specified BCD element. Element type: 0x$($ElementType.ToString('X8')). Object ID: $($BCDObject.Id)"
            }
        }
    }
}

function Set-BCDElement {
<#
.SYNOPSIS

Sets the value of an existing BCD element.

.DESCRIPTION

Set-BCDElement sets the value of an existing BCD element returned from Get-BCDElement. Set-BCDElement will validate that the data type of the value specified matches the data type expected for the supplied element - e.g. if an element expects a string value, you must supply the value via the -String parameter.

Set-BCDElement is equivalent to calling "bcdedit.exe /set".

If the BCD element doesn't already exist, call New-BCDElement to create and set the element.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER String

Specifies the value to set the BCD element to as a string. Specifying -Object calls the WMI SetStringElement BCDObject method.

.PARAMETER Integer

Specifies the value to set the BCD element to as a UInt64. Specifying -Object calls the WMI SetIntegerElement BCDObject method.

.PARAMETER IntegerList

Specifies the value to set the BCD element to as a UInt64 array. Specifying -Object calls the WMI SetIntegerListElement BCDObject method.

.PARAMETER Boolean

Specifies the value to set the BCD element to as a boolean. Specifying -Object calls the WMI SetBooleanElement BCDObject method.

.PARAMETER Object

Specifies the value to set the BCD element to as a GUID. Specifying -Object calls the WMI SetObjectElement BCDObject method.

.PARAMETER ObjectList

Specifies the value to set the BCD element to as a GUID array. A common scenario for setting this value would be when altering the OS loader display order in a boot manager. Specifying -Object calls the WMI SetObjectListElement BCDObject method.

.PARAMETER BCDElement

Specifies the BCD element instance returned from Get-BCDElement.

.PARAMETER PassThru

Specifies that the updated BCD element instance should be returned upon successfully setting the value. If Set-BCDElement will default to not outputting an object.

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Current | Get-BCDElement -Name NX | Set-BCDElement -Integer 2

Sets the NX setting for the current OS loader to 2 (AlwaysOff). This is equivalent to the following bcdedit.exe command:

bcdedit.exe /set {current} nx AlwaysOff

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Default | Get-BCDElement -Name BootMenuPolicyWinLoad | Set-BCDElement -Integer 0 -PassThru

Sets the boot menu policy of the default OS loader to 0 (Legacy). This is equivalent to the following bcdedit.exe command:

bcdedit.exe /set {default} bootmenupolicy legacy

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Current | Get-BCDElement -Name TestSigning | Set-BCDElement -Boolean $False -PassThru

Sets testsigning to off on the current OS loader. This is equivalent to the following bcdedit.exe command:

bcdedit.exe -set TESTSIGNING OFF

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr | Get-BCDElement -Name DisplayOrder | Set-BCDElement -ObjectList '{b5b5d3df-3847-11e8-a5cf-c49ded12be66}', '{3a84da2e-ccc6-11e7-b3db-a14e20c7ef3d}' -PassThru

Sets the OS loader display order for the boot manager. This is equivalent to the following bcdedit.exe command:

bcdedit.exe /displayorder {b5b5d3df-3847-11e8-a5cf-c49ded12be66} {3a84da2e-ccc6-11e7-b3db-a14e20c7ef3d}

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId Current | Get-BCDElement -Name KernelDebuggerEnabled | Set-BCDElement -Boolean $False -PassThru

Turns kernel debugging off for the current OS loader. This is equivalent to the following bcdedit.exe command:

bcdedit.exe /debug off

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr | Get-BCDElement -Name BootDebug | Set-BCDElement -Boolean $False -PassThru

Turns early boot debugging off for the boot manager. This is equivalent to the following bcdedit.exe command:

bcdedit.exe /set {bootmgr} bootdebug off

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement

Accepts a single BCD element returned from Get-BCDElement. Set-BCDElement will only work when it is supplied with a BCD element instance.

.OUTPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement

Outputs a BcdElement instance only if -PassThru is specified.
#>

    [OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement')]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'StringElement')]
        [String]
        $String,

        [Parameter(Mandatory, ParameterSetName = 'IntegerElement')]
        [UInt64]
        $Integer,

        [Parameter(Mandatory, ParameterSetName = 'IntegerListElement')]
        [UInt64[]]
        $IntegerList,

        [Parameter(Mandatory, ParameterSetName = 'BooleanElement')]
        [Boolean]
        $Boolean,

        [Parameter(Mandatory, ParameterSetName = 'ObjectElement')]
        [Guid]
        $Object,

        [Parameter(Mandatory, ParameterSetName = 'ObjectListElement')]
        [Guid[]]
        $ObjectList,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'StringElement')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'IntegerElement')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'IntegerListElement')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'BooleanElement')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ObjectElement')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'ObjectListElement')]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDElement,

        [Switch]
        $PassThru
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDElement.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDElement.GetCimSessionInstanceId() }

    $ElementFormat = $ElementFormatTypes[[Int32] ((($BCDElement.Type) -band 0x0F000000) -shr 24)]

    $ElementFormatMismatch = $False

    switch ($ElementFormat) {
       # To-do: support device objects when it is requested. I honestly don't feel like implementing this right now.
       #'Device'   { if (-not $PSBoundParameters['Device'])      { $ElementFormatMismatch = $True; $ArgToSpecify = 'Device' } }
        'String'   { if (-not $PSBoundParameters.ContainsKey('String'))      { $ElementFormatMismatch = $True; $ArgToSpecify = 'String' } }
        'Id'       { if (-not $PSBoundParameters.ContainsKey('Object'))      { $ElementFormatMismatch = $True; $ArgToSpecify = 'Object' } }
        'Ids'      { if (-not $PSBoundParameters.ContainsKey('ObjectList'))  { $ElementFormatMismatch = $True; $ArgToSpecify = 'ObjectList' } }
        'Integer'  { if (-not $PSBoundParameters.ContainsKey('Integer'))     { $ElementFormatMismatch = $True; $ArgToSpecify = 'Integer' } }
        'Boolean'  { if (-not $PSBoundParameters.ContainsKey('Boolean'))     { $ElementFormatMismatch = $True; $ArgToSpecify = 'Boolean' } }
        'Integers' { if (-not $PSBoundParameters.ContainsKey('IntegerList')) { $ElementFormatMismatch = $True; $ArgToSpecify = 'IntegerList' } }
    }

    if ($ElementFormatMismatch) {
        Write-Error "The data type of the element value specified does not match the expected data type for the specified element. Supply a correct value to -$ArgToSpecify and try again."
    } else {
        if ($PSBoundParameters.ContainsKey('String')) {
            $MethodName = 'SetStringElement'
            $Arguments = @{ String = $String }
        } elseif ($PSBoundParameters.ContainsKey('Object')) {
            $MethodName = 'SetObjectElement'
            # GUID strings must have curly braces upon calling the SetObjectElement method.
            $Arguments = @{ Id = "{$($Object.Guid)}" }
        } elseif ($PSBoundParameters.ContainsKey('ObjectList')) {
            $MethodName = 'SetObjectListElement'
            # GUID strings must have curly braces upon calling the SetObjectListElement method.
            $Arguments = @{ Ids = ([String[]] ($ObjectList.Guid | ForEach-Object { "{$_}" })) }
        } elseif ($PSBoundParameters.ContainsKey('Integer')) {
            $MethodName = 'SetIntegerElement'
            $Arguments = @{ Integer = $Integer }
        } elseif ($PSBoundParameters.ContainsKey('Boolean')) {
            $MethodName = 'SetBooleanElement'
            $Arguments = @{ Boolean = $Boolean }
        } elseif ($PSBoundParameters.ContainsKey('IntegerList')) {
            $MethodName = 'SetIntegerListElement'
            $Arguments = @{ Integers = $IntegerList }
        }

        $Arguments['Type'] = $BCDElement.Type

        $Result = Invoke-CimMethod -InputObject $BcdElement.Object -MethodName $MethodName -Arguments $Arguments @CimMethodArgs

        if ($Result -and $Result.ReturnValue) {
            # Only output the object if -PassThru was specified.
            if ($PassThru) { Get-BCDElement -BcdObject $BCDElement.Object -Type $BCDElement.Type }
        } else {
            if (-not $PSBoundParameters['WhatIf']) {
                Write-Error "Failed to set value for the specified element. Element name: $($BCDElement.ElementName). Object ID: $($BCDElement.ObjectId)"
            }
        }
    }
}

filter Remove-BCDElement {
<#
.SYNOPSIS

Deletes an existing BCD element from a BCD object.

.DESCRIPTION

Remove-BCDElement deletes one or more BCD elements. Remove-BCDElement is designed to accept pipeline input from Get-BCDElement.

Remove-BCDElement is equivalent to calling "bcdedit.exe /deletevalue".

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER BCDElement

Specifies one or more BCD element instances returned from Get-BCDElement to delete.

.EXAMPLE

Get-BCDObject -BCDStore $BCDStore -WellKnownId BootMgr | Get-BCDElement -Name BootDebug | Remove-BCDElement

Turns early boot debugging off for the boot manager. This is equivalent to the following bcdedit.exe command:

bcdedit.exe /deletevalue {bootmgr} bootdebug

.INPUTS

Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement

Accepts one or more BCD element instances returned from Get-BCDElement.
#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSTypeName('Microsoft.Management.Infrastructure.CimInstance#ROOT/WMI/BcdElement')]
        [Microsoft.Management.Infrastructure.CimInstance]
        $BCDElement
    )

    $CimMethodArgs = @{}
    $CimSessionComputerName = $BCDElement.GetCimSessionComputerName()

    if ($CimSessionComputerName) { $CimMethodArgs['CimSession'] = Get-CimSession -InstanceId $BCDElement.GetCimSessionInstanceId() }

    $Result = Invoke-CimMethod -InputObject $BCDElement.Object -MethodName DeleteElement -Arguments @{ Type = $BCDElement.Type } @CimMethodArgs

    if ((-not $Result) -or (-not $Result.ReturnValue)) {
        if (-not $PSBoundParameters['WhatIf']) {
            Write-Error "Unable to delete the specified element. Element name: $($BCDElement.ElementName). Object ID: $($BCDElement.ObjectId)"
        }
    }
}

Export-ModuleMember -Function 'New-BCDStore',
                              'Export-BCDStore',
                              'Import-BCDStore',
                              'Get-BCDStore',
                              'New-BCDObject',
                              'Copy-BCDObject',
                              'Get-BCDObject',
                              'Remove-BCDObject',
                              'Get-BCDElement',
                              'New-BCDElement',
                              'Set-BCDElement',
                              'Remove-BCDElement'

. "$PSScriptRoot\Helpers\BCDHelperFuncs.ps1"