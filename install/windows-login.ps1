param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$script:LoginItemGroups = [ordered]@{
    'Tu dong (mo dung co che chinh thuc cua app)' = @(
        [PSCustomObject]@{ Name = 'GitHub CLI (gh auth login)'; Type = 'Cli'; Command = 'gh'; ArgumentList = @('auth', 'login') }
        [PSCustomObject]@{ Name = 'Docker Desktop (docker login)'; Type = 'Cli'; Command = 'docker'; ArgumentList = @('login') }
    )
    'Mo app, ban tu dang nhap' = @(
        [PSCustomObject]@{ Name = 'GitHub Desktop'; Type = 'App'; SearchTerm = 'GitHub Desktop' }
        [PSCustomObject]@{ Name = 'Claude Desktop'; Type = 'App'; SearchTerm = 'Claude' }
        [PSCustomObject]@{ Name = 'Discord (dung QR code tren dien thoai - nhanh nhat)'; Type = 'App'; SearchTerm = 'Discord' }
        [PSCustomObject]@{ Name = 'Zalo (dung QR code tren dien thoai - nhanh nhat)'; Type = 'App'; SearchTerm = 'Zalo' }
        [PSCustomObject]@{ Name = 'DataGrip (tuy chon)'; Type = 'App'; SearchTerm = 'DataGrip' }
        [PSCustomObject]@{ Name = 'VS Code (tuy chon)'; Type = 'App'; SearchTerm = 'Visual Studio Code' }
        [PSCustomObject]@{ Name = 'Bitwarden'; Type = 'App'; SearchTerm = 'Bitwarden' }
    )
}

function Get-FlatLoginItems {
    param([System.Collections.Specialized.OrderedDictionary]$Groups)
    $flat = @()
    $i = 1
    foreach ($category in $Groups.Keys) {
        foreach ($item in $Groups[$category]) {
            $entry = [PSCustomObject]@{
                Index        = $i
                Name         = $item.Name
                Category     = $category
                Type         = $item.Type
                Command      = $item.Command
                ArgumentList = $item.ArgumentList
                SearchTerm   = $item.SearchTerm
            }
            $flat += $entry
            $i++
        }
    }
    return $flat
}

function ConvertTo-ToggledSelection {
    param(
        [bool[]]$CurrentState,
        [string]$InputLine
    )
    $state = $CurrentState.Clone()
    $warnings = @()
    $trimmed = $InputLine.Trim()

    if ($trimmed -eq '') {
        return [PSCustomObject]@{ State = $state; Warnings = $warnings }
    }

    if ($trimmed -eq 'all') {
        for ($i = 0; $i -lt $state.Length; $i++) { $state[$i] = $true }
        return [PSCustomObject]@{ State = $state; Warnings = $warnings }
    }

    $tokens = $trimmed -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    foreach ($token in $tokens) {
        $num = 0
        if (-not [int]::TryParse($token, [ref]$num)) {
            $warnings += "Bo qua '$token': khong phai so hop le."
            continue
        }
        if ($num -lt 1 -or $num -gt $state.Length) {
            $warnings += "Bo qua ${num}: ngoai pham vi (1-$($state.Length))."
            continue
        }
        $idx = $num - 1
        $state[$idx] = -not $state[$idx]
    }
    return [PSCustomObject]@{ State = $state; Warnings = $warnings }
}

function Format-LoginMenu {
    param(
        [object[]]$FlatItems,
        [bool[]]$SelectionState
    )
    $lines = @()
    $currentCategory = $null
    foreach ($item in $FlatItems) {
        if ($item.Category -ne $currentCategory) {
            $lines += "-- $($item.Category) --"
            $currentCategory = $item.Category
        }
        $mark = if ($SelectionState[$item.Index - 1]) { '[x]' } else { '[ ]' }
        $lines += " $mark $($item.Index). $($item.Name)"
    }
    return $lines
}
