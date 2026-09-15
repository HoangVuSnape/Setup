# Cài Git, kết nối GitHub qua SSH, và VS Code

## Mục tiêu

Sau bước này, máy có Git đã cấu hình sẵn danh tính, có SSH key kết nối được với tài khoản GitHub (không cần gõ mật khẩu mỗi lần push/pull code), có VS Code cùng các extension cần thiết cho việc học Python/Docker/WSL sau này, và có Windows Terminal để làm việc dòng lệnh.

## Các bước

1. **Cài Git bằng winget.**
   ```
   winget install --id Git.Git -e
   ```
   Cài xong, đóng và mở lại Terminal để lệnh `git` được nhận diện (winget vừa thêm Git vào PATH).

2. **Cấu hình danh tính cho Git.**
   - Vì sao cần: mỗi lần commit code, Git gắn tên và email này vào để biết ai là tác giả thay đổi. Thay `"Tên"` và `"email"` bằng thông tin thật của bạn (nên dùng đúng email sẽ dùng cho tài khoản GitHub ở bước sau).
     ```
     git config --global user.name "Tên"
     git config --global user.email "email@example.com"
     ```
   - Xem lại đã cấu hình đúng chưa:
     ```
     git config --global --list
     ```

3. **Tạo tài khoản GitHub (bỏ qua nếu đã có).**
   - Vào [github.com](https://github.com), bấm **Sign up**, làm theo hướng dẫn (nhập email, đặt mật khẩu, chọn username, xác minh email).

4. **Tạo SSH key.**
   - SSH key là một cặp khóa mật mã — khóa riêng (private key) giữ bí mật trên máy, khóa công khai (public key) đưa cho GitHub — giúp máy xác thực với GitHub mà không cần gõ mật khẩu mỗi lần push/pull.
   - Trong Terminal, chạy (thay email bằng email tài khoản GitHub của bạn):
     ```
     ssh-keygen -t ed25519 -C "email@example.com"
     ```
   - Lệnh sẽ hỏi 3 câu, cứ nhấn `Enter` để dùng mặc định (lưu ở vị trí mặc định `C:\Users\<tên user>\.ssh\id_ed25519`, không đặt passphrase — đơn giản cho máy cá nhân; nếu muốn bảo mật hơn có thể đặt passphrase).

5. **Thêm public key vào GitHub.**
   - Copy nội dung file public key (`id_ed25519.pub`, **không phải** file không có đuôi `.pub` — đó là private key, tuyệt đối không chia sẻ) vào clipboard:
     ```
     Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | clip
     ```
   - Trên GitHub: bấm ảnh đại diện (góc trên phải) > **Settings** > mục **SSH and GPG keys** (sidebar bên trái) > bấm **New SSH key**.
   - Điền **Title** (tên gợi nhớ máy này, ví dụ "PC Windows học AI"), giữ **Key type** là **Authentication Key**, dán key vào ô **Key** (`Ctrl+V`), bấm **Add SSH key**.

6. **Test kết nối SSH với GitHub.**
   ```
   ssh -T git@github.com
   ```
   Lần đầu sẽ hỏi có tin tưởng địa chỉ `github.com` không (fingerprint) — gõ `yes` rồi Enter.

7. **Cài VS Code bằng winget.**
   ```
   winget install --id Microsoft.VisualStudioCode -e
   ```

8. **Cài các extension gợi ý cho VS Code.**
   - Có thể cài qua giao diện (mở VS Code, vào tab **Extensions** ở sidebar trái, gõ tên tìm) hoặc nhanh hơn bằng dòng lệnh `code` (mở Terminal mới sau khi cài VS Code xong):
     ```
     code --install-extension ms-python.python
     code --install-extension eamodio.gitlens
     code --install-extension ms-azuretools.vscode-containers
     code --install-extension ms-vscode-remote.remote-wsl
     code --install-extension ms-toolsai.jupyter
     ```
   - Ý nghĩa từng extension:
     - `ms-python.python` — **Python**: chạy/debug code Python, hỗ trợ IntelliSense.
     - `eamodio.gitlens` — **GitLens**: xem lịch sử, ai sửa dòng nào (blame), so sánh commit ngay trong VS Code.
     - `ms-azuretools.vscode-containers` — **Container Tools**: quản lý Docker container/image (extension "Docker" cũ đã được thay bằng extension này, xem mục Lỗi thường gặp).
     - `ms-vscode-remote.remote-wsl` — **Remote - WSL**: mở và code trực tiếp trong môi trường Linux (WSL2) từ VS Code trên Windows — sẽ dùng ở bước cài WSL2 sau này.
     - `ms-toolsai.jupyter` — **Jupyter**: mở và chạy file `.ipynb` (Jupyter Notebook) ngay trong VS Code.

9. **Windows Terminal.**
   - Windows 11 thường đã có sẵn Windows Terminal (đây cũng là app đã dùng để chạy các lệnh ở trên). Nếu kiểm tra không thấy trong Start Menu, cài bằng:
     ```
     winget install --id Microsoft.WindowsTerminal -e
     ```

## ✅ Kiểm tra đã thành công

- `git --version` ra số phiên bản, không báo lỗi `not recognized`.
- `git config --global --list` hiện đúng `user.name` và `user.email` vừa đặt.
- `ssh -T git@github.com` trả về dòng dạng `Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.` (thấy đúng username GitHub của mình là thành công, không cần lo về chữ "does not provide shell access").
- `code --version` ra số phiên bản; gõ `code --list-extensions` thấy đủ 5 id vừa cài (`ms-python.python`, `eamodio.gitlens`, `ms-azuretools.vscode-containers`, `ms-vscode-remote.remote-wsl`, `ms-toolsai.jupyter`).
- Mở Start Menu gõ `Terminal`, app Windows Terminal xuất hiện và mở được.

## ⚠️ Lỗi thường gặp

- `ssh -T git@github.com` báo `Permission denied (publickey)`: thường do dán nhầm file (dán private key thay vì `.pub`), dán thiếu/thừa ký tự khi copy public key, hoặc quên bấm **Add SSH key** sau khi dán. Kiểm tra lại đúng file `id_ed25519.pub` đã được thêm vào đúng mục **SSH and GPG keys** của đúng tài khoản GitHub.
- Tìm extension "Docker" trên VS Code Marketplace không thấy như hướng dẫn cũ trên mạng: Microsoft đã đổi tên/thay thế extension Docker cũ (`ms-azuretools.vscode-docker`) bằng **Container Tools** (`ms-azuretools.vscode-docker` giờ chỉ còn là một pack trỏ tới Container Tools) — cài đúng id `ms-azuretools.vscode-containers` như bước 8 ở trên là đủ, không cần cài thêm extension Docker cũ.
