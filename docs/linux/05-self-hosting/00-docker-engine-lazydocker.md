# Cài Docker Engine và lazydocker

## Mục tiêu

Sau bước này, máy Linux chạy **Docker Engine** trực tiếp như một service của hệ thống, không cài Docker Desktop. Bạn cũng có `lazydocker` — giao diện Terminal để xem và quản lý container, image, volume và log Docker dễ hơn.

Docker Engine sẽ dùng cho các ứng dụng self-host chạy bằng container sau này. `lazydocker` chỉ là công cụ điều khiển Docker; nó không thay thế Docker Engine và không tự chạy container nếu Docker Engine chưa được cài.

> **Lưu ý về Linux Mint:** Docker công bố hướng dẫn repository cho Ubuntu. Linux Mint dựa trên Ubuntu nên tài liệu này dùng đúng repository Ubuntu tương ứng được hệ thống cung cấp qua `UBUNTU_CODENAME`. Nếu bạn đang dùng bản Mint không dựa trên Ubuntu hoặc kiến trúc không phải `amd64`/`arm64`, dừng lại và kiểm tra lại trước khi chạy các lệnh cài đặt.

## Các bước

1. **Đảm bảo đã có kết nối mạng và mở Terminal.**
   - Có thể mở Terminal trực tiếp trên máy Linux hoặc kết nối qua SSH từ máy Windows theo [03-remote-access.md](../03-remote-access.md).
   - Các lệnh có `sudo` sẽ hỏi mật khẩu đăng nhập Linux. Khi gõ mật khẩu, Terminal không hiện ký tự nào; đó là bình thường.

2. **Thêm Docker repository chính thức.**
   - Docker repository là nơi `apt` tải Docker Engine và các plugin chính thức. Chạy lần lượt:
     ```
     sudo apt update
     sudo apt install -y ca-certificates curl
     sudo install -m 0755 -d /etc/apt/keyrings
     sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
     sudo chmod a+r /etc/apt/keyrings/docker.asc
     ```
   - Thêm repository tương ứng với nền Ubuntu của Linux Mint:
     ```
     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
     sudo apt update
     ```
   - Không dùng các lệnh cài `docker-desktop` hoặc Docker Desktop trong tài liệu này. Docker Engine chạy nền trực tiếp trên Linux và nhẹ hơn cho mục đích server.

3. **Cài Docker Engine và Docker Compose plugin.**
   - Chạy:
     ```
     sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     ```
   - Kiểm tra service Docker đã chạy:
     ```
     sudo systemctl status docker --no-pager
     ```
   - Nếu màn hình mở trình xem trạng thái, nhấn `q` để quay lại Terminal. Dòng trạng thái cần có `active (running)`.

4. **Chạy Docker bằng user hiện tại, không cần gõ `sudo` mỗi lần.**
   - Docker daemon vẫn chạy với quyền hệ thống, nhưng thêm user hiện tại vào group `docker` giúp dùng lệnh Docker thuận tiện hơn:
     ```
     sudo usermod -aG docker $USER
     ```
   - Đăng xuất rồi đăng nhập lại (hoặc khởi động lại máy) để group mới có hiệu lực. Sau đó kiểm tra:
     ```
     docker run hello-world
     ```
   - Lệnh này tải image nhỏ từ Docker Hub, chạy một container kiểm tra rồi in thông báo thành công. Sau khi kiểm tra xong, image/container kiểm tra này có thể xoá bằng:
     ```
     docker system prune
     ```
     Khi được hỏi xác nhận, gõ `y`. Không dùng lệnh này nếu máy đã có container/image muốn giữ lại.

5. **Cài `lazydocker` từ GitHub Releases.**
   - `lazydocker` là một terminal UI mã nguồn mở của [jesseduffield/lazydocker trên GitHub](https://github.com/jesseduffield/lazydocker), dùng để quản lý Docker và Docker Compose bằng giao diện bàn phím. Script cài đặt dưới đây là script do chính repository đó cung cấp:
     ```
     sudo apt install -y curl tar
     mkdir -p ~/.local/bin
     curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh -o /tmp/install_lazydocker.sh
     bash /tmp/install_lazydocker.sh
     rm /tmp/install_lazydocker.sh
     ```
   - Thêm thư mục cài đặt vào `PATH` nếu lệnh chưa được nhận diện:
     ```
     echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
     export PATH="$HOME/.local/bin:$PATH"
     ```
   - Kiểm tra phiên bản:
     ```
     lazydocker --version
     ```

6. **Mở lazydocker để làm quen.**
   - Chạy lệnh:
     ```
     lazydocker
     ```
   - Chọn container bằng phím mũi tên; xem log, restart hoặc stop bằng các phím tắt hiển thị trong giao diện. Nhấn `q` để thoát.
   - Chỉ chạy `lazydocker` khi cần quản lý Docker; nó không phải service chạy nền nên không làm máy nặng thêm khi không mở.

## ✅ Kiểm tra đã thành công

- `systemctl status docker --no-pager` hiển thị `active (running)`.
- `docker run hello-world` in thông báo Docker đã chạy thành công.
- `docker compose version` in ra phiên bản Docker Compose plugin.
- `lazydocker --version` in ra phiên bản và `lazydocker` mở được giao diện Terminal.
- Không cần Docker Desktop; Docker Engine tự khởi động cùng hệ thống qua service `docker`.

## ⚠️ Lỗi thường gặp

- `docker: permission denied` sau khi đã chạy `usermod`: user chưa đăng nhập lại. Đăng xuất rồi đăng nhập lại, hoặc khởi động lại máy, sau đó chạy lại lệnh.
- `Package docker-ce has no installation candidate`: repository chưa được thêm đúng hoặc `UBUNTU_CODENAME` không được Docker hỗ trợ. Kiểm tra lại bằng `cat /etc/os-release`, chạy lại `sudo apt update`, không cài một gói Docker không rõ nguồn gốc để thay thế.
- `Cannot connect to the Docker daemon`: kiểm tra `sudo systemctl status docker --no-pager`; nếu service chưa chạy, dùng `sudo systemctl start docker` rồi kiểm tra lại.
- `lazydocker: command not found`: chạy `export PATH="$HOME/.local/bin:$PATH"` rồi thử lại. Nếu muốn áp dụng cho Terminal mới, kiểm tra dòng `export PATH` đã có trong `~/.bashrc`.
- Máy yếu bị đầy ổ đĩa sau khi chạy nhiều container/image: xem dung lượng bằng `docker system df`; chỉ dọn các resource không còn dùng sau khi kiểm tra kỹ, vì xoá image có thể khiến lần chạy sau phải tải lại.
