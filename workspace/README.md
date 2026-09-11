# Bản sao tài liệu workspace

Ba file tài liệu mô tả cách tổ chức `C:\work` trên máy này. Chúng **không thuộc repo nào**
ở chỗ gốc — `C:\work\CLAUDE.md` ghi rõ *"Không có repo bao ngoài ở `C:\work`"* — nên nếu ổ
đĩa hỏng thì mất trắng. Đưa bản sao vào đây để có lịch sử và bản lưu.

## Nội dung

| File ở đây | Bản gốc trên đĩa | Nội dung |
|---|---|---|
| `work/README.md` | `C:\work\README.md` | Vì sao chọn `C:\work`, cây thư mục, quy tắc đặt file |
| `work/CLAUDE.md` | `C:\work\CLAUDE.md` | Hướng dẫn cho Claude Code khi làm việc trong `C:\work` |
| `work/ha-tang/README.md` | `C:\work\ha-tang\README.md` | Trỏ tới 3 script vận hành và cảnh báo của từng cái |

## ⚠️ Đây là bản sao, không phải bản chuẩn

**Bản chuẩn là file trên đĩa.** Sửa thì sửa ở `C:\work\`, rồi chép lại sang đây — không sửa
ở đây rồi đồng bộ ngược. Không có cơ chế tự động nào giữ hai bên khớp nhau, nên bản trong
repo sẽ cũ dần nếu quên cập nhật. Ngày chép gần nhất ghi trong commit.

Tiền lệ: `config/CLAUDE.md` trong repo này cũng là bản sao của `~/.claude/CLAUDE.md`,
do `scripts/build-archive.ps1` chép tự động mỗi lần chạy.

## Vì sao đặt ở `workspace/` chứ không phải `config/`

`scripts/build-archive.ps1` **xoá và dựng lại** `config/`, `transcripts/`, `README.md` và
`.gitignore` mỗi lần chạy. File đặt trong `config/` sẽ biến mất ở lần chạy kế tiếp.
`workspace/` và `scripts/` nằm ngoài danh sách đó nên an toàn.
