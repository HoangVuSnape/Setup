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

function Find-StartMenuShortcut {
    param([string]$SearchTerm)
    $searchPaths = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
        "$env:AppData\Microsoft\Windows\Start Menu\Programs"
    )
    $existingPaths = $searchPaths | Where-Object { Test-Path $_ }
    if (@($existingPaths).Count -eq 0) {
        return $null
    }
    $match = Get-ChildItem -Path $existingPaths -Filter "*$SearchTerm*.lnk" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    return $match
}

function Start-LoginApp {
    param([string]$Name, [string]$SearchTerm)
    $shortcut = Find-StartMenuShortcut -SearchTerm $SearchTerm
    if ($shortcut) {
        Start-Process -FilePath $shortcut.FullName
        return [PSCustomObject]@{ Name = $Name; Launched = $true; Message = 'Da mo app. Dang nhap theo huong dan tren man hinh cua app.' }
    }
    return [PSCustomObject]@{ Name = $Name; Launched = $false; Message = "Khong tim thay shortcut tu dong. Hay tu mo '$Name' tu Start Menu va dang nhap." }
}

function Invoke-ExternalCommand {
    param([string]$Command, [string[]]$ArgumentList)
    & $Command @ArgumentList
}

function Invoke-CliLogin {
    param([string]$Name, [string]$Command, [string[]]$ArgumentList)
    Invoke-ExternalCommand -Command $Command -ArgumentList $ArgumentList
    return [PSCustomObject]@{ Name = $Name; Launched = $true; Message = 'Da chay lenh - lam theo huong dan tren man hinh/trinh duyet.' }
}

function Invoke-LoginItem {
    param([object]$Item)
    if ($Item.Type -eq 'Cli') {
        return Invoke-CliLogin -Name $Item.Name -Command $Item.Command -ArgumentList $Item.ArgumentList
    }
    return Start-LoginApp -Name $Item.Name -SearchTerm $Item.SearchTerm
}

function Invoke-LoginPlan {
    param(
        [object[]]$Items,
        [switch]$DryRun
    )
    $results = @()
    foreach ($item in $Items) {
        if ($DryRun) {
            $results += [PSCustomObject]@{ Name = $item.Name; Launched = $true; Message = '[DRY RUN] se kich hoat dang nhap.' }
            continue
        }
        $results += Invoke-LoginItem -Item $item
    }
    return $results
}

function Format-LoginSummary {
    param([object[]]$Results)
    $launchedCount = @($Results | Where-Object { $_.Launched }).Count
    $total = $Results.Count
    $lines = @()
    $lines += "=== $launchedCount/$total da kich hoat tu dong, xem chi tiet tung muc ben duoi ==="
    foreach ($r in $Results) {
        $lines += "$($r.Name): $($r.Message)"
    }
    return $lines
}
