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
        [PSCustomObject]@{ Name = 'Claude Desktop'; WingetId = 'Anthropic.Claude' }
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
