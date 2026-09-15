# Bật WSL2 và cài Docker Desktop

## Mục tiêu

Sau bước này, máy đã bật WSL2 (chạy nhân Linux thật ngay bên trong Windows) và cài xong Docker Desktop dùng WSL2 backend, đã chạy thử container đầu tiên thành công để xác nhận mọi thứ hoạt động đúng.

## Các bước

1. **WSL2 là gì, Docker là gì — vì sao cần?**
   - WSL2 (Windows Subsystem for Linux, bản 2) cho chạy một bản Linux thật (dùng đúng nhân/kernel Linux, không phải giả lập) ngay bên trong Windows, không cần cài song song 2 hệ điều hành (dual-boot) hay dựng máy ảo nặng nề. Nhiều công cụ lập trình/AI (nhất là Docker container, một số thư viện AI/ML sẽ dùng ở file `06-ai-ml.md`) chạy mượt và ổn định hơn trên Linux — bật WSL2 giúp có sẵn môi trường đó ngay trên máy Windows đang dùng.
   - Docker là công cụ đóng gói một ứng dụng cùng toàn bộ môi trường nó cần (thư viện, cấu hình...) vào một "hộp" độc lập gọi là container, chạy ra kết quả giống hệt nhau trên bất kỳ máy nào có Docker — hữu ích khi thử các dự án AI/ML hoặc dịch vụ self-host có yêu cầu môi trường phức tạp, khỏi lo cài đè/xung đột lên máy thật. Trên Windows, Docker Desktop chạy container thông qua WSL2 (thay cho công nghệ ảo hoá Hyper-V cũ) — vì vậy cần bật WSL2 trước khi cài Docker.

2. **Bật WSL2.**
   - Mở **PowerShell as Administrator**: bấm Start, gõ `PowerShell` (hoặc `Terminal`), chuột phải vào kết quả → **Run as administrator**.
   - Chạy:
     ```
     wsl --install
     ```
     Lệnh này tự bật các tính năng Windows cần thiết cho WSL và cài sẵn bản Linux mặc định hiện tại là **Ubuntu** (muốn đổi sang distro khác như Debian: xem danh sách bằng `wsl --list --online`, rồi cài bằng `wsl --install -d <TênDistro>`).
   - Khởi động lại máy khi được yêu cầu.
   - Sau khi máy khởi động lại, mở **Ubuntu** từ Start Menu (thường tự mở luôn) — lần đầu cần đợi vài phút để giải nén, sau đó được hỏi tạo **username** và **password** riêng cho Linux (khác tài khoản Windows; khi gõ password sẽ không thấy ký tự nào hiện lên trên màn hình — vẫn đang gõ bình thường, không phải máy bị treo).

3. **Kiểm tra WSL2 đã bật đúng.**
   ```
   wsl --list --verbose
   ```
   Cột **VERSION** của distro vừa cài (vd `Ubuntu`) phải là `2`. Nếu ra `1`, chuyển bằng:
   ```
   wsl --set-version Ubuntu 2
   ```

4. **Cài Docker Desktop.**
   - Mở Terminal thường (không cần quyền Administrator), chạy:
     ```
     winget install --id Docker.DockerDesktop -e
     ```
   - Cài xong, mở app **Docker Desktop** từ Start Menu. Lần đầu mở sẽ hiện màn hình **Docker Subscription Service Agreement** — bấm **Accept**. Sau đó có màn hình mời đăng nhập Docker Hub — bước này **không bắt buộc** cho nhu cầu cá nhân, có thể bỏ qua (tìm nút dạng "Skip"/đóng cửa sổ đó lại).
   - Xác nhận Docker đang dùng WSL2 backend: bấm icon **bánh răng (Settings)** ở góc trên bên phải cửa sổ Docker Desktop → mục **General** (sidebar trái) → tìm ô **"Use WSL 2 based engine"**. Trên máy đã bật WSL2 đúng như bước 2–3, Docker Desktop tự bật sẵn tuỳ chọn này — **ô này có thể không hiện ra ở đó luôn** (không phải chỉ mờ đi) vì đã là mặc định bắt buộc trên máy hỗ trợ WSL2, không thấy ô này là bình thường chứ không phải lỗi. Muốn xem/chỉnh distro nào đang được Docker tích hợp, vào thêm **Settings → Resources → WSL Integration**. Nếu ô này hiện ra nhưng bị **mờ kèm theo Docker báo lỗi** (không phải chỉ đơn giản là "ẩn/không thấy"), thử chạy `wsl --update` trong PowerShell rồi khởi động lại Docker Desktop — dấu hiệu WSL2 đang gặp vấn đề thật, không phải chỉ là "trạng thái mặc định".

5. **Kiểm tra Docker hoạt động.**
   ```
   docker run hello-world
   ```

## ✅ Kiểm tra đã thành công

- `wsl --list --verbose` hiện distro (vd `Ubuntu`) với cột `VERSION` = `2`.
- Docker Desktop mở được, icon con cá voi (whale) ở khay hệ thống (system tray, góc dưới phải màn hình cạnh đồng hồ) ở trạng thái đang chạy, không báo lỗi.
- `docker run hello-world` in ra đoạn text bắt đầu bằng `Hello from Docker!`, không báo lỗi kết nối.

## ⚠️ Lỗi thường gặp

- Chạy `wsl --install` mà không thấy cài gì, chỉ hiện ra đoạn hướng dẫn sử dụng (help text): nghĩa là WSL đã được cài từ trước trên máy. Dùng `wsl --list --verbose` để xem distro hiện có, hoặc `wsl --install -d <TênDistro>` để cài thêm distro khác nếu cần.
- Mở Docker Desktop báo lỗi liên quan đến ảo hoá (virtualization), ví dụ nhắc tới Hyper-V/WSL2 không khả dụng: cần vào BIOS/UEFI của máy bật **Intel VT-x** hoặc **AMD-V** (tên gọi tuỳ hãng mainboard) — đây là điều kiện phần cứng bắt buộc để chạy WSL2/Docker, không thể tự bật được từ trong Windows.
- `docker run hello-world` báo lỗi không kết nối được tới Docker Engine (dạng "Cannot connect to the Docker daemon"): app Docker Desktop chưa mở hoặc chưa khởi động xong — mở app, đợi icon cá voi hết trạng thái "starting" rồi chạy lại lệnh.
