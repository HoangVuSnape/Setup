# Cài công cụ AI/ML: PyTorch (CUDA), JupyterLab & Kernel, Ollama và Smoke Test

## Mục tiêu

Sau bước này, môi trường `ai-env` được cài đặt PyTorch hỗ trợ GPU NVIDIA (CUDA), kiểm tra tính toán Tensor trên phần cứng RTX, cài đặt JupyterLab và đăng ký kernel chính xác, cấu hình Ollama chạy mô hình AI cục bộ không làm đầy ổ C, và hoàn thành bộ Smoke Test toàn diện cho hệ thống.

## Các bước

1. **Kích hoạt môi trường ảo `ai-env`.**
   - Mọi thao tác cài đặt gói thư viện AI/ML dưới đây phải thực hiện **bên trong** môi trường `ai-env` đã tạo ở Bước 4.
   - [PowerShell - Windows]:
     ```powershell
     conda activate ai-env
     ```
     *(Đảm bảo nhìn thấy tiền tố `(ai-env)` trước dòng lệnh).*

2. **Kiểm tra GPU NVIDIA trước khi cài PyTorch.**
   - [PowerShell - Windows]:
     ```powershell
     nvidia-smi
     ```
   - **Xác nhận kết quả:**
     - Bảng `NVIDIA-SMI` hiện ra đúng tên GPU (ví dụ: *NVIDIA GeForce RTX 4050 Laptop GPU*).
     - Ghi nhận chỉ số **CUDA Version** hỗ trợ tối đa ở góc trên bên phải (ví dụ: `CUDA Version: 12.6`).
   - *Nếu báo lỗi lệnh không tồn tại:* Máy chưa cài đặt driver NVIDIA hoặc chưa khởi động lại máy sau khi cài driver ở Bước 1.

3. **Cài PyTorch — Lấy lệnh cài đặt động mới nhất từ trang chủ.**
   - Các gói PyTorch và phiên bản CUDA liên tục được cập nhật. **Tuyệt đối không dùng lệnh chép sẵn từ các bài viết cũ** để tránh lỗi không tương thích.
   - Truy cập trang chính thức: [pytorch.org/get-started/locally](https://pytorch.org/get-started/locally/)
   - Tại bảng chọn ma trận:
     - **PyTorch Build:** `Stable`
     - **Your OS:** `Windows`
     - **Package:** `Pip`
     - **Language:** `Python`
     - **Compute Platform:** Chọn bản `CUDA 12.x` (tương thích với CUDA Version hiển thị trong `nvidia-smi`). *(Chỉ chọn `CPU` nếu máy không có card đồ họa rời NVIDIA).*
   - Sao chép lệnh xuất hiện ở dòng **Run this Command**, ví dụ cú pháp chuẩn:
     ```powershell
     python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
     ```
   - Chạy lệnh trong Terminal đang kích hoạt `ai-env`. Quá trình tải các file wheel của CUDA có dung lượng khoảng 2–3GB.

4. **Cài đặt JupyterLab và Đăng ký Kernel cho môi trường `ai-env`.**
   - [PowerShell - Windows]:
     ```powershell
     python -m pip install jupyterlab ipykernel
     ```
   - **Đăng ký kernel:** Để JupyterLab và VS Code nhận diện đúng môi trường `ai-env` khi mở notebook `.ipynb`, bạn bắt buộc phải đăng ký kernel:
     ```powershell
     python -m ipykernel install --user --name ai-env --display-name "Python (ai-env)"
     ```
   - Kiểm tra danh sách kernel đã đăng ký:
     ```powershell
     jupyter kernelspec list
     ```
   - **Chạy JupyterLab:**
     ```powershell
     python -m jupyter lab
     ```
     *(Nếu không muốn tự động bật tab trình duyệt: thêm cờ `--no-browser`). Bấm `Ctrl + C` trong Terminal để tắt khi dùng xong.*

5. **Cài đặt các thư viện Data Science và AI/ML cần thiết.**
   - [PowerShell - Windows]: Cài đặt các gói cốt lõi:
     ```powershell
     python -m pip install numpy pandas scikit-learn matplotlib seaborn tqdm
     ```

6. **Cài đặt Ollama — Quản lý dung lượng ổ đĩa và GPU.**
   - Tải file cài đặt Windows chính thức: [ollama.com/download/windows](https://ollama.com/download/windows)
   - Chạy file `OllamaSetup.exe` để hoàn tất cài đặt.

   > [!WARNING]
   > **Tránh làm đầy ổ C:**
   > - Mặc định Ollama tải toàn bộ weights mô hình (mỗi mô hình từ 2GB đến 20GB+) vào thư mục `C:\Users\<user>\.ollama\models`.
   > - Nếu ổ C dung lượng hạn chế, hãy đổi thư mục lưu sang ổ D hoặc ổ đĩa khác bằng lệnh:
   >   ```powershell
   >   [Environment]::SetEnvironmentVariable("OLLAMA_MODELS", "D:\OllamaModels", "User")
   >   ```
   > - Sau đó chuột phải vào icon Ollama ở góc System Tray > chọn **Quit Ollama**, rồi mở lại Ollama từ Start Menu để biến môi trường có hiệu lực.

   - **Chạy thử mô hình LLM:**
     - Mở PowerShell mới kiểm tra: `ollama --version`
     - Tải và chạy thử model nhỏ (tra cứu danh sách cập nhật tại [ollama.com/library](https://ollama.com/library)):
       ```powershell
       ollama run llama3.2:1b
       ```
     - Khi model đang chạy, mở một cửa sổ PowerShell khác để kiểm tra xem model có thực sự được nạp vào VRAM của GPU hay không:
       ```powershell
       ollama ps
       nvidia-smi
       ```
       *(Nếu cột `PROCESSES` trong `nvidia-smi` xuất hiện tiến trình `ollama_llama_server.exe` và `ollama ps` hiển thị 100% GPU là hoàn hảo).*
     - Gõ `/bye` trong cửa sổ chat Ollama để thoát.

---

## ✅ SMOKE TEST TOÀN DIỆN (Kiểm tra chốt hạ hệ thống)

Sau khi hoàn tất toàn bộ checklist, mở một cửa sổ Windows Terminal mới và chạy lần lượt các bước kiểm tra sau:

1. **Smoke Test 1: PyTorch nhận diện CUDA và GPU:**
   ```powershell
   conda activate ai-env
   python -c "import torch; print('PyTorch Version:', torch.__version__); print('CUDA Available:', torch.cuda.is_available()); print('Device Name:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU')"
   ```
   *(Phải in ra `CUDA Available: True` và đúng tên card đồ họa NVIDIA).*

2. **Smoke Test 2: Chạy tính toán Tensor thực tế trên nhân CUDA của GPU:**
   ```powershell
   python -c "import torch; x = torch.rand(4096, 4096, device='cuda'); y = torch.matmul(x, x); print('CUDA Matrix Mul OK! Mean:', y.mean().item())"
   ```
   *(Phép nhân ma trận 4096x4096 tính toán thành công trên VRAM mà không gặp lỗi OOM hoặc CUDA error).*

3. **Smoke Test 3: Kiểm tra các thư viện cơ bản:**
   ```powershell
   python -c "import numpy, pandas, sklearn, matplotlib; print('Core Data Science libraries OK!')"
   ```

4. **Smoke Test 4: Kiểm tra Docker Desktop:**
   ```powershell
   docker run --rm hello-world
   ```

---

## ⚠️ Lỗi thường gặp

- **`torch.cuda.is_available()` trả về `False`:** 
  - Lỡ cài bản PyTorch mặc định của PyPI (không kèm CUDA). Khắc phục: Gỡ sạch bằng `python -m pip uninstall torch torchvision torchaudio -y`, sau đó chạy lại lệnh cài đặt có cờ `--index-url https://download.pytorch.org/whl/cu...`.
- **VS Code không tìm thấy kernel `ai-env` khi mở file `.ipynb`:**
  - Bạn chưa chạy lệnh đăng ký kernel. Hãy activate `ai-env` và chạy lại: `python -m ipykernel install --user --name ai-env --display-name "Python (ai-env)"`.
- **Ollama chạy chậm, CPU tăng 100%:**
  - Model đang chạy trên CPU thay vì GPU. Kiểm tra lại `nvidia-smi` xem VRAM còn trống không, hoặc giảm context size / dùng model nhỏ hơn để vừa với dung lượng VRAM của card đồ họa.
- **Cài đúng bản CUDA nhưng driver GPU của máy quá cũ so với bản CUDA đó:**
  - Lỗi thường có dòng nhắc tới *"CUDA driver version is insufficient"* khi `import torch` hoặc gọi hàm liên quan tới GPU. Cập nhật driver NVIDIA qua trang chủ NVIDIA hoặc GeForce Experience.
- **Lần đầu mở Ollama xuất hiện popup Windows Firewall:**
  - Bấm **Allow access** (ít nhất cho mạng Private) vì Ollama chạy local server tại cổng `localhost:11434`.


