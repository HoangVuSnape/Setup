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
        ($lines -join "`n") | Should -BeLike '*`[x`] 1. VS Code*'
        ($lines -join "`n") | Should -BeLike '*-- AI & Productivity --*'
        ($lines -join "`n") | Should -BeLike '*`[ `] 2. Obsidian*'
    }
}

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

Describe 'Invoke-InstallPlan' {
    BeforeAll {
        $apps = @(
            [PSCustomObject]@{ Name = 'App1'; WingetId = 'Id1' }
            [PSCustomObject]@{ Name = 'App2'; WingetId = 'Id2' }
            [PSCustomObject]@{ Name = 'App3'; WingetId = 'Id3' }
        )
    }

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
        @($results | Where-Object { $_.Success }).Count | Should -Be 2
        @($results | Where-Object { -not $_.Success }).Count | Should -Be 1
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

Describe 'Format-Summary' {
    BeforeAll {
        $script:summaryResults = @(
            [PSCustomObject]@{ Name = 'Git'; WingetId = 'Git.Git'; Success = $true; Message = 'Cai thanh cong.' }
            [PSCustomObject]@{ Name = 'MiKTeX'; WingetId = 'MiKTeX.MiKTeX'; Success = $false; Message = 'winget tra ve exit code 1.' }
        )
    }

    It 'reports success count and a retry command for each failure' {
        $lines = Format-Summary -Results $script:summaryResults
        ($lines -join "`n") | Should -BeLike '*1/2 thanh cong*'
        ($lines -join "`n") | Should -BeLike '*MiKTeX*'
        ($lines -join "`n") | Should -BeLike '*winget install --id MiKTeX.MiKTeX -e*'
    }
}
