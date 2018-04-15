# Recreating C:\Windows\System32\config\BCD-Template from scratch with the BCD module
# Upon creating the new BCD template from scratch, validate that it matches the original template with the following command:
# bcdedit /store <path_to>\BCD-Template-FromScratch /enum all /v
# bcdedit /store C:\Windows\System32\config\BCD-Template /enum all /v

$NewBCDStorePath = 'C:\BCD-Template-FromScratch'

# First create an empty BCD store
# If you wanted to do everything remotely, you'd establish a CIM session and only pass it once to -CimSession with New-BCDStore.
$BCDStore = New-BCDStore -FilePath $NewBCDStorePath

# First create global, inheritable object types
<# Creating {dbgsettings}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {dbgsettings} /v

Debugger Settings
-----------------
identifier              {4636856e-540f-4170-a130-a84776f4c654}
debugtype               Local
elementstomigrate       0x46000007
#>

$DebugType = 4 # Local

$DbgSettings = $BCDStore | New-BCDObject -WellKnownId DbgSettings
$DbgSettings | New-BCDElement -Name DebugType -Integer $DebugType
$DbgSettings | New-BCDElement -Name ElementsToMigrate -IntegerList @(0x46000007)

<# Creating {emssettings}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {emssettings} /v

EMS Settings
------------
identifier              {0ce4991b-e6b3-4b16-b23c-5e0d9250e5d9}
bootems                 No
#>

$EmsSettings = $BCDStore | New-BCDObject -WellKnownId EmsSettings
$EmsSettings | New-BCDElement -Name BootEMS -Boolean $False

# Creating {badmemory}
# In the template, there are no elements defined for badmemory. Therefore, just create the object.

$BadMemory = $BCDStore | New-BCDObject -WellKnownId BadMemory

<# Creating {globalsettings}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {globalsettings}

Global Settings
---------------
identifier              {globalsettings}
inherit                 {dbgsettings}
                        {emssettings}
                        {badmemory}
#>

$GlobalSettings = $BCDStore | New-BCDObject -WellKnownId GlobalSettings
$GlobalSettings | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($DbgSettings.Id, $EmsSettings.Id, $BadMemory.Id))

<# Creating {hypervisorsettings}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {hypervisorsettings} /v

Hypervisor Settings
-------------------
identifier              {7ff607e0-4395-11db-b0de-0800200c9a66}
hypervisordebugtype     Serial
hypervisordebugport     1
hypervisorbaudrate      115200
elementstomigrate       0x46000007
#>

$HypervisorDebugType = 0 # Serial

$HypervisorSettings = $BCDStore | New-BCDObject -WellKnownId HypervisorSettings
$HypervisorSettings | New-BCDElement -Name HypervisorDebugType -Integer $HypervisorDebugType
$HypervisorSettings | New-BCDElement -Name HypervisorDebugPort -Integer 1
$HypervisorSettings | New-BCDElement -Name HypervisorBaudrate -Integer 115200
$HypervisorSettings | New-BCDElement -Name ElementsToMigrate -IntegerList @(0x46000007)

<# Creating {bootloadersettings}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {bootloadersettings}

Boot Loader Settings
--------------------
identifier              {bootloadersettings}
inherit                 {globalsettings}
                        {hypervisorsettings}
#>

$BootloaderSettings = $BCDStore | New-BCDObject -WellKnownId BootloaderSettings
$BootloaderSettings | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($GlobalSettings.Id, $HypervisorSettings.Id))

<# Creating {default}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {default} /v

Windows Setup
-------------
identifier              {cbd971bf-b7b8-4885-951a-fa03044f5d71}
locale                  en-US
inherit                 {bootloadersettings}
allowedinmemorysettings 0x15000075
systemroot              \windows
nx                      OptOut
bootmenupolicy          Standard
winpe                   Yes
custom:42000002         \system32\winload.exe
custom:42000003         \boot.wim
custom:45000001         2
custom:47000005         301989892
                        1
#>

$NX = 1 # OptOut
$BootMenuPolicy = 1 # Standard

$DefaultSettings = $BCDStore | New-BCDObject -Id '{cbd971bf-b7b8-4885-951a-fa03044f5d71}' -Application OSLoader
$DefaultSettings | New-BCDElement -Name Locale -String 'en-US'
$DefaultSettings | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($BootloaderSettings.Id))
$DefaultSettings | New-BCDElement -Name AllowedInMemorySettings -IntegerList @(0x15000075)
$DefaultSettings | New-BCDElement -Name SystemRoot -String '\windows'
$DefaultSettings | New-BCDElement -Name NX -Integer $NX
# The boot menu policy type value for OS loader objects is different from the type value for resume objects
$DefaultSettings | New-BCDElement -Name BootMenuPolicyWinLoad -Integer $BootMenuPolicy
$DefaultSettings | New-BCDElement -Name WinPE -Boolean $True
$DefaultSettings | New-BCDElement -Type 0x42000002 -String '\system32\winload.exe'
$DefaultSettings | New-BCDElement -Type 0x42000003 -String '\boot.wim'
$DefaultSettings | New-BCDElement -Type 0x45000001 -Integer 2
$DefaultSettings | New-BCDElement -Type 0x47000005 -IntegerList @(301989892, 1)

<# Creating {bootmgr}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {bootmgr} /v

Windows Boot Manager
--------------------
identifier              {9dea862c-5cdd-4e70-acc1-f32b344d4795}
path                    \EFI\Microsoft\Boot\bootmgfw.efi
description             Windows Boot Manager
locale                  en-US
inherit                 {globalsettings}
default                 {default}
timeout                 30
custom:45000001         1
elementstomigrate       0x16000010
                        0x26000020
                        0x25000004
                        0x1600007e
#>

$BootMgr = $BCDStore | New-BCDObject -WellKnownId BootMgr -Description 'Windows Boot Manager'
$BootMgr | New-BCDElement -Name Path -String '\EFI\Microsoft\Boot\bootmgfw.efi'
$BootMgr | New-BCDElement -Name Locale -String 'en-US'
$BootMgr | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($GlobalSettings.Id))
# My understanding is that this is the equivalent of setting bcdedit.exe /default {id}
$BootMgr | New-BCDElement -Name Default -Object ([Guid] $DefaultSettings.Id)
$BootMgr | New-BCDElement -Name Timeout -Integer 30
$BootMgr | New-BCDElement -Type 0x45000001 -Integer 1
$BootMgr | New-BCDElement -Name ElementsToMigrate -IntegerList @(0x16000010, 0x26000020, 0x25000004, 0x1600007e)

<# Creating {7254a080-1510-4e85-ac0f-e7fb3d444736}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {7254a080-1510-4e85-ac0f-e7fb3d444736} /v

Windows Setup
-------------
identifier              {7254a080-1510-4e85-ac0f-e7fb3d444736}
locale                  en-US
inherit                 {bootloadersettings}
isolatedcontext         Yes
allowedinmemorysettings 0x15000075
systemroot              \windows
nx                      OptOut
bootmenupolicy          Standard
winpe                   Yes
custom:42000002         \system32\winload.efi
custom:42000003         \boot.wim
custom:45000001         2
custom:47000005         301989892
                        1
#>

$NX = 1 # OptOut
$BootMenuPolicy = 1 # Standard

$OSLoaderSettings = $BCDStore | New-BCDObject -Id '{7254a080-1510-4e85-ac0f-e7fb3d444736}' -Application OSLoader
$OSLoaderSettings | New-BCDElement -Name Locale -String 'en-US'
$OSLoaderSettings | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($BootloaderSettings.Id))
$OSLoaderSettings | New-BCDElement -Name IsolatedContext -Boolean $True
$OSLoaderSettings | New-BCDElement -Name AllowedInMemorySettings -IntegerList @(0x15000075)
$OSLoaderSettings | New-BCDElement -Name SystemRoot -String '\windows'
$OSLoaderSettings | New-BCDElement -Name NX -Integer $NX
# The boot menu policy type value for OS loader objects is different from the type value for resume objects
$OSLoaderSettings | New-BCDElement -Name BootMenuPolicyWinLoad -Integer $BootMenuPolicy
$OSLoaderSettings | New-BCDElement -Name WinPE -Boolean $True
$OSLoaderSettings | New-BCDElement -Type 0x42000002 -String '\system32\winload.efi'
$OSLoaderSettings | New-BCDElement -Type 0x42000003 -String '\boot.wim'
$OSLoaderSettings | New-BCDElement -Type 0x45000001 -Integer 2
$OSLoaderSettings | New-BCDElement -Type 0x47000005 -IntegerList @(301989892, 1)

<# Creating {resumeloadersettings}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {resumeloadersettings}

Resume Loader Settings
----------------------
identifier              {resumeloadersettings}
inherit                 {globalsettings}
#>

$ResumeloaderSettings = $BCDStore | New-BCDObject -WellKnownId ResumeLoaderSettings
$ResumeloaderSettings | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($GlobalSettings.Id))

<# Creating {memdiag}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {memdiag}

Windows Memory Tester
---------------------
identifier              {memdiag}
path                    \boot\memtest.exe
locale                  en-US
inherit                 {globalsettings}
badmemoryaccess         Yes
custom:45000001         1
custom:47000005         301989892
                        2
#>

$Memdiag = $BCDStore | New-BCDObject -WellKnownId MemDiag
$Memdiag | New-BCDElement -Name Path -String '\boot\memtest.exe'
$Memdiag | New-BCDElement -Name Locale -String 'en-US'
$Memdiag | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($GlobalSettings.Id))
$Memdiag | New-BCDElement -Name BadMemoryAccess -Boolean $True
$Memdiag | New-BCDElement -Type 0x45000001 -Integer 1
$Memdiag | New-BCDElement -Type 0x47000005 -IntegerList @(301989892, 2)

<# Creating {ntldr}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {ntldr}

Windows Legacy OS Loader
------------------------
identifier              {466f5a88-0af2-4f76-9038-095b170dc21c}
path                    \ntldr
custom:45000001         1
custom:47000005         301989892
                        6
#>

$Ntldr = $BCDStore | New-BCDObject -WellKnownId NtLdr
$Ntldr | New-BCDElement -Name Path -String '\ntldr'
$Ntldr | New-BCDElement -Type 0x45000001 -Integer 1
$Ntldr | New-BCDElement -Type 0x47000005 -IntegerList @(301989892, 6)

<# Creating {98b02a23-0674-4ce7-bdad-e0a15a8ff97b}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {98b02a23-0674-4ce7-bdad-e0a15a8ff97b}

Resume from Hibernate
---------------------
identifier              {98b02a23-0674-4ce7-bdad-e0a15a8ff97b}
description             Windows Resume Application
locale                  en-US
inherit                 {resumeloadersettings}
allowedinmemorysettings 0x15000075
filepath                \hiberfil.sys
bootmenupolicy          Standard
custom:42000002         \system32\winresume.exe
custom:45000001         2
custom:46000004         Yes
#>

$BootMenuPolicy = 1 # Standard

$ResumeLoader1 = $BCDStore | New-BCDObject -Id '{98b02a23-0674-4ce7-bdad-e0a15a8ff97b}' -Application Resume -Description 'Windows Resume Application'
$ResumeLoader1 | New-BCDElement -Name Locale -String 'en-US'
$ResumeLoader1 | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($ResumeloaderSettings.Id))
$ResumeLoader1 | New-BCDElement -Name AllowedInMemorySettings -IntegerList @(0x15000075)
$ResumeLoader1 | New-BCDElement -Name FilePath -String '\hiberfil.sys'
# The boot menu policy type value for OS loader objects is different from the type value for resume objects
$ResumeLoader1 | New-BCDElement -Name BootMenuPolicyWinResume -Integer $BootMenuPolicy
$ResumeLoader1 | New-BCDElement -Type 0x42000002 -String '\system32\winresume.exe'
$ResumeLoader1 | New-BCDElement -Type 0x45000001 -Integer 2
$ResumeLoader1 | New-BCDElement -Type 0x46000004 -Boolean $True

<# Creating {0c334284-9a41-4de1-99b3-a7e87e8ff07e}

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {0c334284-9a41-4de1-99b3-a7e87e8ff07e}

Resume from Hibernate
---------------------
identifier              {0c334284-9a41-4de1-99b3-a7e87e8ff07e}
description             Windows Resume Application
locale                  en-US
inherit                 {resumeloadersettings}
isolatedcontext         Yes
allowedinmemorysettings 0x15000075
filepath                \hiberfil.sys
bootmenupolicy          Standard
custom:42000002         \system32\winresume.efi
custom:45000001         2
custom:46000004         Yes
#>

$BootMenuPolicy = 1 # Standard

$ResumeLoader2 = $BCDStore | New-BCDObject -Id '{0c334284-9a41-4de1-99b3-a7e87e8ff07e}' -Application Resume -Description 'Windows Resume Application'
$ResumeLoader2 | New-BCDElement -Name Locale -String 'en-US'
$ResumeLoader2 | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($ResumeloaderSettings.Id))
$ResumeLoader2 | New-BCDElement -Name IsolatedContext -Boolean $True
$ResumeLoader2 | New-BCDElement -Name AllowedInMemorySettings -IntegerList @(0x15000075)
$ResumeLoader2 | New-BCDElement -Name FilePath -String '\hiberfil.sys'
# The boot menu policy type value for OS loader objects is different from the type value for resume objects
$ResumeLoader2 | New-BCDElement -Name BootMenuPolicyWinResume -Integer $BootMenuPolicy
$ResumeLoader2 | New-BCDElement -Type 0x42000002 -String '\system32\winresume.efi'
$ResumeLoader2 | New-BCDElement -Type 0x45000001 -Integer 2
$ResumeLoader2 | New-BCDElement -Type 0x46000004 -Boolean $True

<# Creating {a1943bbc-ea85-487c-97c7-c9ede908a38a} - TargetTemplatePCAT

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {a1943bbc-ea85-487c-97c7-c9ede908a38a}

OS Target Template
------------------
identifier              {a1943bbc-ea85-487c-97c7-c9ede908a38a}
locale                  en-US
inherit                 {bootloadersettings}
allowedinmemorysettings 0x15000075
systemroot              \windows
resumeobject            {98b02a23-0674-4ce7-bdad-e0a15a8ff97b}
nx                      OptIn
bootmenupolicy          Standard
custom:42000002         \system32\winload.exe
custom:45000001         2
custom:47000005         301989892
                        3
elementstomigrate       0x16000010
                        0x260000a0
                        0x260000f2
                        0x16000049
                        0x25000115
                        0x1600007e
#>

$NX = 0 # OptIn
$BootMenuPolicy = 1 # Standard

$PCATTemplate = $BCDStore | New-BCDObject -WellKnownId TargetTemplatePCAT
$PCATTemplate | New-BCDElement -Name Locale -String 'en-US'
$PCATTemplate | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($BootloaderSettings.Id))
$PCATTemplate | New-BCDElement -Name AllowedInMemorySettings -IntegerList @(0x15000075)
$PCATTemplate | New-BCDElement -Name SystemRoot -String '\windows'
# Oddly, bcdedit prints 0x23000003 as ResumeObject when 0x23000003 should be {default}
$PCATTemplate | New-BCDElement -Type 0x23000003 -Object ([Guid] $ResumeLoader1.Id)
$PCATTemplate | New-BCDElement -Name NX -Integer $NX
# The boot menu policy type value for OS loader objects is different from the type value for resume objects
$PCATTemplate | New-BCDElement -Name BootMenuPolicyWinLoad -Integer $BootMenuPolicy
$PCATTemplate | New-BCDElement -Type 0x42000002 -String '\system32\winload.exe'
$PCATTemplate | New-BCDElement -Type 0x45000001 -Integer 2
$PCATTemplate | New-BCDElement -Type 0x47000005 -IntegerList @(301989892, 3)
$PCATTemplate | New-BCDElement -Name ElementsToMigrate -IntegerList @(0x16000010, 0x260000a0, 0x260000f2, 0x16000049, 0x25000115, 0x1600007e)

<# Creating {b012b84d-c47c-4ed5-b722-c0c42163e569} - TargetTemplateEFI

bcdedit /store C:\Windows\System32\config\BCD-Template /enum {b012b84d-c47c-4ed5-b722-c0c42163e569}

OS Target Template
------------------
identifier              {b012b84d-c47c-4ed5-b722-c0c42163e569}
locale                  en-US
inherit                 {bootloadersettings}
isolatedcontext         Yes
allowedinmemorysettings 0x15000075
systemroot              \windows
resumeobject            {0c334284-9a41-4de1-99b3-a7e87e8ff07e}
nx                      OptIn
bootmenupolicy          Standard
custom:42000002         \system32\winload.efi
custom:45000001         2
custom:47000005         301989892
                        3
elementstomigrate       0x16000010
                        0x260000a0
                        0x260000f2
                        0x16000049
                        0x25000115
                        0x1600007e
#>

$NX = 0 # OptIn
$BootMenuPolicy = 1 # Standard

$EFITemplate = $BCDStore | New-BCDObject -WellKnownId TargetTemplateEFI
$EFITemplate | New-BCDElement -Name Locale -String 'en-US'
$EFITemplate | New-BCDElement -Name Inherit -ObjectList ([Guid[]] @($BootloaderSettings.Id))
$EFITemplate | New-BCDElement -Name IsolatedContext -Boolean $True
$EFITemplate | New-BCDElement -Name AllowedInMemorySettings -IntegerList @(0x15000075)
$EFITemplate | New-BCDElement -Name SystemRoot -String '\windows'
# Oddly, bcdedit prints 0x23000003 as ResumeObject when 0x23000003 should be {default}
$EFITemplate | New-BCDElement -Type 0x23000003 -Object ([Guid] $ResumeLoader2.Id)
$EFITemplate | New-BCDElement -Name NX -Integer $NX
# The boot menu policy type value for OS loader objects is different from the type value for resume objects
$EFITemplate | New-BCDElement -Name BootMenuPolicyWinLoad -Integer $BootMenuPolicy
$EFITemplate | New-BCDElement -Type 0x42000002 -String '\system32\winload.efi'
$EFITemplate | New-BCDElement -Type 0x45000001 -Integer 2
$EFITemplate | New-BCDElement -Type 0x47000005 -IntegerList @(301989892, 3)
$EFITemplate | New-BCDElement -Name ElementsToMigrate -IntegerList @(0x16000010, 0x260000a0, 0x260000f2, 0x16000049, 0x25000115, 0x1600007e)
