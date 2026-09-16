# Chọn USB để tạo bộ cài (boot) — dùng chung cho Windows và Linux

## Mục tiêu

Sau bước này, bạn biết chọn đúng loại USB (dung lượng, chuẩn kết nối, độ tin cậy) để tạo USB boot cài Windows 11 hoặc Linux Mint — tránh mua nhầm USB quá nhỏ, quá chậm, hoặc USB dung lượng ảo (fake) khiến quá trình tạo bộ cài lỗi giữa chừng.

## Các bước

1. **Chọn dung lượng: tối thiểu 8GB, nên mua 16GB hoặc 32GB.**
   - Windows 11: Microsoft yêu cầu tối thiểu 8GB, nhưng file cài đặt thực tế đã chiếm hơn 4GB, gần đầy USB 8GB — dễ lỗi "không đủ dung lượng" nếu bản cập nhật sau này nặng hơn.
   - Linux Mint XFCE: file ISO khoảng 2.8GB (xem [docs/linux/01-usb-install.md](../linux/01-usb-install.md)) — 8GB vẫn đủ, nhưng vẫn nên chọn 16GB+ để dùng USB đó cho cả 2 việc mà không cần mua riêng từng cái.
   - Khuyên dùng: **16GB hoặc 32GB** — giá rẻ, phổ biến, dư dả cho cả 2 hệ điều hành.

2. **Chọn chuẩn kết nối: ưu tiên USB 3.0/3.1/3.2 (thường có ký hiệu màu xanh dương bên trong cổng).**
   - USB 3.0 trở lên nhanh hơn USB 2.0 rất nhiều (thường gấp 5-10 lần tốc độ ghi/đọc thực tế) — rút ngắn đáng kể thời gian tạo bộ cài bằng Rufus và cả thời gian cài đặt hệ điều hành sau này (installer phải đọc rất nhiều file nhỏ từ USB).
   - Máy tính đời mới hầu hết đã hỗ trợ USB 3.0 — cắm USB vào đúng cổng có ký hiệu màu xanh dương (nếu máy có cả cổng đen lẫn xanh) để chạy đúng tốc độ.
   - USB 2.0 vẫn dùng được, chỉ là chậm hơn — không phải lỗi, chỉ là trải nghiệm chờ lâu hơn.

3. **Chọn thương hiệu uy tín, tránh USB dung lượng ảo (fake).**
   - Ưu tiên các thương hiệu phổ biến, dễ kiểm tra nguồn gốc: SanDisk, Kingston, Samsung, Transcend.
   - Cẩn thận với USB dung lượng cao (64GB, 128GB...) bán giá rẻ bất thường — đây là dấu hiệu thường gặp của USB "dung lượng ảo": USB thật chỉ có vài GB nhưng bị chỉnh firmware để báo sai dung lượng lớn hơn. Khi ghi dữ liệu vượt quá dung lượng thật, dữ liệu cũ sẽ bị ghi đè âm thầm — cực kỳ nguy hiểm khi dùng để tạo bộ cài hệ điều hành (file cài đặt bị hỏng mà không có cảnh báo rõ ràng).
   - Nếu nghi ngờ, dùng công cụ kiểm tra dung lượng thật miễn phí như **H2testw** (Windows) hoặc `f3` (Linux/macOS) trước khi dùng USB để tạo bộ cài.

4. **Sao lưu dữ liệu trong USB trước khi dùng.**
   - Cả công cụ tạo USB cài Windows (Media Creation Tool) lẫn Rufus (dùng cho Linux Mint, xem [docs/linux/01-usb-install.md](../linux/01-usb-install.md)) đều **xoá sạch toàn bộ dữ liệu** trên USB để ghi bộ cài mới — sao chép file quan trọng ra máy tính hoặc USB khác trước khi bắt đầu.

## ✅ Kiểm tra đã thành công

- USB đã chọn có dung lượng thật từ 16GB trở lên (kiểm tra bằng `Properties` trên Windows hoặc công cụ H2testw/f3 nếu nghi ngờ hàng fake).
- Cắm vào đúng cổng USB 3.0 (cổng màu xanh dương, nếu máy có).
- Đã sao lưu xong dữ liệu cũ trong USB (nếu có) sang nơi khác.

## ⚠️ Lỗi thường gặp

- Tạo bộ cài Windows báo lỗi "không đủ dung lượng" dù USB ghi 8GB: dung lượng khả dụng thực tế sau khi format luôn thấp hơn số ghi trên vỏ hộp (nhà sản xuất tính theo 1GB = 1,000,000,000 byte, hệ điều hành tính theo 1GB = 1,073,741,824 byte) — đổi sang USB 16GB trở lên để tránh vấn đề này hoàn toàn.
- USB báo còn trống nhiều nhưng ghi file lỗi/hỏng liên tục: nghi ngờ USB dung lượng ảo — dùng H2testw (Windows) hoặc `f3write`/`f3read` (Linux) để kiểm tra dung lượng thật, đừng cố dùng tiếp USB đó cho việc cài hệ điều hành.
- Tạo bộ cài xong nhưng máy không boot được từ USB: không phải lỗi do chọn sai USB — xem phần "Lỗi thường gặp" ở [docs/windows/01-fresh-install.md](../windows/01-fresh-install.md) hoặc [docs/linux/01-usb-install.md](../linux/01-usb-install.md) để xử lý phần BIOS/UEFI/Secure Boot.
