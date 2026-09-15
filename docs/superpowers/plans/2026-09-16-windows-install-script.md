# Windows Auto-Install Menu Script Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `install/windows-setup.ps1`, a single self-contained PowerShell script that shows an interactive menu of dev/IT apps, installs the selected ones (plus a fixed mandatory set) via `winget`, and is safe to distribute as an `irm <url> | iex` one-liner.

**Architecture:** All logic lives in one `.ps1` file as small, pure(ish) functions (selection-toggling, menu formatting, install orchestration, summary formatting) plus thin wrapper functions around the only two external calls (`winget list`, `winget install`) so those call sites can be mocked. A `$env:PESTER_TESTING` guard at the bottom prevents the script's `Main` entry point from auto-running when a test file dot-sources it. Pure functions get real Pester unit tests (TDD); the external-call wrappers are tested by mocking the single `Invoke-Winget` choke point; `Main` itself is glue code verified manually via `-DryRun`.

**Tech Stack:** PowerShell 5.1 (matches this repo's dev environment), Pester (PowerShell's standard test framework) for unit tests, `winget` as the install backend.

**Spec:** `docs/superpowers/specs/2026-09-16-windows-install-script-design.md`

---

## Task 1: Scaffold the script file and app data, with researched winget IDs

**Files:**
- Create: `install/windows-setup.ps1`

- [ ] **Step 1: Research and confirm every winget package id**

Run WebSearch for each of these (the spec marks them "tạm" / tentative — confirm the real current id, don't guess):
- `winget package id Git.Git GitHub.cli Docker.DockerDesktop 7zip.7zip Microsoft.WindowsTerminal 2026`
- `winget package id Microsoft.VisualStudioCode GitHub.GitHubDesktop JetBrains.DataGrip MiKTeX.MiKTeX Google.Chrome 2026`
- `winget package id Anthropic Claude Desktop app 2026` (this one is genuinely uncertain — the spec's `Anthropic.Claude` is a guess; find the real id, or if Claude Desktop has no winget package, note that and use the official direct-download URL with `Start-BitsTransfer`/`Invoke-WebRequest` + silent-install args instead — whichever is actually correct)
- `winget package id Anaconda.Miniconda3 Obsidian.Obsidian OBSProject.OBSStudio Discord.Discord VNGCorp.Zalo 2026`

- [ ] **Step 2: Write the file skeleton with researched data**

```powershell
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
        [PSCustomObject]@{ Name = 'Claude Desktop'; WingetId = 'REPLACE_WITH_RESEARCHED_ID' }
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
```

Replace `REPLACE_WITH_RESEARCHED_ID` with the id found in Step 1. If Claude Desktop genuinely has no winget package, replace that whole entry's install path per the fallback noted in Step 1 (this changes what `Install-App` does for that one app — flag this clearly in your task report so Task 6 accounts for it; do not silently drop Claude Desktop from the list).

- [ ] **Step 3: Verify the file parses**

```powershell
powershell -NoProfile -Command "$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw install/windows-setup.ps1), [ref]$null); 'OK: no syntax errors'"
```
Expected: `OK: no syntax errors`

- [ ] **Step 4: Commit**

```bash
git add install/windows-setup.ps1
git commit -m "Scaffold windows-setup.ps1 with researched app data"
```

---

## Task 2: `Get-FlatOptionalApps` — flatten grouped apps into an indexed list

**Files:**
- Modify: `install/windows-setup.ps1` (add function, after the data block)
- Create: `install/windows-setup.Tests.ps1`

- [ ] **Step 1: Write the failing test**

```powershell
BeforeAll {
    $env:PESTER_TESTING = '1'
    . "$PSScriptRoot\windows-setup.ps1"
}

AfterAll {
    Remove-Item Env:\PESTER_TESTING -ErrorAction SilentlyContinue
}

Describe 'Get-FlatOptionalApps' {
    It 'assigns sequential 1-based Index across all groups in order' {
        $groups = [ordered]@{
            'A' = @([PSCustomObject]@{ Name = 'App1'; WingetId = 'Id1' }, [PSCustomObject]@{ Name = 'App2'; WingetId = 'Id2' })
            'B' = @([PSCustomObject]@{ Name = 'App3'; WingetId = 'Id3' })
        }
        $flat = Get-FlatOptionalApps -Groups $groups

        $flat.Count | Should -Be 3
        $flat[0].Index | Should -Be 1
        $flat[0].Name | Should -Be 'App1'
        $flat[0].Category | Should -Be 'A'
        $flat[1].Index | Should -Be 2
        $flat[2].Index | Should -Be 3
        $flat[2].Category | Should -Be 'B'
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: FAIL — `Get-FlatOptionalApps` is not recognized (function doesn't exist yet)

- [ ] **Step 3: Implement**

Add to `install/windows-setup.ps1`, after the `$script:OptionalAppGroups` block:

```powershell
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (1/1)

- [ ] **Step 5: Commit**

```bash
git add install/windows-setup.ps1 install/windows-setup.Tests.ps1
git commit -m "Add Get-FlatOptionalApps with test"
```

---

## Task 3: `ConvertTo-ToggledSelection` — pure selection-toggling logic

**Files:**
- Modify: `install/windows-setup.ps1`
- Modify: `install/windows-setup.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-setup.Tests.ps1`:

```powershell
Describe 'ConvertTo-ToggledSelection' {
    It 'toggles listed 1-based indices on when currently off' {
        $state = @($false, $false, $false, $false, $false)
        $result = ConvertTo-ToggledSelection -CurrentState $state -InputLine '1,3'

        $result.State[0] | Should -Be $true
        $result.State[1] | Should -Be $false
        $result.State[2] | Should -Be $true
        $result.Warnings.Count | Should -Be 0
    }

    It 'toggles the same index twice back to its original value' {
        $state = @($false, $false)
        $result = ConvertTo-ToggledSelection -CurrentState $state -InputLine '1,1'

        $result.State[0] | Should -Be $false
    }

    It 'treats "all" as select-all, not a toggle' {
        $state = @($true, $false, $false)
        $result = ConvertTo-ToggledSelection -CurrentState $state -InputLine 'all'

        $result.State | Should -Be @($true, $true, $true)
    }

    It 'warns and skips non-numeric tokens without throwing' {
        $state = @($false, $false)
        $result = ConvertTo-ToggledSelection -CurrentState $state -InputLine '1,abc'

        $result.State[0] | Should -Be $true
        $result.Warnings.Count | Should -Be 1
    }

    It 'warns and skips out-of-range indices' {
        $state = @($false, $false)
        $result = ConvertTo-ToggledSelection -CurrentState $state -InputLine '99'

        $result.State | Should -Be @($false, $false)
        $result.Warnings.Count | Should -Be 1
    }

    It 'returns the state unchanged for empty input' {
        $state = @($true, $false)
        $result = ConvertTo-ToggledSelection -CurrentState $state -InputLine ''

        $result.State | Should -Be @($true, $false)
        $result.Warnings.Count | Should -Be 0
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: the 6 new `ConvertTo-ToggledSelection` tests FAIL (function not defined); the Task 2 test still PASSes.

- [ ] **Step 3: Implement**

Add to `install/windows-setup.ps1`:

```powershell
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
            $warnings += "Bo qua $num: ngoai pham vi (1-$($state.Length))."
            continue
        }
        $idx = $num - 1
        $state[$idx] = -not $state[$idx]
    }
    return [PSCustomObject]@{ State = $state; Warnings = $warnings }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (7/7 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-setup.ps1 install/windows-setup.Tests.ps1
git commit -m "Add ConvertTo-ToggledSelection with tests"
```

---

## Task 4: `Format-Menu` — render the menu display

**Files:**
- Modify: `install/windows-setup.ps1`
- Modify: `install/windows-setup.Tests.ps1`

- [ ] **Step 1: Write the failing test**

Add to `install/windows-setup.Tests.ps1`:

```powershell
Describe 'Format-Menu' {
    It 'renders mandatory line, category headers, and checkbox marks' {
        $mandatory = @([PSCustomObject]@{ Name = 'Git'; WingetId = 'Git.Git' })
        $flat = @(
            [PSCustomObject]@{ Index = 1; Name = 'VS Code'; WingetId = 'X'; Category = 'Dev Tools' }
            [PSCustomObject]@{ Index = 2; Name = 'Obsidian'; WingetId = 'Y'; Category = 'AI & Productivity' }
        )
        $state = @($true, $false)

        $lines = Format-Menu -FlatOptionalApps $flat -SelectionState $state -MandatoryApps $mandatory

        $lines[0] | Should -BeLike '*Git*'
        ($lines -join "`n") | Should -BeLike '*-- Dev Tools --*'
        ($lines -join "`n") | Should -BeLike '*[x] 1. VS Code*'
        ($lines -join "`n") | Should -BeLike '*-- AI & Productivity --*'
        ($lines -join "`n") | Should -BeLike '*[ ] 2. Obsidian*'
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: FAIL — `Format-Menu` not recognized

- [ ] **Step 3: Implement**

Add to `install/windows-setup.ps1`:

```powershell
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (8/8 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-setup.ps1 install/windows-setup.Tests.ps1
git commit -m "Add Format-Menu with test"
```

---

## Task 5: `Test-WingetAvailable` — pre-flight check

**Files:**
- Modify: `install/windows-setup.ps1`
- Modify: `install/windows-setup.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-setup.Tests.ps1`:

```powershell
Describe 'Test-WingetAvailable' {
    It 'returns true when the winget command is found' {
        Mock Get-Command { return [PSCustomObject]@{ Name = 'winget' } } -ParameterFilter { $Name -eq 'winget' }
        Test-WingetAvailable | Should -Be $true
    }

    It 'returns false when the winget command is missing' {
        Mock Get-Command { return $null } -ParameterFilter { $Name -eq 'winget' }
        Test-WingetAvailable | Should -Be $false
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: FAIL — `Test-WingetAvailable` not recognized

- [ ] **Step 3: Implement**

Add to `install/windows-setup.ps1`:

```powershell
function Test-WingetAvailable {
    return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (10/10 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-setup.ps1 install/windows-setup.Tests.ps1
git commit -m "Add Test-WingetAvailable with tests"
```

---

## Task 6: `Invoke-Winget`, `Test-AppInstalled`, `Install-App` — the winget boundary

**Files:**
- Modify: `install/windows-setup.ps1`
- Modify: `install/windows-setup.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-setup.Tests.ps1`:

```powershell
Describe 'Test-AppInstalled' {
    It 'returns true when Invoke-Winget reports exit code 0' {
        Mock Invoke-Winget { return 0 }
        Test-AppInstalled -WingetId 'Git.Git' | Should -Be $true
    }

    It 'returns false when Invoke-Winget reports a non-zero exit code' {
        Mock Invoke-Winget { return 1 }
        Test-AppInstalled -WingetId 'Git.Git' | Should -Be $false
    }

    It 'calls winget list with the exact id and -e flag' {
        Mock Invoke-Winget { return 0 }
        Test-AppInstalled -WingetId 'Git.Git' | Out-Null
        Should -Invoke Invoke-Winget -ParameterFilter {
            $ArgumentList -join ',' -eq 'list,--id,Git.Git,-e'
        }
    }
}

Describe 'Install-App' {
    It 'returns Success=$true when Invoke-Winget reports exit code 0' {
        Mock Invoke-Winget { return 0 }
        $result = Install-App -Name 'Git' -WingetId 'Git.Git'
        $result.Success | Should -Be $true
        $result.Name | Should -Be 'Git'
    }

    It 'returns Success=$false with the exit code in the message on failure' {
        Mock Invoke-Winget { return 1603 }
        $result = Install-App -Name 'Git' -WingetId 'Git.Git'
        $result.Success | Should -Be $false
        $result.Message | Should -BeLike '*1603*'
    }

    It 'calls winget install with agreement-acceptance flags' {
        Mock Invoke-Winget { return 0 }
        Install-App -Name 'Git' -WingetId 'Git.Git' | Out-Null
        Should -Invoke Invoke-Winget -ParameterFilter {
            $ArgumentList -contains '--accept-source-agreements' -and $ArgumentList -contains '--accept-package-agreements'
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: FAIL — `Invoke-Winget`/`Test-AppInstalled`/`Install-App` not recognized

- [ ] **Step 3: Implement**

Add to `install/windows-setup.ps1`:

```powershell
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
```

If Task 1 found that Claude Desktop has no winget package, add a second branch inside `Install-App` here keyed on a marker (e.g. `$WingetId -eq 'DIRECT_DOWNLOAD:Claude'`) that downloads and silently installs from the researched direct URL instead of calling `Invoke-Winget`; write an equivalent test for that branch before implementing it, mocking `Invoke-WebRequest`/`Start-Process` instead of `Invoke-Winget`.

- [ ] **Step 4: Run tests to verify they pass**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (16/16 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-setup.ps1 install/windows-setup.Tests.ps1
git commit -m "Add Invoke-Winget, Test-AppInstalled, Install-App with tests"
```

---

## Task 7: `Invoke-InstallPlan` — orchestration with non-fatal errors

**Files:**
- Modify: `install/windows-setup.ps1`
- Modify: `install/windows-setup.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-setup.Tests.ps1`:

```powershell
Describe 'Invoke-InstallPlan' {
    $apps = @(
        [PSCustomObject]@{ Name = 'App1'; WingetId = 'Id1' }
        [PSCustomObject]@{ Name = 'App2'; WingetId = 'Id2' }
        [PSCustomObject]@{ Name = 'App3'; WingetId = 'Id3' }
    )

    It 'skips apps already installed without calling Install-App' {
        Mock Test-AppInstalled { return $true }
        Mock Install-App { throw 'should not be called' }

        $results = Invoke-InstallPlan -Apps $apps
        $results.Count | Should -Be 3
        $results | ForEach-Object { $_.Message | Should -Be 'Da cai san, bo qua.' }
    }

    It 'continues installing remaining apps after one fails' {
        Mock Test-AppInstalled { return $false }
        Mock Install-App {
            param($Name, $WingetId)
            if ($Name -eq 'App2') {
                return [PSCustomObject]@{ Name = $Name; WingetId = $WingetId; Success = $false; Message = 'loi gia lap' }
            }
            return [PSCustomObject]@{ Name = $Name; WingetId = $WingetId; Success = $true; Message = 'Cai thanh cong.' }
        }

        $results = Invoke-InstallPlan -Apps $apps
        $results.Count | Should -Be 3
        ($results | Where-Object { $_.Success }).Count | Should -Be 2
        ($results | Where-Object { -not $_.Success }).Count | Should -Be 1
        $results[2].Name | Should -Be 'App3'
        $results[2].Success | Should -Be $true
    }

    It 'in DryRun mode marks every app as a simulated install without calling Test-AppInstalled or Install-App' {
        Mock Test-AppInstalled { throw 'should not be called in DryRun' }
        Mock Install-App { throw 'should not be called in DryRun' }

        $results = Invoke-InstallPlan -Apps $apps -DryRun
        $results.Count | Should -Be 3
        $results | ForEach-Object { $_.Message | Should -BeLike '*DRY RUN*' }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: FAIL — `Invoke-InstallPlan` not recognized

- [ ] **Step 3: Implement**

Add to `install/windows-setup.ps1`:

```powershell
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
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (19/19 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-setup.ps1 install/windows-setup.Tests.ps1
git commit -m "Add Invoke-InstallPlan with tests"
```

---

## Task 8: `Format-Summary` — final report rendering

**Files:**
- Modify: `install/windows-setup.ps1`
- Modify: `install/windows-setup.Tests.ps1`

- [ ] **Step 1: Write the failing test**

Add to `install/windows-setup.Tests.ps1`:

```powershell
Describe 'Format-Summary' {
    It 'reports success count and a retry command for each failure' {
        $results = @(
            [PSCustomObject]@{ Name = 'Git'; WingetId = 'Git.Git'; Success = $true; Message = 'Cai thanh cong.' }
            [PSCustomObject]@{ Name = 'MiKTeX'; WingetId = 'MiKTeX.MiKTeX'; Success = $false; Message = 'winget tra ve exit code 1.' }
        )

        $lines = Format-Summary -Results $results
        ($lines -join "`n") | Should -BeLike '*1/2 thanh cong*'
        ($lines -join "`n") | Should -BeLike '*MiKTeX*'
        ($lines -join "`n") | Should -BeLike '*winget install --id MiKTeX.MiKTeX -e*'
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: FAIL — `Format-Summary` not recognized

- [ ] **Step 3: Implement**

Add to `install/windows-setup.ps1`:

```powershell
function Format-Summary {
    param([object[]]$Results)
    $successCount = ($Results | Where-Object { $_.Success }).Count
    $total = $Results.Count
    $lines = @()
    $lines += "=== Hoan tat: $successCount/$total thanh cong ==="
    foreach ($f in ($Results | Where-Object { -not $_.Success })) {
        $lines += "Loi: $($f.Name) - $($f.Message) - thu lai bang: winget install --id $($f.WingetId) -e"
    }
    return $lines
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (20/20 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-setup.ps1 install/windows-setup.Tests.ps1
git commit -m "Add Format-Summary with test"
```

---

## Task 9: `Main` — wire everything together, with the Pester-testing guard

**Files:**
- Modify: `install/windows-setup.ps1`

- [ ] **Step 1: Implement `Main` and the bottom guard**

Add to the end of `install/windows-setup.ps1`:

```powershell
function Main {
    param([switch]$DryRun)

    if (-not (Test-WingetAvailable)) {
        Write-Host "Khong tim thay winget. Xem docs/windows/02-essentials.md de cai winget truoc." -ForegroundColor Red
        return
    }

    $flatApps = Get-FlatOptionalApps -Groups $script:OptionalAppGroups
    $state = New-Object bool[] $flatApps.Count

    while ($true) {
        Write-Host ''
        (Format-Menu -FlatOptionalApps $flatApps -SelectionState $state -MandatoryApps $script:MandatoryApps) | ForEach-Object { Write-Host $_ }
        Write-Host ''
        $line = Read-Host "Go so de tick/bo chon (vd: 1,3,7), go 'all' de chon het, Enter rong de xac nhan"
        if ($line.Trim() -eq '') { break }
        $toggled = ConvertTo-ToggledSelection -CurrentState $state -InputLine $line
        $state = $toggled.State
        foreach ($w in $toggled.Warnings) { Write-Host $w -ForegroundColor Yellow }
    }

    $selectedApps = @()
    for ($i = 0; $i -lt $flatApps.Count; $i++) {
        if ($state[$i]) { $selectedApps += $flatApps[$i] }
    }
    $allApps = @($script:MandatoryApps) + $selectedApps

    Write-Host ''
    Write-Host "Ban se cai: $(($script:MandatoryApps | ForEach-Object { $_.Name }) -join ', ') (mac dinh)"
    if ($selectedApps.Count -gt 0) {
        Write-Host "          + $(($selectedApps | ForEach-Object { $_.Name }) -join ', ') (da chon)"
    }
    $confirm = Read-Host 'Xac nhan cai? (y/n)'
    if ($confirm -notin @('y', 'Y')) {
        Write-Host 'Da huy.'
        return
    }

    $results = Invoke-InstallPlan -Apps $allApps -DryRun:$DryRun
    (Format-Summary -Results $results) | ForEach-Object { Write-Host $_ }
}

if (-not $env:PESTER_TESTING) {
    Main -DryRun:$DryRun
}
```

- [ ] **Step 2: Run the full test suite to confirm nothing broke**

```bash
powershell -NoProfile -Command "Invoke-Pester -Path install/windows-setup.Tests.ps1 -Output Detailed"
```
Expected: PASS (20/20) — `Main` itself has no new unit tests (it's I/O-driven glue code); this step just confirms adding it didn't break the testable functions above it, and that dot-sourcing under `$env:PESTER_TESTING` still doesn't trigger `Main` to run and block on `Read-Host`.

- [ ] **Step 3: Manual smoke test with `-DryRun` (local file, not yet pushed)**

```bash
powershell -NoProfile -File install/windows-setup.ps1 -DryRun
```
At the prompt, type `1,7` then Enter, then Enter again (empty) to confirm selection, then `y` to confirm install. Expected: menu displays correctly, selected items show `[x]`, final summary shows `[DRY RUN] se duoc cai.` for every app and no real installs happen (verify no new Start Menu entries appear).

- [ ] **Step 4: Commit**

```bash
git add install/windows-setup.ps1
git commit -m "Add Main entry point and Pester-testing guard"
```

---

## Task 10: Verify the `irm | iex` and `ScriptBlock::Create -DryRun` invocation patterns for real

**Files:** none (verification only)

- [ ] **Step 1: Push the current script so a real raw URL exists**

```bash
git push origin master
```

- [ ] **Step 2: Test the plain one-liner against the live raw URL**

```bash
powershell -NoProfile -Command "irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1 | iex"
```
At the prompt, immediately press Enter (empty, select nothing), then Enter again to confirm no optional apps, then `n` to decline the install (to avoid triggering 5 real mandatory installs during this check). Expected: the menu renders exactly as it does locally; declining with `n` prints `Da huy.` and exits cleanly — confirms distribution via `iex` works.

- [ ] **Step 3: Test the `-DryRun` invocation syntax documented in the spec**

```bash
powershell -NoProfile -Command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1))) -DryRun"
```
At the prompt: type `1` Enter, empty Enter to confirm selection, `y` to confirm. Expected: summary shows `[DRY RUN]` messages for all apps (mandatory + the one selected) — confirms `-DryRun` actually reaches `Main` through this invocation form. If this does NOT work as expected (e.g. `-DryRun` is silently ignored or errors), STOP and report back — this means spec §6's documented syntax is wrong and needs a design fix, not a code workaround.

- [ ] **Step 4: Record the result**

No commit needed for this task — it's a verification checkpoint. Report the exact commands used and their actual output in your task report so the next task can write accurate usage docs.

---

## Task 11: Document usage in README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add a usage section**

Add to `README.md`, after the existing "Máy Windows 11" section:

```markdown
### Cài tự động bằng script (tùy chọn, nhanh hơn làm tay)

Sau khi làm xong [01-fresh-install.md](docs/windows/01-fresh-install.md), có thể dùng script này để cài hàng loạt app còn lại thay vì làm tay từng bước — mở PowerShell (không cần Admin) và dán:

```powershell
irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1 | iex
```

Muốn xem trước sẽ cài gì mà không cài thật (chế độ thử):

```powershell
& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1))) -DryRun
```
```

Adjust the exact wording/command based on what Task 10 actually confirmed works — if the `-DryRun` syntax needed a fix, use the corrected version here.

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "Document windows-setup.ps1 usage in README"
```

---

## Self-Review Notes

- **Spec coverage:** §3 (invocation) → Task 10/11. §4 (app list) → Task 1. §5 (menu flow) → Tasks 2-4, 9. §6 (install logic: duplicate-check, non-fatal errors, confirm, DryRun) → Tasks 5-9. §7 (single file, no manifest) → the whole plan keeps everything in one `.ps1`. §8 (testing: static syntax check + manual DryRun, no live fresh-Windows run) → Task 1 Step 3, Task 9 Steps 2-3, Task 10.
- **No placeholders:** every function has complete code and complete tests; the one deliberate placeholder (`REPLACE_WITH_RESEARCHED_ID`) is inside a task whose Step 1 requires researching and replacing it before Step 2 is even written — not a "TBD" left for later.
- **Type consistency checked:** `WingetId`/`Name`/`Category`/`Index` field names are identical across `Get-FlatOptionalApps`, `Format-Menu`, `ConvertTo-ToggledSelection`'s consumers, `Invoke-InstallPlan`, and `Format-Summary`. `Success`/`Message` fields on result objects are consistent between `Install-App`, `Invoke-InstallPlan`, and `Format-Summary`.
