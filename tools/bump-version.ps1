param(
    [string] $Version,
    [int] $AddOnVersion,
    [switch] $Patch,
    [switch] $Check,
    [string] $ApiVersion
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).ProviderPath
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text {
    param([Parameter(Mandatory = $true)][string] $Path)
    return [System.IO.File]::ReadAllText($Path, $utf8)
}

function Write-Text {
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Content
    )
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Get-RegexValue {
    param(
        [Parameter(Mandatory = $true)][string] $Content,
        [Parameter(Mandatory = $true)][string] $Pattern
    )
    $match = [regex]::Match($Content, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $match.Success) { return $null }
    return $match.Groups[1].Value
}

function Set-RegexValue {
    param(
        [Parameter(Mandatory = $true)][string] $Content,
        [Parameter(Mandatory = $true)][string] $Pattern,
        [Parameter(Mandatory = $true)][string] $Value
    )
    return [regex]::Replace($Content, $Pattern, {
        param($match)
        return $match.Groups[1].Value + $Value + $match.Groups[2].Value
    }, [System.Text.RegularExpressions.RegexOptions]::Multiline)
}

function Increment-PatchVersion {
    param([Parameter(Mandatory = $true)][string] $CurrentVersion)
    $parts = $CurrentVersion.Split(".")
    if ($parts.Count -ne 3) {
        throw "Cannot patch-bump non-semver version '$CurrentVersion'. Pass -Version explicitly."
    }
    $patchNumber = 0
    if (-not [int]::TryParse($parts[2], [ref]$patchNumber)) {
        throw "Cannot patch-bump version '$CurrentVersion'. Pass -Version explicitly."
    }
    return "$($parts[0]).$($parts[1]).$($patchNumber + 1)"
}

function Get-ApiVersionTokens {
    param([string] $Value)
    if (-not $Value) { return @() }
    return @($Value -split '\s+' | Where-Object { $_ })
}

function Test-ApiVersionList {
    param(
        [Parameter(Mandatory = $true)][string[]] $Tokens,
        [Parameter(Mandatory = $true)][string] $Label
    )
    if ($Tokens.Count -eq 0) { throw "$Label must contain at least one API version." }
    if ($Tokens.Count -gt 2) { throw "$Label contains $($Tokens.Count) API versions. ESO only honors the first 2 entries." }
    foreach ($token in $Tokens) {
        if ($token -notmatch '^\d+$') { throw "$Label contains invalid API version '$token'." }
    }
}

$manifest = Join-Path $root "EZOGroupFrames.txt"
$main = Join-Path $root "EZOGroupFrames.lua"
$core = Join-Path $root "modules\core.lua"
$metadata = Join-Path $root "ezo-addon.json"

if (-not (Test-Path -LiteralPath $manifest)) { throw "Manifest not found: $manifest" }
if (-not (Test-Path -LiteralPath $core)) { throw "Core version file not found: $core" }

$manifestText = Read-Text $manifest
$mainText = Test-Path -LiteralPath $main | ForEach-Object { if ($_) { Read-Text $main } else { $null } }
$coreText = Read-Text $core
$metadataText = Test-Path -LiteralPath $metadata | ForEach-Object { if ($_) { Read-Text $metadata } else { $null } }

$manifestVersion = Get-RegexValue $manifestText '^## Version:\s*(.+?)\s*$'
$manifestAddOnVersion = Get-RegexValue $manifestText '^## AddOnVersion:\s*(\d+)\s*$'
$manifestApiVersion = Get-RegexValue $manifestText '^## APIVersion:\s*(.+?)\s*$'
$mainAddOnVersion = if ($mainText) { Get-RegexValue $mainText '^\s*addOnVersion\s*=\s*(\d+),\s*$' } else { $null }
$coreVersion = Get-RegexValue $coreText '^\s*EZOGroupFrames\.ADDON_VERSION\s*=\s*"([^"]+)"\s*$'

if ($Check) {
    $ok = $true
    if ($manifestVersion -ne $coreVersion) {
        Write-Error "Version mismatch: EZOGroupFrames.txt=$manifestVersion modules/core.lua=$coreVersion"
        $ok = $false
    }
    if (-not $manifestAddOnVersion) {
        Write-Error "Missing ## AddOnVersion in EZOGroupFrames.txt"
        $ok = $false
    }
    if ($mainText -and $mainAddOnVersion -and $mainAddOnVersion -ne $manifestAddOnVersion) {
        Write-Error "AddOnVersion mismatch: EZOGroupFrames.lua=$mainAddOnVersion EZOGroupFrames.txt=$manifestAddOnVersion"
        $ok = $false
    }
    $manifestApiTokens = Get-ApiVersionTokens $manifestApiVersion
    try { Test-ApiVersionList $manifestApiTokens "## APIVersion" } catch { Write-Error $_; $ok = $false }
    if ($ApiVersion) {
        $expectedApiTokens = Get-ApiVersionTokens $ApiVersion
        try {
            Test-ApiVersionList $expectedApiTokens "-ApiVersion"
            foreach ($expectedApiToken in $expectedApiTokens) {
                if ($manifestApiTokens -notcontains $expectedApiToken) {
                    Write-Error "APIVersion mismatch: EZOGroupFrames.txt='$manifestApiVersion' does not include expected API '$expectedApiToken'"
                    $ok = $false
                }
            }
        } catch { Write-Error $_; $ok = $false }
    }
    if ($metadataText) {
        $metadataObj = $metadataText | ConvertFrom-Json
        if ($metadataObj.addon.version -ne $manifestVersion) {
            Write-Error "Version mismatch: ezo-addon.json=$($metadataObj.addon.version) EZOGroupFrames.txt=$manifestVersion"
            $ok = $false
        }
    }
    if (-not $ok) { exit 1 }
    Write-Host "Version check OK: $manifestVersion / AddOnVersion $manifestAddOnVersion / APIVersion $manifestApiVersion"
    exit 0
}

if ($Patch) {
    if ($Version) { throw "Use either -Patch or -Version, not both." }
    $Version = Increment-PatchVersion $manifestVersion
}

if (-not $Version) { throw "Pass -Version <x.y.z>, or use -Patch, or use -Check." }
if ($manifestVersion -ne $coreVersion) {
    throw "Refusing to bump from inconsistent state: EZOGroupFrames.txt=$manifestVersion modules/core.lua=$coreVersion"
}

if (-not $PSBoundParameters.ContainsKey("AddOnVersion")) {
    $currentAddOnVersion = 0
    if (-not [int]::TryParse($manifestAddOnVersion, [ref]$currentAddOnVersion)) {
        throw "Cannot read current ## AddOnVersion. Pass -AddOnVersion explicitly."
    }
    $AddOnVersion = $currentAddOnVersion + 1
}

$manifestText = Set-RegexValue $manifestText '^(## Version:\s*).+?(\s*)$' $Version
$manifestText = Set-RegexValue $manifestText '^(## AddOnVersion:\s*)\d+(\s*)$' ([string]$AddOnVersion)
if ($ApiVersion) {
    $apiTokens = Get-ApiVersionTokens $ApiVersion
    Test-ApiVersionList $apiTokens "-ApiVersion"
    $manifestText = Set-RegexValue $manifestText '^(## APIVersion:\s*).+?(\s*)$' $ApiVersion
}
Write-Text $manifest $manifestText

if ($mainText) {
    $mainText = Set-RegexValue $mainText '^(\s*addOnVersion\s*=\s*)\d+(,\s*)$' ([string]$AddOnVersion)
    Write-Text $main $mainText
}

$coreText = Set-RegexValue $coreText '^(\s*EZOGroupFrames\.ADDON_VERSION\s*=\s*")[^"]+("\s*)$' $Version
Write-Text $core $coreText

if ($metadataText) {
    $metadataText = Set-RegexValue $metadataText '^(\s*"version":\s*")[^"]+(",\s*)$' $Version
    $metadataText = Set-RegexValue $metadataText '^(\s*"zipName":\s*"EZOGroupFrames_v)[^"]+(\.zip",\s*)$' $Version
    Write-Text $metadata $metadataText
}

Write-Host "Version updated to $Version / AddOnVersion $AddOnVersion"
if ($ApiVersion) { Write-Host "APIVersion updated to $ApiVersion" }
Write-Host "Review with: git diff --check; git diff"
