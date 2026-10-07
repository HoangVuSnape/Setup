# Checklist: Setup máy Windows 11 (Chuẩn cho AI/ML)

Tick từng bước khi hoàn thành. Xem chi tiết ở file tương ứng.

- [ ] **Bước 1 — Chuẩn bị & Cài đặt hệ điều hành** (xem [01-fresh-install.md](01-fresh-install.md))
  - Backup dữ liệu, lưu BitLocker Recovery Key, chuẩn bị sẵn driver Wi-Fi/LAN.
  - Cài mới / Reset Windows 11, cập nhật Windows Update đầy đủ.
  - Cài driver GPU (NVIDIA Game Ready / Studio) và kiểm tra kích hoạt bản quyền.
- [ ] **Bước 2 — Công cụ cơ bản & Tinh chỉnh Windows** (xem [02-essentials.md](02-essentials.md))
  - Dùng `winget`, trình duyệt, 7-Zip, hiện đuôi file, Dark Mode.
- [ ] **Bước 3 — Git, GitHub SSH, GitHub CLI, VS Code** (xem [03-dev-tools.md](03-dev-tools.md))
  - Cấu hình danh tính Git với email verified, SSH key + bảo vệ private key.
  - Cấu hình Git dùng SSH mặc định, đăng nhập GitHub CLI (`gh`).
  - Cài VS Code + extension (Python, WSL, Containers, Jupyter, GitLens).
- [ ] **Bước 4 — Môi trường Python (Miniconda / uv)** (xem [04-python-env.md](04-python-env.md))
  - Cài Miniconda **không add vào PATH**, chạy `conda init powershell`.
  - Tạo environment `ai-env` với **Python 3.11 hoặc 3.12** (chuẩn tương thích AI/ML).
  - Dùng `python -m pip install` và quản lý qua `requirements.txt`.
- [ ] **Bước 5 — WSL2 & Docker Desktop** (xem [05-wsl2-docker.md](05-wsl2-docker.md))
  - Bật ảo hóa, cài WSL2 (Ubuntu), chạy `apt update && apt upgrade`.
  - Cài Docker Desktop (WSL2 backend), bật WSL Integration, cấu hình giới hạn tài nguyên (`.wslconfig`) và dọn dẹp container.
- [ ] **Bước 6 — AI/ML: PyTorch, JupyterLab, Ollama & Smoke Test** (xem [06-ai-ml.md](06-ai-ml.md))
  - Kiểm tra `nvidia-smi`, tra cứu lệnh cài PyTorch CUDA mới nhất trên trang chủ.
  - Cài JupyterLab, đăng ký kernel `ai-env` qua `ipykernel`.
  - Cài Ollama, cấu hình thư mục model `OLLAMA_MODELS` tránh đầy ổ C, xác nhận GPU chạy LLM.
  - Chạy smoke test toàn hệ thống xác nhận CUDA, Tensor, Docker, Jupyter hoạt động hoàn hảo.

