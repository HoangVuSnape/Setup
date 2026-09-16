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
