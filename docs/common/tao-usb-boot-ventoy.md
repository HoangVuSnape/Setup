# Tạo USB Multiboot bằng Ventoy — chứa cả Windows, Linux Mint và dữ liệu

## Mục tiêu

Sau bước này, bạn có một chiếc USB hoặc thẻ nhớ (đặc biệt phù hợp với dung lượng lớn từ 16GB, 32GB đến 128GB) đa năng:
- Vừa boot cài được **Windows 11**, vừa boot cài được **Linux Mint XFCE** (và bất kỳ file ISO nào khác sau này).
- Không cần format hay ghi đè lại USB mỗi khi muốn đổi hệ điều hành cài đặt — chỉ cần **Copy & Paste file ISO** như chép phim, nhạc.
- Phân vùng trống còn lại vẫn dùng để lưu trữ tài liệu, code, dữ liệu học tập cá nhân bình thường.

---

## Các bước

### 1. Tải công cụ Ventoy cho Windows
- Vào trang tải chính thức: `https://www.ventoy.net/en/download.html` (hoặc kho GitHub: `https://github.com/ventoy/Ventoy/releases`).
- Tải gói dành cho Windows có đuôi `.zip` (ví dụ: `ventoy-1.0.xx-windows.zip`, dung lượng khoảng 15–20MB).
- Giải nén file `.zip` vừa tải ra một thư mục trên máy tính.

### 2. Cài đặt Ventoy vào USB / thẻ nhớ
> [!CAUTION]
> **Bước này sẽ format và xoá toàn bộ dữ liệu đang có trên USB/thẻ nhớ 1 lần duy nhất.** Hãy sao lưu tài liệu quan trọng trên USB sang máy tính trước khi bấm cài đặt!

- Cắm USB hoặc thẻ nhớ (ví dụ thẻ 128GB) vào máy tính.
- Vào thư mục Ventoy vừa giải nén, nhấp chuột phải vào file **`Ventoy2Disk.exe`** → chọn **Run as administrator**.
- Trong giao diện Ventoy2Disk:
  - Mục **Device**: Bấm vào menu thả xuống và chọn đúng USB/thẻ nhớ của bạn (nhìn kỹ ký tự ổ đĩa và dung lượng, ví dụ `115 GB / 128 GB`, tránh chọn nhầm ổ cứng ngoài khác).
  - Kiểm tra thiết lập phân vùng (Menu **Option > Partition Style**):
    - Khuyên dùng: Để mặc định là **MBR**. Bản bootloader MBR của Ventoy tương thích rất tốt với cả các dòng máy đời cũ chạy BIOS/Legacy lẫn máy đời mới chạy UEFI.
    - (Chỉ chọn **GPT** nếu máy tính của bạn rất mới và bạn biết chắc chắn máy không bao giờ cần boot chế độ Legacy BIOS cũ).
  - Bấm nút **Install**.
  - Chương trình sẽ hiện hộp thoại cảnh báo xoá dữ liệu 2 lần liên tiếp để chắc chắn bạn không chọn nhầm ổ → Bấm **OK** cả 2 lần.
  - Chờ khoảng 10–30 giây cho quá trình format hoàn tất, hiện thông báo thành công: *"Congratulations! Ventoy has been successfully installed to the device."*

### 3. Copy các file ISO hệ điều hành vào USB
Sau khi cài Ventoy xong, trong File Explorer bạn sẽ thấy USB/thẻ nhớ được đổi tên thành **Ventoy** với dung lượng gần như toàn bộ thẻ (định dạng `exFAT`).

Bây giờ bạn chỉ cần copy trực tiếp các file `.iso` đã tải thả vào ổ `Ventoy`:
- File **Linux Mint XFCE**: `linuxmint-22.3-xfce-64bit.iso` (khoảng ~2.8GB).
- File **Windows 11**: `Win11_xx_English_x64.iso` (nếu có tải từ trang chủ Microsoft, khoảng ~5–6GB).
- *(Tùy chọn)* Bạn có thể tạo thêm một thư mục tên `ISO` hoặc để thẳng ở thư mục gốc của USB đều được — Ventoy tự động quét mọi thư mục để tìm file `.iso`.
- *(Tùy chọn)* Bạn có thể tạo thêm các thư mục khác như `Tai_Lieu`, `Phan_Mem` trên cùng USB đó để lưu trữ dữ liệu cá nhân bình thường.

### 4. Boot máy từ USB Ventoy
- Cắm USB vào máy cần cài đặt (máy cũ muốn cài Linux Mint hoặc máy muốn cài Windows).
- Khởi động lại máy và bấm phím gọi **Boot Menu** liên tục (F12, F11, F2, Del, hoặc Esc tùy hãng máy — xem chi tiết tại [docs/linux/01-usb-install.md](../linux/01-usb-install.md)).
- Chọn boot từ USB (thường hiện tên USB hoặc `UEFI: Ventoy...`).
- Màn hình đồ hoạ của Ventoy sẽ xuất hiện với danh sách các file ISO bạn đã chép vào USB:
  - Muốn cài Linux Mint: Dùng phím mũi tên chọn `linuxmint-22.3-xfce-64bit.iso` → bấm **Enter** → chọn **Boot in normal mode** để vào thẳng live desktop Linux Mint và tiến hành cài đặt.
  - Muốn cài Windows 11: Chọn file ISO Windows → bấm **Enter** để vào trình cài đặt Windows bình thường.

---

## ✅ Kiểm tra đã thành công

- Mở File Explorer trên Windows, ổ USB mang tên `Ventoy`, chứa file `linuxmint-22.3-xfce-64bit.iso` (và file ISO Win11 nếu có).
- Cắm vào máy tính và boot thử: Máy hiện lên menu Ventoy liệt kê đầy đủ tên các file ISO, chọn vào và khởi động được vào bộ cài hệ điều hành mà không bị báo lỗi thiếu file.
- Khi cắm vào máy tính, phân vùng trống còn lại vẫn sao chép, đọc ghi file tài liệu bình thường.

---

## ⚠️ Lỗi thường gặp & Mẹo sử dụng

- **Máy báo lỗi Secure Boot ("Verification failed" / "Security Boot Violation"):**
  - *Cách 1 (Nhanh nhất):* Vào BIOS/UEFI của máy tính, tìm mục **Secure Boot** và chuyển sang **Disabled (Tắt)**, sau đó lưu lại (F10) và khởi động lại.
  - *Cách 2 (Giữ Secure Boot):* Ventoy có hỗ trợ Secure Boot. Khi gặp màn hình xanh **Perform MOK management**, bấm Enter → chọn **Enroll key from disk** → chọn phân vùng `VTOYBOOT` → chọn file `ENROLL_THIS_KEY_IN_MOKMANAGER.cer` → chọn **Continue** → **Yes** → **Reboot**.
- **Sau này muốn nâng cấp phiên bản mới của Ventoy có bị mất file ISO không?**
  - **Không mất:** Cắm USB vào máy tính Windows, mở lại `Ventoy2Disk.exe`, bấm nút **Update** (thay vì nút *Install*). Ventoy sẽ chỉ cập nhật bootloader mà giữ nguyên 100% file ISO và dữ liệu của bạn trên USB.
- **Tên file ISO không nhận hoặc báo lỗi khi boot:**
  - Không đặt tên file ISO có dấu tiếng Việt, ký tự lạ (`#`, `%`, `&`) hoặc quá nhiều dấu cách. Nên đặt tên ngắn gọn, ví dụ: `linuxmint-22.3-xfce-64bit.iso`, `Windows11.iso`.
- **Boot vào Linux Mint bị màn hình đen hoặc đơ:**
  - Trong menu chọn ISO của Ventoy, sau khi chọn file ISO Linux Mint, thay vì chọn *Boot in normal mode*, thử chọn **Boot in grub2 mode**.
