# Thiết kế: Personal PC Setup Docs (Windows 11 + Linux)

**Ngày:** 2026-09-15
**Trạng thái:** Đã duyệt thiết kế, chờ viết implementation plan

## 1. Mục tiêu

Xây dựng một kho tài liệu cá nhân (`docs/`) hướng dẫn từng bước để thiết lập lại máy tính từ đầu, dùng khi:
- Cài lại Windows 11 trên máy hiện tại (dùng để học IT & AI).
- Cài Linux Mint XFCE lên máy cũ chạy Win10 (cấu hình yếu), dùng để tự host vài server cơ bản.

Người đọc là chính chủ dự án — trình độ **beginner hoàn toàn**, chưa có sẵn công cụ/kiến thức gì. Tài liệu phải dẫn dắt từng bước, không giả định kiến thức nền.

## 2. Phạm vi

**Trong phạm vi:**
- Checklist + hướng dẫn thủ công dạng Markdown, từng bước có thể làm tay.
- Tách riêng theo 2 nền tảng: Windows 11 và Linux.
- File `CLAUDE.md` ở gốc project để các phiên Claude Code sau hiểu quy ước dự án.
- Dùng plugin `agentmemory` (đã cài sẵn trong môi trường Claude Code của user) để lưu các fact bối cảnh dự án ở tầm memory cá nhân (không phải nội dung docs).

**Ngoài phạm vi (chưa làm ở giai đoạn này):**
- Script tự động hoá cài đặt (PowerShell/Bash) — có thể bổ sung sau nếu cần, không nằm trong lần triển khai này.
- Nội dung media server hay các dịch vụ self-host khác ngoài NAS/file-share và Git/web server cá nhân.
- Ảnh chụp màn hình thực tế (chỉ mô tả bằng chữ ở giai đoạn đầu).

## 3. Hồ sơ 2 máy (bối cảnh)

| | Máy Windows | Máy Linux |
|---|---|---|
| OS hiện tại/dự kiến | Windows 11 | Win 10 cũ → cài lại Linux Mint XFCE |
| Cấu hình | Máy đang dùng để code, khá đủ mạnh | Máy cũ, cấu hình yếu |
| Mục đích chính | Học IT & AI: lập trình, thử nghiệm AI/ML | Tự host vài server cơ bản (NAS, Git/web cá nhân), chạy 24/7, không dùng để code nặng |
| Ghi chú | | Giữ GUI (Mint XFCE) dù nặng hơn bản không-GUI, vì ưu tiên dễ dùng cho beginner hơn là tối ưu tuyệt đối tài nguyên. Cài đặt qua USB boot (sẽ mua sau). |

## 4. Cấu trúc thư mục

```
Setup/
├── CLAUDE.md
├── README.md
└── docs/
    ├── superpowers/specs/        # spec/design docs (nội bộ, không phải nội dung hướng dẫn)
    ├── windows/
    │   ├── 00-checklist.md
    │   ├── 01-fresh-install.md
    │   ├── 02-essentials.md
    │   ├── 03-dev-tools.md
    │   ├── 04-python-env.md
    │   ├── 05-wsl2-docker.md
    │   └── 06-ai-ml.md
    └── linux/
        ├── 00-checklist.md
        ├── 01-usb-install.md
        ├── 02-first-boot-optimize.md
        ├── 03-remote-access.md
        ├── 04-dev-tools.md
        └── 05-self-hosting/
            ├── 01-nas-file-share.md
            └── 02-git-web-server.md
```

Quy ước đặt tên: `NN-ten-chu-de.md`, số thứ tự phản ánh đúng trình tự thao tác thực tế. `00-checklist.md` là trang tổng hợp checkbox, link tới từng file chi tiết — đây là điểm vào khi ngồi cài máy thật. `README.md` ở gốc chỉ là trang giới thiệu ngắn, link tới 2 checklist.

`05-self-hosting/` là thư mục con (không phải 1 file) để dễ mở rộng thêm dịch vụ self-host khác sau này mà không phải sửa các file hiện có.

## 5. Phạm vi nội dung từng file

### Windows (`docs/windows/`)

| File | Nội dung |
|---|---|
| `01-fresh-install.md` | Cài Win 11 từ USB (nếu cần), Windows Update, driver (đặc biệt GPU driver — quan trọng cho AI sau này), kích hoạt Windows, gỡ bớt phần mềm rác mặc định |
| `02-essentials.md` | Trình duyệt, 7-Zip, giới thiệu & cấu hình `winget`, tinh chỉnh Windows cơ bản |
| `03-dev-tools.md` | Git + tài khoản GitHub + SSH key, VS Code + extension gợi ý, Windows Terminal |
| `04-python-env.md` | Cài Python, venv/conda (Miniconda), pip, cách chọn phiên bản |
| `05-wsl2-docker.md` | Bật WSL2, cài Ubuntu trong WSL2, Docker Desktop (dùng WSL2 backend) |
| `06-ai-ml.md` | Jupyter Notebook/Lab, PyTorch (CPU/GPU tuỳ máy), numpy/pandas/scikit-learn, giới thiệu Ollama (LLM chạy local) |

### Linux (`docs/linux/`)

| File | Nội dung |
|---|---|
| `01-usb-install.md` | Tải ISO Linux Mint XFCE, tạo USB boot (Rufus/balenaEtcher), các bước cài đặt |
| `02-first-boot-optimize.md` | Update hệ thống, tối ưu tài nguyên cho máy yếu (tắt hiệu ứng đồ hoạ, quản lý app khởi động cùng máy, dọn swap...) |
| `03-remote-access.md` | Cài & cấu hình SSH để điều khiển máy Linux từ máy Win — quan trọng vì máy này chạy "treo" làm server |
| `04-dev-tools.md` | Git, các gói CLI cơ bản — nhẹ, không cài bộ AI/ML (vì code chính làm ở máy Win) |
| `05-self-hosting/01-nas-file-share.md` | Chia sẻ file cơ bản qua Samba (nhẹ hơn Nextcloud, phù hợp máy yếu) |
| `05-self-hosting/02-git-web-server.md` | Tự host Git cá nhân bằng Gitea (nhẹ, phù hợp máy yếu) |

Nội dung chi tiết (lệnh cụ thể, link tải...) sẽ được viết ở bước triển khai, có tra cứu nguồn chính thức hiện tại (9/2026) để đảm bảo còn đúng, tránh hướng dẫn lỗi thời.

## 6. CLAUDE.md

File `CLAUDE.md` ở gốc project chứa:
- Mục đích dự án (kho hướng dẫn cá nhân setup máy Win 11 + Linux khi cài mới/cài lại).
- Quy ước viết: tiếng Việt + giữ thuật ngữ kỹ thuật tiếng Anh nguyên gốc, giọng văn cho beginner hoàn toàn, mỗi bước đánh số, luôn có mục "kiểm tra đã thành công".
- Quy ước đặt tên file (`NN-ten-chu-de.md`) và yêu cầu cập nhật `00-checklist.md` khi thêm/bớt file.
- Tóm tắt hồ sơ 2 máy (mục 3 ở trên) để không phải hỏi lại từ đầu mỗi phiên.

## 7. agentmemory

Lưu vào agentmemory (tầm project memory, không phải nội dung docs) các fact:
- User đang học IT/AI (TDTU), có máy Win 11 mạnh dùng để code + AI, máy Linux cũ yếu dùng để self-host.
- Distro đã chọn: Linux Mint XFCE — giữ GUI dù máy yếu vì ưu tiên dễ dùng cho beginner.
- Các service tự host dự kiến: NAS/file-share (Samba) + Git/web cá nhân (Gitea).
- Quyết định cấu trúc docs (nhiều file nhỏ đánh số thứ tự + checklist tổng hợp) làm quy ước tham khảo cho các dự án setup tương tự sau này.

## 8. Quy ước định dạng mỗi file hướng dẫn

```markdown
# Tiêu đề

## Mục tiêu
(Bạn sẽ đạt được gì sau bước này)

## Các bước
1. ...
2. ...

## ✅ Kiểm tra đã thành công

## ⚠️ Lỗi thường gặp
(nếu có)
```

`00-checklist.md` mỗi OS: danh sách `- [ ] Bước X — mô tả ngắn (xem chi tiết: [file](đường dẫn))`.

## 9. Đảm bảo chất lượng

Đây là dự án tài liệu, không có test tự động như phần mềm:
- Trước khi viết mỗi file, tra cứu nguồn chính thức hiện tại để lệnh/link tải/phiên bản phần mềm còn đúng.
- Mỗi bước có mục kiểm tra đã thành công để người đọc tự xác nhận.
- Kiểm thử thật diễn ra khi user thực sự cài lại máy bằng USB — nếu phát hiện bước sai/thiếu, quay lại cập nhật (vòng lặp cải thiện liên tục, không phải làm một lần là xong).

## 10. Các quyết định đã chốt (tóm tắt)

- Docs + hướng dẫn thủ công, không cần script tự động hoá (giai đoạn này).
- Windows: bộ công cụ toàn diện cho IT + AI (Git, VS Code, Python, WSL2, Docker, Jupyter, PyTorch...).
- Linux: Linux Mint XFCE, giữ GUI dù máy yếu.
- Mục đích máy Linux: làm quen Linux/terminal + self-host NAS và Git/web cá nhân, tối ưu tài nguyên nhưng không hy sinh GUI.
- Ngôn ngữ docs: tiếng Việt, giữ thuật ngữ kỹ thuật tiếng Anh.
- Memory: dùng cả CLAUDE.md (trong project) và agentmemory (plugin đã cài sẵn) song song.
- Cấu trúc: nhiều file nhỏ đánh số thứ tự theo trình tự thao tác thực tế, có checklist tổng hợp.
