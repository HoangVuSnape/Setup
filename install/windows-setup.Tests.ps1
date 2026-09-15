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
