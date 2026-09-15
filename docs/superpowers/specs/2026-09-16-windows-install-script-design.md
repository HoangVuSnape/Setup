# Thiết kế: Script cài đặt tự động cho Windows (menu chọn app)

**Ngày:** 2026-09-16
**Trạng thái:** Đã duyệt thiết kế, chờ viết implementation plan

## 1. Mục tiêu

Bổ sung một công cụ chạy được (không chỉ đọc) cho project setup docs hiện có: một script PowerShell mà khi chạy trên máy **Windows 11 vừa reset/cài lại xong**, sẽ hiện menu terminal cho người dùng chọn những ứng dụng IT/dev muốn cài, rồi tự động tải và cài đặt các ứng dụng đó qua `winget`.

Đây là **phần mở rộng có chủ đích** của project, đảo ngược quyết định "chỉ docs, không script" trong spec gốc (`docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md` §2, §10) — quyết định đó vẫn đúng cho lần viết đầu, nhưng giờ user chủ động muốn có thêm lớp tự động hoá phía trên các hướng dẫn thủ công đã có.

Bước đăng nhập/xác thực (ví dụ đăng nhập GitHub, Docker Hub, Claude...) **nằm ngoài phạm vi** thiết kế này — sẽ làm ở giai đoạn sau.

## 2. Phạm vi

**Trong phạm vi:**
- 1 script PowerShell (`install/windows-setup.ps1`) chạy được bằng lệnh `irm <raw-url> | iex` trên Windows 11.
- Menu terminal: nhập số để tick/bỏ chọn app tùy chọn, `all` để chọn hết, Enter rỗng để xác nhận.
- Một nhóm app "luôn cài" không cần chọn (Git, GitHub CLI, Docker Desktop, 7-Zip, Windows Terminal).
- Cài đặt qua `winget install --id <id> -e`, có kiểm tra đã cài trước đó để tránh cài đè.
- Lỗi ở 1 app không làm dừng toàn bộ script; tổng kết cuối cùng liệt kê thành công/lỗi.
- Cờ `-DryRun` để xem trước danh sách sẽ cài mà không thực sự cài gì.

**Ngoài phạm vi (chưa làm ở giai đoạn này):**
- Bản tương đương cho Linux (chưa có máy thật để test).
- Bước đăng nhập/xác thực cho các dịch vụ sau khi cài (GitHub, Docker, Claude...).
- Một file manifest JSON tách riêng danh sách app (dùng thiết kế đơn file tự chứa, xem §7 lý do).
- Gỡ cài đặt (uninstall) hàng loạt — script này chỉ cài, không gỡ.

## 3. Cách chạy

Không cần cài Git hay tải repo trước — mở PowerShell (không cần Admin) trên máy Windows 11 vừa cài xong, dán:

```powershell
irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1 | iex
```

`iex` (Invoke-Expression) chạy trực tiếp nội dung script tải về, không phải chạy file `.ps1` trên đĩa — nên **không** cần chỉnh `Set-ExecutionPolicy` như khi chạy file script thông thường.

Script tự kiểm tra `winget` có sẵn trong `PATH` không ngay khi bắt đầu chạy. Nếu thiếu, in lỗi rõ ràng (winget thường có sẵn theo mặc định trên Win 11, tham khảo `docs/windows/02-essentials.md` nếu thiếu) rồi dừng, không cố chạy tiếp.

Từng app nếu cần quyền Admin để cài, bản thân `winget`/installer của app đó sẽ tự bật popup UAC xin quyền khi tới lượt — không bắt cả phiên PowerShell chạy Admin ngay từ đầu.

## 4. Danh sách app

**Luôn cài (không hỏi):**

| App | winget id (tạm — xác nhận lại khi viết code) |
|---|---|
| Git | `Git.Git` |
| GitHub CLI | `GitHub.cli` |
| Docker Desktop | `Docker.DockerDesktop` |
| 7-Zip | `7zip.7zip` |
| Windows Terminal | `Microsoft.WindowsTerminal` |

**Tùy chọn — nhóm Dev Tools:**

| App | winget id (tạm) |
|---|---|
| VS Code | `Microsoft.VisualStudioCode` |
| GitHub Desktop | `GitHub.GitHubDesktop` |
| DataGrip | `JetBrains.DataGrip` |
| Claude Desktop | *winget id tạm — xác nhận lúc viết code (ví dụ `Anthropic.Claude`)* |
| MiKTeX | `MiKTeX.MiKTeX` |
| Trình duyệt (Chrome) | `Google.Chrome` |
| Bitwarden (password manager) | `Bitwarden.Bitwarden` |

**Tùy chọn — nhóm AI & Productivity:**

| App | winget id (tạm) |
|---|---|
| Python/Miniconda | `Anaconda.Miniconda3` |
| Obsidian | `Obsidian.Obsidian` |

**Tùy chọn — nhóm Media & Communication:**

| App | winget id (tạm) |
|---|---|
| OBS Studio | `OBSProject.OBSStudio` |
| Discord | `Discord.Discord` |
| Zalo | `VNGCorp.Zalo` |

Tất cả winget id ở trên đánh dấu "tạm" phải được xác nhận lại bằng nghiên cứu thực tế (winget search / trang chính thức) ở bước triển khai — đúng nguyên tắc "tra cứu nguồn hiện tại" đã áp dụng xuyên suốt project (`CLAUDE.md`).

## 5. Flow menu (tham khảo)

```
=== PC Setup - Cài đặt ứng dụng cho Windows 11 ===

Sẽ tự cài (không cần chọn): Git, GitHub CLI, Docker Desktop, 7-Zip, Windows Terminal

-- Dev Tools --
 [ ] 1. VS Code
 [ ] 2. GitHub Desktop
 [ ] 3. DataGrip
 [ ] 4. Claude Desktop
 [ ] 5. MiKTeX
 [ ] 6. Trình duyệt (Chrome)
 [ ] 7. Bitwarden

-- AI & Productivity --
 [ ] 8. Python/Miniconda
 [ ] 9. Obsidian

-- Media & Communication --
 [ ] 10. OBS Studio
 [ ] 11. Discord
 [ ] 12. Zalo

Gõ số để tick/bỏ chọn (vd: 1,3,7), gõ 'all' để chọn hết, Enter rỗng để xác nhận và bắt đầu cài.
> 1,4,8,9
Đã chọn: VS Code, Claude Desktop, Python/Miniconda, Obsidian
> [Enter để xác nhận]

Bạn sẽ cài: Git, GitHub CLI, Docker Desktop, 7-Zip, Windows Terminal (mặc định)
          + VS Code, Claude Desktop, Python/Miniconda, Obsidian (đã chọn)
Xác nhận cài? (y/n): y

[1/9] Git ... đã cài sẵn, bỏ qua ✓
[2/9] GitHub CLI ... đang cài... xong ✓
...
=== Hoàn tất: 8/9 thành công, 1 lỗi ===
Lỗi: MiKTeX - winget báo timeout, thử lại bằng: winget install --id MiKTeX.MiKTeX -e
```

## 6. Logic cài đặt

- **Kiểm tra trùng:** trước khi cài mỗi app, chạy `winget list --id <id> -e` — nếu đã có kết quả thì báo "đã cài sẵn, bỏ qua" thay vì cài đè lại từ đầu.
- **Lỗi không dừng cả script:** app nào cài lỗi (winget trả về exit code khác 0) thì ghi nhận vào danh sách lỗi và **tiếp tục app kế tiếp** — không dừng toàn bộ. Cuối script in tổng kết `X/Y thành công`, kèm danh sách lỗi và lệnh `winget install --id ... -e` tương ứng để người dùng tự chạy lại thủ công nếu muốn.
- **Xác nhận trước khi cài:** sau khi chọn xong (tick số + Enter), script hiện lại toàn bộ danh sách sẽ cài (mandatory + đã chọn) và hỏi `y/n` một lần trước khi thực sự bắt đầu — tránh cài nhầm do bấm sai số.
- **`-DryRun`:** cờ tuỳ chọn. Khi bật, script chạy toàn bộ flow chọn menu và in ra danh sách "sẽ cài" nhưng **không** gọi `winget install` thật. `irm ... | iex` kiểu thường không truyền tham số trực tiếp được, nên để dùng `-DryRun` phải gọi theo cú pháp sau (biến nội dung tải về thành một script block rồi gọi kèm tham số):
  ```powershell
  & ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1))) -DryRun
  ```
  Cách gọi bình thường (không kèm cờ) vẫn giữ nguyên dạng đơn giản `irm <raw-url> | iex` như ở §3. `README.md`/hướng dẫn sử dụng sẽ ghi rõ cả 2 cú pháp.

## 7. Vì sao 1 file tự chứa (không tách manifest JSON)

Với ~17 app hiện tại, để toàn bộ danh sách + logic trong 1 file `.ps1` vẫn dễ đọc/sửa. Quan trọng hơn: cách chạy `irm | iex` chỉ tải đúng 1 file qua mạng và thực thi ngay — nếu tách app list ra JSON riêng, script phải tự tải thêm 1 request nữa ở runtime để lấy file đó, thêm điểm có thể lỗi (mạng chập chờn, sai URL) mà không cần thiết ở quy mô hiện tại. Khi danh sách app phình to hơn nhiều (ví dụ 50+), có thể tách ra sau.

## 8. Kiểm thử / đảm bảo chất lượng

Đây là code thực thi thật (khác với các file docs Markdown trước đó), nên cách QA khác:
- Tự kiểm tra cú pháp PowerShell hợp lệ (parse-check tĩnh) trước khi commit — không cần môi trường Windows đầy đủ để làm việc này.
- Không có sẵn máy Windows 11 "vừa reset" thật để chạy full flow an toàn (chạy thật sẽ cài hàng loạt app lên máy đang dùng) — cờ `-DryRun` dùng để tự test luồng chọn menu mà không cài đè gì lên máy hiện tại.
- Khi user có máy thật (sau khi mua USB cài Win, hoặc thử trên máy ảo), chạy thật lần đầu và báo lại lỗi nếu có — áp dụng vòng lặp cải thiện giống như đã làm với phần docs trước đó.

## 9. Các quyết định đã chốt (tóm tắt)

- Chỉ làm cho Windows trước; Linux để sau khi có máy thật.
- Tương tác menu: gõ số để tick/bỏ chọn, Enter rỗng để xác nhận (không dùng mũi tên/Space).
- 5 app luôn cài, 12 app tùy chọn chia 3 nhóm (Dev Tools / AI & Productivity / Media & Communication) — bao gồm Bitwarden (password manager), thêm sau khi script gốc đã triển khai xong, theo yêu cầu bổ sung của user.
- Cách chạy: `irm <raw-url> | iex` — cần repo GitHub public.
- 1 file `.ps1` tự chứa, không tách manifest JSON.
- Có kiểm tra trùng, không dừng khi lỗi 1 app, xác nhận trước khi cài, cờ `-DryRun` để test an toàn.
- Bước đăng nhập/xác thực các dịch vụ: ngoài phạm vi, làm sau.
