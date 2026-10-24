# Kiểm tra phần cứng, tải ISO và cài Linux Mint XFCE từ USB

## Mục tiêu

Sau bước này, bạn đã lưu lại model laptop và mã chipset Wi-Fi để tra cứu driver khi cần. Máy cũ có một bản Linux Mint XFCE Edition (phiên bản 22.3 "Zena") cài mới hoàn toàn, xoá sạch Windows 10 cũ, đã đăng nhập được vào desktop — sẵn sàng cho các bước tối ưu và cài server ở các file tiếp theo. Máy này cấu hình yếu nên chọn bản XFCE (nhẹ hơn Cinnamon/MATE) thay vì bản mặc định.

## Các bước

1. **Ghi lại model laptop và thông tin Wi-Fi trước khi xoá Windows.**
   - Trên Windows, mở **Settings → System → About**. Ghi lại các dòng **Model** (hoặc **System model**) và **Manufacturer**.
   - Cách xem chi tiết hơn: bấm `Win + R`, nhập `msinfo32`, rồi xem **System Manufacturer** và **System Model**. Có thể bấm **File → Export** để lưu toàn bộ thông tin thành file `.txt`.
   - Để biết chính xác chipset Wi-Fi, bấm chuột phải vào **Start → Device Manager → Network adapters**. Ghi tên adapter có chữ `Wi-Fi`, `Wireless`, `WLAN` hoặc `802.11` (ví dụ `Intel Wireless-AC 8265`, `Realtek RTL8821CE`, `Qualcomm Atheros...`). Không dùng tên `WAN Miniport` — đó không phải card Wi-Fi thật.
   - Nếu tên adapter không rõ hoặc đang thiếu driver, trong **Device Manager** bấm chuột phải vào thiết bị đó → **Properties → Details → Hardware Ids**. Ghi dòng đầu tiên có dạng `PCI\VEN_....&DEV_....` (card gắn trong) hoặc `USB\VID_....&PID_....` (USB Wi-Fi). Đây là mã chính xác để tìm driver.
   - Có thể lưu nhanh thông tin bằng PowerShell (mở **PowerShell**, không cần quyền Administrator):
     ```powershell
     Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model
     Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress
     ```
   - Chụp ảnh hoặc lưu các thông tin này vào điện thoại/cloud **trước khi cài**. Khi tìm driver, tìm theo mẫu `tên model laptop + Linux Mint Wi-Fi` hoặc `tên chipset + Ubuntu 24.04`, ưu tiên trang hỗ trợ của hãng laptop và tài liệu Ubuntu/Linux Mint.

2. **Tải ISO Linux Mint — chọn đúng bản XFCE Edition.**
   - Vào trang tải chính thức: `https://linuxmint.com/download.php`.
   - Trang này liệt kê 3 bản (edition) khác nhau: **Cinnamon**, **MATE**, và **Xfce**. **Bắt buộc chọn Xfce** (ghi chú "Light, simple, efficient") — đây là bản desktop nhẹ nhất trong 3 bản, phù hợp máy cấu hình yếu. Không chọn Cinnamon (bản mặc định, nặng nhất) hay MATE.
   - Phiên bản hiện tại (kiểm tra 9/2026): **Linux Mint 22.3 "Zena"**, dựa trên Ubuntu 24.04 LTS, được hỗ trợ tới 2029. File ISO tên `linuxmint-22.3-xfce-64bit.iso`, dung lượng khoảng 2.8GB.
   - Bấm vào mục Xfce Edition, trang sẽ hiện danh sách mirror (máy chủ tải) theo khu vực — chọn 1 mirror gần Việt Nam (ví dụ khu vực Asia) để tải nhanh hơn.
   - (Tuỳ chọn, nên làm) Kiểm tra file ISO tải về không bị lỗi/giả mạo bằng SHA256 checksum: trang download có link tới file `sha256sum.txt` — so khớp mã checksum của file vừa tải với mã trong file này.

3. **Chuẩn bị USB và tạo USB boot (chọn 1 trong 2 cách bên dưới).**
   - Chuẩn bị 1 USB dung lượng tối thiểu 4GB (ISO nặng ~2.8GB), nhưng nên dùng USB 16GB trở lên chuẩn USB 3.0 để dùng chung được cho cả việc cài Windows sau này — xem hướng dẫn chọn USB đầy đủ tại [docs/common/chon-usb-boot.md](../common/chon-usb-boot.md).

   - **Cách 1: Dùng Ventoy (Khuyên dùng — đặc biệt khi có USB/thẻ nhớ dung lượng lớn 16GB–128GB).**
     - Ventoy cho phép chứa **cả bộ cài Windows 11 lẫn Linux Mint** và lưu trữ dữ liệu cá nhân trên cùng 1 chiếc USB mà không lo bị chia nhỏ phân vùng hay lãng phí dung lượng.
     - Bạn chỉ cần format USB bằng Ventoy 1 lần, sau đó **copy & paste** file `linuxmint-22.3-xfce-64bit.iso` thẳng vào USB là xong.
     - 👉 **Xem hướng dẫn từng bước chi tiết tại: [docs/common/tao-usb-boot-ventoy.md](../common/tao-usb-boot-ventoy.md).**

   - **Cách 2: Dùng Rufus (Cách truyền thống — ghi đè toàn bộ USB để chứa riêng Linux Mint).**
     - *Lưu ý: Cách này sẽ xoá sạch 100% dữ liệu trên USB để nạp riêng bộ cài Linux Mint.*
     - Tải Rufus (bản portable, không cần cài) tại trang chính thức: `https://rufus.ie`.
     - Chạy file `.exe` vừa tải (bấm **Yes** nếu Windows hỏi UAC). Trong cửa sổ Rufus:
     - Mục **Device**: chọn đúng USB vừa cắm vào (kiểm tra kỹ dung lượng hiển thị để chắc chắn không chọn nhầm ổ đĩa khác).
     - Mục **Boot selection**: bấm **SELECT**, trỏ tới file `linuxmint-22.3-xfce-64bit.iso` vừa tải.
     - Mục **Partition scheme**: để mặc định **MBR** (tương thích cả BIOS cũ lẫn UEFI) trừ khi biết chắc máy chỉ hỗ trợ UEFI thuần.
     - Nếu Rufus hiện hộp thoại hỏi cách ghi ISO (ISOHybrid), chọn **"Write in ISO Image mode (Recommended)"** — chỉ đổi sang **"Write in DD Image mode"** nếu USB tạo xong không boot được (thử lại từ đầu).
     - Bấm **START**. Rufus sẽ cảnh báo toàn bộ dữ liệu trên USB sẽ bị xoá — bấm **OK** để tiếp tục. Quá trình ghi mất khoảng 5–15 phút tuỳ tốc độ USB.

4. **Boot máy cũ từ USB (vào Boot Menu qua BIOS/UEFI).**
   - Cắm USB vào máy cũ, khởi động lại máy.
   - Trong lúc máy vừa bật (trước khi vào Windows), bấm liên tục phím vào **Boot Menu**. Phím này **tuỳ hãng máy/mainboard**, phổ biến nhất là `F12`, `F2`, `Del`, hoặc `Esc` — nếu không chắc phím nào đúng, tra cứu theo đúng hãng và model máy (ví dụ tìm "boot menu key + tên hãng + model máy").
   - Trong Boot Menu, chọn đúng tên USB vừa cắm (thường hiện tên hãng USB, ví dụ "Kingston DataTraveler...", hoặc "UEFI: Ventoy...") để boot từ đó.
   - *(Nếu dùng USB tạo bằng Ventoy)*: Menu Ventoy xuất hiện, dùng phím mũi tên chọn dòng `linuxmint-22.3-xfce-64bit.iso` → bấm **Enter** → chọn **Boot in normal mode**.
   - Nếu không thấy USB trong danh sách boot hoặc máy tự động vào thẳng Windows: vào BIOS/UEFI Setup (cũng bằng 1 trong các phím trên, tuỳ máy), kiểm tra mục **Boot Order** để USB được ưu tiên, và thử tắt **Secure Boot** nếu máy vẫn không boot được từ USB.

5. **Cài đặt Linux Mint (installer).**
   - Trước khi cài thật, hãy chọn **Start Linux Mint** để vào **live session**. Bấm biểu tượng mạng ở góc phải màn hình và kiểm tra xem Wi-Fi có hiện mạng hay không. Live session cho phép thử phần cứng mà chưa xoá Windows.
   - Nếu không có Wi-Fi, cắm dây mạng Ethernet hoặc chuẩn bị điện thoại có thể **USB tethering**. Có Internet tạm thời sẽ giúp cài driver bằng **Driver Manager** sau khi cài xong.
   - Sau khi kiểm tra xong, trong **live session** (chạy thử Mint trực tiếp từ USB, chưa cài gì vào ổ cứng), bấm đúp icon **"Install Linux Mint"** để bắt đầu cài.
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
- Trước khi cài, đã lưu được **hãng + model laptop** và **tên chipset hoặc Hardware ID của Wi-Fi** ở nơi khác ngoài ổ đĩa laptop.
- Trong live session hoặc sau khi cài, biểu tượng mạng hiển thị được các mạng Wi-Fi gần đó. Nếu chưa có, vẫn có cách dùng Ethernet/USB tethering để cài driver.

## ⚠️ Lỗi thường gặp

- Máy không boot được từ USB dù đã vào đúng Boot Menu: kiểm tra lại USB đã tạo đúng cách chưa (thử tạo lại bằng Rufus, đổi sang **"Write in DD Image mode"** thay vì ISO Image mode), và kiểm tra BIOS/UEFI đã tắt **Secure Boot** hoặc bật **Legacy Boot/CSM** nếu máy quá cũ.
- Vào được live session nhưng không có Wi-Fi (máy cũ dùng card Wi-Fi đời cũ, driver không có sẵn trong live session): cắm dây mạng (Ethernet) trực tiếp vào máy để cài đặt trước, xử lý driver Wi-Fi sau khi cài xong (xem file `02-first-boot-optimize.md`).
- **Device Manager chỉ hiện `Network Controller` hoặc thiết bị có dấu chấm than:** mở **Properties → Details → Hardware Ids**, lấy mã `PCI\VEN...`/`USB\VID...` thay vì đoán theo model laptop. Nếu đã xoá Windows mà chưa kịp ghi mã, có thể vào live session và mở Terminal chạy `lspci -nnk | grep -iA3 -E 'network|wireless'` hoặc `lsusb` nếu là Wi-Fi USB.
- Ở bước "Installation type" không thấy "Erase disk and install Linux Mint" mà chỉ thấy "Something else": thường do máy có nhiều ổ đĩa hoặc phân vùng lạ khiến installer không tự tin xoá — kiểm tra kỹ đang thao tác đúng ổ đĩa cần cài trước khi tiếp tục.
- Installer báo lỗi hoặc đứng im rất lâu ở bước copy file: nếu máy dùng ổ HDD cũ (không phải SSD), quá trình này chậm hơn bình thường nhiều — chờ thêm trước khi kết luận bị treo; chỉ tắt cứng máy nếu đứng yên quá 30–40 phút không nhúc nhích.
