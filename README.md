# Setup — Hướng dẫn cài đặt máy cá nhân

Kho tài liệu hướng dẫn từng bước để setup lại 2 máy tính, viết cho người mới bắt đầu hoàn toàn.

## Máy Windows 11 (học IT & AI)

Bắt đầu tại [docs/windows/00-checklist.md](docs/windows/00-checklist.md).

### Cài tự động bằng script (tùy chọn, nhanh hơn làm tay)

Sau khi làm xong [01-fresh-install.md](docs/windows/01-fresh-install.md), có thể dùng script này để cài hàng loạt app còn lại thay vì làm tay từng bước — mở PowerShell (không cần Admin) và dán:

```powershell
irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1 | iex
```

Muốn xem trước sẽ cài gì mà không cài thật (chế độ thử):

```powershell
& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1))) -DryRun
```

## Máy Linux (Mint XFCE, self-host server)

Bắt đầu tại [docs/linux/00-checklist.md](docs/linux/00-checklist.md).

---

Xem thiết kế đầy đủ của dự án tại [docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md](docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md).
