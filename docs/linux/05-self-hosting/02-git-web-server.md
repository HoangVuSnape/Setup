# Tự host Git server bằng Gitea

## Mục tiêu

Sau bước này, máy Linux chạy Gitea — một Git server nhẹ có giao diện web, phù hợp để lưu các repository cá nhân trong mạng nội bộ. Gitea sẽ tự khởi động cùng máy, dùng SQLite tích hợp sẵn nên không cần cài thêm database riêng.

## Các bước

1. **Hiểu Gitea và chọn cách cài đặt.**
   - Gitea là một Git server mã nguồn mở, có giao diện web giống một phiên bản GitHub nhỏ gọn. Bạn có thể tạo repository, xem code, commit, issue và quản lý tài khoản ngay trên máy Linux của mình.
   - File này dùng cách cài **binary trực tiếp + systemd**, không dùng Docker. Cách này phù hợp máy yếu vì không cần chạy thêm Docker Engine và database container.
   - Các lệnh dưới đây dùng cho Linux Mint 22.x 64-bit trên máy Intel/AMD. Nếu máy là ARM hoặc 32-bit, phải chọn binary khác trên [trang download chính thức](https://dl.gitea.com/gitea/).

2. **Kiểm tra Git và tải Gitea.**
   - Gitea yêu cầu Git phiên bản 2.0 trở lên. Kiểm tra trước:
     ```
     git --version
     ```
   - Tại thời điểm viết tài liệu này (09/2026), bản stable được dùng là **Gitea 1.27.3**. Tải binary `linux-amd64` từ máy chủ chính thức:
     ```
     cd /tmp
     wget -O gitea https://dl.gitea.com/gitea/1.27.3/gitea-1.27.3-linux-amd64
     chmod +x gitea
     ```
   - Nếu trang chính thức đã có bản mới hơn khi bạn cài, thay cả số phiên bản trong URL và tên file theo bản mới đó. Không tải binary từ website không rõ nguồn gốc.

3. **Tạo user riêng để chạy Gitea.**
   - Không nên chạy Gitea bằng user cá nhân hoặc bằng `root`. Tạo một system user tên `git`:
     ```
     sudo adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
     ```
   - Copy binary vào vị trí dùng chung:
     ```
     sudo cp /tmp/gitea /usr/local/bin/gitea
     sudo chmod 755 /usr/local/bin/gitea
     ```
   - Kiểm tra binary:
     ```
     /usr/local/bin/gitea --version
     ```

4. **Tạo thư mục dữ liệu và cấu hình.**
   - Gitea lưu repository, database SQLite, file cấu hình và log ở các thư mục riêng. Chạy lần lượt:
     ```
     sudo mkdir -p /var/lib/gitea/{custom,data,log}
     sudo chown -R git:git /var/lib/gitea/
     sudo chmod -R 750 /var/lib/gitea/
     sudo mkdir -p /etc/gitea
     sudo chown root:git /etc/gitea
     sudo chmod 770 /etc/gitea
     ```
   - Quyền ghi `770` trên `/etc/gitea` chỉ cần trong lúc web installer tạo file cấu hình. Sau khi cài đặt xong, file này sẽ được khoá lại ở bước 7.

5. **Tạo systemd service để Gitea tự chạy khi bật máy.**
   - Mở file service bằng `nano`:
     ```
     sudo nano /etc/systemd/system/gitea.service
     ```
   - Dán toàn bộ nội dung sau:
     ```ini
     [Unit]
     Description=Gitea (Git with a cup of tea)
     After=network.target

     [Service]
     Type=simple
     User=git
     Group=git
     WorkingDirectory=/var/lib/gitea/
     ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
     Restart=always
     RestartSec=2s
     Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

     [Install]
     WantedBy=multi-user.target
     ```
   - Lưu bằng `Ctrl+O`, bấm `Enter`, rồi thoát bằng `Ctrl+X`.
   - Nạp service mới, bật tự khởi động và chạy ngay:
     ```
     sudo systemctl daemon-reload
     sudo systemctl enable --now gitea
     ```

6. **Mở trình cài đặt Gitea lần đầu.**
   - Lấy IP của máy Linux nếu chưa nhớ:
     ```
     hostname -I
     ```
   - Trên máy Windows, mở trình duyệt và truy cập:
     ```
     http://<ip-máy-linux>:3000
     ```
     Ví dụ: `http://192.168.1.50:3000`.
   - Trong trang **Install Gitea** giữ các lựa chọn chính sau:
     - **Database Type**: `SQLite3`.
     - **Path**: giữ đường dẫn mặc định do Gitea đề xuất trong `/var/lib/gitea/data`.
     - **Server Domain**: nhập IP hoặc tên máy Linux trong mạng nội bộ.
     - **Gitea Base URL**: nhập `http://<ip-máy-linux>:3000/`.
     - **SSH Server Port**: nhập `222`. Cổng `22` đã dành cho OpenSSH dùng để SSH quản trị máy Linux.
     - **Gitea HTTP Listen Port**: giữ `3000`.
   - Bấm **Install Gitea** và đợi trang hoàn tất. Lần đầu cài có thể mất một lúc vì Gitea tạo database SQLite và các thư mục cần thiết.

7. **Tạo tài khoản administrator đầu tiên và khoá cấu hình.**
   - Ở phần tạo tài khoản đầu tiên, nhập username, email và mật khẩu đủ mạnh. Tài khoản này là administrator của Gitea, không nhất thiết phải trùng với user Linux `git`.
   - Đăng nhập bằng tài khoản vừa tạo, thử tạo một repository rỗng để xác nhận giao diện hoạt động.
   - Sau khi web installer hoàn tất, khoá thư mục cấu hình theo khuyến nghị của Gitea:
     ```
     sudo chmod 750 /etc/gitea
     sudo chmod 640 /etc/gitea/app.ini
     ```

8. **Kiểm tra service và thử clone repository.**
   - Kiểm tra Gitea đang chạy:
     ```
     sudo systemctl status gitea
     ```
     Cần thấy `Active: active (running)`. Bấm `q` để thoát màn hình status.
   - Xem log nếu cần:
     ```
     sudo journalctl -u gitea -n 50 --no-pager
     ```
   - Từ máy Windows, dùng URL clone HTTPS mà Gitea hiển thị, có dạng:
     ```
     git clone http://<ip-máy-linux>:3000/<username>/<repository>.git
     ```
   - Khi cần cập nhật Gitea, backup `/var/lib/gitea` và thay binary `/usr/local/bin/gitea` bằng bản mới, sau đó chạy:
     ```
     sudo systemctl restart gitea
     ```

## ✅ Kiểm tra đã thành công

- Truy cập được `http://<ip-máy-linux>:3000` từ máy Windows.
- Đăng nhập được tài khoản administrator và tạo được repository đầu tiên.
- `sudo systemctl status gitea` hiện `Active: active (running)`.
- Sau khi khởi động lại máy Linux, Gitea tự chạy lại và trang web vẫn truy cập được.
- Clone được repository từ URL HTTPS mà Gitea cung cấp.

## ⚠️ Lỗi thường gặp

- Trình duyệt báo không kết nối được tới port `3000`: kiểm tra `sudo systemctl status gitea`, lấy lại IP bằng `hostname -I`, và bảo đảm máy Windows cùng mạng nội bộ với máy Linux.
- Service báo `permission denied` hoặc tự dừng: kiểm tra lại user `git` sở hữu `/var/lib/gitea` bằng `sudo chown -R git:git /var/lib/gitea/`, sau đó chạy `sudo systemctl restart gitea`.
- Gitea báo port `3000` đã được sử dụng: xem tiến trình đang dùng port bằng `sudo ss -ltnp | grep ':3000'`, rồi đổi HTTP port trong file `/etc/gitea/app.ini` hoặc dừng service đang chiếm port.
- Web installer không ghi được cấu hình: tạm đặt lại quyền bằng `sudo chmod 770 /etc/gitea`, chạy lại installer, sau đó nhớ thực hiện bước 7 để khoá quyền.
- Không clone được bằng SSH: Gitea dùng SSH port `222`, không phải port `22` của OpenSSH hệ thống. Dùng URL SSH do Gitea hiển thị hoặc cấu hình SSH client chỉ rõ port `222`.
- Binary báo không tương thích: kiểm tra kiến trúc bằng `uname -m`. Máy Intel/AMD 64-bit cần file `linux-amd64`; máy ARM cần chọn file `linux-arm64` tương ứng.
