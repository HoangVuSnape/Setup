# Setup — Hướng dẫn cài đặt máy cá nhân

Kho tài liệu hướng dẫn từng bước để setup lại 2 máy tính, viết cho người mới bắt đầu hoàn toàn.

## Máy Windows 11 (học IT & AI)

Bắt đầu tại [docs/windows/00-checklist.md](docs/windows/00-checklist.md).

## Máy Linux (Mint XFCE, self-host server)

Bắt đầu tại [docs/linux/00-checklist.md](docs/linux/00-checklist.md).

---

Xem thiết kế đầy đủ của dự án tại [docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md](docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md).

## Mở menu từ Terminal

Menu hiện tại chỉ mở đúng file hướng dẫn đã chọn; nó chưa tự chạy lệnh cài đặt.

- Windows PowerShell: chạy `.\scripts\setup-menu.ps1`.
- Linux Mint: chạy `chmod +x scripts/setup-menu.sh` một lần, sau đó chạy `./scripts/setup-menu.sh`.

Menu sẽ cho chọn Windows hoặc Linux, rồi mở từng bước bằng VS Code. Nếu chưa cài VS Code, menu sẽ dùng ứng dụng mặc định của hệ điều hành để mở file Markdown.
