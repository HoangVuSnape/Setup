# Cập nhật hệ thống và tối ưu tài nguyên cho máy yếu

## Mục tiêu

Sau bước này, máy Linux Mint vừa cài xong sẽ được cập nhật đầy đủ, tắt bớt hiệu ứng đồ hoạ và ứng dụng khởi động không cần thiết để nhẹ máy hơn (máy này cấu hình yếu), có sẵn công cụ `htop` để theo dõi CPU/RAM, và bạn hiểu sơ qua về swap để biết máy có đang "đuối" RAM hay không — chuẩn bị nền tảng trước khi cài các dịch vụ self-host ở các file sau.

## Các bước

1. **Mở Terminal lần đầu tiên.**
   - Đây là cửa sổ dòng lệnh (command line) — cách chính để cài đặt và quản lý phần mềm trên Linux, khác với Windows quen dùng giao diện chuột click. Mở bằng cách: bấm **Menu** (góc dưới bên trái màn hình) → gõ "Terminal" → bấm vào kết quả **Terminal** hiện ra. Hoặc dùng phím tắt `Ctrl+Alt+T`.
   - Một cửa sổ nền đen/tối hiện ra với dấu nhắc lệnh (prompt) — đây là nơi gõ toàn bộ các lệnh ở file này và các file tiếp theo.

2. **Cập nhật toàn bộ hệ thống ngay sau khi cài xong.**
   - Gõ lệnh sau rồi bấm Enter:
     ```
     sudo apt update && sudo apt upgrade -y
     ```
   - Giải thích các phần của lệnh:
     - `apt` là trình quản lý gói (package manager) của Linux Mint/Ubuntu — tương đương "kho ứng dụng" dùng qua dòng lệnh.
     - `apt update` tải lại danh sách phiên bản phần mềm mới nhất từ máy chủ (chưa cài gì cả, chỉ cập nhật danh sách).
     - `apt upgrade -y` cài các bản cập nhật thật sự cho phần mềm đã có sẵn trên máy; `-y` để tự động trả lời "Yes" khi được hỏi xác nhận, khỏi phải gõ tay.
     - `sudo` (viết tắt "superuser do") là chạy lệnh với quyền quản trị (admin/root) — bắt buộc cho các thao tác cài đặt/cập nhật hệ thống. Lần đầu dùng `sudo` trong phiên terminal, máy sẽ hỏi **mật khẩu đăng nhập** (mật khẩu user đã tạo lúc cài Mint) — gõ vào rồi Enter; **màn hình sẽ không hiện ký tự nào kể cả dấu `*`** khi gõ mật khẩu, đây là bình thường của terminal Linux, không phải bị lỗi.
   - Quá trình tải/cài có thể mất vài phút tuỳ số lượng bản cập nhật và tốc độ mạng — cứ để chạy tới khi thấy dấu nhắc lệnh quay lại (con trỏ nhấp nháy chờ lệnh mới).
   - Nếu có cập nhật kernel (nhân hệ điều hành), nên khởi động lại máy (**Menu > Restart** hoặc gõ `sudo reboot`) để áp dụng đầy đủ trước khi làm tiếp các bước sau.

3. **Tắt hiệu ứng đồ hoạ (compositing) để nhẹ máy.**
   - Máy này cấu hình yếu nên các hiệu ứng trong suốt/đổ bóng/chuyển động (visual effects) của cửa sổ nên tắt hết — không cần thiết cho việc dùng làm server, chỉ tốn thêm CPU/RAM.
   - Vào **Menu > Settings > Window Manager Tweaks** (nếu không thấy trực tiếp trong menu, vào **Menu > Settings > Settings Manager** rồi bấm icon **Window Manager Tweaks**).
   - Chuyển sang tab **Compositor**, **bỏ tick** ô **"Enable display compositing"**, rồi đóng cửa sổ lại (áp dụng ngay, không cần khởi động lại).
   - Lưu ý: đây là ứng dụng **"Window Manager Tweaks"**, khác với ứng dụng **"Window Manager"** (chỉ chỉnh theme/viền cửa sổ, không có tab Compositor).

4. **Tắt bớt ứng dụng khởi động cùng máy (startup apps) không cần thiết.**
   - Nhiều ứng dụng nền tự chạy ngay khi đăng nhập dù không dùng tới (applet in ấn, Bluetooth, đổi màu màn hình theo giờ...) — tắt bớt để giải phóng RAM ngay từ lúc khởi động.
   - Vào **Menu > Settings > Session and Startup**, chuyển sang tab **Application Autostart**.
   - Danh sách hiện các ứng dụng đang tự khởi động kèm checkbox — **bỏ tick** những cái không cần cho việc chạy server (ví dụ: applet máy in nếu không dùng máy in, applet Bluetooth nếu máy không dùng Bluetooth, các ứng dụng đổi giao diện/hiệu ứng).
   - **Không tắt** các mục liên quan tới mạng (Network Manager), âm thanh (nếu còn dùng loa/tai nghe trên máy này), hoặc bất kỳ mục nào không chắc chắn tác dụng — cứ để nguyên nếu không rõ, tắt nhầm có thể gây lỗi âm thầm khó nhận ra sau này. Cài mới thường danh sách này đã khá gọn, không cần tắt quá nhiều.

5. **Cài `htop` để theo dõi tài nguyên máy.**
   - Gõ lệnh:
     ```
     sudo apt install -y htop
     ```
   - Sau khi cài xong, gõ `htop` rồi Enter để mở — màn hình hiện các thanh biểu đồ CPU (từng nhân/core) ở trên, thanh RAM và Swap ngay dưới, và danh sách tiến trình (process) đang chạy phía dưới cùng. Đây là công cụ sẽ dùng lại nhiều lần sau này để kiểm tra máy có bị quá tải khi chạy các dịch vụ self-host không.
   - Bấm phím `q` để thoát `htop`, quay lại dấu nhắc lệnh terminal.

6. **Tìm hiểu sơ qua về swap và swappiness (cho máy ít RAM).**
   - Swap là một vùng trên ổ đĩa được dùng như "RAM ảo" khi RAM thật đầy — chậm hơn RAM thật nhiều lần (đặc biệt nếu ổ là HDD cũ) nhưng giúp máy không bị treo/crash khi thiếu RAM. Bộ cài Linux Mint thường đã tự tạo sẵn swap (dạng swap file) trong lúc cài.
   - `swappiness` là một con số từ 0–100 quyết định hệ điều hành "thích" dùng swap sớm hay muộn (càng cao càng dùng swap sớm dù RAM còn trống). Kiểm tra giá trị hiện tại bằng lệnh:
     ```
     cat /proc/sys/vm/swappiness
     ```
   - Mặc định trên Linux Mint/Ubuntu là `60`. Với máy có RAM khoảng 4GB trở lên, **cứ để nguyên giá trị mặc định là được**, không cần chỉnh. Chỉ cân nhắc giảm giá trị này (ví dụ xuống 10–20, sẽ hướng dẫn cách chỉnh ở file self-hosting sau nếu cần) khi máy có RAM dưới khoảng 4GB và thấy máy chậm bất thường do dùng swap quá sớm — quan sát qua thanh Swap trong `htop` lúc máy đang chạy nhiều dịch vụ.

## ✅ Kiểm tra đã thành công

- Chạy lại `sudo apt update` không báo gói nào cần nâng cấp thêm (hoặc rất ít, mới phát sinh).
- Vào lại **Window Manager Tweaks > Compositor**, thấy ô "Enable display compositing" đang **bỏ tick** — di chuyển/đóng mở cửa sổ không còn hiệu ứng mờ/trượt như trước.
- Vào lại **Session and Startup > Application Autostart**, thấy đúng những mục đã chủ động bỏ tick, máy khởi động lại thấy màn hình vào desktop nhanh hơn một chút.
- Gõ `htop` chạy được, thấy biểu đồ CPU/RAM/Swap cập nhật liên tục theo thời gian thực; bấm `q` thoát được về terminal bình thường.
- Gõ `cat /proc/sys/vm/swappiness` ra một con số hợp lệ (thường là `60`).

## ⚠️ Lỗi thường gặp

- `sudo apt upgrade` báo lỗi kiểu "Unable to fetch some archives" hoặc "failed to fetch": thường do mất mạng giữa chừng — kiểm tra lại kết nối Internet rồi chạy lại `sudo apt update && sudo apt upgrade -y` (apt tự tiếp tục, không cần lo tải lại từ đầu).
- Gõ mật khẩu sau `sudo` mà không thấy gì hiện ra kể cả dấu `*`: đây là hành vi bình thường của terminal Linux (ẩn hoàn toàn input khi nhập mật khẩu) — cứ gõ đúng mật khẩu rồi Enter, không phải máy bị treo.
- Gõ sai mật khẩu vài lần liên tiếp, terminal báo "Sorry, try again" hoặc tạm khoá thử lại: đợi vài giây rồi gõ lại cho đúng, chú ý bàn phím có đang gõ nhầm ký tự hoa/thường hay bật Caps Lock không.
- Tắt nhầm một startup app hoá ra cần thiết (ví dụ mất tiếng, không đổi được layout bàn phím): quay lại **Session and Startup > Application Autostart**, tick lại đúng mục đó, đăng xuất/đăng nhập lại (hoặc khởi động lại máy) để có hiệu lực.
- Không thấy mục **Window Manager Tweaks** hay **Session and Startup** trực tiếp trong Menu: mở **Menu > Settings > Settings Manager** (biểu tượng bánh răng, gom toàn bộ các mục settings vào một cửa sổ), từ đó bấm vào đúng icon tương ứng.
