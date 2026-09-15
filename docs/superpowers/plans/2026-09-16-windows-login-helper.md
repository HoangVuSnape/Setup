# Windows Login Helper Script Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `install/windows-login.ps1`, a companion script to `install/windows-setup.ps1` that shows a menu of 9 login items, triggers the 2 that have a genuine safe CLI device-flow (`gh auth login`, `docker login`), and launches the other 7 apps (via their Start Menu shortcut) with a reminder to log in through the app's own UI — never touching any password, token, or 2FA code.

**Architecture:** Same self-contained single-file pattern as `windows-setup.ps1`: small pure functions with real Pester tests, thin mockable wrappers around the only two kinds of external I/O (`Invoke-ExternalCommand` for `gh`/`docker`, `Start-Process` + `Find-StartMenuShortcut` for launching GUI apps), a `$env:PESTER_TESTING` guard before `Main`, and a `-DryRun` switch (new relative to the design spec, added here for the same reason it was useful in `windows-setup.ps1`: it lets the live `irm | iex` distribution mechanism be verified for real without triggering actual logins or opening real apps).

**Tech Stack:** PowerShell 5.1, Pester v6 (already installed on the dev machine), same `winget`/console environment as the install script.

**Spec:** `docs/superpowers/specs/2026-09-16-account-login-helper-design.md`

**House style reference:** `docs/superpowers/plans/2026-09-16-windows-install-script.md` (prior plan in this repo — match its function-naming, test structure, and commit-message conventions exactly). Known PowerShell 5.1 / Pester v6 gotchas already discovered by that plan's execution, apply proactively:
1. `$var:` (variable immediately followed by colon) parses as a scope-qualified variable — use `${var}:` in string interpolation instead.
2. `-like` / `Should -BeLike` treats `[...]` as a wildcard character-class — escape with backticks for literal `[`/`]`.
3. Variables assigned directly in a `Describe` block body (not inside `BeforeAll`/`It`) are `$null` during the Run phase — always use `BeforeAll { }` for shared test fixtures.
4. `Where-Object` returning exactly one match yields a scalar with no `.Count` property in Windows PowerShell 5.1 — wrap in `@(...)` before `.Count`, or use `Measure-Object` instead.

---

## Task 1: Scaffold the script file and login-item data

**Files:**
- Create: `install/windows-login.ps1`

- [ ] **Step 1: Light research — confirm Start Menu shortcut naming**

Run WebSearch for anything you're not confident about (these are mostly just the apps' own display names, low-drift, but confirm the less obvious ones):
- `GitHub Desktop Windows Start Menu shortcut name`
- `Claude Desktop app Windows Start Menu shortcut name`
- `VS Code Windows Start Menu shortcut name "Visual Studio Code"`

For Discord, Zalo, DataGrip, Bitwarden the shortcut name is expected to just match the app's own name (`Discord`, `Zalo`, `DataGrip`, `Bitwarden`) — a plain substring search will find it regardless of exact wording (see Task 5's `*$SearchTerm*.lnk` matching), so exhaustive research isn't needed for those.

- [ ] **Step 2: Write the file skeleton**

```powershell
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
```

Adjust `SearchTerm` values only if Step 1's research found the actual Start Menu shortcut uses meaningfully different wording (e.g. if VS Code's shortcut is confirmed to literally be "Visual Studio Code", the value above is already correct — don't change it without a real finding).

- [ ] **Step 3: Verify the file parses**

```powershell
$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw install/windows-login.ps1), [ref]$null); 'OK: no syntax errors'
```
Expected: `OK: no syntax errors`

- [ ] **Step 4: Commit**

```bash
git add install/windows-login.ps1
git commit -m "Scaffold windows-login.ps1 with login item data"
```

---

## Task 2: `Get-FlatLoginItems` — flatten grouped login items into an indexed list

**Files:**
- Modify: `install/windows-login.ps1`
- Create: `install/windows-login.Tests.ps1`

- [ ] **Step 1: Write the failing test**

Create `install/windows-login.Tests.ps1`:

```powershell
BeforeAll {
    $env:PESTER_TESTING = '1'
    . "$PSScriptRoot\windows-login.ps1"
}

AfterAll {
    Remove-Item Env:\PESTER_TESTING -ErrorAction SilentlyContinue
}

Describe 'Get-FlatLoginItems' {
    It 'assigns sequential 1-based Index across all groups in order' {
        $groups = [ordered]@{
            'A' = @([PSCustomObject]@{ Name = 'Item1'; Type = 'Cli'; Command = 'x'; ArgumentList = @() }, [PSCustomObject]@{ Name = 'Item2'; Type = 'App'; SearchTerm = 'y' })
            'B' = @([PSCustomObject]@{ Name = 'Item3'; Type = 'App'; SearchTerm = 'z' })
        }
        $flat = Get-FlatLoginItems -Groups $groups

        $flat.Count | Should -Be 3
        $flat[0].Index | Should -Be 1
        $flat[0].Name | Should -Be 'Item1'
        $flat[0].Category | Should -Be 'A'
        $flat[1].Index | Should -Be 2
        $flat[2].Index | Should -Be 3
        $flat[2].Category | Should -Be 'B'
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: FAIL — `Get-FlatLoginItems` not recognized. Also confirm the run completes quickly and does not hang (at this stage the script has no `Main`/bottom guard yet, so dot-sourcing is inert — same sanity check the prior plan's Task 2 did).

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1`, after the `$script:LoginItemGroups` block:

```powershell
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
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (1/1)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add Get-FlatLoginItems with test"
```

---

## Task 3: `ConvertTo-ToggledSelection` — pure selection-toggling logic (duplicated from windows-setup.ps1)

**Files:**
- Modify: `install/windows-login.ps1`
- Modify: `install/windows-login.Tests.ps1`

This is the exact same function as in `windows-setup.ps1` (Task 3 of the prior plan) — `windows-login.ps1` is a separate self-contained file per the design spec §3 (no shared module, so it's duplicated here, not imported).

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-login.Tests.ps1`:

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

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: the 6 new tests FAIL; the Task 2 test still PASSES.

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1` (identical body to the version in `windows-setup.ps1`):

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
            $warnings += "Bo qua ${num}: ngoai pham vi (1-$($state.Length))."
            continue
        }
        $idx = $num - 1
        $state[$idx] = -not $state[$idx]
    }
    return [PSCustomObject]@{ State = $state; Warnings = $warnings }
}
```

Note the `${num}:` interpolation (not `$num:`) per gotcha #1 above — already applied here, don't revert it.

- [ ] **Step 4: Run tests to verify they pass**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (7/7 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add ConvertTo-ToggledSelection with tests"
```

---

## Task 4: `Format-LoginMenu` — render the menu display

**Files:**
- Modify: `install/windows-login.ps1`
- Modify: `install/windows-login.Tests.ps1`

Unlike `windows-setup.ps1`'s `Format-Menu`, there is no "mandatory apps" line here — every login item is selectable.

- [ ] **Step 1: Write the failing test**

Add to `install/windows-login.Tests.ps1`:

```powershell
Describe 'Format-LoginMenu' {
    It 'renders category headers and checkbox marks, with no mandatory line' {
        $flat = @(
            [PSCustomObject]@{ Index = 1; Name = 'GitHub CLI (gh auth login)'; Category = 'Tu dong' }
            [PSCustomObject]@{ Index = 2; Name = 'Bitwarden'; Category = 'Mo app' }
        )
        $state = @($true, $false)

        $lines = Format-LoginMenu -FlatItems $flat -SelectionState $state

        ($lines -join "`n") | Should -BeLike '*-- Tu dong --*'
        ($lines -join "`n") | Should -BeLike '*`[x`] 1. GitHub CLI (gh auth login)*'
        ($lines -join "`n") | Should -BeLike '*-- Mo app --*'
        ($lines -join "`n") | Should -BeLike '*`[ `] 2. Bitwarden*'
    }
}
```

Note the backtick-escaped `` `[x`] `` / `` `[ `] `` per gotcha #2 above (`-like` treats `[...]` as a wildcard char-class) — already applied, don't remove the backticks.

- [ ] **Step 2: Run test to verify it fails**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: FAIL — `Format-LoginMenu` not recognized; the 7 earlier tests still PASS.

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1`:

```powershell
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
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (8/8 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add Format-LoginMenu with test"
```

---

## Task 5: `Find-StartMenuShortcut` — locate a GUI app's Start Menu shortcut

**Files:**
- Modify: `install/windows-login.ps1`
- Modify: `install/windows-login.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-login.Tests.ps1`:

```powershell
Describe 'Find-StartMenuShortcut' {
    It 'returns the first matching .lnk file found' {
        Mock Test-Path { return $true }
        Mock Get-ChildItem {
            return [PSCustomObject]@{ FullName = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Bitwarden.lnk' }
        }

        $result = Find-StartMenuShortcut -SearchTerm 'Bitwarden'
        $result.FullName | Should -Be 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Bitwarden.lnk'
    }

    It 'returns $null when no shortcut matches' {
        Mock Test-Path { return $true }
        Mock Get-ChildItem { return $null }

        Find-StartMenuShortcut -SearchTerm 'NoSuchApp' | Should -BeNullOrEmpty
    }

    It 'skips a search path that does not exist without throwing' {
        Mock Test-Path { return $false }
        Mock Get-ChildItem { throw 'should not be called for a nonexistent path' }

        { Find-StartMenuShortcut -SearchTerm 'Bitwarden' } | Should -Not -Throw
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: FAIL — `Find-StartMenuShortcut` not recognized; the 8 earlier tests still PASS.

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1`:

```powershell
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
```

Note `@($existingPaths).Count` per gotcha #4 above (single-item `Where-Object` result loses `.Count` on Windows PowerShell 5.1) — already applied.

- [ ] **Step 4: Run tests to verify they pass**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (11/11 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add Find-StartMenuShortcut with tests"
```

---

## Task 6: `Start-LoginApp` — launch a GUI app via its shortcut

**Files:**
- Modify: `install/windows-login.ps1`
- Modify: `install/windows-login.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-login.Tests.ps1`:

```powershell
Describe 'Start-LoginApp' {
    It 'launches the shortcut and reports Launched=$true when found' {
        Mock Find-StartMenuShortcut { return [PSCustomObject]@{ FullName = 'C:\path\Bitwarden.lnk' } }
        Mock Start-Process { }

        $result = Start-LoginApp -Name 'Bitwarden' -SearchTerm 'Bitwarden'

        $result.Launched | Should -Be $true
        $result.Name | Should -Be 'Bitwarden'
        Should -Invoke Start-Process -ParameterFilter { $FilePath -eq 'C:\path\Bitwarden.lnk' }
    }

    It 'reports Launched=$false with a manual-open hint when no shortcut is found' {
        Mock Find-StartMenuShortcut { return $null }
        Mock Start-Process { throw 'should not be called when no shortcut found' }

        $result = Start-LoginApp -Name 'Bitwarden' -SearchTerm 'Bitwarden'

        $result.Launched | Should -Be $false
        $result.Message | Should -BeLike '*Start Menu*'
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: FAIL — `Start-LoginApp` not recognized; the 11 earlier tests still PASS.

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1`:

```powershell
function Start-LoginApp {
    param([string]$Name, [string]$SearchTerm)
    $shortcut = Find-StartMenuShortcut -SearchTerm $SearchTerm
    if ($shortcut) {
        Start-Process -FilePath $shortcut.FullName
        return [PSCustomObject]@{ Name = $Name; Launched = $true; Message = 'Da mo app. Dang nhap theo huong dan tren man hinh cua app.' }
    }
    return [PSCustomObject]@{ Name = $Name; Launched = $false; Message = "Khong tim thay shortcut tu dong. Hay tu mo '$Name' tu Start Menu va dang nhap." }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (13/13 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add Start-LoginApp with tests"
```

---

## Task 7: `Invoke-ExternalCommand` + `Invoke-CliLogin` — the gh/docker boundary

**Files:**
- Modify: `install/windows-login.ps1`
- Modify: `install/windows-login.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-login.Tests.ps1`:

```powershell
Describe 'Invoke-CliLogin' {
    It 'calls Invoke-ExternalCommand with the exact command and args, and reports Launched=$true' {
        Mock Invoke-ExternalCommand { }

        $result = Invoke-CliLogin -Name 'GitHub CLI (gh auth login)' -Command 'gh' -ArgumentList @('auth', 'login')

        $result.Launched | Should -Be $true
        $result.Name | Should -Be 'GitHub CLI (gh auth login)'
        Should -Invoke Invoke-ExternalCommand -ParameterFilter {
            $Command -eq 'gh' -and ($ArgumentList -join ',') -eq 'auth,login'
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: FAIL — `Invoke-CliLogin`/`Invoke-ExternalCommand` not recognized; the 13 earlier tests still PASS.

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1`:

```powershell
function Invoke-ExternalCommand {
    param([string]$Command, [string[]]$ArgumentList)
    & $Command @ArgumentList
}

function Invoke-CliLogin {
    param([string]$Name, [string]$Command, [string[]]$ArgumentList)
    Invoke-ExternalCommand -Command $Command -ArgumentList $ArgumentList
    return [PSCustomObject]@{ Name = $Name; Launched = $true; Message = 'Da chay lenh - lam theo huong dan tren man hinh/trinh duyet.' }
}
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (14/14 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add Invoke-ExternalCommand and Invoke-CliLogin with tests"
```

---

## Task 8: `Invoke-LoginItem` + `Invoke-LoginPlan` — orchestration with DryRun

**Files:**
- Modify: `install/windows-login.ps1`
- Modify: `install/windows-login.Tests.ps1`

- [ ] **Step 1: Write the failing tests**

Add to `install/windows-login.Tests.ps1`:

```powershell
Describe 'Invoke-LoginItem' {
    It 'dispatches Type=Cli items to Invoke-CliLogin' {
        Mock Invoke-CliLogin { return [PSCustomObject]@{ Name = 'x'; Launched = $true; Message = 'cli' } }
        Mock Start-LoginApp { throw 'should not be called for a Cli item' }

        $item = [PSCustomObject]@{ Name = 'x'; Type = 'Cli'; Command = 'gh'; ArgumentList = @('auth', 'login') }
        $result = Invoke-LoginItem -Item $item

        $result.Message | Should -Be 'cli'
        Should -Invoke Invoke-CliLogin -Times 1
    }

    It 'dispatches Type=App items to Start-LoginApp' {
        Mock Start-LoginApp { return [PSCustomObject]@{ Name = 'y'; Launched = $true; Message = 'app' } }
        Mock Invoke-CliLogin { throw 'should not be called for an App item' }

        $item = [PSCustomObject]@{ Name = 'y'; Type = 'App'; SearchTerm = 'Bitwarden' }
        $result = Invoke-LoginItem -Item $item

        $result.Message | Should -Be 'app'
        Should -Invoke Start-LoginApp -Times 1
    }
}

Describe 'Invoke-LoginPlan' {
    BeforeAll {
        $script:loginItems = @(
            [PSCustomObject]@{ Name = 'Item1'; Type = 'Cli'; Command = 'gh'; ArgumentList = @('auth', 'login') }
            [PSCustomObject]@{ Name = 'Item2'; Type = 'App'; SearchTerm = 'Bitwarden' }
        )
    }

    It 'calls Invoke-LoginItem for each item when not in DryRun' {
        Mock Invoke-LoginItem { param($Item) return [PSCustomObject]@{ Name = $Item.Name; Launched = $true; Message = 'real' } }

        $results = Invoke-LoginPlan -Items $script:loginItems
        $results.Count | Should -Be 2
        $results | ForEach-Object { $_.Message | Should -Be 'real' }
        Should -Invoke Invoke-LoginItem -Times 2
    }

    It 'in DryRun mode marks every item as simulated without calling Invoke-LoginItem' {
        Mock Invoke-LoginItem { throw 'should not be called in DryRun' }

        $results = Invoke-LoginPlan -Items $script:loginItems -DryRun
        $results.Count | Should -Be 2
        $results | ForEach-Object { $_.Message | Should -BeLike '*DRY RUN*' }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: FAIL — `Invoke-LoginItem`/`Invoke-LoginPlan` not recognized; the 14 earlier tests still PASS.

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1`:

```powershell
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
```

- [ ] **Step 4: Run tests to verify they pass**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (18/18 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add Invoke-LoginItem and Invoke-LoginPlan with tests"
```

---

## Task 9: `Format-LoginSummary` — final report rendering

**Files:**
- Modify: `install/windows-login.ps1`
- Modify: `install/windows-login.Tests.ps1`

Unlike `windows-setup.ps1`'s `Format-Summary` (which only lists failures, since a plain success needs no follow-up), every login item here needs the user to actually go complete the login themselves — so `Format-LoginSummary` lists **every** item's message, not just the unlaunched ones.

- [ ] **Step 1: Write the failing test**

Add to `install/windows-login.Tests.ps1`:

```powershell
Describe 'Format-LoginSummary' {
    It 'lists every item with its message, and counts how many launched' {
        $results = @(
            [PSCustomObject]@{ Name = 'GitHub CLI (gh auth login)'; Launched = $true; Message = 'Da chay lenh - lam theo huong dan tren man hinh/trinh duyet.' }
            [PSCustomObject]@{ Name = 'Bitwarden'; Launched = $false; Message = "Khong tim thay shortcut tu dong. Hay tu mo 'Bitwarden' tu Start Menu va dang nhap." }
        )

        $lines = Format-LoginSummary -Results $results
        $joined = $lines -join "`n"

        $joined | Should -BeLike '*1/2 da kich hoat tu dong*'
        $joined | Should -BeLike '*GitHub CLI*lam theo huong dan*'
        $joined | Should -BeLike '*Bitwarden*Start Menu*'
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: FAIL — `Format-LoginSummary` not recognized; the 18 earlier tests still PASS.

- [ ] **Step 3: Implement**

Add to `install/windows-login.ps1`:

```powershell
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
```

- [ ] **Step 4: Run test to verify it passes**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (19/19 total so far)

- [ ] **Step 5: Commit**

```bash
git add install/windows-login.ps1 install/windows-login.Tests.ps1
git commit -m "Add Format-LoginSummary with test"
```

---

## Task 10: `Main` — wire everything together, with the Pester-testing guard

**Files:**
- Modify: `install/windows-login.ps1`

**Safety note (read before implementing):** unlike `windows-setup.ps1`, the two `Cli` items here (`gh auth login`, `docker login`) will actually start a real, safe browser-based login flow if triggered for real, and `App` items will actually launch real installed apps. `-DryRun` exists specifically so this can be exercised safely — do not skip wiring it through correctly.

- [ ] **Step 1: Implement `Main` and the bottom guard**

Add to the end of `install/windows-login.ps1`:

```powershell
function Main {
    param([switch]$DryRun)

    $flatItems = Get-FlatLoginItems -Groups $script:LoginItemGroups
    $state = New-Object bool[] $flatItems.Count

    while ($true) {
        Write-Host ''
        (Format-LoginMenu -FlatItems $flatItems -SelectionState $state) | ForEach-Object { Write-Host $_ }
        Write-Host ''
        $line = Read-Host "Go so de tick/bo chon (vd: 1,3,7), go 'all' de chon het, Enter rong de xac nhan"
        if ($line.Trim() -eq '') { break }
        $toggled = ConvertTo-ToggledSelection -CurrentState $state -InputLine $line
        $state = $toggled.State
        foreach ($w in $toggled.Warnings) { Write-Host $w -ForegroundColor Yellow }
    }

    $selectedItems = @()
    for ($i = 0; $i -lt $flatItems.Count; $i++) {
        if ($state[$i]) { $selectedItems += $flatItems[$i] }
    }

    if ($selectedItems.Count -eq 0) {
        Write-Host 'Chua chon gi. Da huy.'
        return
    }

    Write-Host ''
    Write-Host "Se kich hoat: $(($selectedItems | ForEach-Object { $_.Name }) -join ', ')"
    $confirm = Read-Host 'Xac nhan kich hoat? (y/n)'
    if ($confirm -notin @('y', 'Y')) {
        Write-Host 'Da huy.'
        return
    }

    $results = Invoke-LoginPlan -Items $selectedItems -DryRun:$DryRun
    (Format-LoginSummary -Results $results) | ForEach-Object { Write-Host $_ }
}

if (-not $env:PESTER_TESTING) {
    Main -DryRun:$DryRun
}
```

- [ ] **Step 2: Run the full test suite to confirm nothing broke and it doesn't hang**

```powershell
Invoke-Pester -Path install/windows-login.Tests.ps1 -Output Detailed
```
Expected: PASS (19/19). If it hangs (doesn't return within ~15 seconds), treat that as BLOCKED and report exactly what you observed rather than guessing a fix — the `$env:PESTER_TESTING` guard mechanism itself would need the controller's judgment to fix.

- [ ] **Step 3: Manual smoke test with `-DryRun` (local file, not yet pushed)**

```powershell
$inputFile = New-TemporaryFile
Set-Content -Path $inputFile -Value @('1,9', '', 'y')
Get-Content $inputFile | powershell -NoProfile -File install/windows-login.ps1 -DryRun
Remove-Item $inputFile
```
At the prompt this feeds: select items 1 and 9 (GitHub CLI and Bitwarden), confirm selection with empty line, confirm install with `y`. Expected: menu displays correctly, items 1 and 9 show `[x]`, final summary shows `[DRY RUN] se kich hoat dang nhap.` for both — and critically, **no browser opens and no app launches** (verify by checking no new `gh`/`docker`/app windows appeared).

- [ ] **Step 4: Commit**

```bash
git add install/windows-login.ps1
git commit -m "Add Main entry point and Pester-testing guard"
```

---

## Task 11: Verify the `irm | iex` and `-DryRun` invocation for real

**Files:** none (verification only)

**CRITICAL SAFETY NOTE:** every real (non-DryRun) invocation in this task must be answered with `n` at the confirmation prompt, or must select zero items — never let a real run reach `y` with items selected, since items 1-2 (`gh auth login`, `docker login`) would start a real browser-based login flow, and app items would really launch installed apps. If any step's actual observed output looks like it's about to do something real, stop and report BLOCKED rather than proceeding.

- [ ] **Step 1: Push the current script so a real raw URL exists**

```bash
git push origin master
```

- [ ] **Step 2: Test the plain one-liner against the live raw URL, declining**

Drive it non-interactively with an empty selection, empty confirm, then decline:
```powershell
$inputFile = New-TemporaryFile
Set-Content -Path $inputFile -Value @('', '')
Get-Content $inputFile | powershell -NoProfile -Command "irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-login.ps1 | iex"
Remove-Item $inputFile
```
With an empty selection, `Main` should print `Chua chon gi. Da huy.` and return before ever reaching the confirm prompt — this is actually the safest possible live test since it can't proceed to a real trigger regardless of what's typed next. Expected: the menu renders exactly as it does locally (9 items across 2 categories); output ends with `Chua chon gi. Da huy.`; confirm via the real output text that no further prompt appeared.

- [ ] **Step 3: Test the `-DryRun` invocation syntax, with a real selection this time (safe because of `-DryRun`)**

```powershell
$inputFile = New-TemporaryFile
Set-Content -Path $inputFile -Value @('1,9', '', 'y')
Get-Content $inputFile | powershell -NoProfile -Command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-login.ps1))) -DryRun"
Remove-Item $inputFile
```
Expected: final summary shows `[DRY RUN] se kich hoat dang nhap.` for both GitHub CLI and Bitwarden. If `-DryRun` does not reach `Main` correctly (e.g. a real browser/app would open), STOP immediately and report BLOCKED — do not let it proceed.

- [ ] **Step 4: Record the result**

No commit needed — verification only. Report the exact commands used and their actual output.

---

## Task 12: Document usage in README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add a usage section**

Add to `README.md`, right after the "Cài tự động bằng script" section added for `windows-setup.ps1`:

```markdown
### Kích hoạt đăng nhập (sau khi cài xong app)

Script này **không bao giờ** đụng vào password/token/mã 2FA của bạn — chỉ mở đúng cơ chế đăng nhập chính thức của từng app (trình duyệt/QR code), hoặc mở app lên để bạn tự đăng nhập. Chạy sau khi đã cài app bằng `windows-setup.ps1`:

```powershell
irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-login.ps1 | iex
```

Muốn xem trước sẽ kích hoạt gì mà không mở app/trình duyệt thật (chế độ thử):

```powershell
& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-login.ps1))) -DryRun
```
```

Adjust the exact commands based on what Task 11 actually confirmed works.

- [ ] **Step 2: Commit and push**

```bash
git add README.md
git commit -m "Document windows-login.ps1 usage in README"
git push origin master
```

---

## Self-Review Notes

- **Spec coverage:** §2 (which apps get which treatment) → Task 1's data block. §3 (architecture: separate self-contained file, same menu UX, Cli items inherit console, App items launch-and-remind, no success verification) → Tasks 1-10. §0 (hard credential boundary) → enforced by construction: no function in this plan reads, stores, or transmits any secret; `Invoke-CliLogin`/`Start-LoginApp` only ever trigger and report, never capture output. §5 (testing: pure logic gets real tests, external wrappers get mocked) → every task's test mocks the boundary function one level below what it's testing, consistent with `windows-setup.ps1`'s pattern.
- **No placeholders:** every function has complete code and complete tests. Start Menu shortcut search terms are filled in directly (not left as TBD) since they're low-drift display-name strings; Task 1's research step is there to catch the rare case one is confirmed wrong, not to fill in an unknown.
- **Type consistency checked:** `Name`/`Category`/`Type`/`Command`/`ArgumentList`/`SearchTerm`/`Index` fields match between `Get-FlatLoginItems`'s output and every consumer (`Format-LoginMenu`, `Invoke-LoginItem`). `Launched`/`Message` result fields are consistent across `Start-LoginApp`, `Invoke-CliLogin`, `Invoke-LoginItem`, `Invoke-LoginPlan`, and `Format-LoginSummary`.
- **Deviation from the spec's literal mockup:** the design spec's §3 mockup doesn't show a `-DryRun` flag or a confirm-before-trigger prompt. Both are added here as an implementation-level safety mechanism (mirroring `windows-setup.ps1`'s pattern) so the live verification in Task 11 can be done without accidentally triggering a real login — this doesn't change what the spec approved (still only 2 safe CLI triggers + 7 launch-and-remind items, still no credential handling anywhere), it only adds a safety rail around exercising it.
