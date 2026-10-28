# Cài Gemini Notebook CLI và NotebookLM MCP Server

## Mục tiêu

Sau bước này, máy Windows có thể:

- Cài `nlm` để thao tác với Gemini Notebook (trước đây thường gọi là NotebookLM) từ terminal.
- Đăng nhập Google bằng cửa sổ Chrome riêng do `nlm` mở.
- Kiểm tra, refresh và đăng nhập lại khi session hết hạn.
- Kết nối NotebookLM MCP Server với GitHub Copilot trong VS Code.

> **Lưu ý bảo mật:** Credential đăng nhập được lưu cục bộ trên máy. Không commit hoặc sao chép thư mục chứa credential vào Git, USB công khai hay cloud không mã hóa. Khi chuyển sang máy mới, hãy đăng nhập Gmail lại.

## Các bước

1. **Cài `uv` trên Windows.**

   `uv` là tool dùng để cài và chạy các Python CLI độc lập, không cần tự quản lý virtual environment cho `nlm`.

   - Mở trang cài đặt chính thức: [docs.astral.sh/uv/getting-started/installation](https://docs.astral.sh/uv/getting-started/installation/).
   - Hoặc nếu máy đã có `winget`, chạy trong PowerShell:

     ```powershell
     winget install --id astral-sh.uv --exact
     ```

   - Đóng PowerShell rồi mở lại. Kiểm tra:

     ```powershell
     uv --version
     ```

2. **Cài Gemini Notebook CLI và MCP Server.**

   Chạy:

   ```powershell
   uv tool install notebooklm-mcp-cli
   ```

   Sau đó cập nhật PATH cho các cửa sổ PowerShell mới:

   ```powershell
   uv tool update-shell
   ```

   Đóng PowerShell, mở lại rồi kiểm tra:

   ```powershell
   nlm --version
   ```

   Nếu PowerShell hiện tại chưa nhận `nlm`, dùng tạm:

   ```powershell
   $env:Path = "$HOME\.local\bin;$env:Path"
   ```

   Nếu lệnh cài đặt báo lỗi build `pyyaml` vì đang dùng Python quá mới, cài bằng Python 3.13:

   ```powershell
   uv python install 3.13
   uv tool install --python 3.13 notebooklm-mcp-cli
   ```

3. **Đăng nhập Google.**

   Chạy:

   ```powershell
   nlm login --storage protected
   ```

   `nlm` sẽ mở một cửa sổ Chrome riêng. Đăng nhập Gmail trong **chính cửa sổ Chrome đó**, sau đó bấm `Continue` hoặc `Allow` nếu Google hỏi.

   `protected` yêu cầu Windows bảo vệ credential bằng cơ chế lưu trữ an toàn của hệ điều hành. Không nhập password Google trực tiếp vào terminal.

   Kiểm tra đăng nhập:

   ```powershell
   nlm login --check
   ```

   Liệt kê notebook:

   ```powershell
   nlm notebook list
   ```

4. **Cấu hình NotebookLM MCP Server cho GitHub Copilot trong VS Code.**

   Chạy:

   ```powershell
   nlm setup add github-copilot --scope user
   ```

   Kiểm tra cấu hình:

   ```powershell
   nlm setup list
   ```

   Khởi động lại VS Code. Mở Copilot Chat và kiểm tra danh sách MCP tools; khi được hỏi quyền dùng tool, chỉ cho phép nếu bạn hiểu hành động mà tool sẽ thực hiện.

   Có thể dùng client khác bằng các lệnh tương ứng:

   ```powershell
   nlm setup add gemini
   nlm setup add antigravity
   nlm setup add cursor
   ```

   Không chạy các lệnh trên nếu client tương ứng chưa được cài.

5. **Kiểm tra MCP và NotebookLM end-to-end.**

   ```powershell
   nlm login --check
   nlm notebook list
   nlm doctor auth-replay
   ```

   Trong Copilot Chat, thử câu hỏi chỉ đọc trước:

   ```text
   Hãy liệt kê các notebook tôi có quyền truy cập và chỉ hiển thị tên cùng số lượng source.
   ```

   Không bắt đầu bằng yêu cầu xóa notebook, xóa source, mời người khác hoặc tạo artifact nếu chưa kiểm tra tool và phạm vi quyền.

6. **Xử lý session hết hạn.**

   Thử refresh session trước:

   ```powershell
   nlm auth refresh
   nlm login --check
   ```

   Có thể thử refresh không mở browser:

   ```powershell
   nlm auth refresh --http-only
   ```

   Cách `--http-only` chỉ dùng được khi session Google chưa hết hoàn toàn. Nếu refresh thất bại, đăng nhập tương tác lại:

   ```powershell
   nlm login --force --storage protected
   ```

   Khi muốn đổi sang tài khoản Google khác:

   ```powershell
   nlm login --clear --storage protected
   ```

7. **Cài lại trên máy mới.**

   Thực hiện lại từ Bước 1 đến Bước 4. Không sao chép cookie/token từ máy cũ; chỉ cần:

   ```powershell
   uv tool install notebooklm-mcp-cli
   uv tool update-shell
   ```

   Mở PowerShell mới rồi chạy:

   ```powershell
   nlm login --storage protected
   nlm setup add github-copilot --scope user
   nlm login --check
   ```

   Nếu muốn giữ danh sách notebook hoặc dữ liệu, dữ liệu đó vẫn nằm trong tài khoản Google/NotebookLM; không nằm trong thư mục cài `nlm`.

## ✅ Kiểm tra đã thành công

- `uv --version` chạy được.
- `nlm --version` chạy được.
- `nlm login --check` báo `Authentication valid!`.
- `nlm notebook list` liệt kê được notebook.
- `nlm setup list` hiển thị GitHub Copilot đã có MCP configuration.
- Copilot Chat trong VS Code nhìn thấy các NotebookLM MCP tools.
- Câu hỏi chỉ đọc trong Copilot trả về notebook/source mà không cần copy credential vào workspace.

## ⚠️ Lỗi thường gặp

- **`nlm` không được nhận diện trong PowerShell:**
  - Đóng và mở lại PowerShell sau khi chạy `uv tool update-shell`.
  - Hoặc chạy tạm:
    ```powershell
    $env:Path = "$HOME\.local\bin;$env:Path"
    ```

- **`Profile not found: default`:**
  - Profile chưa được tạo. Chạy:
    ```powershell
    nlm login --storage protected
    ```

- **`Authentication failed` sau một thời gian không dùng:**
  - Chạy `nlm auth refresh`.
  - Nếu không được, chạy `nlm login --force --storage protected` và đăng nhập lại trong Chrome riêng.

- **Đăng nhập xong nhưng `nlm login` vẫn timeout:**
  - Đảm bảo đăng nhập trong cửa sổ Chrome do `nlm` mở, không phải Chrome profile thông thường.
  - Không đóng cửa sổ Chrome hoặc PowerShell trong lúc lệnh đang chờ.
  - Thử lại với `nlm login --clear --storage protected` nếu profile Chrome bị kẹt.

- **Lệnh cài đặt lỗi khi build `pyyaml`:**
  - Dùng Python 3.13:
    ```powershell
    uv python install 3.13
    uv tool install --python 3.13 notebooklm-mcp-cli
    ```

- **Copilot không thấy MCP tools:**
  - Chạy lại `nlm setup list`.
  - Kiểm tra đã dùng đúng scope `user`:
    ```powershell
    nlm setup add github-copilot --scope user
    ```
  - Reload hoặc khởi động lại VS Code.
  - Không tự copy credential vào file cấu hình MCP.

- **Không nên backup thư mục credential:**
  - Không đưa `C:\Users\<user>\.notebooklm-mcp-cli\profiles` vào repository.
  - Trên máy mới, cài CLI và chạy `nlm login` để tạo credential mới.

## Nguồn tham khảo

- [Gemini Notebook CLI & MCP Server trên GitHub](https://github.com/jacob-bd/gemini-notebook-mcp-cli)
- [uv - Installation](https://docs.astral.sh/uv/getting-started/installation/)
- [NotebookLM](https://notebooklm.google.com/)
