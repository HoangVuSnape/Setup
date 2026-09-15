param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$script:MandatoryApps = @(
    [PSCustomObject]@{ Name = 'Git'; WingetId = 'Git.Git' }
    [PSCustomObject]@{ Name = 'GitHub CLI'; WingetId = 'GitHub.cli' }
    [PSCustomObject]@{ Name = 'Docker Desktop'; WingetId = 'Docker.DockerDesktop' }
    [PSCustomObject]@{ Name = '7-Zip'; WingetId = '7zip.7zip' }
    [PSCustomObject]@{ Name = 'Windows Terminal'; WingetId = 'Microsoft.WindowsTerminal' }
)

$script:OptionalAppGroups = [ordered]@{
    'Dev Tools' = @(
        [PSCustomObject]@{ Name = 'VS Code'; WingetId = 'Microsoft.VisualStudioCode' }
        [PSCustomObject]@{ Name = 'GitHub Desktop'; WingetId = 'GitHub.GitHubDesktop' }
        [PSCustomObject]@{ Name = 'DataGrip'; WingetId = 'JetBrains.DataGrip' }
        [PSCustomObject]@{ Name = 'Claude Desktop'; WingetId = 'Anthropic.Claude' }
        [PSCustomObject]@{ Name = 'MiKTeX'; WingetId = 'MiKTeX.MiKTeX' }
        [PSCustomObject]@{ Name = 'Trinh duyet (Chrome)'; WingetId = 'Google.Chrome' }
    )
    'AI & Productivity' = @(
        [PSCustomObject]@{ Name = 'Python/Miniconda'; WingetId = 'Anaconda.Miniconda3' }
        [PSCustomObject]@{ Name = 'Obsidian'; WingetId = 'Obsidian.Obsidian' }
    )
    'Media & Communication' = @(
        [PSCustomObject]@{ Name = 'OBS Studio'; WingetId = 'OBSProject.OBSStudio' }
        [PSCustomObject]@{ Name = 'Discord'; WingetId = 'Discord.Discord' }
        [PSCustomObject]@{ Name = 'Zalo'; WingetId = 'VNGCorp.Zalo' }
    )
}

function Get-FlatOptionalApps {
    param([System.Collections.Specialized.OrderedDictionary]$Groups)
    $flat = @()
    $i = 1
    foreach ($category in $Groups.Keys) {
        foreach ($app in $Groups[$category]) {
            $flat += [PSCustomObject]@{
                Index    = $i
                Name     = $app.Name
                WingetId = $app.WingetId
                Category = $category
            }
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

function Format-Menu {
    param(
        [object[]]$FlatOptionalApps,
        [bool[]]$SelectionState,
        [object[]]$MandatoryApps
    )
    $lines = @()
    $lines += "Se tu cai (khong can chon): $(($MandatoryApps | ForEach-Object { $_.Name }) -join ', ')"
    $lines += ''
    $currentCategory = $null
    foreach ($app in $FlatOptionalApps) {
        if ($app.Category -ne $currentCategory) {
            $lines += "-- $($app.Category) --"
            $currentCategory = $app.Category
        }
        $mark = if ($SelectionState[$app.Index - 1]) { '[x]' } else { '[ ]' }
        $lines += " $mark $($app.Index). $($app.Name)"
    }
    return $lines
}

function Test-WingetAvailable {
    return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

function Invoke-Winget {
    param([string[]]$ArgumentList)
    & winget @ArgumentList | Out-Null
    return $LASTEXITCODE
}

function Test-AppInstalled {
    param([string]$WingetId)
    $exitCode = Invoke-Winget -ArgumentList @('list', '--id', $WingetId, '-e')
    return ($exitCode -eq 0)
}

function Install-App {
    param([string]$Name, [string]$WingetId)
    $exitCode = Invoke-Winget -ArgumentList @('install', '--id', $WingetId, '-e', '--accept-source-agreements', '--accept-package-agreements')
    if ($exitCode -eq 0) {
        return [PSCustomObject]@{ Name = $Name; WingetId = $WingetId; Success = $true; Message = 'Cai thanh cong.' }
    }
    return [PSCustomObject]@{ Name = $Name; WingetId = $WingetId; Success = $false; Message = "winget tra ve exit code $exitCode." }
}

function Invoke-InstallPlan {
    param(
        [object[]]$Apps,
        [switch]$DryRun
    )
    $results = @()
    foreach ($app in $Apps) {
        if ($DryRun) {
            $results += [PSCustomObject]@{ Name = $app.Name; WingetId = $app.WingetId; Success = $true; Message = '[DRY RUN] se duoc cai.' }
            continue
        }
        if (Test-AppInstalled -WingetId $app.WingetId) {
            $results += [PSCustomObject]@{ Name = $app.Name; WingetId = $app.WingetId; Success = $true; Message = 'Da cai san, bo qua.' }
            continue
        }
        $results += Install-App -Name $app.Name -WingetId $app.WingetId
    }
    return $results
}
