# Personal PC Setup Docs (Windows 11 + Linux) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a complete, beginner-friendly, Vietnamese-language documentation project (`docs/windows/`, `docs/linux/`) guiding the user through setting up a Windows 11 machine (IT/AI study) and an old machine reinstalled with Linux Mint XFCE (self-hosting), plus `CLAUDE.md`, `README.md`, and agentmemory facts so future Claude Code sessions have full context.

**Architecture:** One Markdown file per task/topic, numbered `NN-topic.md`, organized under `docs/windows/` and `docs/linux/` (with `docs/linux/05-self-hosting/` as a subfolder for self-hosted services). Each OS folder has a `00-checklist.md` index. Root has `CLAUDE.md` (project conventions for Claude) and `README.md` (human entry point).

**Tech Stack:** Plain Markdown, git for version control, `agentmemory` MCP plugin (already installed) for cross-session project memory, `WebSearch` for verifying current (Sept 2026) install commands/links before writing each guide.

**Spec:** `docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md`

---

## Standard File Checklist (applies to every guide file, referenced by tasks below — not repeated per task)

Before committing any `NN-topic.md` guide file, confirm:

- [ ] Starts with `# <Tiêu đề>` matching the topic
- [ ] Has `## Mục tiêu` (1–3 câu, tiếng Việt, nói rõ đạt được gì sau bước này)
- [ ] Has `## Các bước` — numbered steps; every CLI action has an exact command in a fenced code block; every GUI action names the exact menu path
- [ ] Has `## ✅ Kiểm tra đã thành công` — at least one concrete way to verify (a command whose output confirms success, or an observable UI state)
- [ ] Has `## ⚠️ Lỗi thường gặp` — at least 1–2 real, specific pitfalls (skip only if the task is genuinely trivial with no plausible failure mode)
- [ ] Prose is in Vietnamese; technical terms, command names, software names, menu labels stay in English (per spec §6/§9 language convention)
- [ ] Commands, download URLs, version numbers, and UI menu paths reflect the research done in this task's Step 1, not just prior training knowledge — flag anything that could have changed since with a short note if uncertain

---

## Task 1: CLAUDE.md

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: Write CLAUDE.md**

Content is fully determined by spec §6 — write exactly this:

```markdown
# CLAUDE.md

Dự án này là kho tài liệu **cá nhân** hướng dẫn setup lại 2 máy tính từ đầu (cài Win mới hoặc cài lại). Người đọc chính là chủ dự án — trình độ beginner hoàn toàn.

## Hồ sơ 2 máy

| | Máy Windows | Máy Linux |
|---|---|---|
| OS | Windows 11 | Linux Mint XFCE (cài mới từ USB) |
| Cấu hình | Đủ mạnh để code + AI | Máy cũ, cấu hình yếu |
| Mục đích | Học IT & AI: lập trình, thử nghiệm AI/ML | Self-host server cơ bản (NAS, Git/web cá nhân), chạy 24/7 |
| Ghi chú | | Giữ GUI (XFCE) dù nặng hơn bản không-GUI — ưu tiên dễ dùng cho beginner hơn tối ưu tuyệt đối tài nguyên |

## Quy ước viết docs

- Ngôn ngữ: tiếng Việt, giữ nguyên thuật ngữ kỹ thuật/tên lệnh/tên phần mềm bằng tiếng Anh (không dịch "terminal", "package manager", tên lệnh...).
- Giọng văn: cho người mới hoàn toàn, không giả định kiến thức nền, giải thích ngắn gọn trước khi ra lệnh.
- Mỗi file hướng dẫn theo khung: `# Tiêu đề` → `## Mục tiêu` → `## Các bước` (đánh số) → `## ✅ Kiểm tra đã thành công` → `## ⚠️ Lỗi thường gặp`.
- Đặt tên file: `NN-ten-chu-de.md`, số phản ánh đúng thứ tự thao tác thực tế.
- Khi thêm/bớt file trong `docs/windows/` hoặc `docs/linux/`, luôn cập nhật `00-checklist.md` tương ứng.
- Trước khi viết/sửa nội dung có lệnh cụ thể hoặc link tải, tra cứu nguồn hiện tại — tránh hướng dẫn lỗi thời.

## Cấu trúc

```
docs/
├── windows/   (00-checklist.md + 01..06 theo thứ tự cài đặt)
└── linux/     (00-checklist.md + 01..04 + 05-self-hosting/)
```

Xem chi tiết đầy đủ tại `docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md`.
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "Add CLAUDE.md with project conventions and machine profile"
```

---

## Task 2: docs/windows/01-fresh-install.md

**Files:**
- Create: `docs/windows/01-fresh-install.md`

- [ ] **Step 1: Ensure directory exists, then research**

```bash
mkdir -p "docs/windows"
```

Run WebSearch for (things that drift over time — confirm before writing):
- `Windows 11 fresh install steps 2026 Media Creation Tool`
- `Windows 11 check for updates activation status settings 2026`
- `NVIDIA AMD Intel GPU driver download page 2026`
- `Windows 11 safe to uninstall default apps list 2026`

- [ ] **Step 2: Write the file**

Cover, in this order: (a) nhánh rẽ ngắn — máy đã có sẵn Win 11 thì bỏ qua bước cài mới, chỉ máy trống/cài lại từ đầu mới cần Media Creation Tool + USB; (b) Windows Update: `Settings > Windows Update > Check for updates`, cài hết, restart; (c) driver GPU — xác định máy dùng GPU hãng nào, tải driver từ trang chính hãng (NVIDIA/AMD/Intel), giải thích ngắn gọn vì sao driver GPU quan trọng cho AI/ML sau này (CUDA cần driver NVIDIA đúng phiên bản); (d) kiểm tra kích hoạt Windows tại `Settings > System > Activation`; (e) tuỳ chọn gỡ bớt vài app mặc định không cần qua `Settings > Apps > Installed apps`. Use exact current menu paths/URLs found in Step 1 research.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/windows/01-fresh-install.md
git commit -m "Add Windows fresh-install guide"
```

---

## Task 3: docs/windows/02-essentials.md

**Files:**
- Create: `docs/windows/02-essentials.md`

- [ ] **Step 1: Research**

- `winget command syntax install search upgrade 2026`
- `winget package id 7zip`
- `Windows 11 show file extensions dark mode settings path 2026`

- [ ] **Step 2: Write the file**

Cover: (a) giới thiệu `winget` là gì (Windows Package Manager, có sẵn trong Win 11), cách mở (Terminal/PowerShell), 3 lệnh cơ bản `winget search <tên>`, `winget install <id>`, `winget upgrade --all`; (b) cài trình duyệt (Chrome hoặc Firefox qua winget, hoặc dùng Edge có sẵn) và 7-Zip: `winget install 7zip.7zip` (xác nhận đúng id qua research); (c) tinh chỉnh cơ bản — hiện đuôi file: `File Explorer > View > Show > File name extensions`; bật dark mode: `Settings > Personalization > Colors`.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/windows/02-essentials.md
git commit -m "Add Windows essentials guide"
```

---

## Task 4: docs/windows/03-dev-tools.md

**Files:**
- Create: `docs/windows/03-dev-tools.md`

- [ ] **Step 1: Research**

- `winget package id Git.Git Microsoft.VisualStudioCode Microsoft.WindowsTerminal`
- `GitHub add SSH key steps 2026`
- `VS Code recommended extensions Python GitLens Docker Remote WSL 2026`

- [ ] **Step 2: Write the file**

Cover: (a) cài Git: `winget install Git.Git`; cấu hình `git config --global user.name "Tên"` và `git config --global user.email "email"`; (b) tạo tài khoản GitHub nếu chưa có; tạo SSH key: `ssh-keygen -t ed25519 -C "email@example.com"`, thêm public key vào GitHub qua đường dẫn Settings hiện tại (research), test bằng `ssh -T git@github.com`; (c) cài VS Code: `winget install Microsoft.VisualStudioCode`; cài extension gợi ý (liệt kê tên chính xác từ research: Python, GitLens, Docker, WSL, Jupyter); (d) Windows Terminal (thường có sẵn Win 11; nếu chưa có: `winget install Microsoft.WindowsTerminal`).

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/windows/03-dev-tools.md
git commit -m "Add Windows dev-tools guide (Git, GitHub SSH, VS Code)"
```

---

## Task 5: docs/windows/04-python-env.md

**Files:**
- Create: `docs/windows/04-python-env.md`

- [ ] **Step 1: Research**

- `Miniconda download install Windows 2026`
- `Python current stable version recommended for data science ML 2026`
- `python venv activate Windows PowerShell command`

- [ ] **Step 2: Write the file**

Cover: (a) giải thích ngắn tại sao cần venv/conda (tránh xung đột thư viện giữa các project); (b) cài Miniconda: link tải chính thức (từ research), chạy installer, kiểm tra `conda --version`; (c) tạo/kích hoạt conda env: `conda create -n myenv python=3.X` (dùng version xác nhận ở research), `conda activate myenv`; (d) cách khác — Python venv thuần: `python -m venv myenv`, kích hoạt bằng `myenv\Scripts\activate` (PowerShell); (e) cài package cơ bản: `pip install numpy pandas`.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/windows/04-python-env.md
git commit -m "Add Windows Python environment guide (venv/conda)"
```

---

## Task 6: docs/windows/05-wsl2-docker.md

**Files:**
- Create: `docs/windows/05-wsl2-docker.md`

- [ ] **Step 1: Research**

- `wsl --install command default distro 2026`
- `Docker Desktop Windows system requirements WSL2 backend setting 2026`
- `winget package id Docker.DockerDesktop`

- [ ] **Step 2: Write the file**

Cover: (a) bật WSL2: mở PowerShell as Administrator, chạy `wsl --install` (ghi rõ distro mặc định hiện tại từ research), restart máy; (b) kiểm tra: `wsl --list --verbose` phải thấy VERSION 2; (c) cài Docker Desktop: `winget install Docker.DockerDesktop`, mở app, xác nhận trong Settings đang dùng WSL2 backend (đường dẫn menu từ research); (d) kiểm tra Docker hoạt động: `docker run hello-world`.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/windows/05-wsl2-docker.md
git commit -m "Add Windows WSL2 + Docker guide"
```

---

## Task 7: docs/windows/06-ai-ml.md

**Files:**
- Create: `docs/windows/06-ai-ml.md`

- [ ] **Step 1: Research**

- `pytorch.org get started install command CUDA CPU 2026`
- `Ollama Windows install download run first model 2026`
- `jupyterlab pip install run command 2026`

- [ ] **Step 2: Write the file**

Cover: (a) cài JupyterLab: `pip install jupyterlab`, chạy `jupyter lab`; (b) cài PyTorch — hướng dẫn dùng trang chính thức pytorch.org/get-started để lấy đúng lệnh theo có/không GPU NVIDIA, dẫn ví dụ lệnh cụ thể từ research; (c) cài thư viện cơ bản: `pip install numpy pandas scikit-learn`; (d) giới thiệu Ollama để thử chạy LLM ngay trên máy (local): cài từ ollama.com (link từ research), chạy thử model gợi ý hiện tại (tên model xác nhận qua research, ví dụ `ollama run <model>`).

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/windows/06-ai-ml.md
git commit -m "Add Windows AI/ML tools guide (Jupyter, PyTorch, Ollama)"
```

---

## Task 8: docs/windows/00-checklist.md

**Files:**
- Create: `docs/windows/00-checklist.md`

- [ ] **Step 1: Write the file**

```markdown
# Checklist: Setup máy Windows 11

Tick từng bước khi hoàn thành. Xem chi tiết ở file tương ứng.

- [ ] Bước 1 — Cài đặt mới/cập nhật Windows, driver, kích hoạt (xem [01-fresh-install.md](01-fresh-install.md))
- [ ] Bước 2 — Trình duyệt, 7-Zip, winget, tinh chỉnh cơ bản (xem [02-essentials.md](02-essentials.md))
- [ ] Bước 3 — Git, GitHub SSH, VS Code (xem [03-dev-tools.md](03-dev-tools.md))
- [ ] Bước 4 — Python, venv/conda (xem [04-python-env.md](04-python-env.md))
- [ ] Bước 5 — WSL2, Docker (xem [05-wsl2-docker.md](05-wsl2-docker.md))
- [ ] Bước 6 — Jupyter, PyTorch, Ollama (xem [06-ai-ml.md](06-ai-ml.md))
```

- [ ] **Step 2: Verify all links resolve** — confirm files from Tasks 2–7 exist at those exact relative paths (`ls docs/windows/`).

- [ ] **Step 3: Commit**

```bash
git add docs/windows/00-checklist.md
git commit -m "Add Windows setup checklist index"
```

---

## Task 9: docs/linux/01-usb-install.md

**Files:**
- Create: `docs/linux/01-usb-install.md`

- [ ] **Step 1: Ensure directory exists, then research**

```bash
mkdir -p "docs/linux"
```

- `Linux Mint XFCE edition current version download 2026`
- `Rufus create bootable USB Linux ISO steps 2026`
- `Linux Mint installer partitioning steps for beginners`

- [ ] **Step 2: Write the file**

Cover: (a) tải ISO Linux Mint **XFCE Edition** (nhấn mạnh chọn đúng bản XFCE, không phải Cinnamon/MATE) từ linuxmint.com, version cụ thể từ research; (b) tạo USB boot bằng Rufus trên máy Windows — các bước cụ thể từ research; (c) vào BIOS/UEFI để boot từ USB (giải thích chung phím tắt phổ biến F2/F12/Del/Esc, khuyên kiểm tra hãng máy cụ thể); (d) các bước cài đặt Mint: chọn ngôn ngữ, chọn "Erase disk and install Mint" (giải thích đơn giản đây là máy cũ dùng lại từ đầu nên xoá sạch), tạo user/mật khẩu, hoàn tất & reboot, rút USB.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/linux/01-usb-install.md
git commit -m "Add Linux Mint USB install guide"
```

---

## Task 10: docs/linux/02-first-boot-optimize.md

**Files:**
- Create: `docs/linux/02-first-boot-optimize.md`

- [ ] **Step 1: Research**

- `Linux Mint XFCE current version Window Manager effects settings menu path`
- `Linux Mint Startup Applications disable menu path`
- `Linux Mint apt update upgrade commands`

- [ ] **Step 2: Write the file**

Cover: (a) update hệ thống ngay sau khi cài: `sudo apt update && sudo apt upgrade -y`; (b) tắt hiệu ứng đồ hoạ để nhẹ máy — đường dẫn menu chính xác từ research (thường `Menu > Preferences > Window Manager Settings/Effects`); (c) tắt bớt app khởi động cùng máy: `Menu > Preferences > Startup Applications`; (d) cài `htop` để theo dõi tài nguyên: `sudo apt install htop`, chạy `htop` để xem RAM/CPU đang dùng; (e) giải thích ngắn gọn về swap/swappiness cho máy RAM thấp: kiểm tra `cat /proc/sys/vm/swappiness`, gợi ý không cần chỉnh trừ khi máy có dưới ~4GB RAM.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/linux/02-first-boot-optimize.md
git commit -m "Add Linux first-boot and low-resource optimization guide"
```

---

## Task 11: docs/linux/03-remote-access.md

**Files:**
- Create: `docs/linux/03-remote-access.md`

- [ ] **Step 1: Research**

- `Linux Mint install enable openssh-server systemctl 2026`
- `Windows 11 built-in ssh client PowerShell 2026`
- `Linux Mint Network Manager set static IP steps`

- [ ] **Step 2: Write the file**

Cover: (a) cài OpenSSH server: `sudo apt install openssh-server`; (b) bật & kiểm tra: `sudo systemctl enable --now ssh`, `sudo systemctl status ssh`; (c) tìm IP máy Linux: `hostname -I` hoặc `ip a`; (d) kết nối từ máy Windows dùng Terminal có sẵn: `ssh <user>@<ip>` (xác nhận Win 11 có sẵn ssh client, từ research); (e) gợi ý đặt IP tĩnh cho máy Linux (trên router hoặc qua Network Manager của Mint) vì máy chạy 24/7 — giải thích ngắn tại sao quan trọng (IP đổi thì mất kết nối SSH).

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/linux/03-remote-access.md
git commit -m "Add Linux SSH remote access guide"
```

---

## Task 12: docs/linux/04-dev-tools.md

**Files:**
- Create: `docs/linux/04-dev-tools.md`

- [ ] **Step 1: Research**

- `Linux Mint apt install git nano basic commands 2026`

- [ ] **Step 2: Write the file**

Cover: (a) cài Git: `sudo apt install git`; cấu hình giống máy Windows: `git config --global user.name "Tên"`, `git config --global user.email "email"`; (b) giới thiệu `nano` (đã có sẵn) để sửa file config qua terminal: mở bằng `nano <tên file>`, lưu bằng `Ctrl+O`, thoát bằng `Ctrl+X`; (c) ghi chú ngắn: máy này không cài VS Code/AI stack nặng vì coding chính làm ở máy Windows — chỉ cần đủ Git + terminal cơ bản để quản trị server.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/linux/04-dev-tools.md
git commit -m "Add Linux lightweight dev-tools guide"
```

---

## Task 13: docs/linux/05-self-hosting/01-nas-file-share.md

**Files:**
- Create: `docs/linux/05-self-hosting/01-nas-file-share.md`

- [ ] **Step 1: Ensure directory exists, then research**

```bash
mkdir -p "docs/linux/05-self-hosting"
```

- `Samba install config share folder Ubuntu Mint 2026 smb.conf example`
- `smbpasswd add user command`

- [ ] **Step 2: Write the file**

Cover: (a) cài Samba: `sudo apt install samba`; (b) tạo thư mục chia sẻ: `mkdir ~/shared`; (c) thêm block cấu hình vào `/etc/samba/smb.conf` — show cụ thể ví dụ khối `[shared]` với `path`, `read only = no`, `browsable = yes` (nội dung chính xác từ research); (d) đặt mật khẩu Samba cho user hiện tại: `sudo smbpasswd -a $USER`; (e) khởi động lại service: `sudo systemctl restart smbd`; (f) truy cập từ máy Windows: mở File Explorer, gõ `\\<ip-máy-linux>\shared`, đăng nhập bằng user/mật khẩu Samba vừa tạo.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/linux/05-self-hosting/01-nas-file-share.md
git commit -m "Add Samba NAS file-share self-hosting guide"
```

---

## Task 14: docs/linux/05-self-hosting/02-git-web-server.md

**Files:**
- Create: `docs/linux/05-self-hosting/02-git-web-server.md`

- [ ] **Step 1: Research**

- `Gitea install guide 2026 docker or binary current version`
- `Gitea default port first admin account setup`

- [ ] **Step 2: Write the file**

Cover: (a) giải thích ngắn Gitea là gì (Git server nhẹ, giao diện web giống GitHub thu nhỏ, phù hợp máy yếu); (b) hướng dẫn cài đặt — chọn 1 cách đơn giản nhất cho beginner theo research (ưu tiên Docker nếu Docker đã quen thuộc từ máy Windows, hoặc binary trực tiếp nếu đơn giản hơn trên máy yếu không cần Docker); show cụ thể lệnh/docker-compose từ research; (c) truy cập lần đầu qua trình duyệt: `http://<ip-máy-linux>:<port>` (port chính xác từ research, mặc định thường 3000); (d) tạo tài khoản admin đầu tiên qua giao diện web.

- [ ] **Step 3: Self-check** against the Standard File Checklist above.

- [ ] **Step 4: Commit**

```bash
git add docs/linux/05-self-hosting/02-git-web-server.md
git commit -m "Add Gitea self-hosted Git server guide"
```

---

## Task 15: docs/linux/00-checklist.md

**Files:**
- Create: `docs/linux/00-checklist.md`

- [ ] **Step 1: Write the file**

```markdown
# Checklist: Setup máy Linux (Mint XFCE)

Tick từng bước khi hoàn thành. Xem chi tiết ở file tương ứng.

- [ ] Bước 1 — Tạo USB & cài Linux Mint XFCE (xem [01-usb-install.md](01-usb-install.md))
- [ ] Bước 2 — Update hệ thống & tối ưu tài nguyên (xem [02-first-boot-optimize.md](02-first-boot-optimize.md))
- [ ] Bước 3 — Cài SSH để điều khiển từ xa (xem [03-remote-access.md](03-remote-access.md))
- [ ] Bước 4 — Git & công cụ dev cơ bản (xem [04-dev-tools.md](04-dev-tools.md))
- [ ] Bước 5a — Self-host NAS/file-share bằng Samba (xem [05-self-hosting/01-nas-file-share.md](05-self-hosting/01-nas-file-share.md))
- [ ] Bước 5b — Self-host Git server bằng Gitea (xem [05-self-hosting/02-git-web-server.md](05-self-hosting/02-git-web-server.md))
```

- [ ] **Step 2: Verify all links resolve** — confirm files from Tasks 9–14 exist at those exact relative paths (`ls docs/linux/ docs/linux/05-self-hosting/`).

- [ ] **Step 3: Commit**

```bash
git add docs/linux/00-checklist.md
git commit -m "Add Linux setup checklist index"
```

---

## Task 16: Save project facts to agentmemory

**Files:** none (writes to the agentmemory plugin's store, not the filesystem)

- [ ] **Step 1: Load the tool schema**

```
ToolSearch query: "select:mcp__plugin_agentmemory_agentmemory__memory_save"
```

Inspect the returned schema to see the exact parameters it expects (e.g. content/text field, tags/category field).

- [ ] **Step 2: Save each fact** (one `memory_save` call per fact, or combined if the schema supports a list — check the schema from Step 1):

1. "User đang học IT/AI (TDTU). Có máy Windows 11 đủ mạnh dùng để code + AI, và máy Linux cũ cấu hình yếu dùng để self-host server."
2. "Distro đã chọn cho máy Linux cũ: Linux Mint XFCE Edition — giữ giao diện đồ hoạ (GUI) dù máy yếu, vì ưu tiên dễ dùng cho beginner hơn là tối ưu tuyệt đối tài nguyên."
3. "Các service tự host (self-hosting) dự kiến trên máy Linux: NAS/file-share qua Samba, và Git/web server cá nhân qua Gitea."
4. "Quy ước cấu trúc docs setup máy cho user: nhiều file Markdown nhỏ đánh số thứ tự theo trình tự thao tác thực tế (NN-topic.md), kèm 1 file 00-checklist.md tổng hợp checkbox — áp dụng cho các dự án setup/hướng dẫn tương tự sau này."

- [ ] **Step 3: Verify** — call the plugin's recall/search tool (e.g. `mcp__plugin_agentmemory_agentmemory__memory_recall` or `memory_smart_search`, load via ToolSearch if needed) with a query like "PC setup Windows Linux" and confirm the facts above come back.

No commit needed for this task (external store, not a file in this repo).

---

## Task 17: README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write the file**

```markdown
# Setup — Hướng dẫn cài đặt máy cá nhân

Kho tài liệu hướng dẫn từng bước để setup lại 2 máy tính, viết cho người mới bắt đầu hoàn toàn.

## Máy Windows 11 (học IT & AI)

Bắt đầu tại → [docs/windows/00-checklist.md](docs/windows/00-checklist.md)

## Máy Linux (Mint XFCE, self-host server)

Bắt đầu tại → [docs/linux/00-checklist.md](docs/linux/00-checklist.md)

---

Xem thiết kế đầy đủ của dự án tại [docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md](docs/superpowers/specs/2026-09-15-pc-setup-docs-design.md).
```

- [ ] **Step 2: Verify links resolve** — confirm `docs/windows/00-checklist.md` and `docs/linux/00-checklist.md` exist (they were created in Tasks 8 and 15).

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "Add project README linking to both setup checklists"
```

---

## Self-Review Notes

- **Spec coverage:** Every file in spec §4's folder tree has a task (Tasks 1–15, 17). Spec §7 (agentmemory) is Task 16. Spec §8/§9 (formatting + QA) are enforced via the Standard File Checklist applied in every content task's Step 3, plus a research step before writing to satisfy the "verify current sources" requirement.
- **No placeholders:** Every content task names the exact commands/menu paths to include (not "add appropriate steps"); CLAUDE.md and the two checklist files have fully written-out content since they don't depend on external research.
- **Ordering:** Tasks 2–8 (Windows) and 9–15 (Linux) each end with that OS's checklist task, so links always resolve at write time. README.md (Task 17) is last so both checklists already exist.
