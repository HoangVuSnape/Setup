# Cài công cụ AI/ML: JupyterLab, PyTorch, Ollama

## Mục tiêu

Sau bước này, máy có đủ bộ công cụ cơ bản để học và thử nghiệm AI/ML: chạy được JupyterLab để viết code dạng notebook, cài xong PyTorch (framework deep learning chính) đúng bản phù hợp với phần cứng, cài các thư viện data science nền tảng (`numpy`, `pandas`, `scikit-learn`), và chạy thử được một mô hình ngôn ngữ (LLM) ngay trên máy bằng Ollama — không cần tài khoản hay API key của bên nào.

## Các bước

1. **Kích hoạt lại conda environment `myenv`.**
   - Tất cả các bước cài đặt bằng `pip` dưới đây cần chạy **bên trong** environment `myenv` đã tạo ở file `04-python-env.md` (không tạo environment mới). Mở Terminal, chạy:
     ```
     conda activate myenv
     ```
     Kiểm tra thấy tiền tố `(myenv)` ở đầu dòng lệnh trước khi làm tiếp các bước sau.

2. **Cài JupyterLab — môi trường viết code Python dạng "notebook".**
   - Notebook là kiểu file code đặc biệt, chạy từng đoạn nhỏ (cell) một và thấy kết quả (số liệu, bảng, biểu đồ) ngay bên dưới đoạn code đó — rất phổ biến khi học/thử nghiệm AI/ML vì dễ thử-sai từng bước thay vì chạy lại cả file mỗi lần. JupyterLab là bản giao diện đầy đủ (nhiều tab, file explorer...) thay cho Jupyter Notebook cũ hơn.
   - Cài bằng `pip` (đang ở trong `myenv`):
     ```
     pip install jupyterlab
     ```
   - Chạy JupyterLab:
     ```
     jupyter lab
     ```
     Lệnh này tự mở tab trình duyệt trỏ tới địa chỉ dạng `http://localhost:8888/lab` — đây là giao diện JupyterLab chạy ngay trên máy (không phải dịch vụ online), Terminal đang chạy lệnh này phải để mở, đóng Terminal sẽ tắt luôn JupyterLab. Nhấn `Ctrl+C` trong Terminal (rồi gõ `y` nếu được hỏi) để tắt khi dùng xong.

3. **Cài PyTorch — framework deep learning chính.**
   - PyTorch có nhiều bản cài khác nhau tuỳ máy có GPU NVIDIA (chạy AI nhanh hơn nhiều nhờ CUDA) hay không (chạy bằng CPU, chậm hơn nhưng chạy được trên mọi máy). Lệnh cài **thay đổi thường xuyên** theo từng bản PyTorch/CUDA mới, nên **luôn lấy lệnh chính xác từ trang chọn chính thức** thay vì chỉ chép nguyên lệnh ví dụ dưới đây nếu đang đọc file này sau ngày viết khá lâu:
     - Vào [pytorch.org/get-started/locally](https://pytorch.org/get-started/locally/), ở phần **"Start Locally"** chọn lần lượt: **PyTorch Build** = Stable, **Your OS** = Windows, **Package** = Pip, **Language** = Python, **Compute Platform** = một bản CUDA (nếu máy có GPU NVIDIA) hoặc CPU (nếu không có, hoặc dùng GPU hãng khác như AMD/Intel — PyTorch trên Windows không hỗ trợ tốt các hãng đó ngoài CPU). Trang sẽ hiện đúng lệnh `pip install ...` để chép và chạy.
   - Ví dụ lệnh tại thời điểm viết file này (9/2026, PyTorch 2.14, CUDA 13.0) — **chỉ dùng để tham khảo cấu trúc lệnh**, ưu tiên lệnh lấy trực tiếp từ trang trên:
     - Có GPU NVIDIA (bản CUDA 13.0):
       ```
       pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130
       ```
     - Không có GPU NVIDIA (bản CPU-only):
       ```
       pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
       ```
   - Python 3.13 (bản đang dùng trong `myenv`) được PyTorch hỗ trợ đầy đủ tính đến thời điểm viết bài (PyTorch yêu cầu tối thiểu Python 3.10).
   - Kiểm tra cài đúng bản (xem mục **Kiểm tra đã thành công** bên dưới).

4. **Cài các thư viện AI/ML/data science cơ bản còn lại.**
   - `numpy` và `pandas` đã cài thử ở file `04-python-env.md`; ở đây cài thêm `scikit-learn` (thư viện machine learning cổ điển: hồi quy, phân loại, clustering...) và chạy lại luôn cả 3 gói cho chắc (đã cài rồi thì `pip` chỉ báo "already satisfied", không cài đè lại mất công):
     ```
     pip install numpy pandas scikit-learn
     ```

5. **Giới thiệu Ollama — chạy thử một AI chatbot (LLM) ngay trên máy, chạy offline.**
   - Ollama là công cụ tải và chạy các mô hình ngôn ngữ (LLM) mã nguồn mở (như Llama, Gemma, Qwen...) trực tiếp trên máy, không cần gửi dữ liệu lên server ngoài hay trả phí API — phù hợp để làm quen cách LLM hoạt động trước khi dùng tới các API trả phí (OpenAI, Anthropic...).
   - Tải bộ cài tại trang chính thức: [ollama.com/download/windows](https://ollama.com/download/windows) (file `OllamaSetup.exe`, không cần quyền Administrator để cài).
   - Mở file `.exe` vừa tải, cửa sổ cài đặt hiện ra chỉ có một nút **Install** (bộ cài Ollama rất gọn, không có màn hình chọn tuỳ chọn như Miniconda) — bấm **Install** rồi đợi xong. Cài xong Ollama tự chạy nền, có icon ở khay hệ thống (system tray, cạnh đồng hồ) — bản 2026 của Ollama còn kèm sẵn một cửa sổ chat GUI đơn giản mở được từ icon này, nhưng hướng dẫn dưới đây dùng Terminal cho nhất quán với các bước khác trong tài liệu.
   - Mở Terminal **mới** (không cần activate `myenv`, Ollama cài độc lập với Python/conda), kiểm tra cài thành công:
     ```
     ollama --version
     ```
   - Chạy thử model đầu tiên — `llama3.2` (tag mặc định trỏ tới bản 3B tham số, khoảng 2GB, đủ nhẹ để chạy trên hầu hết máy kể cả không có GPU rời, phù hợp làm model thử đầu tiên):
     ```
     ollama run llama3.2
     ```
     Lần chạy đầu tự tải model về (chờ tuỳ tốc độ mạng), xong vào thẳng khung chat — gõ câu hỏi bất kỳ rồi Enter để thử. Gõ `/bye` để thoát khung chat.
   - Máy yếu hơn hoặc muốn tải nhẹ/nhanh hơn nữa, có thể thử model nhỏ hơn: `ollama run gemma3:1b`. Xem thêm các model khác tại [ollama.com/library](https://ollama.com/library).

## ✅ Kiểm tra đã thành công

- `jupyter lab` mở được tab trình duyệt tại địa chỉ `http://localhost:8888/lab`, thấy giao diện JupyterLab (không phải trang lỗi "connection refused").
- Trong `myenv` đã activate, chạy được:
  ```
  python -c "import torch; print(torch.__version__, torch.cuda.is_available())"
  ```
  không báo `ModuleNotFoundError`. Nếu cài bản CUDA (có GPU NVIDIA), `torch.cuda.is_available()` phải in ra `True` — in ra `False` nghĩa là cài nhầm bản CPU, xem mục lỗi thường gặp bên dưới.
- Chạy được:
  ```
  python -c "import numpy, pandas, sklearn; print('ok')"
  ```
  in ra `ok`, không báo lỗi.
- `ollama --version` in ra số phiên bản, không báo lỗi `not recognized`.
- `ollama run llama3.2` tải xong model và cho gõ chat, trả lời được câu hỏi đơn giản (vd "Xin chào" hoặc "1+1 bằng mấy?").

## ⚠️ Lỗi thường gặp

- Quên `conda activate myenv` trước khi `pip install`: gói bị cài vào environment `base` (hoặc environment khác đang active) thay vì `myenv`, sau đó chạy code trong `myenv` báo `ModuleNotFoundError` dù rõ ràng đã cài. Luôn kiểm tra thấy `(myenv)` ở đầu dòng lệnh trước khi `pip install`.
- Máy có GPU NVIDIA nhưng lỡ cài nhầm bản CPU-only của PyTorch (hoặc quên `--index-url`, cài phải bản CPU mặc định từ PyPI): `torch.cuda.is_available()` trả về `False`, code chạy được nhưng chậm vì không dùng GPU. Gỡ bản cũ rồi cài lại đúng bản CUDA từ trang chọn:
  ```
  pip uninstall torch torchvision torchaudio
  ```
  rồi chạy lại lệnh CUDA lấy từ [pytorch.org/get-started/locally](https://pytorch.org/get-started/locally/).
- Cài đúng bản CUDA nhưng driver GPU của máy quá cũ so với bản CUDA đó: lỗi thường có dòng nhắc tới "CUDA driver version is insufficient" khi `import torch` hoặc gọi hàm liên quan tới GPU. Cập nhật driver NVIDIA (đã nói ở file `01-fresh-install.md`) qua NVIDIA App/GeForce Experience, hoặc chọn bản CUDA thấp hơn ở trang chọn PyTorch.
- Lần đầu mở Ollama (hoặc lần đầu `ollama run`), Windows Firewall hiện popup hỏi cho phép kết nối mạng: bấm **Allow access** (ít nhất cho mạng private) — Ollama chạy một server nội bộ ở `localhost:11434`, chặn popup này sẽ làm các lệnh `ollama run`/app dùng Ollama không kết nối được.
- `ollama run <model>` bị treo lâu ở bước tải model (model vài GB, mạng chậm): đợi thêm hoặc thử model nhỏ hơn như `gemma3:1b` trước, tải nhanh hơn nhiều để kiểm tra Ollama hoạt động đúng trước khi tải model lớn hơn.

