# Hướng dẫn cho Claude Code khi làm việc trong `C:\work`

Bổ sung cho `~/.claude/CLAUDE.md` (hướng dẫn toàn máy). Chỗ nào mâu thuẫn thì file này thắng,
vì nó hẹp hơn.

## Nguyên tắc đặt file

- Mọi thứ sinh ra trong lúc làm việc phải nằm trong repo dự án tương ứng dưới `C:\work`.
  **Không** ghi ra `~/Downloads`, thư mục home, hay OneDrive.
- File tạm, log, output chẩn đoán → `C:\work\_kho\`. Coi như thùng rác có thời hạn, không phải kho lưu.
- Tài liệu gốc (docx, pdf, ảnh, spec sheet) → thư mục `tai-lieu/` của repo, đặt tên theo
  `YYYY-MM-DD_loai-tai-lieu_mo-ta-ngan.ext`.

## Viết script PowerShell

Máy này là **PowerShell 5.1**, không phải PS 7:

- Không có `&&`, `||`, `?:`, `??`, `?.` — nối lệnh bằng `A; if ($?) { B }`.
- Không có `head`, `tail`, `which`, `touch`, `wc`, `mkdir -p`, `rm -rf`.
- **Không có Python và không có Node.js** trên máy. Đừng viết hook hay script phụ thuộc chúng.
- **Không hard-code đường dẫn có dấu tiếng Việt.** PS 5.1 đọc `.ps1` không BOM theo ANSI →
  `Cung Đức Lương` biến thành mojibake. Dùng `$env:USERPROFILE`, hoặc `$PSScriptRoot` để
  script tự định vị. Nếu buộc phải viết tiếng Việt trong script, lưu file **có BOM UTF-8**
  hoặc dựng chuỗi từ mã Unicode (xem `ca-phe-xuat-khau/tai-lieu/.../verify.ps1` làm mẫu).
- Khi ghi file cho công cụ khác đọc: `-Encoding utf8` tường minh.

## Git

- Mỗi thư mục con của `C:\work` là một repo riêng. Không có repo bao ngoài ở `C:\work`.
- Commit message bằng **tiếng Việt**, mô tả nội dung thay đổi chứ không mô tả thao tác.
- Không commit: bundle log chẩn đoán (có thể chứa token plaintext), hợp đồng đã ký,
  bảng giá, dữ liệu cá nhân nông hộ.

## Orca

- Orca ghi đè `%APPDATA%\orca\profiles\local-default\orca-data.json` khi thoát.
  Muốn sửa tay thì **tắt hẳn Orca trước**, không thì mất thay đổi.
- Agent mặc định của Orca là `claude`.

## Bản trùng đã biết

`~/OneDrive/Documents/caffe/` chứa bản sao tài liệu Word của dự án cà phê, người dùng giữ
làm dự phòng. **`C:\work\ca-phe-xuat-khau\tai-lieu\` là bản chuẩn.** Sửa tài liệu thì sửa
trong repo; đừng đồng bộ ngược từ OneDrive về.
