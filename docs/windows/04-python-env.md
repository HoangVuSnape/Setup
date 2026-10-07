# Cài Python qua Miniconda (conda), uv và quản lý môi trường ảo

## Mục tiêu

Sau bước này, máy có môi trường Python chuẩn không bị xung đột PATH, biết dùng `conda` hoặc `uv`/`venv` để tạo môi trường ảo độc lập (`ai-env`) sử dụng **Python 3.11** (phiên bản ổn định và tương thích cao nhất cho AI/ML), dùng cú pháp an toàn `python -m pip`, và quản lý thư viện qua `requirements.txt`.

## Các bước

1. **Vì sao cần "virtual environment" và không nên cài gói toàn cục?**
   - Các dự án AI/ML thường sử dụng các phiên bản thư viện rất khắt khe (ví dụ: PyTorch 2.x cần CUDA tương ứng, các gói extension như flash-attn, unsloth, triton yêu cầu đúng bản Python). Cài đặt tràn lan vào môi trường gốc (base/global) sẽ dẫn đến xung đột phiên bản và làm hỏng toàn bộ hệ thống Python.
   - Mỗi dự án phải có một "môi trường ảo" riêng biệt, cô lập hoàn toàn.

2. **Cài đặt Miniconda — Lưu ý sống còn về biến môi trường PATH.**
   - Miniconda là bản rút gọn chỉ gồm Python + `conda` (trình quản lý gói & môi trường mạnh mẽ).
   - Tải bộ cài Windows 64-bit từ trang chủ: [repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe](https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe).
   - Mở file `.exe`, chọn **Just Me**, giữ nguyên đường dẫn cài đặt mặc định (tránh thư mục có dấu tiếng Việt hoặc khoảng trắng).

   > [!WARNING]
   > **Tại màn hình "Advanced Installation Options":**
   > - **TUYỆT ĐỐI KHÔNG TICK** ô *"Add Miniconda3 to my PATH environment variable"*.
   > - *Lý do:* Tick ô này sẽ ghi đè PATH hệ thống, gây xung đột nghiêm trọng với Python của Windows Store, Python của các IDE khác, làm `pip` và `python` trỏ lệch phiên bản dẫn đến lỗi môi trường ảo không nhận đúng package.

   - Giữ nguyên ô *"Register Miniconda3 as my default Python"*, bấm **Install** và đợi hoàn thành.

3. **Khởi tạo Conda trong Windows Terminal (`conda init`).**
   - Sau khi cài xong, bấm nút Start, tìm và mở app **Anaconda Prompt (Miniconda3)**.
   - Trong cửa sổ Anaconda Prompt, chạy lệnh để tích hợp conda vào PowerShell:
     ```powershell
     conda init powershell
     ```
   - Đóng cửa sổ Anaconda Prompt. Từ nay về sau, bạn chỉ cần mở **Windows Terminal** (PowerShell) thông thường là đã có thể dùng được lệnh `conda`.
   - Mở Windows Terminal mới, kiểm tra đường dẫn các file thực thi:
     - [PowerShell - Windows]:
       ```powershell
       where.exe python
       where.exe conda
       conda --version
       ```

4. **Tạo và kích hoạt môi trường ảo `ai-env` với Python 3.11.**
   - **Vì sao chọn Python 3.11 mà không phải 3.13?**
     - Các thư viện AI/ML nền tảng (PyTorch, TensorFlow, CUDA Toolkit, vLLM, Unsloth, Flash Attention) phụ thuộc rất nhiều vào các thư viện C/C++ (C extensions).
     - **Python 3.11** là phiên bản có độ tương thích cao và an toàn nhất hiện nay cho hệ sinh thái AI/ML.
     - **Python 3.12** có thể sử dụng cho các dự án data thông thường.
     - **Python 3.13** chưa nên dùng làm mặc định cho AI/ML vì nhiều gói CUDA chưa biên dịch sẵn wheel cho bản này.
   - [PowerShell - Windows]: Tạo môi trường tên `ai-env`:
     ```powershell
     conda create -n ai-env python=3.11 -y
     ```
   - Kích hoạt môi trường:
     ```powershell
     conda activate ai-env
     ```
     *(Dấu hiệu nhận biết: đầu dòng lệnh xuất hiện tiền tố `(ai-env)`).*
   - Khi muốn thoát môi trường:
     ```powershell
     conda deactivate
     ```

5. **Quy tắc cài package bằng `python -m pip` và `requirements.txt`.**
   - **Tránh dùng `pip install ...` trực tiếp:** Khi máy có nhiều bản Python, gõ `pip` có thể gọi nhầm pip của bản Python khác. Luôn dùng cú pháp tường minh:
     ```powershell
     python -m pip install <tên-gói>
     ```
   - Kiểm tra xem python và pip có đang trỏ đúng vào `ai-env` không:
     ```powershell
     python -c "import sys; print(sys.executable)"
     python -m pip --version
     ```
     *(Đường dẫn in ra phải nằm trong thư mục `miniconda3\envs\ai-env\...`)*.

   - **Quản lý dependencies chuẩn qua `requirements.txt`:**
     - Tạo file `requirements.txt` với nội dung các thư viện cần thiết:
       ```text
       numpy
       pandas
       scikit-learn
       ```
     - Cài đặt toàn bộ:
       ```powershell
       python -m pip install -r requirements.txt
       ```
     - Xuất danh sách phiên bản cố định để chia sẻ hoặc backup:
       ```powershell
       python -m pip freeze > requirements-lock.txt
       ```

6. **(Lựa chọn hiện đại) Quản lý môi trường cực nhanh bằng `uv`.**
   - Nếu bạn đã cài `uv (Astral)` qua script hoặc winget (`winget install --id astral-sh.uv -e`), `uv` có thể thay thế cả pip và conda để tạo venv và cài package với tốc độ nhanh gấp 10-50 lần:
     ```powershell
     uv python install 3.11
     uv venv --python 3.11
     .\.venv\Scripts\Activate.ps1
     uv pip install numpy pandas scikit-learn
     ```

---

## ✅ Kiểm tra đã thành công

- [PowerShell - Windows]: Khi đã chạy `conda activate ai-env`:
  ```powershell
  python -c "import sys, numpy, pandas; print(sys.version); print('Numpy:', numpy.__version__); print('Pandas:', pandas.__version__)"
  ```
  *(Hiển thị Python phiên bản 3.11.x và số phiên bản của numpy, pandas mà không báo lỗi)*.

---

## ⚠️ Lỗi thường gặp

- **Chạy `conda activate` báo lỗi script bị chặn trên PowerShell:** Mở PowerShell chạy lệnh cấp quyền:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- **Lỗi `CommandNotFoundError: Run 'conda init' before 'conda activate'`:** Mở lại **Anaconda Prompt** từ Start Menu và gõ lại `conda init powershell`, sau đó tắt đi và mở lại Windows Terminal mới.
- **Thư viện cài xong nhưng import báo `ModuleNotFoundError`:** 99% nguyên nhân là bạn cài bằng `pip` của một môi trường khác. Luôn kiểm tra xem `(ai-env)` đã xuất hiện ở đầu prompt chưa và luôn dùng lệnh `python -m pip install`.

