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
