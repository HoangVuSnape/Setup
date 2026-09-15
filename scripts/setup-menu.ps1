$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$windowsDocs = @(
    @{ Name = 'Cai dat / cap nhat Windows'; Path = 'docs/windows/01-fresh-install.md' }
    @{ Name = 'Cong cu co ban'; Path = 'docs/windows/02-essentials.md' }
    @{ Name = 'Git, GitHub va VS Code'; Path = 'docs/windows/03-dev-tools.md' }
    @{ Name = 'Python va moi truong ao'; Path = 'docs/windows/04-python-env.md' }
    @{ Name = 'WSL2 va Docker'; Path = 'docs/windows/05-wsl2-docker.md' }
    @{ Name = 'Cong cu AI/ML'; Path = 'docs/windows/06-ai-ml.md' }
)
$linuxDocs = @(
    @{ Name = 'Tao USB va cai Linux Mint'; Path = 'docs/linux/01-usb-install.md' }
    @{ Name = 'First boot va toi uu may yeu'; Path = 'docs/linux/02-first-boot-optimize.md' }
    @{ Name = 'SSH truy cap tu xa'; Path = 'docs/linux/03-remote-access.md' }
    @{ Name = 'Git va cong cu dev'; Path = 'docs/linux/04-dev-tools.md' }
    @{ Name = 'NAS file-share bang Samba'; Path = 'docs/linux/05-self-hosting/01-nas-file-share.md' }
    @{ Name = 'Git server bang Gitea'; Path = 'docs/linux/05-self-hosting/02-git-web-server.md' }
)

function Open-Guide($guide) {
    $fullPath = Join-Path $root $guide.Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "Khong tim thay: $fullPath" -ForegroundColor Red
        return
    }

    if (Get-Command code -ErrorAction SilentlyContinue) {
        code --reuse-window $fullPath
    } else {
        Start-Process $fullPath
    }
}

function Select-Guide($title, $guides) {
    while ($true) {
        Clear-Host
        Write-Host "=== $title ===" -ForegroundColor Cyan
        for ($index = 0; $index -lt $guides.Count; $index++) {
            Write-Host "$($index + 1). $($guides[$index].Name)"
        }
        Write-Host '0. Quay lai'
        $choice = Read-Host 'Chon mot muc'
        if ($choice -eq '0') { return }
        $number = 0
        if ([int]::TryParse($choice, [ref]$number) -and $number -ge 1 -and $number -le $guides.Count) {
            Open-Guide $guides[$number - 1]
            Read-Host 'Nhan Enter de quay lai menu'
        }
    }
}

while ($true) {
    Clear-Host
    Write-Host '=== PC Setup Menu ===' -ForegroundColor Green
    Write-Host '1. Setup may Windows 11'
    Write-Host '2. Setup may Linux Mint XFCE'
    Write-Host '0. Thoat'
    $choice = Read-Host 'Chon he dieu hanh'
    switch ($choice) {
        '1' { Select-Guide 'Windows 11' $windowsDocs }
        '2' { Select-Guide 'Linux Mint XFCE' $linuxDocs }
        '0' { exit }
    }
}
