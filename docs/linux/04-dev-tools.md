# Cài Git và làm quen nano — công cụ dòng lệnh cơ bản

## Mục tiêu

Sau bước này, máy Linux có Git đã cài và cấu hình danh tính giống như máy Windows (dùng để tự host Git/web server cá nhân ở file sau), và bạn biết dùng `nano` — trình soạn thảo văn bản dòng lệnh có sẵn — để mở/sửa các file cấu hình (config) trực tiếp qua Terminal khi cần. Máy Linux này **không** cần cài VS Code hay bộ công cụ AI/ML nặng — việc lập trình chính vẫn làm ở máy Windows, máy này chỉ cần đủ Git + vài lệnh Terminal cơ bản để tự quản trị chính nó với vai trò server.

## Các bước

1. **Cài Git bằng apt.**
   - Git là phần mềm quản lý phiên bản (version control) — cần ở đây chủ yếu để tự host Git/web server cá nhân (sẽ làm ở `05-self-hosting/02-git-web-server.md`) và để tải (clone)/cập nhật file cấu hình từ GitHub xuống máy Linux khi cần.
   - Gõ lệnh:
     ```
     sudo apt install -y git
     ```
   - Kiểm tra cài thành công:
     ```
     git --version
     ```
     ra kết quả dạng `git version 2.x.x`.

2. **Cấu hình danh tính cho Git — giống như đã làm ở máy Windows.**
   - Lý do: mỗi lần commit, Git gắn tên và email này vào để biết ai là tác giả thay đổi. Nên dùng lại đúng tên và email đã cấu hình ở máy Windows (xem `docs/windows/03-dev-tools.md`) để đồng bộ danh tính giữa 2 máy — thay `"Tên"` và `"email"` bằng thông tin thật:
     ```
     git config --global user.name "Tên"
     git config --global user.email "email@example.com"
     ```
   - Xem lại đã cấu hình đúng chưa:
     ```
     git config --global --list
     ```

3. **Làm quen `nano` — trình soạn thảo văn bản dòng lệnh có sẵn.**
   - `nano` đã được cài sẵn mặc định trên Linux Mint, không cần cài thêm gì. Đây là công cụ để mở và sửa trực tiếp các file văn bản/cấu hình ngay trong Terminal — sẽ dùng nhiều ở các bước self-host sau này (ví dụ sửa file cấu hình Samba, Gitea...), vì máy này chạy chủ yếu qua SSH/Terminal, không tiện mở app đồ hoạ như trên Windows.
   - Mở một file bằng nano (thay `<tên-file>` bằng đường dẫn file muốn sửa; nếu file chưa tồn tại, nano sẽ tự tạo file mới khi lưu):
     ```
     nano <tên-file>
     ```
   - Gõ/sửa nội dung bình thường như một trình soạn thảo văn bản — di chuyển con trỏ bằng phím mũi tên, không cần dùng chuột.
   - Các phím tắt cơ bản (ký hiệu `^` nano hiển thị ở thanh dưới cùng màn hình nghĩa là giữ phím `Ctrl`):
     - `Ctrl+O` (Write Out) — lưu file. Nano hỏi lại tên file ở dòng dưới cùng, bấm `Enter` để xác nhận giữ nguyên tên.
     - `Ctrl+X` (Exit) — thoát khỏi nano, quay lại dấu nhắc lệnh Terminal. Nếu có thay đổi chưa lưu, nano sẽ hỏi có muốn lưu không trước khi thoát (`Y` = lưu rồi thoát, `N` = thoát không lưu, `Ctrl+C` = huỷ, không thoát).
     - `Ctrl+G` (Get Help) — xem danh sách đầy đủ các phím tắt khác ngay trong nano nếu cần.

4. **Vì sao máy này không cần VS Code hay bộ công cụ AI/ML.**
   - Theo hồ sơ 2 máy (xem `CLAUDE.md`): máy Windows là nơi lập trình chính (đủ mạnh, có VS Code + Python + AI/ML...), còn máy Linux này cấu hình yếu, chỉ đóng vai trò server chạy nền 24/7.
   - Vì vậy máy Linux chỉ cần Git (để tự host Git/web server và thi thoảng clone/pull file cấu hình) và vài lệnh Terminal cơ bản (bao gồm `nano` ở trên) là đủ để tự quản trị chính nó — không cài VS Code, không cài Python/Jupyter/PyTorch hay bất kỳ công cụ AI nặng nào lên máy này, giữ máy nhẹ và đúng vai trò server.

## ✅ Kiểm tra đã thành công

- `git --version` ra số phiên bản (dạng `git version 2.x.x`), không báo lỗi "command not found".
- `git config --global --list` hiện đúng `user.name` và `user.email` vừa đặt.
- Gõ `nano test.txt`, gõ thử vài chữ, bấm `Ctrl+O` rồi `Enter` để lưu, bấm `Ctrl+X` để thoát — quay lại được dấu nhắc lệnh Terminal. Gõ `cat test.txt` thấy đúng nội dung vừa gõ.

## ⚠️ Lỗi thường gặp

- Gõ `git` báo "command not found" dù đã chạy lệnh cài: thường do lệnh `sudo apt install -y git` bị lỗi giữa chừng (mất mạng) — chạy lại `sudo apt update` rồi `sudo apt install -y git` lần nữa.
- Gõ `git config --global user.name "Tên"` mà quên dấu ngoặc kép khi tên có khoảng trắng (ví dụ gõ `Nguyen Van A` không có `""`): Git/terminal sẽ hiểu nhầm thành nhiều tham số riêng, lưu sai tên — luôn bọc tên và email trong dấu ngoặc kép `"..."` như ví dụ ở bước 2, kiểm tra lại bằng `git config --global --list`.
- Đang gõ trong nano, bấm nhầm `Ctrl+X` để thoát mà quên lưu trước: nano sẽ tự hỏi "Save modified buffer?" trước khi thoát — bấm `Y` rồi `Enter` (giữ tên file cũ) để lưu lại, đừng bấm `N` nếu chưa chắc muốn bỏ hết thay đổi vừa gõ.
- Lỡ gõ nhầm lệnh `vim` (hoặc `vi`) thay vì `nano` và bị "kẹt" màn hình, gõ gì cũng không ra chữ bình thường như mong đợi: đây là trình soạn thảo khác (vim) với cách dùng phím riêng biệt, không giống nano — gõ `Esc` rồi gõ `:q!` và `Enter` để thoát ra không lưu, sau đó dùng lại đúng lệnh `nano <tên-file>` cho đơn giản, dễ dùng hơn khi mới bắt đầu.
