# Bật WSL2 và cài Docker Desktop

## Mục tiêu

Sau bước này, máy đã bật WSL2 (Ubuntu), cấu hình kernel mới nhất, cập nhật gói Linux cơ bản, cài đặt Docker Desktop với WSL2 backend, kiểm tra chạy Docker thành công từ cả Windows và bên trong Ubuntu, và cấu hình giới hạn RAM để tránh Docker làm tràn bộ nhớ máy.

## Các bước

1. **Kiểm tra phần cứng ảo hóa (Virtualization) trước khi cài.**
   - Mở Task Manager (`Ctrl + Shift + Esc`) > tab **Performance** > mục **CPU** > nhìn góc dưới bên phải: dòng **Virtualization** phải báo **Enabled**.
   - Hoặc kiểm tra qua [PowerShell - Windows]:
     ```powershell
     Get-ComputerInfo | Select-Object HyperVisorPresent
     ```
   - *Nếu báo Disabled:* Bạn bắt buộc phải vào BIOS/UEFI khi khởi động máy (phím F2/Del) để bật **Intel Virtualization Technology (Intel VT-x)** hoặc **AMD-V / SVM Mode**.

2. **Cài đặt và cập nhật WSL2.**
   - Mở **PowerShell với quyền Administrator** (chuột phải nút Start > Terminal (Admin)):
     ```powershell
     wsl --install
     wsl --update
     wsl --set-default-version 2
     ```
   - Khởi động lại máy tính khi Windows yêu cầu.

3. **Khởi tạo Ubuntu và cập nhật hệ điều hành Linux.**
   - Sau khi khởi động lại, bấm Start mở ứng dụng **Ubuntu**. Lần đầu mở sẽ mất 1–2 phút giải nén.
   - Thiết lập **username** và **password** cho Ubuntu (lưu ý khi gõ password Linux sẽ không hiển thị ký tự lên màn hình, cứ gõ đúng và Enter).
   - **Cập nhật hệ thống và cài các công cụ dòng lệnh cơ bản:**
     - [Ubuntu - WSL2]:
       ```bash
       sudo apt update && sudo apt upgrade -y
       sudo apt install -y git curl wget build-essential unzip
       ```

4. **Kiểm tra trạng thái WSL2 trên Windows.**
   - Mở Windows Terminal mới (PowerShell thường):
     - [PowerShell - Windows]:
       ```powershell
       wsl --status
       wsl --list --verbose
       ```
       *(Cột **VERSION** của Ubuntu phải là **2**. Distro mặc định có dấu `*` bên cạnh).*

5. **Cấu hình giới hạn tài nguyên máy cho WSL2 (`.wslconfig`).**
   - WSL2 mặc định có thể tự động chiếm dụng tới 50% - 80% dung lượng RAM của máy nếu không được giới hạn. Với máy có 16GB RAM học AI/ML, nên giới hạn WSL2 tối đa 6GB–8GB RAM để chừa tài nguyên cho Windows và GPU.
   - [PowerShell - Windows]: Tạo file cấu hình:
     ```powershell
     @"
     [wsl2]
     memory=8GB
     processors=4
     swap=4GB
     "@ | Out-File -FilePath "$env:USERPROFILE\.wslconfig" -Encoding utf8
     ```
   - Khởi động lại WSL để áp dụng:
     ```powershell
     wsl --shutdown
     ```

6. **Cài đặt Docker Desktop và kích hoạt WSL Integration.**
   - [PowerShell - Windows]:
     ```powershell
     winget install --id Docker.DockerDesktop -e
     ```
   - Cài xong, mở app **Docker Desktop** từ Start Menu. Bấm **Accept** ở màn hình thỏa thuận bản quyền.
   - **Kích hoạt tích hợp với Ubuntu:**
     - Trong Docker Desktop, bấm icon **Bánh răng (Settings)** ở góc trên phải.
     - Vào **General**: đảm bảo đã bật *"Use the WSL 2 based engine"*.
     - Vào **Resources > WSL Integration**: gạt bật **Enable integration with additional distros** cho `Ubuntu`.
     - Bấm **Apply & restart**.

   > [!NOTE]
   > Không cài thêm Docker Engine trực tiếp bên trong Ubuntu bằng lệnh `apt install docker` để tránh xung đột hai daemon Docker cùng lúc. Docker Desktop đã tự động tích hợp lệnh `docker` vào thẳng Ubuntu.

7. **Kiểm tra Docker hoạt động từ cả hai môi trường.**
   - [PowerShell - Windows]:
     ```powershell
     docker version
     docker run hello-world
     ```
   - [Ubuntu - WSL2]: Mở Ubuntu terminal và chạy thử:
     ```bash
     docker version
     docker run hello-world
     ```
     *(Cả 2 môi trường đều in ra thông điệp `Hello from Docker!` là thành công hoàn hảo).*

8. **Quản lý dung lượng và dọn dẹp Docker định kỳ.**
   - Khi build và tải image Docker về học tập, ổ cứng C có thể bị đầy nhanh chóng.
   - [PowerShell - Windows]: Kiểm tra dung lượng Docker đang chiếm:
     ```powershell
     docker system df
     ```
   - Dọn dẹp cache và các container/image không còn dùng:
     ```powershell
     docker system prune
     ```
     *(Gõ `y` để xác nhận. Lưu ý lệnh này sẽ xóa các container đã dừng, network rác và build cache).*

---

## ✅ Kiểm tra đã thành công

- `wsl --list --verbose` hiển thị Ubuntu chạy Version 2.
- `docker run hello-world` chạy thành công mượt mà cả trên PowerShell và bên trong Ubuntu WSL.
- Icon cá voi của Docker Desktop ở khay hệ thống chuyển sang màu xanh (Running).

---

## ⚠️ Lỗi thường gặp

- **Ubuntu không nhận lệnh `docker`:** Kiểm tra xem Docker Desktop đã chạy chưa, và vào Settings > Resources > WSL Integration đã gạt bật công tắc cho Ubuntu chưa.
- **Docker Desktop báo lỗi "Virtualization not enabled":** Ảo hóa chưa được bật trong BIOS/UEFI. Cần restart máy vào BIOS bật VT-x/AMD-V.
- **Máy bị đơ/lag sau khi chạy Docker một thời gian:** Do WSL2 chiếm hết RAM. Đảm bảo bạn đã tạo file `$env:USERPROFILE\.wslconfig` ở Bước 5 và chạy `wsl --shutdown` để áp dụng giới hạn RAM.

