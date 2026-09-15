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
