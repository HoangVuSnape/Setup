#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

windows_names=(
  "Cai dat / cap nhat Windows"
  "Cong cu co ban"
  "Git, GitHub va VS Code"
  "Python va moi truong ao"
  "WSL2 va Docker"
  "Cong cu AI/ML"
)
windows_paths=(
  "docs/windows/01-fresh-install.md"
  "docs/windows/02-essentials.md"
  "docs/windows/03-dev-tools.md"
  "docs/windows/04-python-env.md"
  "docs/windows/05-wsl2-docker.md"
  "docs/windows/06-ai-ml.md"
)
linux_names=(
  "Tao USB va cai Linux Mint"
  "First boot va toi uu may yeu"
  "SSH truy cap tu xa"
  "Git va cong cu dev"
  "NAS file-share bang Samba"
  "Git server bang Gitea"
)
linux_paths=(
  "docs/linux/01-usb-install.md"
  "docs/linux/02-first-boot-optimize.md"
  "docs/linux/03-remote-access.md"
  "docs/linux/04-dev-tools.md"
  "docs/linux/05-self-hosting/01-nas-file-share.md"
  "docs/linux/05-self-hosting/02-git-web-server.md"
)

open_guide() {
  local path="$ROOT/$1"
  if [[ ! -f "$path" ]]; then
    echo "Khong tim thay: $path"
    read -r -p "Nhan Enter de quay lai..."
    return
  fi

  if command -v code >/dev/null 2>&1; then
    code --reuse-window "$path"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$path" >/dev/null 2>&1 &
  else
    echo "Khong tim thay VS Code hoac ung dung mo file Markdown."
    echo "File: $path"
  fi
  read -r -p "Nhan Enter de quay lai menu..."
}

select_guide() {
  local title="$1"
  local names_name="$2[@]"
  local paths_name="$3[@]"
  local names=("${!names_name}")
  local paths=("${!paths_name}")

  while true; do
    clear
    echo "=== $title ==="
    for i in "${!names[@]}"; do
      echo "$((i + 1)). ${names[$i]}"
    done
    echo "0. Quay lai"
    read -r -p "Chon mot muc: " choice
    [[ "$choice" == "0" ]] && return
    if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice <= ${#names[@]} )); then
      open_guide "${paths[$((choice - 1))]}"
    fi
  done
}

while true; do
  clear
  echo "=== PC Setup Menu ==="
  echo "1. Setup may Windows 11"
  echo "2. Setup may Linux Mint XFCE"
  echo "0. Thoat"
  read -r -p "Chon he dieu hanh: " choice
  case "$choice" in
    1) select_guide "Windows 11" windows_names windows_paths ;;
    2) select_guide "Linux Mint XFCE" linux_names linux_paths ;;
    0) exit 0 ;;
  esac
done
