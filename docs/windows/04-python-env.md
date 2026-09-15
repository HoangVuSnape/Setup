# Cài Python qua Miniconda (conda) và virtual environment (venv)

## Mục tiêu

Sau bước này, máy có Miniconda (Python + trình quản lý gói `conda`) cài sẵn, biết tạo và kích hoạt một "môi trường ảo" (virtual environment) riêng cho từng dự án Python — bằng `conda` hoặc bằng `venv` chuẩn có sẵn trong Python — và đã cài thử được 2 thư viện cơ bản (`numpy`, `pandas`) để kiểm tra mọi thứ hoạt động đúng.

## Các bước

1. **Vì sao cần "virtual environment" (môi trường ảo)?**
   - Mỗi dự án Python thường cần các phiên bản thư viện khác nhau — ví dụ dự án A cần `numpy` bản cũ, dự án B lại cần `numpy` bản mới hơn (có hàm mới, bỏ hàm cũ). Nếu cài tất cả thẳng vào **một** bản Python duy nhất của máy (gọi là môi trường "global"/"base"), bản cài sau sẽ đè lên bản trước — cập nhật thư viện cho dự án mới có thể làm hỏng dự án cũ.
   - "Virtual environment" giải quyết việc này bằng cách tạo ra các "bản sao Python" độc lập với nhau, mỗi bản có bộ thư viện riêng — cài, gỡ, nâng cấp thư viện trong môi trường này không ảnh hưởng tới môi trường khác hay bản Python gốc của máy.
   - Có 2 cách phổ biến để tạo môi trường ảo trên Windows, hướng dẫn dưới đây có cả 2, **chỉ cần chọn 1**:
     - **conda** (đi kèm Miniconda) — phổ biến trong giới AI/ML, quản lý được cả nhiều phiên bản Python khác nhau chứ không chỉ thư viện. **Khuyến nghị dùng cách này** vì các bước sau (WSL2/Docker, PyTorch, Jupyter ở file `06-ai-ml.md`) sẽ dùng conda environment.
     - **venv** — module có sẵn trong Python, không cần cài thêm gì ngoài chính Python, gọn nhẹ hơn.

2. **Cài Miniconda.**
   - Miniconda là bản cài đặt gọn của Anaconda: chỉ gồm Python + `conda` (trình quản lý gói & môi trường ảo), không kèm sẵn hàng trăm package như bản Anaconda đầy đủ nên đỡ nặng máy.
   - Tải bản cài Windows 64-bit tại link tải trực tiếp chính thức (Anaconda luôn cập nhật link này trỏ tới bản mới nhất):
     ```
     https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
     ```
     (Trang liệt kê đầy đủ các bản: [repo.anaconda.com/miniconda](https://repo.anaconda.com/miniconda/); trang giới thiệu chính thức: [anaconda.com/download](https://www.anaconda.com/download) — kéo xuống mục **Miniconda Installers**.)
   - Mở file `.exe` vừa tải, cài theo các bước: bấm **Next**, ở **Select Installation Type** chọn **Just Me**, giữ nguyên thư mục cài mặc định (tránh đổi sang đường dẫn có dấu cách hoặc ký tự tiếng Việt có dấu — dễ gây lỗi với các công cụ mã nguồn mở). Ở **Advanced Installation Options**, **tick thêm ô "Add Miniconda3 to my PATH environment variable"** — ô này mặc định KHÔNG được tick (Anaconda khuyên không tick để tránh xung đột với các bản Python khác trên máy), nhưng tick lên thì mới gõ được `conda`/`python` trực tiếp trong Terminal thường như hướng dẫn này dùng xuyên suốt, thay vì phải mở riêng "Anaconda Prompt (miniconda3)" mỗi lần. Giữ nguyên ô còn lại (**Register Miniconda3 as my default Python**) theo mặc định, bấm **Install**, đợi xong bấm **Finish**.
   - Đóng cửa sổ Terminal đang mở (nếu có) và mở **Terminal mới** để PATH vừa được cài đặt cập nhật, sau đó kiểm tra:
     ```
     conda --version
     ```

3. **Tạo và kích hoạt một conda environment.**
   - Tạo môi trường mới tên `myenv` với Python 3.13 — lùi lại một bản so với bản mới nhất (3.14, tính tới 9/2026) để tránh các vấn đề tương thích thường gặp ở bản Python vừa ra mắt, trong khi vẫn được các thư viện AI/ML như `numpy`, `pandas`, PyTorch hỗ trợ đầy đủ (sẽ dùng lại ở file `06-ai-ml.md`):
     ```
     conda create -n myenv python=3.13
     ```
     Đổi `myenv` thành tên gợi nhớ theo từng dự án thật (ví dụ `ai-project`). Gõ `y` rồi Enter khi được hỏi xác nhận cài các gói cơ bản.
   - Kích hoạt môi trường vừa tạo:
     ```
     conda activate myenv
     ```
     Nhận biết đã vào đúng môi trường qua chữ `(myenv)` xuất hiện ở đầu dòng lệnh.
   - Muốn thoát ra môi trường hiện tại (quay về `base`), gõ:
     ```
     conda deactivate
     ```

4. **Cách khác — venv chuẩn của Python (không dùng conda).**
   - `venv` là module có sẵn đi kèm mọi bản Python — không cần Miniconda. Vì Miniconda ở bước 2 đã cài sẵn một bản Python, có thể dùng `venv` ngay trong Terminal thường (không cần `conda activate` trước); nếu muốn dùng `venv` hoàn toàn độc lập, không qua conda, cần tải Python riêng tại [python.org/downloads](https://www.python.org/downloads/).
   - Trong thư mục dự án, tạo môi trường ảo tên `myenv`:
     ```
     python -m venv myenv
     ```
     Lệnh này tạo ra một thư mục con `myenv\` chứa bản Python riêng cho dự án.
   - Kích hoạt (PowerShell):
     ```
     .\myenv\Scripts\Activate.ps1
     ```
     Nhận biết đã kích hoạt qua chữ `(myenv)` ở đầu dòng lệnh, giống conda. Xem mục **Lỗi thường gặp** bên dưới nếu PowerShell báo lỗi chặn script.
   - Thoát ra bằng lệnh:
     ```
     deactivate
     ```

5. **Cài thử một thư viện cơ bản để kiểm tra.**
   - Dù dùng conda environment (bước 3) hay venv (bước 4), sau khi đã **activate** (thấy `(myenv)` ở đầu dòng lệnh), cài thử 2 thư viện data science cơ bản bằng `pip` (đã có sẵn trong cả 2 loại môi trường):
     ```
     pip install numpy pandas
     ```

## ✅ Kiểm tra đã thành công

- `conda --version` ra số phiên bản (dạng `conda 2x.x.x`), không báo lỗi `not recognized`.
- `conda env list` liệt kê thấy `myenv` trong danh sách.
- Sau khi activate (conda hoặc venv), dòng lệnh hiện tiền tố `(myenv)` phía trước đường dẫn.
- Chạy lệnh sau trong môi trường đã activate, ra đúng 2 số phiên bản, không báo lỗi `ModuleNotFoundError`:
  ```
  python -c "import numpy, pandas; print(numpy.__version__, pandas.__version__)"
  ```

## ⚠️ Lỗi thường gặp

- Gõ `conda activate myenv` trong Terminal/PowerShell thường mà báo `CommandNotFoundError: Run 'conda init' before 'conda activate'`: conda chưa được "gắn" vào shell đang dùng. Chạy `conda init powershell`, sau đó **đóng hẳn và mở lại Terminal mới** rồi thử lại (bước này chỉ cần làm 1 lần).
- Kích hoạt venv bằng `.\myenv\Scripts\Activate.ps1` mà PowerShell báo đỏ dạng `... cannot be loaded because running scripts is disabled on this system`: do PowerShell mặc định chặn chạy script local. Chạy lệnh sau (chỉ ảnh hưởng user hiện tại, không cần quyền admin), rồi thử activate lại:
  ```
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
