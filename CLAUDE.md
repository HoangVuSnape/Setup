# CLAUDE.md

Dự án này là kho tài liệu **cá nhân** hướng dẫn setup lại 2 máy tính từ đầu (cài Win mới hoặc cài lại). Người đọc chính là chủ dự án — trình độ beginner hoàn toàn.

## Hồ sơ 2 máy

| | Máy Windows | Máy Linux |
|---|---|---|
| OS | Windows 11 | Linux Mint XFCE (cài mới từ USB) |
| Cấu hình | Đủ mạnh để code + AI | Máy cũ, cấu hình yếu |
| Mục đích | Học IT & AI: lập trình, thử nghiệm AI/ML | Self-host server cơ bản (NAS, Git/web cá nhân), chạy 24/7 |
| Ghi chú | | Giữ GUI (XFCE) dù nặng hơn bản không-GUI — ưu tiên dễ dùng cho beginner hơn tối ưu tuyệt đối tài nguyên |

## Quy ước viết docs

- Ngôn ngữ: tiếng Việt, giữ nguyên thuật ngữ kỹ thuật/tên lệnh/tên phần mềm bằng tiếng Anh (không dịch "terminal", "package manager", tên lệnh...).
- Giọng văn: cho người mới hoàn toàn, không giả định kiến thức nền, giải thích ngắn gọn trước khi ra lệnh.
- Mỗi file hướng dẫn theo khung: `# Tiêu đề` → `## Mục tiêu` → `## Các bước` (đánh số) → `## ✅ Kiểm tra đã thành công` → `## ⚠️ Lỗi thường gặp`.
- Đặt tên file: `NN-ten-chu-de.md`, số phản ánh đúng thứ tự thao tác thực tế.
- Khi thêm/bớt file trong `docs/windows/` hoặc `docs/linux/`, luôn cập nhật `00-checklist.md` tương ứng.
- Trước khi viết/sửa nội dung có lệnh cụ thể hoặc link tải, tra cứu nguồn hiện tại — tránh hướng dẫn lỗi thời.

## Cấu trúc

```
docs/
├── windows/   (00-checklist.md + 01..06 theo thứ tự cài đặt)
└── linux/     (00-checklist.md + 01..04 + 05-self-hosting/)
```

Xem chi tiết đầy đủ tại `docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md`.
