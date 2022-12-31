# Copyright 2018-2019, Bingxing Wang <uefi-oss-projects@imbushuo.net>
# All rights reserved.
#
# This script module provides shared utilities.
#

# function Get-AcpiToolsPath {
#     $iaslPath = which "iasl"
#     if ($null -eq $iaslPath) {
#         Write-Error -Message "ACPI tools are not present on this system."
#         return $null
#     }
# 
#     return $iaslPath
# }

function Get-GnuArmCrossCollectionPath {
    param(
        [switch]$AllowFallback
    )

    $possibleGccCommands = @(
        "arm-eabi-gcc",
        "arm-none-eabi-gcc",
        "arm-unknown-eabi-gcc",
        "arm-linux-gnueabihf-gcc"
    )

    $ccprefix = $null
    foreach ($gccCommand in $possibleGccCommands) {
        $path = which $gccCommand
        if ($null -ne $path) {
            # Trim "gcc"
            $ccprefix = $path.Substring(0, $path.LastIndexOf("gcc"))
            Write-Verbose "Use GCC at $($ccprefix)."
            break
        }
    }

    if (($null -eq $ccprefix) -and $AllowFallback) {
        $ccprefix = "/opt/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
        Write-Warning -Message "GCC not found, fallback to /opt/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf- prefix."
    }

    # Now it's not the fallback case
    if ($null -eq $ccprefix) {
        Write-Error -Message "GCC not found. Either Linaro or distro-GCC is needed for build."
    }

    $env:GCC5_ARM_PREFIX = $ccprefix
    return $ccprefix
}

function Test-GnuArmCrossCollectionVersionRequirements {
    $prefix = Get-GnuArmCrossCollectionPath -AllowFallback
    $cc = "$($prefix)gcc"
    $versionOutput = . $cc --version
    if (($null -eq $versionOutput) -or ($versionOutput.Length -lt 1)) {
        Write-Error -Message "GCC Arm toolchain is malfunctioned"
        return $false
    }

    # Match line one using RegEx
    $match = [regex]::Match($versionOutput[0], '[0-9]+\.[0-9]+\.[0-9]+')
    if ($match.Success -eq $true) {
        # Load version .NET assembly.
        $gccVersion = [System.Version]::Parse($match.Value)
        # Need at least GCC5
        return ($gccVersion.Major -ge 5)
    }

    # Fallback
    return $false
}

# Exports
Export-ModuleMember -Function Get-GnuArmCrossCollectionPath
Export-ModuleMember -Function Test-GnuArmCrossCollectionVersionRequirements
Export-ModuleMember -Function Get-AcpiToolsPath
