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
