# Cài Windows 11 mới / cài lại từ đầu

## Mục tiêu

Sau bước này, máy có một bản Windows 11 sạch, đã cập nhật đầy đủ, có driver GPU đúng, đã kích hoạt (activated), và đã dọn bớt vài app mặc định không cần thiết — sẵn sàng để cài các công cụ dev ở các bước tiếp theo.

## Các bước

1. **Kiểm tra xem có cần cài Windows 11 từ đầu hay không.**
   - Nếu máy đang dùng đã có sẵn Windows 11 (chỉ đang rà lại theo checklist này, không phải cài từ máy trống), **bỏ qua bước 2 và 3**, chuyển thẳng tới bước 4 (Windows Update).
   - Chỉ khi máy trống hoàn toàn (máy mới mua chưa cài OS, hoặc chủ động muốn xoá sạch ổ đĩa và cài lại) thì mới cần làm bước 2 và 3.

2. **(Chỉ khi cài mới) Tạo USB cài đặt bằng Media Creation Tool.**
   - Chuẩn bị một USB rỗng dung lượng tối thiểu 8GB, nên dùng 16GB trở lên chuẩn USB 3.0 — xem hướng dẫn chọn USB đầy đủ tại [docs/common/chon-usb-boot.md](../common/chon-usb-boot.md). Toàn bộ dữ liệu trên USB sẽ bị xoá khi tạo bộ cài.
   - Vào trang tải chính thức của Microsoft: `https://www.microsoft.com/software-download/windows11`, tìm mục **"Create Windows 11 Installation Media"** và tải Media Creation Tool.
   - Chạy file `.exe` vừa tải, chọn **"Create installation media (USB flash drive, DVD, or ISO file) for another PC"**, chọn ổ USB, để tool tự tải bản Windows 11 mới nhất và ghi vào USB.
   - Lưu ý điều kiện tối thiểu để cài được Windows 11: máy phải có TPM 2.0, Secure Boot bật trong BIOS/UEFI, và CPU nằm trong danh sách được hỗ trợ — Microsoft không nới lỏng yêu cầu này.

3. **(Chỉ khi cài mới) Cài Windows 11 từ USB.**
   - Cắm USB vào máy, khởi động lại, vào Boot Menu (thường là phím F11/F12/Esc lúc khởi động, tuỳ mainboard) để chọn boot từ USB.
   - Làm theo các màn hình cài đặt: chọn ngôn ngữ; nếu màn hình hỏi Product key mà máy vốn đã có digital license, chọn **"I don't have a product key"** rồi chọn đúng edition Windows 11 khớp với license cũ; ở màn hình điều khoản, chọn **Accept**.
   - Ở màn hình **"Select location to install Windows 11"**: nếu muốn cài sạch, xoá hết các partition hiện có trên Disk 0 cho tới khi chỉ còn Unallocated Space, chọn Unallocated Space rồi bấm **Next**.
   - Máy sẽ tự khởi động lại vài lần trong lúc cài. Sau khi cài xong, làm theo wizard thiết lập ban đầu (đăng nhập tài khoản Microsoft hoặc tạo local account, chọn vùng/ngôn ngữ...).

4. **Windows Update — cập nhật đầy đủ trước khi làm bất cứ gì khác.**
   - Mở Settings (phím tắt `Win + I`) rồi vào **Windows Update**, bấm **Check for updates**.
   - Cài hết mọi bản cập nhật hiện ra. Vì Windows Update thường trả kết quả theo từng đợt, có thể cần bấm **Check for updates** lại nhiều lần cho tới khi không còn gì để cài.
   - Nếu được yêu cầu, restart máy rồi lặp lại bước "Check for updates" tới khi màn hình báo **"You're up to date"**.
   - (Tuỳ chọn) vào **Settings > Windows Update > Advanced options**, bật **"Get the latest updates as soon as they're available"** để nhận bản vá sớm hơn.

5. **Xác định GPU và cài driver đúng — quan trọng cho AI/ML sau này.**
   - Xác định máy đang có GPU hãng nào bằng một trong hai cách:
     - Bấm `Ctrl + Shift + Esc` mở Task Manager, chọn tab **Performance**, mục **GPU** — tên GPU hiện ở góc trên bên phải khung đó.
     - Hoặc chuột phải nút Start > **Device Manager** > mở rộng mục **Display adapters**.
   - Vào đúng trang driver chính thức của hãng GPU tương ứng (không tải driver từ trang bên thứ ba):
     - **NVIDIA**: `https://www.nvidia.com/en-us/drivers/`
     - **AMD (Radeon)**: `https://www.amd.com/en/support/download/drivers.html` — dùng AMD Auto-detect Tool để tự nhận diện GPU, hoặc chọn thủ công đúng dòng card qua Product Selector.
     - **Intel (Arc hoặc GPU tích hợp)**: `https://www.intel.com/content/www/us/en/download-center/home.html`, hoặc dùng app **Intel Driver & Support Assistant** (thường cài sẵn trên máy có Intel Arc).
   - Tải bản driver mới nhất khớp đúng model GPU + Windows 11, chạy file cài, restart nếu được yêu cầu.
   - Vì sao bước này quan trọng: ở file `06-ai-ml.md` sau này sẽ cài PyTorch để tận dụng GPU tăng tốc train model. PyTorch (bản GPU) chạy qua CUDA, và CUDA chỉ nhận đúng GPU khi driver NVIDIA đủ mới và tương thích phiên bản — driver quá cũ là nguyên nhân phổ biến nhất khiến PyTorch không thấy GPU. Nếu máy dùng GPU AMD/Intel, phần tăng tốc AI sẽ đi hướng khác (ROCm/DirectML) ở bước sau; ở bước này chỉ cần cài driver chính hãng mới nhất là đủ.

6. **Kiểm tra Windows đã kích hoạt (activated) chưa.**
   - Vào **Settings > System > Activation** (hoặc bấm `Win + R`, gõ `ms-settings:activation`, Enter để mở thẳng trang này).
   - Xem dòng **Activation state**: nếu ghi **"Active"**, nghĩa là Windows đã kích hoạt xong (thường tự động nếu máy có digital license gắn với phần cứng từ trước, hoặc do đã nhập product key lúc cài).
   - Nếu chưa active, làm theo hướng dẫn ngay trên trang Activation (nhập product key, hoặc chạy Activation Troubleshooter tích hợp sẵn).

7. **(Tuỳ chọn) Gỡ bớt vài app mặc định không cần dùng.**
   - Vào **Settings > Apps > Installed apps**.
   - Tìm app muốn gỡ (ví dụ: Cortana, một vài app hãng máy cài sẵn không dùng tới), bấm nút **"..."** (3 chấm) bên cạnh app đó > **Uninstall**.
   - Chỉ gỡ app chắc chắn không cần. Một số app do OEM (hãng sản xuất máy) cài sẵn để điều khiển phần cứng (chỉnh quạt, giới hạn sạc pin, phím chức năng, firmware...) — không gỡ nếu không chắc app đó dùng để làm gì.
   - Không cần "debloat" triệt để ở bước này — mục tiêu chỉ là dọn bớt những app rõ ràng không dùng tới.

## ✅ Kiểm tra đã thành công

- **Settings > Windows Update** hiện dòng **"You're up to date"**.
- Task Manager > Performance > GPU (hoặc Device Manager > Display adapters) hiện đúng tên GPU của máy, không có dấu chấm than vàng cảnh báo lỗi driver.
- **Settings > System > Activation** hiện **Activation state: Active**.

## ⚠️ Lỗi thường gặp

- Máy không boot được từ USB cài Windows: vào BIOS/UEFI (thường phím `Del` hoặc `F2` lúc khởi động, tuỳ mainboard), kiểm tra Boot Order để USB được ưu tiên trước ổ cứng, và đảm bảo Secure Boot + TPM 2.0 đang bật — thiếu 1 trong 2 cái này Windows 11 sẽ từ chối cài.
- Cài driver GPU xong nhưng Device Manager vẫn báo lỗi hoặc app không nhận GPU: gỡ driver cũ hoàn toàn bằng công cụ DDU (Display Driver Uninstaller) ở Safe Mode rồi cài lại bản mới, tránh tình trạng driver cũ còn sót gây xung đột.
- Windows Update báo lỗi khi tải/cài update: bấm "Check for updates" lại vài lần (Windows Update đôi khi chỉ trả một phần kết quả), hoặc chạy Windows Update Troubleshooter tại **Settings > System > Troubleshoot > Other troubleshooters**.
- Windows báo "Not activated" dù máy từng active trước đó (ví dụ sau khi đổi mainboard/cài lại): cần đăng nhập đúng tài khoản Microsoft đã link với digital license cũ, hoặc dùng Activation Troubleshooter ngay trong trang Activation.
