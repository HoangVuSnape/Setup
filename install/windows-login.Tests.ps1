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
