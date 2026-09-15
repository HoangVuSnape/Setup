# Thiết kế: Script hỗ trợ đăng nhập tài khoản an toàn

**Ngày:** 2026-09-16
**Trạng thái:** Đã viết xong, **chờ bạn duyệt** — chưa lập implementation plan, chưa code. Đây là bản thiết kế mình tự quyết định phần lớn theo yêu cầu của bạn ("chọn theo hướng bạn recommend"), bạn đọc và phản hồi khi rảnh.

## 0. Giới hạn cứng — đọc trước khi đọc phần còn lại

Mình (Claude) **không bao giờ** được phép xử lý mật khẩu, API key, token hay bất kỳ thông tin xác thực nào — không nhập hộ, không lưu, không yêu cầu bạn dán vào script để mình đọc. Giới hạn này áp dụng **kể cả khi bạn chủ động yêu cầu/cho phép**.

Vì vậy "tự động hoá đăng nhập an toàn" ở đây chỉ có thể là 1 trong 2 việc:
1. **Kích hoạt đúng cơ chế đăng nhập chính thức** của bản thân app/dịch vụ đó (mở trình duyệt để OAuth, hoặc hiện QR code) — người dùng tự xác thực trực tiếp với dịch vụ thật (GitHub, Docker, Discord...), không có secret nào đi qua hay chạm vào script.
2. **Mở app lên và nhắc bạn tự đăng nhập** theo giao diện riêng của app đó.

Script **không bao giờ**: hỏi/nhận password qua `Read-Host`, lưu bất kỳ giá trị nào vào file/biến môi trường, đoán/điền form đăng nhập bằng UI automation.

## 1. Mục tiêu

Sau khi `windows-setup.ps1` cài xong các app, người dùng cần đăng nhập vào một số dịch vụ trước khi dùng được đầy đủ (GitHub, Docker Hub, Claude, Discord, Zalo...). Script này giúp **kích hoạt đúng bước đăng nhập** cho từng app đã cài, theo đúng cơ chế an toàn nhất mà chính app/dịch vụ đó cung cấp — không phải mình tự chế ra cách đăng nhập.

## 2. Nghiên cứu: app nào dùng được cơ chế nào

| App | Cơ chế đăng nhập thật | Script làm được gì |
|---|---|---|
| **GitHub CLI** | `gh auth login` — mặc định mở trình duyệt, xác thực OAuth, token được `gh` tự lưu an toàn vào Windows Credential Manager (không phải script lưu) | **Tự chạy lệnh này** (kế thừa console cho người dùng thao tác trong trình duyệt) |
| **Docker Desktop** | `docker login` (không kèm `--username`) — mặc định dùng **device code flow**: hiện 1 mã, người dùng bấm Enter để mở trình duyệt hoặc tự vào `login.docker.com/activate`, nhập mã, xác thực trên web. Không gõ password vào terminal. | **Tự chạy lệnh này** |
| GitHub Desktop | OAuth qua trình duyệt, nhưng chỉ có trong giao diện app riêng, không có lệnh CLI kích hoạt từ ngoài | Chỉ mở app + nhắc |
| Claude Desktop | OAuth Anthropic qua giao diện app riêng | Chỉ mở app + nhắc |
| Discord | **QR code**: mở app → điện thoại đã có Discord → quét mã (hết hạn sau 2 phút, phải xác nhận trên điện thoại) | Chỉ mở app + nhắc dùng QR |
| Zalo | QR code tương tự (theo hiểu biết chung — sẽ xác nhận lại chi tiết chính xác lúc code thật) | Chỉ mở app + nhắc dùng QR |
| DataGrip | JetBrains Account qua trình duyệt, chỉ cần nếu muốn dùng bản quyền đầy đủ (có thể dùng thử không cần đăng nhập) | Chỉ mở app + nhắc, ghi rõ là **tùy chọn** |
| VS Code | Đăng nhập GitHub/Microsoft chỉ cần cho Settings Sync, không bắt buộc để dùng | Chỉ mở app + nhắc, ghi rõ là **tùy chọn** |
| Git, 7-Zip, Windows Terminal, MiKTeX, Python/Miniconda, OBS Studio, Chrome, Obsidian | Không có khái niệm "đăng nhập" cần thiết cho việc dùng cơ bản (Chrome/Obsidian có sync tùy chọn nhưng không cần cho use case hiện tại) | **Không đưa vào script này** |

## 3. Kiến trúc

Một file riêng, **tách khỏi** `windows-setup.ps1` (không gộp chung) — vì đây là 2 trách nhiệm khác nhau (cài đặt vs. đăng nhập), và người dùng có thể muốn chạy lại phần đăng nhập sau này (ví dụ đổi máy, đăng nhập lại) mà không cần cài lại app:

```
install/
├── windows-setup.ps1        (đã có)
├── windows-setup.Tests.ps1  (đã có)
├── windows-login.ps1        (mới)
└── windows-login.Tests.ps1  (mới)
```

Cách chạy — cùng kiểu `irm | iex` như script cài đặt, để nhất quán:

```powershell
irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-login.ps1 | iex
```

Menu chọn giống hệt UX của `windows-setup.ps1` (gõ số để tick/bỏ chọn, `all` để chọn hết, Enter rỗng để xác nhận) — tái dùng đúng pattern đã có, không phát minh lại:

```
=== Kich hoat dang nhap ===

-- Tu dong (mo dung co che chinh thuc cua app) --
 [ ] 1. GitHub CLI (gh auth login)
 [ ] 2. Docker Desktop (docker login)

-- Mo app, ban tu dang nhap --
 [ ] 3. GitHub Desktop
 [ ] 4. Claude Desktop
 [ ] 5. Discord (dung QR code tren dien thoai - nhanh nhat)
 [ ] 6. Zalo (dung QR code tren dien thoai - nhanh nhat)
 [ ] 7. DataGrip (tuy chon - chi can neu muon ban quyen day du)
 [ ] 8. VS Code (tuy chon - chi can neu muon Settings Sync)

Go so de tick/bo chon, 'all' de chon het, Enter rong de xac nhan.
> 1,2,5
...
Dang kich hoat...
[1/3] GitHub CLI: dang chay 'gh auth login' - lam theo huong dan tren man hinh/trinh duyet...
[2/3] Docker Desktop: dang chay 'docker login' - lam theo ma hien tren man hinh...
[3/3] Discord: da mo app - vao Cai dat > Quet ma QR, dung Discord tren dien thoai de quet.
=== Xong. Kiem tra lai tung app da dang nhap thanh cong chua. ===
```

Với các mục "tự động" (`gh auth login`, `docker login`), script **không capture output**, không đọc bất kỳ input nào từ 2 lệnh này — chỉ gọi lệnh và để nó chiếm console trực tiếp, người dùng thao tác thẳng với `gh`/`docker`, không qua tay script.

Với các mục "mở app", script chỉ `Start-Process <đường dẫn exe>` rồi in dòng nhắc — không chờ, không kiểm tra đăng nhập thành công hay chưa (không có cách nào làm việc này mà không đụng tới thông tin nhạy cảm).

## 4. Phạm vi

**Trong phạm vi:** menu chọn, kích hoạt 2 cơ chế CLI an toàn (gh/docker), mở app + nhắc cho 6 app còn lại, tài liệu rõ giới hạn cứng ở §0.

**Ngoài phạm vi:**
- Không kiểm tra/xác nhận đăng nhập đã thành công (không có cách an toàn để làm).
- Không lưu bất kỳ trạng thái đăng nhập nào.
- Không tự động hoá cho Zalo/Discord xa hơn việc mở app (không có QR "ảo" nào script tạo ra được — QR là do chính app hiển thị).
- Chưa xác nhận 100% cơ chế QR của Zalo desktop (dựa trên hiểu biết chung, phổ biến ở VN) — sẽ nghiên cứu xác nhận lại khi viết code thật, theo đúng kỷ luật "tra cứu trước khi viết" của dự án.

## 5. Testing

Tương tự `windows-setup.ps1`: phần logic thuần (menu, chọn item) viết Pester test được. Phần gọi `gh auth login`/`docker login`/`Start-Process` là I/O thật với hệ thống ngoài — bọc qua 1 hàm mỏng để mock được trong test (giống pattern `Invoke-Winget` đã dùng), không test bằng cách chạy thật (sẽ mở trình duyệt/app thật, không phù hợp để test tự động).

## 6. Việc cần bạn xác nhận khi đọc

- Đồng ý tách file riêng (`windows-login.ps1`) thay vì gộp vào `windows-setup.ps1`?
- Đồng ý bỏ MiKTeX/Python/OBS/Chrome/Obsidian ra khỏi danh sách (không có nhu cầu đăng nhập thật)?
- Danh sách 8 mục ở §2 đã đủ chưa, hay có app/dịch vụ nào khác bạn muốn thêm (ví dụ: đăng nhập Windows bằng Microsoft Account, license Windows...)?
