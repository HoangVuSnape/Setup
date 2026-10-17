# Script cai dat cong cu tren Windows 11.
# Nguoi dung chu dong tick chon cac cong cu can cai (khong co app bat buoc).
# KHONG cai PyTorch, CUDA Toolkit, numpy, pandas, Jupyter, Ollama.
# Thu vien AI/ML se cai sau bang uv trong tung project.
#
# Cach chay:
#   .\windows-setup.ps1
#
# Chay thu, khong cai that:
#   .\windows-setup.ps1 -DryRun
#
# Luu y:
# - Nen chay trong PowerShell / Windows Terminal.
# - Khong tat cua so khi winget dang cai app.

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ---------------------------------------------------------------------------
# DANH SACH APP
# ---------------------------------------------------------------------------

# Khong con app bat buoc. Tat ca app deu phai do nguoi dung tick chon.
$script:MandatoryApps = @()

# Toan bo app duoc chia theo nhom va chon bang so trong menu.
$script:OptionalAppGroups = [ordered]@{
    'Core Tools' = @(
        [PSCustomObject]@{ Name = 'Git';              WingetId = 'Git.Git' }
        [PSCustomObject]@{ Name = 'GitHub CLI';       WingetId = 'GitHub.cli' }
        [PSCustomObject]@{ Name = '7-Zip';            WingetId = '7zip.7zip' }
        [PSCustomObject]@{ Name = 'Windows Terminal'; WingetId = 'Microsoft.WindowsTerminal' }
    )

    'Dev Tools' = @(
        [PSCustomObject]@{ Name = 'VS Code';               WingetId = 'Microsoft.VisualStudioCode' }
        [PSCustomObject]@{ Name = 'Docker Desktop';        WingetId = 'Docker.DockerDesktop' }
        [PSCustomObject]@{ Name = 'GitHub Desktop';        WingetId = 'GitHub.GitHubDesktop' }
        [PSCustomObject]@{ Name = 'DataGrip';              WingetId = 'JetBrains.DataGrip' }
        [PSCustomObject]@{ Name = 'Claude Desktop';        WingetId = 'Anthropic.Claude' }
        [PSCustomObject]@{ Name = 'MiKTeX';                WingetId = 'MiKTeX.MiKTeX' }
        [PSCustomObject]@{ Name = 'Chrome';                WingetId = 'Google.Chrome' }
        [PSCustomObject]@{ Name = 'Bitwarden';             WingetId = 'Bitwarden.Bitwarden' }
    )

    'AI and Productivity' = @(
        [PSCustomObject]@{ Name = 'uv (Astral)';           WingetId = 'astral-sh.uv' }
        [PSCustomObject]@{ Name = 'Obsidian';              WingetId = 'Obsidian.Obsidian' }
    )

    'Media and Communication' = @(
        [PSCustomObject]@{ Name = 'OBS Studio';            WingetId = 'OBSProject.OBSStudio' }
        [PSCustomObject]@{ Name = 'Discord';               WingetId = 'Discord.Discord' }
        [PSCustomObject]@{ Name = 'Zalo';                  WingetId = 'VNGCorp.Zalo' }
    )
}

$script:AppGroups = $script:OptionalAppGroups

# ---------------------------------------------------------------------------
# HAM HIEN THI MENU
# ---------------------------------------------------------------------------

function Get-FlatOptionalApps {
    param(
        [System.Collections.Specialized.OrderedDictionary]$Groups
    )

    $flat = @()
    $index = 1

    foreach ($category in $Groups.Keys) {
        foreach ($app in $Groups[$category]) {
            $flat += [PSCustomObject]@{
                Index    = $index
                Name     = $app.Name
                WingetId = $app.WingetId
                Category = $category
            }
            $index++
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
    $trimmed = $InputLine.Trim().ToLower()

    if ($trimmed -eq '') {
        return [PSCustomObject]@{
            State    = $state
            Warnings = $warnings
        }
    }

    if ($trimmed -eq 'all') {
        for ($i = 0; $i -lt $state.Length; $i++) {
            $state[$i] = $true
        }

        return [PSCustomObject]@{
            State    = $state
            Warnings = $warnings
        }
    }

    if ($trimmed -eq 'none') {
        for ($i = 0; $i -lt $state.Length; $i++) {
            $state[$i] = $false
        }

        return [PSCustomObject]@{
            State    = $state
            Warnings = $warnings
        }
    }

    $tokens = $trimmed -split ',' |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne '' }

    foreach ($token in $tokens) {
        $number = 0

        if (-not [int]::TryParse($token, [ref]$number)) {
            $warnings += "Bo qua '$token': khong phai so hop le."
            continue
        }

        if ($number -lt 1 -or $number -gt $state.Length) {
            $warnings += "Bo qua ${number}: ngoai pham vi 1-$($state.Length)."
            continue
        }

        $arrayIndex = $number - 1
        $state[$arrayIndex] = -not $state[$arrayIndex]
    }

    return [PSCustomObject]@{
        State    = $state
        Warnings = $warnings
    }
}

function Format-Menu {
    param(
        [object[]]$FlatOptionalApps,
        [bool[]]$SelectionState,
        [object[]]$MandatoryApps = @()
    )

    $lines = @()

    $lines += '============================================================'
    $lines += 'DANH SACH UNG DUNG (TICK CHON BANG SO DE CAI DAT)'
    $lines += '============================================================'
    $lines += ''
    $lines += "Nhap so de tick/bo tick. Vi du: 1,3,7"
    $lines += "Nhap 'all' de chon tat ca | 'none' de bo chon tat ca"
    $lines += ''

    $currentCategory = $null

    foreach ($app in $FlatOptionalApps) {
        if ($app.Category -ne $currentCategory) {
            $lines += "-- $($app.Category) --"
            $currentCategory = $app.Category
        }

        $mark = if ($SelectionState[$app.Index - 1]) {
            '[x]'
        }
        else {
            '[ ]'
        }

        $lines += " $mark $($app.Index). $($app.Name)"
    }

    return $lines
}

function Show-SelectedApps {
    param(
        [object[]]$MandatoryApps = @(),
        [object[]]$SelectedApps = @()
    )

    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Cyan

    if ($SelectedApps.Count -gt 0) {
        $selectedText = ($SelectedApps | ForEach-Object { $_.Name }) -join ', '
        Write-Host "Da chon ($($SelectedApps.Count) app): $selectedText" -ForegroundColor Yellow
    }
    else {
        Write-Host 'Da chon: Chua chon ung dung nao.' -ForegroundColor DarkGray
    }

    Write-Host '============================================================' -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# HAM WINGET
# ---------------------------------------------------------------------------

function Test-WingetAvailable {
    return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

function Invoke-Winget {
    param(
        [string[]]$ArgumentList
    )

    Write-Host ''
    Write-Host ">> winget $($ArgumentList -join ' ')" -ForegroundColor Cyan

    # Xuat log truc tiep de nguoi dung theo doi tien do
    & winget @ArgumentList

    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host '>> Winget hoan thanh.' -ForegroundColor Green
    }
    else {
        Write-Host ">> Winget that bai. Exit code: $exitCode" -ForegroundColor Red
    }

    return $exitCode
}

function Install-App {
    param(
        [string]$Name,
        [string]$WingetId
    )

    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Yellow
    Write-Host "Dang cai: $Name" -ForegroundColor Yellow
    Write-Host "Package ID: $WingetId" -ForegroundColor DarkYellow
    Write-Host '============================================================' -ForegroundColor Yellow

    $arguments = @(
        'install',
        '--id', $WingetId,
        '--exact',
        '--source', 'winget',
        '--accept-source-agreements',
        '--accept-package-agreements',
        '--disable-interactivity'
    )

    $exitCode = Invoke-Winget -ArgumentList $arguments

    if ($exitCode -eq 0) {
        return [PSCustomObject]@{
            Name     = $Name
            WingetId = $WingetId
            Success  = $true
            Message  = 'Cai thanh cong.'
        }
    }

    return [PSCustomObject]@{
        Name     = $Name
        WingetId = $WingetId
        Success  = $false
        Message  = "winget tra ve exit code $exitCode."
    }
}

function Show-TqdmProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$ItemName = '',
        [int]$Width = 25
    )

    $percent = [int][math]::Round(($Current / $Total) * 100)
    $filled = [int][math]::Round(($Current / $Total) * $Width)
    $empty = [int][math]::Max(0, $Width - $filled)
    $block = [string][char]0x2588
    $shade = [string][char]0x2591
    $bar = ($block * $filled) + ($shade * $empty)

    $tqdmDisplay = "TQDM: {0,3}%|{1}| {2}/{3} [{4}]" -f $percent, $bar, $Current, $Total, $ItemName

    Write-Host ''
    Write-Host $tqdmDisplay -ForegroundColor Cyan
    Write-Progress -Activity 'Windows Setup - Tien do cai dat' -Status "[$Current/$Total] $ItemName ($percent%)" -PercentComplete $percent
}

function Invoke-InstallPlan {
    param(
        [object[]]$Apps,
        [switch]$DryRun
    )

    $results = @()
    $total = $Apps.Count
    $current = 0

    foreach ($app in $Apps) {
        $current++

        Show-TqdmProgressBar -Current $current -Total $total -ItemName $app.Name

        if ($DryRun) {
            Write-Host "  -> [DRY RUN] Se cai: $($app.WingetId)" -ForegroundColor Yellow

            $results += [PSCustomObject]@{
                Name     = $app.Name
                WingetId = $app.WingetId
                Success  = $true
                Message  = '[DRY RUN] Se duoc cai.'
            }

            continue
        }

        # Khong dung "winget list" de tranh bi treo.
        # Winget install tu xu ly truong hop app da ton tai.
        $results += Install-App -Name $app.Name -WingetId $app.WingetId
    }

    Write-Progress -Activity 'Windows Setup - Tien do cai dat' -Completed
    return $results
}

function Format-Summary {
    param(
        [object[]]$Results
    )

    $successCount = @($Results | Where-Object { $_.Success }).Count
    $failedResults = @($Results | Where-Object { -not $_.Success })
    $total = $Results.Count

    $lines = @()
    $lines += ''
    $lines += '============================================================'
    $lines += "HOAN TAT: $successCount/$total app xu ly thanh cong."
    $lines += '============================================================'

    if ($failedResults.Count -gt 0) {
        $lines += ''
        $lines += 'CAC APP CAI THAT BAI:'

        foreach ($result in $failedResults) {
            $lines += "  - $($result.Name): $($result.Message)"
            $lines += "    Thu lai bang:"
            $lines += "    winget install --id $($result.WingetId) -e --accept-source-agreements --accept-package-agreements"
        }
    }
    else {
        $lines += 'Khong co app nao bao loi.'
    }

    $lines += ''
    $lines += 'Luu y: Thu vien AI/ML (torch, numpy, pandas, Jupyter, ...) se cai sau bang uv trong tung project.'
    $lines += 'Luu y: Neu vua cai Git, VS Code hoac uv, hay dong va mo lai Terminal truoc khi go lenh git/code/uv.'
    $lines += 'Luu y: Neu vua cai Docker Desktop, mo Docker Desktop va lam theo huong dan WSL2 neu app yeu cau.'

    return $lines
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

function Main {
    param(
        [switch]$DryRun
    )

    Clear-Host

    Write-Host 'Windows Setup Script - Cai dat cong cu theo nhu cau' -ForegroundColor Cyan
    Write-Host 'Khong cai PyTorch, CUDA, Jupyter hay Ollama.' -ForegroundColor DarkGray
    Write-Host ''

    if (-not (Test-WingetAvailable)) {
        Write-Host 'Khong tim thay winget.' -ForegroundColor Red
        Write-Host 'Mo Microsoft Store, tim "App Installer", sau do Install/Update.' -ForegroundColor Yellow
        return
    }

    Write-Host "Winget: $(winget --version)" -ForegroundColor Green

    $flatApps = Get-FlatOptionalApps -Groups $script:OptionalAppGroups
    $state = New-Object bool[] $flatApps.Count

    while ($true) {
        Write-Host ''

        (Format-Menu `
            -FlatOptionalApps $flatApps `
            -SelectionState $state) |
            ForEach-Object {
                Write-Host $_
            }

        Write-Host ''
        $line = Read-Host 'Nhap lua chon (vd: 1,3,5); Enter rong de xac nhan'

        if ($line.Trim() -eq '') {
            break
        }

        $toggled = ConvertTo-ToggledSelection `
            -CurrentState $state `
            -InputLine $line

        $state = $toggled.State

        foreach ($warning in $toggled.Warnings) {
            Write-Host $warning -ForegroundColor Yellow
        }
    }

    $selectedApps = @()

    for ($i = 0; $i -lt $flatApps.Count; $i++) {
        if ($state[$i]) {
            $selectedApps += $flatApps[$i]
        }
    }

    Show-SelectedApps -SelectedApps $selectedApps

    if ($selectedApps.Count -eq 0) {
        Write-Host ''
        Write-Host 'Ban chua chon ung dung nao. Script ket thuc, khong co app nao duoc cai.' -ForegroundColor Yellow
        return
    }

    if ($DryRun) {
        Write-Host ''
        Write-Host 'CHE DO DRY RUN: Script chi hien thi ke hoach, KHONG cai app that.' -ForegroundColor Yellow
    }

    $confirm = Read-Host 'Xac nhan cai? (y/n)'

    if ([string]::IsNullOrWhiteSpace($confirm) -or $confirm.Trim().ToLower() -notin @('y', 'yes')) {
        Write-Host 'Da huy. Khong co app nao duoc cai.' -ForegroundColor Yellow
        return
    }

    try {
        $results = Invoke-InstallPlan -Apps $selectedApps -DryRun:$DryRun

        (Format-Summary -Results $results) |
            ForEach-Object {
                Write-Host $_
            }
    }
    catch {
        Write-Host ''
        Write-Host 'SCRIPT GAP LOI KHONG MONG MUON:' -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ''
        Write-Host 'Neu app cai that bai, thu cai lai bang lenh winget install.' -ForegroundColor Yellow
        Write-Host 'Sau do chay lai script hoac cai tung app bang winget install --id <PackageId> -e' -ForegroundColor Yellow
    }
}

if (-not $env:PESTER_TESTING) {
    Main -DryRun:$DryRun
}
