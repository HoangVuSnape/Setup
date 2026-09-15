# Cài công cụ cơ bản: winget, trình duyệt, 7-Zip, tinh chỉnh Windows

## Mục tiêu

Sau bước này, máy biết dùng `winget` để cài/cập nhật phần mềm bằng dòng lệnh, đã có trình duyệt và 7-Zip để giải nén file, và đã bật 2 tinh chỉnh cơ bản giúp dùng máy thuận tiện hơn: hiện đuôi file và Dark Mode.

## Các bước

1. **Mở Terminal — nơi chạy `winget`.**
   - Windows 11 có sẵn app **Terminal** (chạy PowerShell bên trong). Mở bằng cách bấm nút Start, gõ `Terminal`, Enter. Hoặc chuột phải nút Start > **Terminal**.
   - `winget` (Windows Package Manager) đã có sẵn trên Windows 11 hiện đại, đi kèm app nền **App Installer** — không cần cài thêm. Nếu gõ lệnh `winget` mà Terminal báo `'winget' is not recognized`, vào Microsoft Store, tìm và cài/update app **App Installer**.
   - Lần đầu chạy `winget`, nó có thể hỏi đồng ý điều khoản nguồn dữ liệu (source agreements) — gõ `Y` rồi Enter để đồng ý.

2. **Học 3 lệnh `winget` cơ bản.**
   - Tìm phần mềm theo tên:
     ```
     winget search <tên phần mềm>
     ```
     Ví dụ `winget search 7zip`. Kết quả trả về có cột **Id** — đây mới là mã chính xác dùng để cài, không phải tên hiển thị (Name).
   - Cài phần mềm theo đúng Id (an toàn hơn cài theo tên vì tránh winget tự chọn nhầm gói gần giống):
     ```
     winget install --id <Id> -e
     ```
     Cờ `-e` (viết đầy đủ là `--exact`) bắt buộc khớp chính xác Id đã tra ở bước tìm kiếm.
   - Cập nhật toàn bộ phần mềm đã cài qua winget lên bản mới nhất, chỉ với 1 lệnh:
     ```
     winget upgrade --all
     ```
     Nên chạy lệnh này định kỳ (vài tuần một lần) thay vì tự vào từng trang web tải bản mới.

3. **Cài trình duyệt (bỏ qua nếu chỉ dùng Edge có sẵn).**
   - Windows 11 có sẵn **Microsoft Edge** — nếu thấy đủ dùng, có thể bỏ qua bước này.
   - Muốn cài Chrome, chạy:
     ```
     winget install --id Google.Chrome -e
     ```
   - Hoặc cài Firefox, chạy:
     ```
     winget install --id Mozilla.Firefox -e
     ```
   - Chỉ cần chọn 1 trong 2, không cần cài cả hai.

4. **Cài 7-Zip — phần mềm nén/giải nén file `.zip`, `.rar`, `.7z`...**
   ```
   winget install --id 7zip.7zip -e
   ```

5. **Bật hiện đuôi file (file name extensions).**
   - Vì sao cần: mặc định Windows ẩn đuôi file (`.exe`, `.txt`, `.py`...), dễ gây nhầm lẫn (không phân biệt được `report.pdf` thật với file giả mạo tên `report.pdf.exe`) và bất tiện khi làm việc với code/dữ liệu sau này.
   - Mở File Explorer (`Win + E`), trên ribbon bấm tab **View** > **Show** > tick chọn **File name extensions**.
   - Bật 1 lần là áp dụng cho toàn bộ File Explorer, không cần lặp lại theo từng thư mục.

6. **Bật Dark Mode.**
   - Vào **Settings > Personalization > Colors**, ở mục **Mode**, chọn **Dark** (hoặc **Custom** nếu muốn App mode và Windows mode khác nhau).

## ✅ Kiểm tra đã thành công

- Gõ `winget --version` trong Terminal ra một số phiên bản (dạng `v1.x`), không báo lỗi `not recognized`.
- Trình duyệt vừa cài (Chrome hoặc Firefox) và 7-Zip xuất hiện trong Start Menu, mở lên chạy bình thường.
- Trong File Explorer, các file quen thuộc hiện đuôi, ví dụ thấy `setup.exe` thay vì chỉ `setup`.
- Giao diện Windows (Taskbar, Settings, File Explorer...) chuyển sang nền tối.

## ⚠️ Lỗi thường gặp

- `winget upgrade --all` chạy xong nhưng `winget upgrade` vẫn liệt kê vài phần mềm "chưa cập nhật": một số phần mềm winget không đọc được số phiên bản hiện tại (hiện `Unknown`) nên mặc định bị bỏ qua khi nâng cấp hàng loạt — chạy `winget upgrade --all --include-unknown` để ép cập nhật luôn nhóm này.
- Không tìm thấy mục **"For developers"** hoặc "Show file extensions" trong `Settings > System` như một số hướng dẫn cũ trên mạng: ở các bản Windows 11 mới (25H2 trở lên), Microsoft đã gộp mục này vào **Settings > System > Advanced**. Cách chắc ăn nhất, đúng với mọi phiên bản, vẫn là làm theo bước 5 ở trên (qua ribbon **View > Show** của File Explorer).
