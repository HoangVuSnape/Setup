# Tải ISO và cài Linux Mint XFCE từ USB

## Mục tiêu

Sau bước này, máy cũ có một bản Linux Mint XFCE Edition (phiên bản 22.3 "Zena") cài mới hoàn toàn, xoá sạch Windows 10 cũ, đã đăng nhập được vào desktop — sẵn sàng cho các bước tối ưu và cài server ở các file tiếp theo. Máy này cấu hình yếu nên chọn bản XFCE (nhẹ hơn Cinnamon/MATE) thay vì bản mặc định.

## Các bước

1. **Tải ISO Linux Mint — chọn đúng bản XFCE Edition.**
   - Vào trang tải chính thức: `https://linuxmint.com/download.php`.
   - Trang này liệt kê 3 bản (edition) khác nhau: **Cinnamon**, **MATE**, và **Xfce**. **Bắt buộc chọn Xfce** (ghi chú "Light, simple, efficient") — đây là bản desktop nhẹ nhất trong 3 bản, phù hợp máy cấu hình yếu. Không chọn Cinnamon (bản mặc định, nặng nhất) hay MATE.
   - Phiên bản hiện tại (kiểm tra 9/2026): **Linux Mint 22.3 "Zena"**, dựa trên Ubuntu 24.04 LTS, được hỗ trợ tới 2029. File ISO tên `linuxmint-22.3-xfce-64bit.iso`, dung lượng khoảng 2.8GB.
   - Bấm vào mục Xfce Edition, trang sẽ hiện danh sách mirror (máy chủ tải) theo khu vực — chọn 1 mirror gần Việt Nam (ví dụ khu vực Asia) để tải nhanh hơn.
   - (Tuỳ chọn, nên làm) Kiểm tra file ISO tải về không bị lỗi/giả mạo bằng SHA256 checksum: trang download có link tới file `sha256sum.txt` — so khớp mã checksum của file vừa tải với mã trong file này.

2. **Chuẩn bị USB rỗng và tạo USB boot bằng Rufus (làm trên máy Windows).**
   - Chuẩn bị 1 USB dung lượng tối thiểu 4GB (ISO nặng ~2.8GB), nhưng nên dùng USB 16GB trở lên chuẩn USB 3.0 để dùng chung được cho cả việc cài Windows sau này — xem hướng dẫn chọn USB đầy đủ tại [docs/common/chon-usb-boot.md](../common/chon-usb-boot.md). Toàn bộ dữ liệu trên USB sẽ bị xoá sạch khi tạo bộ cài.
   - Tải Rufus (bản portable, không cần cài) tại trang chính thức: `https://rufus.ie`.
   - Chạy file `.exe` vừa tải (bấm **Yes** nếu Windows hỏi UAC). Trong cửa sổ Rufus:
     - Mục **Device**: chọn đúng USB vừa cắm vào (kiểm tra kỹ dung lượng hiển thị để chắc chắn không chọn nhầm ổ đĩa khác).
     - Mục **Boot selection**: bấm **SELECT**, trỏ tới file `linuxmint-22.3-xfce-64bit.iso` vừa tải.
     - Mục **Partition scheme**: để mặc định **MBR** (tương thích cả BIOS cũ lẫn UEFI) trừ khi biết chắc máy chỉ hỗ trợ UEFI thuần.
     - Nếu Rufus hiện hộp thoại hỏi cách ghi ISO (ISOHybrid), chọn **"Write in ISO Image mode (Recommended)"** — chỉ đổi sang **"Write in DD Image mode"** nếu USB tạo xong không boot được (thử lại từ đầu).
   - Bấm **START**. Rufus sẽ cảnh báo toàn bộ dữ liệu trên USB sẽ bị xoá — bấm **OK** để tiếp tục. Quá trình ghi mất khoảng 5–15 phút tuỳ tốc độ USB.

3. **Boot máy cũ từ USB (vào Boot Menu qua BIOS/UEFI).**
   - Cắm USB vào máy cũ, khởi động lại máy.
   - Trong lúc máy vừa bật (trước khi vào Windows), bấm liên tục phím vào **Boot Menu**. Phím này **tuỳ hãng máy/mainboard**, phổ biến nhất là `F12`, `F2`, `Del`, hoặc `Esc` — nếu không chắc phím nào đúng, tra cứu theo đúng hãng và model máy (ví dụ tìm "boot menu key + tên hãng + model máy").
   - Trong Boot Menu, chọn đúng tên USB vừa cắm (thường hiện tên hãng USB, ví dụ "Kingston DataTraveler...") để boot từ đó.
   - Nếu không thấy USB trong danh sách boot hoặc máy tự động vào thẳng Windows: vào BIOS/UEFI Setup (cũng bằng 1 trong các phím trên, tuỳ máy), kiểm tra mục **Boot Order** để USB được ưu tiên, và thử tắt **Secure Boot** nếu máy vẫn không boot được từ USB.

4. **Cài đặt Linux Mint (installer).**
   - Máy sẽ vào **live session** (chạy thử Mint trực tiếp từ USB, chưa cài gì vào ổ cứng). Trên desktop, bấm đúp icon **"Install Linux Mint"** để bắt đầu cài.
   - **Chọn ngôn ngữ** (có thể chọn Vietnamese hoặc English tuỳ thích) → **Continue**.
   - **Chọn bố cục bàn phím** (keyboard layout) — mặc định thường đã đúng (English US), bấm **Continue**.
   - Màn hình **"Multimedia codecs"**: tick chọn **"Install multimedia codecs"** để phát được nhạc/video định dạng phổ biến sau này, rồi **Continue**.
   - Màn hình **"Installation type"** — đây là bước quan trọng nhất: chọn **"Erase disk and install Linux Mint"**.
     - Giải thích đơn giản: đây là máy cũ đang được tái sử dụng làm server riêng, không cần giữ lại Windows 10 hay dữ liệu cũ trên máy — nên chọn xoá sạch toàn bộ ổ đĩa và cài Mint chiếm hết ổ, không dual-boot, không cần chọn "Something else" (chỉ dùng cho cài nâng cao/dual-boot).
     - Nếu máy có sẵn dữ liệu quan trọng, sao lưu (backup) ra USB/ổ ngoài khác **trước khi** làm bước này — vì "Erase disk" sẽ xoá vĩnh viễn mọi thứ trên ổ đĩa được chọn.
   - Bấm **Install Now** → xác nhận hộp thoại cảnh báo ghi đè ổ đĩa → bấm **Continue**.
   - Chọn **múi giờ** (timezone) trên bản đồ — chọn Ho Chi Minh/Hanoi (Asia/Ho_Chi_Minh) → **Continue**.
   - Màn hình tạo tài khoản người dùng: nhập **tên** (your name), **tên máy** (computer's name), **tên đăng nhập** (username), và **mật khẩu** (password) — đây sẽ là tài khoản dùng để đăng nhập và SSH vào máy sau này (xem file `03-remote-access.md`), nên chọn mật khẩu vừa đủ mạnh vừa nhớ được, không cần tick "Log in automatically" vì máy này chạy làm server để "treo" lâu dài.
   - Installer sẽ copy file và cài đặt (progress bar chạy khoảng 10–20 phút tuỳ tốc độ máy/ổ đĩa cũ, có thể lâu hơn nếu ổ là HDD đời cũ) — cứ để máy chạy, không tắt giữa chừng.
   - Khi hiện **"Installation Complete"**, bấm **Restart Now**.
   - Máy sẽ hiện dòng chữ nhắc **"Please remove the installation medium, then press ENTER"** — lúc này rút USB ra khỏi máy rồi bấm Enter để máy khởi động vào Mint vừa cài.

## ✅ Kiểm tra đã thành công

- Máy khởi động thẳng vào màn hình đăng nhập (login screen) của Linux Mint, không còn boot vào USB hay Windows cũ nữa.
- Đăng nhập được bằng username/password vừa tạo, thấy desktop XFCE hiện ra bình thường (taskbar, menu Start ở góc dưới trái).
- Mở Menu → gõ "About" hoặc vào **Menu > System Tools > System Info**, thấy đúng thông tin **Linux Mint 22.3** bản **Xfce**.

## ⚠️ Lỗi thường gặp

- Máy không boot được từ USB dù đã vào đúng Boot Menu: kiểm tra lại USB đã tạo đúng cách chưa (thử tạo lại bằng Rufus, đổi sang **"Write in DD Image mode"** thay vì ISO Image mode), và kiểm tra BIOS/UEFI đã tắt **Secure Boot** hoặc bật **Legacy Boot/CSM** nếu máy quá cũ.
- Vào được live session nhưng không có Wi-Fi (máy cũ dùng card Wi-Fi đời cũ, driver không có sẵn trong live session): cắm dây mạng (Ethernet) trực tiếp vào máy để cài đặt trước, xử lý driver Wi-Fi sau khi cài xong (xem file `02-first-boot-optimize.md`).
- Ở bước "Installation type" không thấy "Erase disk and install Linux Mint" mà chỉ thấy "Something else": thường do máy có nhiều ổ đĩa hoặc phân vùng lạ khiến installer không tự tin xoá — kiểm tra kỹ đang thao tác đúng ổ đĩa cần cài trước khi tiếp tục.
- Installer báo lỗi hoặc đứng im rất lâu ở bước copy file: nếu máy dùng ổ HDD cũ (không phải SSD), quá trình này chậm hơn bình thường nhiều — chờ thêm trước khi kết luận bị treo; chỉ tắt cứng máy nếu đứng yên quá 30–40 phút không nhúc nhích.
