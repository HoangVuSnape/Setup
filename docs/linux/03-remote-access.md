# Cài & cấu hình SSH để điều khiển máy Linux từ xa

## Mục tiêu

Sau bước này, máy Linux Mint sẽ chạy sẵn SSH server, cho phép đăng nhập và gõ lệnh vào máy này trực tiếp từ Terminal có sẵn trên máy Windows — không cần cắm thêm màn hình/bàn phím riêng vào máy Linux cho hầu hết các thao tác sau này. Máy Linux cũng được đặt IP tĩnh để địa chỉ kết nối không đổi mỗi khi máy khởi động lại, vì máy này sẽ chạy "treo" 24/7 làm server.

## Các bước

1. **Hiểu sơ qua SSH là gì.**
   - SSH (Secure Shell) là một giao thức cho phép điều khiển một máy tính khác từ xa bằng dòng lệnh, qua kết nối mạng đã được mã hoá (encrypted) — không ai xem trộm được nội dung gõ qua lại giữa 2 máy.
   - Cần 2 phần: **SSH server** (chạy trên máy muốn điều khiển từ xa — máy Linux này) và **SSH client** (chạy trên máy dùng để kết nối tới — máy Windows). Sau bước này, việc cài đặt/quản lý máy Linux hằng ngày sẽ làm qua SSH từ máy Windows là chính, chỉ cần dùng lại màn hình/bàn phím gắn trực tiếp vào máy Linux khi có sự cố (ví dụ mất mạng, không SSH vào được).

2. **Cài OpenSSH server trên máy Linux.**
   - Mở Terminal trên máy Linux (xem lại file `02-first-boot-optimize.md` nếu quên cách mở), gõ:
     ```
     sudo apt install -y openssh-server
     ```
   - Lệnh này dùng `sudo` (quyền quản trị) để cài gói `openssh-server` — phần mềm SSH server. Nếu được hỏi mật khẩu, đây là mật khẩu đăng nhập máy Linux (gõ vào sẽ không hiện ký tự nào kể cả dấu `*`, bình thường) — đã giải thích chi tiết ở file `02-first-boot-optimize.md`.
   - Gói này thường tự bật kèm luôn dịch vụ SSH ngay sau khi cài xong, nhưng vẫn nên kiểm tra và bật tường minh ở bước tiếp theo cho chắc chắn.

3. **Bật SSH tự khởi động cùng máy và kiểm tra trạng thái.**
   - Gõ lệnh:
     ```
     sudo systemctl enable --now ssh
     ```
   - Giải thích: `systemctl` là công cụ quản lý các dịch vụ (service) chạy nền trên Linux. `enable` nghĩa là bật dịch vụ `ssh` tự khởi động mỗi khi mở máy (kể cả sau khi restart), `--now` nghĩa là bật chạy ngay lập tức luôn, không cần khởi động lại máy mới có hiệu lực.
   - Kiểm tra dịch vụ đang chạy đúng chưa:
     ```
     sudo systemctl status ssh
     ```
   - Kết quả cần thấy dòng `Active: active (running)` (thường hiện màu xanh). Nếu màn hình dừng lại chờ (rơi vào chế độ xem theo trang, gọi là pager) thay vì quay lại dấu nhắc lệnh ngay, bấm phím `q` để thoát ra.

4. **Tìm địa chỉ IP của máy Linux trong mạng nội bộ.**
   - Gõ một trong hai lệnh sau:
     ```
     hostname -I
     ```
     hoặc xem chi tiết hơn:
     ```
     ip a
     ```
   - Với `hostname -I`: kết quả trả về là (các) địa chỉ IP của máy, dạng `192.168.x.x`.
   - Với `ip a`: tìm mục tên bắt đầu bằng `eth0`/`enp...` (nếu dùng dây mạng LAN) hoặc `wlan0`/`wlp...` (nếu dùng Wi-Fi) — bỏ qua mục `lo` (địa chỉ loopback `127.0.0.1`, không dùng để kết nối từ máy khác). Dòng `inet 192.168.x.x/24` bên dưới tên interface đó chính là địa chỉ IP cần dùng.
   - Ghi nhớ lại địa chỉ IP này (ví dụ `192.168.1.50`) để dùng ở bước kết nối từ Windows.

5. **Kết nối từ máy Windows bằng Terminal có sẵn.**
   - Windows 11 đã tích hợp sẵn SSH client (`ssh`) từ nhiều năm nay, không cần cài thêm phần mềm gì thêm — dùng được ngay trong Windows Terminal hoặc PowerShell có sẵn.
   - Trên máy Windows, mở **Windows Terminal** (hoặc PowerShell): bấm nút **Start** → gõ "Terminal" → bấm vào kết quả **Terminal** hiện ra.
   - Gõ lệnh, thay `<user>` bằng đúng username đã tạo lúc cài Linux Mint và `<ip>` bằng địa chỉ IP tìm được ở bước 4:
     ```
     ssh <user>@<ip>
     ```
   - **Lần đầu kết nối tới máy này**, sẽ hiện cảnh báo dạng "The authenticity of host ... can't be established... Are you sure you want to continue connecting (yes/no/[fingerprint])?" — đây là bước xác nhận lần đầu bình thường của SSH (máy Windows chưa từng "biết" tới máy Linux này), gõ `yes` rồi Enter.
   - Tiếp theo, nhập mật khẩu của user trên máy Linux (màn hình cũng sẽ không hiện ký tự nào khi gõ, bình thường như trên Terminal Linux) rồi Enter. Kết nối thành công sẽ thấy dấu nhắc lệnh đổi thành `<user>@<tên-máy-Linux>:~$` — từ giờ mọi lệnh gõ vào cửa sổ Terminal này chạy thẳng trên máy Linux.

6. **Đặt IP tĩnh cho máy Linux (vì máy chạy 24/7).**
   - Lý do cần làm bước này: theo mặc định, router cấp IP kiểu "động" (DHCP) — địa chỉ IP của máy Linux có thể tự đổi sau khi router khởi động lại hoặc sau một thời gian dài. Nếu IP đổi, lệnh `ssh <user>@<ip>` đã lưu/quen dùng ở bước 5 sẽ không kết nối được nữa vì trỏ sai địa chỉ — phải dò lại IP mới mỗi lần. Đặt IP tĩnh (cố định) giúp địa chỉ này không đổi, kết nối SSH luôn ổn định.
   - Có 2 cách, chọn 1 trong 2 (khuyến khích cách qua router nếu router hỗ trợ, vì không phụ thuộc vào việc cài lại Mint sau này):
     - **Cách A — Đặt qua router (khuyến khích):** đăng nhập trang quản trị router (thường truy cập bằng trình duyệt tại địa chỉ gateway, ví dụ `192.168.1.1` — xem hướng dẫn theo đúng hãng router đang dùng), tìm mục có tên tương tự **"DHCP Reservation"**, **"Static Lease"**, hoặc **"Address Reservation"** — gán cố định địa chỉ IP hiện tại của máy Linux cho đúng địa chỉ MAC của máy đó. Tên mục và vị trí menu khác nhau tuỳ hãng router nên không hướng dẫn chi tiết từng bước ở đây.
     - **Cách B — Đặt trực tiếp trên Linux Mint qua Network Manager:**
       1. Trước tiên lấy thông tin mạng hiện tại để điền lại cho đúng — gõ trong Terminal:
          ```
          ip a
          ```
          (ghi nhớ IP và số sau dấu `/`, ví dụ `192.168.1.50/24`) và:
          ```
          ip route show default
          ```
          (dòng kết quả có dạng `default via 192.168.1.1 ...` — `192.168.1.1` chính là địa chỉ gateway/router).
       2. Bấm chuột phải vào **icon mạng** ở khay hệ thống (system tray, góc dưới bên phải màn hình, cạnh đồng hồ) → chọn **"Edit Connections..."**.
       3. Trong danh sách hiện ra, chọn đúng kết nối đang dùng (ví dụ **"Wired connection 1"** nếu cắm dây LAN), bấm biểu tượng **bánh răng (gear icon)** phía dưới để chỉnh sửa.
       4. Chuyển sang tab **IPv4 Settings**, đổi mục **Method** từ **Automatic (DHCP)** sang **Manual**.
       5. Bấm nút **Add**, điền **Address** (địa chỉ IP muốn cố định — có thể dùng lại đúng IP hiện tại lấy ở bước 6.1), **Netmask** (`255.255.255.0` tương ứng với `/24`), và **Gateway** (địa chỉ router lấy ở bước 6.1). Điền thêm **DNS servers** (ví dụ `8.8.8.8`) nếu ô đó đang trống.
       6. Bấm **Save**, sau đó tắt rồi bật lại kết nối mạng đó (bấm vào icon mạng ở khay hệ thống, tắt rồi bật lại) hoặc khởi động lại máy để áp dụng.
   - Sau khi đặt IP tĩnh, kiểm tra lại bằng `hostname -I` — IP hiển thị phải đúng bằng IP vừa đặt, và giữ nguyên sau khi khởi động lại máy.

## ✅ Kiểm tra đã thành công

- Lệnh `sudo systemctl status ssh` trên máy Linux hiện `Active: active (running)`.
- Từ Terminal trên máy Windows, gõ `ssh <user>@<ip>` kết nối thành công, dấu nhắc lệnh đổi thành `<user>@<tên-máy-Linux>:~$`, gõ thử một lệnh bất kỳ (ví dụ `whoami`) chạy đúng trên máy Linux.
- Sau khi đặt IP tĩnh (bước 6) và khởi động lại máy Linux, gõ `hostname -I` vẫn ra đúng địa chỉ IP đã đặt (không đổi sang địa chỉ khác), và `ssh <user>@<ip>` từ Windows với đúng IP đó vẫn kết nối được bình thường.

## ⚠️ Lỗi thường gặp

- Gõ `ssh` trên Windows Terminal báo "ssh: The term 'ssh' is not recognized...": rất hiếm gặp trên Windows 11 vì OpenSSH Client cài sẵn mặc định, nhưng nếu bị tắt thủ công trước đó thì vào **Settings > Apps > Optional features**, tìm và cài lại **"OpenSSH Client"**.
- Gõ lệnh `ssh` xong đứng chờ rất lâu rồi báo "Connection timed out" hoặc "No route to host": kiểm tra lại 2 máy có đang cùng chung 1 mạng nội bộ không (cùng Wi-Fi/router, hoặc cùng cắm vào 1 switch/router qua dây LAN) — 2 máy khác mạng (ví dụ 1 máy dùng 4G, 1 máy dùng Wi-Fi nhà) sẽ không thấy nhau qua IP nội bộ kiểu này.
- Báo lỗi "Connection refused": thường do dịch vụ `ssh` trên máy Linux chưa chạy — quay lại máy Linux, gõ `sudo systemctl status ssh` kiểm tra, nếu không phải `active (running)` thì gõ `sudo systemctl restart ssh` rồi thử kết nối lại.
- Sau khi cài lại Linux Mint (hoặc đổi máy) mà dùng lại đúng IP cũ, Windows báo cảnh báo đỏ dạng "REMOTE HOST IDENTIFICATION HAS CHANGED" và từ chối kết nối: đây là cơ chế bảo mật của SSH (máy Linux mới có "chữ ký" khác máy cũ dù cùng IP) — không phải bị tấn công, chỉ cần xoá dòng ghi nhớ cũ bằng lệnh sau trên Windows Terminal rồi kết nối lại: `ssh-keygen -R <ip>`.
- Đặt IP tĩnh ở bước 6 xong không vào được mạng nữa (mất Internet trên máy Linux): thường do điền sai Gateway hoặc Netmask — mở lại **Edit Connections**, kiểm tra lại đúng 3 giá trị Address/Netmask/Gateway đã lấy từ lệnh `ip a` và `ip route show default` ở bước 6.1, sửa lại cho đúng rồi Save và bật/tắt lại kết nối.
- Chọn IP tĩnh trùng với IP một thiết bị khác đang dùng trong mạng (xung đột địa chỉ - IP conflict) khiến mạng chập chờn: nên chọn IP tĩnh nằm ngoài dải mà router thường tự cấp qua DHCP (kiểm tra dải DHCP trong trang quản trị router), hoặc ưu tiên dùng Cách A (DHCP Reservation qua router) ở bước 6 để router tự tránh cấp trùng.
