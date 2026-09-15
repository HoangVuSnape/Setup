# Cài Samba để chia sẻ file (NAS cơ bản) từ máy Linux

## Mục tiêu

Sau bước này, máy Linux sẽ chạy Samba — phần mềm giúp một thư mục trên máy Linux hiện ra như một ổ đĩa mạng (network drive) trên máy Windows, y hệt cách các NAS thương mại hoạt động. Bạn có thể mở File Explorer trên máy Windows, vào thẳng thư mục đó để copy/xem/xoá file qua lại giữa 2 máy mà không cần cắm USB hay dùng dây cáp.

## Các bước

1. **Hiểu sơ qua Samba là gì.**
   - Windows dùng giao thức riêng (gọi là SMB/CIFS) để chia sẻ file/thư mục qua mạng nội bộ — đây chính là cơ chế đứng sau các ổ đĩa mạng, NAS quen thuộc. Samba là phần mềm mã nguồn mở cài trên Linux để "nói" đúng giao thức này, giúp máy Linux giả lập thành một Windows file server — máy Windows truy cập vào mà không nhận ra khác biệt gì.
   - Cần đăng nhập (username/password) để vào được thư mục chia sẻ — Samba dùng một hệ mật khẩu **riêng**, tách biệt với mật khẩu đăng nhập Linux (chi tiết ở bước 4).

2. **Cài Samba bằng apt.**
   - Mở Terminal trên máy Linux (qua SSH từ Windows — xem lại `03-remote-access.md` — hoặc mở trực tiếp trên máy Linux), gõ:
     ```
     sudo apt install samba
     ```
   - Gói `samba` chứa dịch vụ server chính (`smbd`) và tự kéo theo các công cụ phụ trợ cần thiết như `smbpasswd` (dùng ở bước 4).
   - Kiểm tra cài xong chưa:
     ```
     smbd --version
     ```
     ra kết quả dạng `Version 4.x.x`.

3. **Tạo thư mục sẽ dùng để chia sẻ.**
   - Gõ lệnh sau để tạo thư mục tên `shared` ngay trong home directory của user hiện tại (dấu `~` là ký hiệu viết tắt của home directory, ví dụ `/home/<user>`):
     ```
     mkdir ~/shared
     ```
   - Đây là thư mục sẽ "hiện ra" bên máy Windows sau khi cấu hình xong — copy file vào đây trên máy Linux thì bên Windows cũng thấy, và ngược lại.

4. **Thêm cấu hình chia sẻ vào file `/etc/samba/smb.conf`.**
   - Đây là file cấu hình chính của Samba — mỗi thư mục muốn chia sẻ cần khai báo một khối (block) riêng trong file này. Mở file bằng `nano` (đã làm quen ở `04-dev-tools.md`):
     ```
     sudo nano /etc/samba/smb.conf
     ```
   - File này khá dài (toàn chú thích và cấu hình mặc định) — dùng phím mũi tên xuống hoặc `Page Down` để kéo xuống **tận cuối file**, rồi dán (paste) đúng khối sau vào:
     ```
     [shared]
        comment = Thu muc chia se tu may Linux
        path = /home/<user>/shared
        read only = no
        browsable = yes
     ```
   - Thay `<user>` bằng đúng username Linux của bạn (username đã dùng để `ssh` vào máy ở `03-remote-access.md`) — ví dụ nếu username là `quyvu` thì dòng `path` sửa thành `path = /home/quyvu/shared`.
   - Giải thích từng dòng: `[shared]` là tên của share, sẽ hiện ra bên Windows dưới dạng `\\<ip>\shared`; `comment` là mô tả ngắn (không bắt buộc, có thể để tiếng Việt không dấu để tránh lỗi font); `path` là đường dẫn thư mục thật trên máy Linux (chính là thư mục tạo ở bước 3); `read only = no` cho phép ghi/xoá file (không chỉ đọc); `browsable = yes` cho phép share này hiện ra khi duyệt danh sách share từ máy khác.
   - Nếu kết nối qua SSH (Windows Terminal) và không gõ tay nổi đoạn trên, có thể copy đoạn cấu hình rồi dán vào Terminal bằng chuột phải (right-click) hoặc `Ctrl+Shift+V` — nano sẽ nhận đúng nội dung dán vào vị trí con trỏ đang đứng.
   - Lưu file bằng `Ctrl+O` rồi `Enter`, thoát bằng `Ctrl+X` (xem lại chi tiết phím tắt nano ở `04-dev-tools.md` nếu quên).

5. **Đặt mật khẩu Samba cho user hiện tại.**
   - Như đã nói ở bước 1, Samba dùng mật khẩu riêng, không tự dùng chung mật khẩu đăng nhập Linux — cần đặt mật khẩu này một lần cho user hiện tại bằng lệnh:
     ```
     sudo smbpasswd -a $USER
     ```
   - `$USER` là biến môi trường (environment variable) luôn chứa sẵn username đang đăng nhập trên Terminal — không cần gõ tay tên user. Lệnh sẽ hỏi nhập mật khẩu 2 lần (New SMB password / Retype new SMB password) — có thể đặt giống hoặc khác mật khẩu đăng nhập Linux, miễn nhớ được vì sẽ dùng để đăng nhập từ máy Windows ở bước 7. Gõ mật khẩu sẽ không hiện ký tự nào, bình thường.

6. **Khởi động lại dịch vụ Samba để áp dụng cấu hình mới.**
   - Gõ lệnh:
     ```
     sudo systemctl restart smbd
     ```
   - `smbd` là tên dịch vụ (service) chạy nền của Samba — lệnh này nạp lại toàn bộ nội dung file `smb.conf` vừa sửa ở bước 4 mà không cần khởi động lại cả máy.
   - Kiểm tra dịch vụ chạy đúng chưa:
     ```
     sudo systemctl status smbd
     ```
     cần thấy dòng `Active: active (running)` (giống cách kiểm tra dịch vụ `ssh` ở `03-remote-access.md`). Bấm `q` nếu màn hình dừng ở chế độ xem theo trang (pager).

7. **Truy cập thư mục chia sẻ từ máy Windows.**
   - Xác định IP của máy Linux nếu chưa nhớ (xem lại bước 4 ở `03-remote-access.md`, dùng `hostname -I`).
   - Trên máy Windows, mở **File Explorer** (bấm icon thư mục ở taskbar, hoặc phím tắt `Windows + E`).
   - Bấm vào thanh địa chỉ (address bar) phía trên, gõ đúng cú pháp sau (thay `<ip-máy-linux>` bằng IP tìm được ở trên) rồi Enter:
     ```
     \\<ip-máy-linux>\shared
     ```
   - Sẽ hiện hộp thoại yêu cầu đăng nhập — nhập đúng **username Linux** và **mật khẩu Samba** vừa đặt ở bước 5 (không phải mật khẩu Windows). Có thể tích ô "Remember my credentials" để lần sau không phải nhập lại.
   - Đăng nhập thành công sẽ thấy nội dung thư mục `~/shared` bên máy Linux hiện ra ngay trong File Explorer — thử tạo/copy một file vào đây.

## ✅ Kiểm tra đã thành công

- `sudo systemctl status smbd` trên máy Linux hiện `Active: active (running)`.
- Từ File Explorer trên máy Windows, gõ `\\<ip-máy-linux>\shared`, đăng nhập bằng username Linux + mật khẩu Samba thành công, thấy được nội dung thư mục.
- Copy thử một file từ Windows vào thư mục mạng này, quay lại Terminal máy Linux gõ `ls ~/shared` thấy đúng file vừa copy (và ngược lại: tạo file trong `~/shared` trên Linux rồi refresh bên Windows cũng phải thấy).

## ⚠️ Lỗi thường gặp

- Gõ `sudo smbpasswd -a $USER` báo "command not found": gói `smbpasswd` đôi khi không tự kéo theo đầy đủ — chạy `sudo apt install samba-common-bin` rồi thử lại.
- File Explorer báo "Windows cannot access \\\\<ip>\shared" (không tìm thấy đường dẫn mạng): kiểm tra lại đúng IP (dùng `hostname -I` để lấy lại cho chắc), kiểm tra 2 máy có cùng mạng nội bộ không (xem lỗi tương tự ở `03-remote-access.md`), và kiểm tra tường lửa trên Linux — nếu `sudo ufw status` báo `active`, mở thêm cho Samba bằng `sudo ufw allow samba`.
- Hộp thoại đăng nhập cứ hỏi lại mật khẩu dù gõ đúng: thường do gõ nhầm mật khẩu **Windows** thay vì mật khẩu **Samba** vừa đặt ở bước 5 — hai mật khẩu này độc lập nhau. Nếu Windows đã lỡ lưu (cache) thông tin đăng nhập sai trước đó, mở **Control Panel > Credential Manager**, xoá mục liên quan tới IP máy Linux rồi thử kết nối lại từ đầu.
- Sửa `smb.conf` xong nhưng share không hiện hoặc restart báo lỗi: có thể do gõ sai cú pháp (thiếu dấu `[` `]`, sai dòng lệnh) — chạy lệnh `testparm` để Samba tự kiểm tra và báo lỗi cú pháp trong file trước khi restart lại `smbd`.
- Gõ `sudo systemctl restart smbd` báo "Unit smbd.service not found": thường do bước cài đặt ở bước 2 (`sudo apt install samba`) bị lỗi giữa chừng (mất mạng) — chạy lại `sudo apt update` rồi `sudo apt install samba` lần nữa.
