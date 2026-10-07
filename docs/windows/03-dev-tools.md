# Cài Git, kết nối GitHub qua SSH, GitHub CLI và VS Code

## Mục tiêu

Sau bước này, máy có Git đã cấu hình danh tính đúng (email verified), có SSH key bảo mật kết nối với GitHub, cấu hình tự động dùng SSH thay vì HTTPS khi clone, cài và đăng nhập GitHub CLI (`gh`), cài VS Code với các extension cần thiết cho Python/Docker/WSL/Jupyter, và có Windows Terminal.

## Các bước

1. **Cài Git và GitHub CLI bằng winget.**
   - [PowerShell - Windows]:
     ```powershell
     winget install --id Git.Git -e
     winget install --id GitHub.cli -e
     ```
   - Cài xong, đóng và mở lại Terminal mới để lệnh `git` và `gh` được nhận diện.

2. **Cấu hình danh tính cho Git.**
   - Mỗi lần commit code, Git sẽ gắn tên và email này vào.
   - **Lưu ý quan trọng:** Email cấu hình phải là **email đã được xác minh (verified)** trong tài khoản GitHub của bạn để các commit được tính đóng góp (contribution graph) đúng chính chủ.
   - [PowerShell - Windows]:
     ```powershell
     git config --global user.name "Tên Của Bạn"
     git config --global user.email "email-da-verified@example.com"
     ```
   - Kiểm tra lại cấu hình:
     ```powershell
     git config --global --get user.name
     git config --global --get user.email
     ```

3. **Tạo tài khoản GitHub (bỏ qua nếu đã có).**
   - Vào [github.com](https://github.com), đăng ký tài khoản và hoàn tất xác minh email trong hộp thư đến.

4. **Tạo SSH key và bảo mật Private Key.**
   - SSH key là một cặp khóa mật mã: **Private key** (khóa riêng, giữ bí mật tuyệt đối trên máy) và **Public key** (khóa công khai, đưa lên GitHub).

   > [!CAUTION]
   > **Quy tắc an toàn bảo mật:**
   > - **TUYỆT ĐỐI KHÔNG BAO GIỜ** chia sẻ private key (`id_ed25519`), không upload lên GitHub, Google Drive hay dán vào cửa sổ chat AI.
   > - Nếu là máy laptop dùng nghiên cứu/dự án cơ quan: **Khuyến nghị đặt passphrase** khi tạo key. Nếu là máy bàn cá nhân chỉ dùng học tập tại nhà: có thể nhấn Enter để trống passphrase cho tiện lợi.

   - [PowerShell - Windows]: Chạy lệnh tạo key chuẩn `ed25519` (thay bằng email GitHub của bạn):
     ```powershell
     ssh-keygen -t ed25519 -C "email-da-verified@example.com"
     ```
   - Nhấn `Enter` để lưu ở đường dẫn mặc định (`$env:USERPROFILE\.ssh\id_ed25519`). Nhập passphrase (hoặc Enter để trống).

5. **Thêm Public Key vào GitHub.**
   - [PowerShell - Windows]: Copy nội dung file public key (`id_ed25519.pub` — **chỉ file có đuôi `.pub`**):
     ```powershell
     Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | clip
     ```
   - Trên trình duyệt: Vào GitHub > **Settings** (góc trên bên phải) > **SSH and GPG keys** > bấm **New SSH key**.
   - Đặt Title gợi nhớ (vd: `Laptop-RTX4050-Win11`), Key type chọn `Authentication Key`, dán (`Ctrl + V`) nội dung vào ô Key và bấm **Add SSH key**.

6. **Test kết nối SSH và Cấu hình Git luôn dùng SSH.**
   - [PowerShell - Windows]: Kiểm tra kết nối với GitHub:
     ```powershell
     ssh -T git@github.com
     ```
     *(Lần đầu sẽ hỏi xác nhận fingerprint của github.com, gõ `yes` rồi Enter).*
   - **Tự động chuyển mọi URL `https://github.com/` sang SSH:** Giúp bạn khi clone link HTTPS bất kỳ trên mạng thì Git vẫn tự động dùng SSH key để push/pull mà không bị hỏi mật khẩu hay token:
     ```powershell
     git config --global url."git@github.com:".insteadOf "https://github.com/"
     ```

7. **Đăng nhập và kiểm tra GitHub CLI (`gh`).**
   - GitHub CLI giúp tạo repo, clone, quản lý pull request, issue trực tiếp từ terminal.
   - [PowerShell - Windows]:
     ```powershell
     gh --version
     gh auth login
     ```
   - Khi chạy `gh auth login`, chọn các tùy chọn sau:
     - *What account do you want to log into?* → **GitHub.com**
     - *What is your preferred protocol for Git operations?* → **SSH**
     - *Generate a new SSH key to add to your GitHub account?* → **No** (hoặc chọn public key vừa tạo)
     - *How would you like to authenticate GitHub CLI?* → **Login with a web browser**
     - Nhấn Enter, copy mã code 8 ký tự hiện trên terminal, trình duyệt sẽ tự mở trang kích hoạt của GitHub, dán mã vào và bấm **Authorize**.
   - Kiểm tra trạng thái đăng nhập:
     ```powershell
     gh auth status
     ```

8. **Cài VS Code và các extension cần thiết.**
   - [PowerShell - Windows]:
     ```powershell
     winget install --id Microsoft.VisualStudioCode -e
     ```
   - Cài đặt các extension chính thức qua dòng lệnh:
     ```powershell
     code --install-extension ms-python.python
     code --install-extension ms-toolsai.jupyter
     code --install-extension ms-vscode-remote.remote-wsl
     code --install-extension ms-azuretools.vscode-containers
     code --install-extension eamodio.gitlens
     ```
   - *Giải thích:*
     - `ms-python.python`: Hỗ trợ linting, debugging, autocomplete cho Python.
     - `ms-toolsai.jupyter`: Chạy Jupyter Notebook `.ipynb` trực tiếp trong VS Code.
     - `ms-vscode-remote.remote-wsl`: Mở và làm việc trực tiếp trong nhân Ubuntu của WSL2.
     - `ms-azuretools.vscode-containers`: Quản lý Docker containers & images trực quan.
     - `eamodio.gitlens`: Xem lịch sử git blame, so sánh commit chi tiết.

9. **Windows Terminal.**
   - Windows 11 mặc định đã có sẵn Windows Terminal. Nếu máy chưa có, cài bằng:
     ```powershell
     winget install --id Microsoft.WindowsTerminal -e
     ```

---

## ✅ Kiểm tra đã thành công

- [PowerShell - Windows]:
  - `git --version` và `gh --version` đều in ra số phiên bản hợp lệ.
  - `git config --global --get user.email` hiện đúng email đã verified trên GitHub.
  - `ssh -T git@github.com` trả về: `Hi <username>! You've successfully authenticated...`
  - `gh auth status` báo: `Logged in to github.com as <username>`.
  - `code --list-extensions` hiển thị đủ các extension đã cài đặt.

---

## ⚠️ Lỗi thường gặp

- **`Permission denied (publickey)` khi test SSH:** Thường do copy nhầm file private key (không có `.pub`), copy bị thiếu ký tự, hoặc chưa bấm Add SSH key trên GitHub.
- **Git push bị hỏi mật khẩu HTTPS:** Đảm bảo đã chạy lệnh `git config --global url."git@github.com:".insteadOf "https://github.com/"`. Khi clone một dự án, kiểm tra bằng lệnh `git remote -v`, remote phải có dạng `git@github.com:username/repo.git`.
- **Extension Docker không tìm thấy:** Microsoft đã thay thế extension `ms-azuretools.vscode-docker` cũ bằng **Container Tools** (`ms-azuretools.vscode-containers`). Cài extension này là chuẩn nhất.

