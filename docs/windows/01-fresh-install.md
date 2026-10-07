# Cài Windows 11 mới / cài lại từ đầu

## Mục tiêu

Sau bước này, máy có một bản Windows 11 sạch, an toàn về dữ liệu cũ, đã sao lưu BitLocker Recovery Key và driver mạng, đã cập nhật đầy đủ Windows Update, có driver GPU đúng, đã kích hoạt bản quyền — sẵn sàng để cài các công cụ dev ở các bước tiếp theo.

## Các bước chuẩn bị quan trọng (BẮT BUỘC TRƯỚC KHI CÀI)

### 0. Sao lưu dữ liệu, BitLocker Recovery Key và Driver mạng

> [!CAUTION]
> **Đừng vội cài đặt khi chưa hoàn thành bước này!** Nếu ổ cứng đang bật BitLocker hoặc cài xong máy không nhận Wi-Fi, bạn có thể bị mất trắng dữ liệu hoặc không vào được mạng.

1. **Kiểm tra và lưu BitLocker Recovery Key:**
   - Mở PowerShell (Admin) chạy:
     ```powershell
     manage-bde -status
     ```
   - Nếu ở dòng **Protection Status** ghi `Protection On`: ổ đĩa đang được mã hóa BitLocker. Bạn **bắt buộc** phải lưu Recovery Key 48 chữ số.
     - Truy cập vào trang quản lý của Microsoft: [account.microsoft.com/devices/recoverykey](https://account.microsoft.com/devices/recoverykey) và đăng nhập tài khoản Microsoft của máy để xem và lưu lại key (chụp ảnh bằng điện thoại hoặc ghi ra giấy).
     - Hoặc xuất key ra file trên ổ USB ngoài:
       ```powershell
       (Get-BitLockerVolume -MountPoint C:).KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' } | Select-Object -ExpandProperty RecoveryPassword
       ```
   - Nếu ở dòng **Protection Status** ghi `Protection Off`: **Ổ đĩa không bị mã hóa BitLocker**. Bạn hoàn toàn yên tâm **bỏ qua bước này** và chuyển thẳng sang bước chuẩn bị driver bên dưới.

2. **Tải sẵn Driver Wi-Fi / LAN và GPU ra USB:**
   - Nhiều bản cài Windows 11 mới thiếu driver mạng cho các dòng card Wi-Fi mới (Intel Wi-Fi 6E/7, Realtek, MediaTek). Sau khi cài xong nếu không có mạng thì không tải được driver khác hay Windows Update.
   - Lên trang hỗ trợ của hãng máy (Dell, Lenovo, Asus, HP, Acer...) hoặc mainboard, tìm đúng model máy và tải file cài đặt **Wi-Fi Driver** + **LAN Driver**, lưu sẵn vào một USB.
   - *Mẹo cứu nguy:* Chuẩn bị sẵn cáp kết nối điện thoại với laptop và bật chế độ **USB Tethering (Chia sẻ kết nối qua USB)** trên điện thoại Android/iPhone trong trường hợp máy tính chưa nhận Wi-Fi.

3. **Kiểm tra trạng thái bản quyền Windows (License):**
   - Không phải máy nào cũng gắn key vĩnh viễn trong chip firmware (BIOS). Bản quyền Windows có thể là: OEM key trong firmware, Digital License liên kết phần cứng, hoặc License liên kết tài khoản Microsoft.
   - Kiểm tra xem máy có OEM Key trong firmware không bằng PowerShell:
     ```powershell
     (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey
     ```
   - Nếu trả về key: Máy có key phần cứng, cài lại đúng edition (Home/Pro) sẽ tự nhận.
   - Nếu **không trả về key**: Điều đó **không đồng nghĩa với việc mất bản quyền**, máy có thể đang dùng Digital License liên kết với tài khoản Microsoft (MSA). Hãy đảm bảo bạn nhớ tài khoản Microsoft đang dùng trên máy để sau khi cài xong đăng nhập lại là tự kích hoạt.

---

## Các bước cài đặt

1. **Xác định phương án phù hợp — có 3 trường hợp:**
   - **Trường hợp A:** Máy đang dùng ổn định, chỉ rà lại checklist để cài môi trường dev AI → **Bỏ qua bước 2, 3, 4**, chuyển thẳng tới bước 5 (Windows Update).
   - **Trường hợp B:** Máy đang chạy Windows 11 nhưng muốn làm mới hoàn toàn, máy chạy chậm/rác → dùng **Reset this PC** ở bước 2 (không cần USB).
   - **Trường hợp C:** Máy trống hoàn toàn (máy mới, thay SSD mới) hoặc muốn cài sạch 100% bằng USB → làm bước 3 và 4.

2. **(Phương án Reset this PC) Khôi phục máy sạch không cần USB.**
   - Vào **Settings > System > Recovery** (hoặc `Win + R`, gõ `ms-settings:recovery`).
   - Ở mục **Reset this PC**, bấm **Reset PC**.
   - Chọn **Remove everything** (xóa app và file rác cũ).
   - Chọn **Cloud download** (tải bản mới sạch trực tiếp từ Microsoft, cần tải ~4GB) thay vì *Local reinstall*.
   - Ở **Additional settings**: giữ mặc định (không cần chọn Full Clean Drive trừ khi bán máy).
   - Nếu máy hỏi có muốn cài lại phần mềm kèm theo của hãng sản xuất không: **Chọn không cài lại** để hệ điều hành sạch nhất.
   - Bấm **Reset**, cắm sạc cho máy tự khởi động lại và tiến hành cài đặt (thường mất 20–40 phút).

   #### 👉 Từng bước thao tác khi máy khởi động lại vào màn hình thiết lập ban đầu (OOBE):
   Sau khi máy chạy 100% và khởi động lại, bạn sẽ thấy màn hình xanh với các câu hỏi thiết lập:
   1. **Country or region:** Chọn *United States* hoặc *Vietnam* > Bấm **Yes**.
   2. **Keyboard layout:** Chọn *US* > Bấm **Yes**. Màn hình hỏi thêm layout thứ hai: Bấm **Skip**.
   3. **Connect to a network:** Chọn mạng Wi-Fi nhà bạn và nhập mật khẩu để kết nối Internet. *(Nếu chưa nhận card Wi-Fi: cắm USB có driver mạng ở Bước 0 vào hoặc cắm cáp sạc điện thoại bật USB Tethering).*
   4. **Name your PC:** Đặt tên cho máy tính không dấu (ví dụ: `hoang-laptop`) > Bấm **Next**. Máy sẽ tự khởi động lại một lần.
   5. **Sign in with Microsoft:** Nhập tài khoản Microsoft đã dùng trước đây (để tự kích hoạt lại bản quyền Windows).
   6. **Restore or Set up as new:** Chọn **"Set up as a new PC"** (để máy sạch hoàn toàn, không đồng bộ lại app rác từ máy cũ) > Bấm **Next**.
   7. **Create a PIN:** Đặt mã PIN bảo mật 4–6 số để mở khóa máy.
   8. **Privacy settings:** Gạt tắt các mục không cần thiết (Location, Diagnostic data tùy chọn, Personalized ads) > Bấm **Accept**.
   9. **Các màn hình quảng cáo (Game Pass, Microsoft 365, OneDrive backup):** Chọn **"No thanks"** / **"Skip for now"** / **"Decline"**.
   10. Chờ 1–2 phút cho màn hình chào đón *"Hi, Getting things ready for you..."* chạy xong là bạn sẽ vào thẳng **Màn hình Desktop mới**.

   #### 👉 Vừa vào màn hình Desktop mới thì làm gì tiếp theo? (Thứ tự chuẩn):
   - **Việc 1:** Vào ngay **Settings (`Win + I`) > Windows Update**, bấm **Check for updates** cho máy cập nhật hết các bản vá và restart máy (làm theo Bước 5 bên dưới).
   - **Việc 2:** Cài đặt **Driver GPU NVIDIA** mới nhất (làm theo Bước 6 bên dưới).
   - **Việc 3 (Bắt đầu cài bộ công cụ Dev):** Bạn có 2 lựa chọn:
     - *Cách nhanh (Khuyên dùng):* Mở PowerShell dán đúng 1 dòng lệnh cài tự động toàn bộ app:
       ```powershell
       irm https://raw.githubusercontent.com/HoangVuSnape/Setup/master/install/windows-setup.ps1 | iex
       ```
     - *Cách thủ công:* Mở trình duyệt Edge, vào GitHub `https://github.com/HoangVuSnape/Setup` và làm tiếp lần lượt theo file [02-essentials.md](02-essentials.md), [03-dev-tools.md](03-dev-tools.md), v.v.


3. **(Phương án USB) Tạo USB cài đặt bằng Media Creation Tool.**
   - Chuẩn bị một USB rỗng dung lượng tối thiểu 8GB (xem hướng dẫn tại [docs/common/chon-usb-boot.md](../common/chon-usb-boot.md)). Mọi dữ liệu trên USB này sẽ bị format sạch.
   - Tải Media Creation Tool chính thức tại: [microsoft.com/software-download/windows11](https://www.microsoft.com/software-download/windows11).
   - Chạy tool, chọn **"Create installation media for another PC"**, chọn USB và để tool tự tải và tạo USB boot.
   - **Cách kiểm tra máy có hỗ trợ UEFI, TPM 2.0, Secure Boot:**
     - Nếu máy đang chạy sẵn Windows 11 thì 100% phần cứng đã hỗ trợ và đang bật đầy đủ.
     - Muốn kiểm tra lại chắc chắn: Mở PowerShell chạy:
       ```powershell
       Get-ComputerInfo | Select-Object BiosFirmwareType, BiosSecureBootValue
       Get-Tpm | Select-Object TpmPresent, TpmReady
       ```
       *(BiosFirmwareType hiện `Uefi`, BiosSecureBootValue hiện `1` (Bật), TpmPresent & TpmReady đều hiện `True`).*


4. **(Phương án USB) Cài đặt Windows 11 từ USB.**
   - Rút toàn bộ ổ cứng ngoài, thẻ nhớ, USB dữ liệu khác (chỉ để lại đúng 1 USB cài đặt) để tránh xóa nhầm dữ liệu.
   - Cắm USB vào máy, khởi động lại, bấm phím Boot Menu (F11/F12/Esc tuỳ mainboard) để chọn boot từ USB.
   - Đến bước hỏi Product key: Nếu máy đã có license từ trước, chọn **"I don't have a product key"** rồi chọn đúng Edition (Home hoặc Pro) đã dùng trước đó.

   > [!CAUTION]
   > **Cảnh báo cực kỳ quan trọng tại màn hình "Where do you want to install Windows?":**
   > - **KHÔNG ĐƯỢC mặc định giả định Disk 0 luôn là ổ cài hệ điều hành!** Nếu máy có 2 ổ cứng (ví dụ 1 ổ SSD NVMe chứa OS và 1 ổ SSD/HDD chứa dữ liệu học tập), xóa nhầm ổ sẽ mất toàn bộ tài liệu.
   > - Hãy quan sát kỹ **Cột Dung lượng (Total Size / Free Space)** và số thứ tự Disk.
   > - Chỉ chọn các phân vùng thuộc đúng ổ cứng bạn muốn cài lại Windows. Nếu muốn cài sạch hoàn toàn trên ổ đó, chọn từng phân vùng của ổ đó và bấm **Delete** cho tới khi thành một khối **Unallocated Space**, sau đó chọn khối đó và bấm **Next**.

5. **Windows Update — cập nhật triệt để.**
   - Mở Settings (`Win + I`) > **Windows Update** > bấm **Check for updates**.
   - Cài hết tất cả bản cập nhật. Khởi động lại máy khi được yêu cầu.
   - Lặp lại thao tác bấm **Check for updates** cho đến khi hiện thông báo **"You're up to date"**.

6. **Kiểm tra và cài Driver GPU — nền tảng bắt buộc cho AI/ML.**
   - Xác định model GPU: Mở Task Manager (`Ctrl + Shift + Esc`) > tab **Performance** > mục **GPU** (hoặc Device Manager > Display adapters).
   - Tải driver mới nhất từ trang chính thức:
     - **NVIDIA:** [nvidia.com/en-us/drivers/](https://www.nvidia.com/en-us/drivers/) (chọn bản Game Ready Driver hoặc Studio Driver tương ứng với GPU của bạn, ví dụ RTX 4050 Laptop).
     - **AMD:** [amd.com/en/support/download/drivers.html](https://www.amd.com/en/support/download/drivers.html).
     - **Intel:** [intel.com/content/www/us/en/download-center/home.html](https://www.intel.com/content/www/us/en/download-center/home.html).
   - Chạy file cài đặt và restart máy.
   - *Lý do:* PyTorch, CUDA, và các framework AI/ML đòi hỏi driver NVIDIA phải đủ mới để nhận diện phần cứng và biên dịch CUDA kernel.

7. **Kiểm tra trạng thái kích hoạt (Activation).**
   - Mở Settings > **System > Activation** (hoặc gõ `ms-settings:activation`).
   - Kiểm tra dòng **Activation state**: phải hiện **Active**.
   - Nếu chưa active: bấm **Troubleshoot** hoặc đăng nhập tài khoản Microsoft đã liên kết bản quyền.

8. **(Tuỳ chọn) Gỡ bớt ứng dụng rác không cần thiết.**
   - Vào **Settings > Apps > Installed apps**, gỡ các ứng dụng mặc định không dùng tới. Không gỡ các ứng dụng điều khiển phần cứng cần thiết (quạt tản nhiệt, chuyển đổi chế độ GPU mux switch).

---

## ✅ Kiểm tra đã thành công

- [PowerShell - Windows]: Kiểm tra thông tin hệ thống cơ bản:
  ```powershell
  systeminfo | Select-String "OS Name", "OS Version", "System Model"
  ```
- [PowerShell - Windows]: Kiểm tra GPU NVIDIA đã nhận driver thành công:
  ```powershell
  nvidia-smi
  ```
  *(Hiện bảng thông tin Driver Version, CUDA Version và danh sách GPU là thành công).*
- **Settings > Windows Update** hiện **"You're up to date"**.
- **Settings > System > Activation** báo **Active**.

---

## ⚠️ Lỗi thường gặp

- **Cài xong không có kết nối Wi-Fi:** Cắm USB đã lưu sẵn Driver Wi-Fi ở Bước 0 vào cài đặt, hoặc cắm dây cáp điện thoại vào máy tính bật tính năng "Chia sẻ kết nối Internet qua USB" (USB Tethering).
- **Xóa nhầm phân vùng dữ liệu:** Trước khi format/delete ở bước chọn ổ đĩa, luôn đối chiếu dung lượng ổ trong Task Manager hoặc chụp ảnh lại sơ đồ phân vùng cũ bằng điện thoại trước khi tiến hành.
- **`nvidia-smi` báo lỗi `'nvidia-smi' is not recognized`:** Driver NVIDIA chưa được cài đặt hoặc thư mục `C:\Program Files\NVIDIA Corporation\NVSMI` chưa được thêm vào PATH. Hãy tải lại và cài đặt driver từ trang chủ NVIDIA.
- **Windows báo "Not activated":** Nếu key nằm trong firmware nhưng chưa nhận, hãy kết nối mạng ổn định rồi bấm **Troubleshoot** trong mục Activation. Nếu là Digital License, hãy đăng nhập tài khoản Microsoft tương ứng.

