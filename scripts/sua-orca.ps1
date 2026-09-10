# sua-orca.ps1 — áp dụng cấu hình Orca thân thiện hơn.
#
# CHẠY SCRIPT NÀY KHI ORCA ĐÃ TẮT HẲN.
# Orca giữ cấu hình trong bộ nhớ và ghi đè file khi thoát, nên sửa lúc nó đang
# chạy sẽ mất trắng.
#
# Cách chạy: mở Windows PowerShell (KHÔNG phải terminal trong Orca), gõ:
#     powershell -ExecutionPolicy Bypass -File "C:\work\chat-archive\scripts\sua-orca.ps1"

$ErrorActionPreference = 'Stop'

$duong_dan = Join-Path $env:APPDATA 'orca\profiles\local-default\orca-data.json'

# --- 1. Chặn nếu Orca còn chạy ------------------------------------------------
$dang_chay = @(Get-Process -Name 'Orca', 'orca-terminal-daemon' -ErrorAction SilentlyContinue)
if ($dang_chay.Count -gt 0) {
    Write-Host ''
    Write-Host '  DUNG LAI: Orca van dang chay (' -NoNewline -ForegroundColor Red
    Write-Host $dang_chay.Count -NoNewline -ForegroundColor Red
    Write-Host ' tien trinh).' -ForegroundColor Red
    Write-Host '  Hay thoat han Orca (ke ca icon o khay he thong), roi chay lai script nay.'
    Write-Host ''
    exit 1
}

if (-not (Test-Path $duong_dan)) {
    Write-Host "  Khong tim thay: $duong_dan" -ForegroundColor Red
    exit 1
}

# --- 2. Sao lưu ---------------------------------------------------------------
$ban_luu = "$duong_dan.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $duong_dan $ban_luu -Force
Write-Host "  Da sao luu -> $ban_luu" -ForegroundColor DarkGray

# --- 3. Thay thế từng mục (khớp chính xác, đếm để chắc chắn) ------------------
$noi_dung = [System.IO.File]::ReadAllText($duong_dan, [System.Text.Encoding]::UTF8)

$thay_the = [ordered]@{
    'Font giao dien: Times New Roman -> mac dinh he thong' = @(
        '"appFontFamily":"Times New Roman"', '"appFontFamily":""')
    'Terminal luon dung theme toi (hop mau voi Claude)'    = @(
        '"terminalUseSeparateLightTheme":true', '"terminalUseSeparateLightTheme":false')
    'Scrollback terminal: 5000 -> 20000 dong'              = @(
        '"terminalScrollbackRows":5000', '"terminalScrollbackRows":20000')
    'Giu may thuc khi agent dang chay'                     = @(
        '"keepComputerAwakeWhileAgentsRun":false', '"keepComputerAwakeWhileAgentsRun":true')
    'Tat telemetry Orca (dong bo voi Claude)'              = @(
        '"optedIn":true', '"optedIn":false')
    'Bo --dangerously-skip-permissions cho claude'         = @(
        '"claude":"--dangerously-skip-permissions"', '"claude":""')
    'Bo --dangerously-skip-permissions cho claude-agent-teams' = @(
        '"claude-agent-teams":"--dangerously-skip-permissions"', '"claude-agent-teams":""')
}

$loi = 0
foreach ($muc in $thay_the.GetEnumerator()) {
    $cu, $moi = $muc.Value
    $so_lan = ([regex]::Matches($noi_dung, [regex]::Escape($cu))).Count
    if ($so_lan -eq 1) {
        $noi_dung = $noi_dung.Replace($cu, $moi)
        Write-Host "  [OK]   $($muc.Key)" -ForegroundColor Green
    }
    elseif ($so_lan -eq 0) {
        Write-Host "  [BO QUA] $($muc.Key) - da doi tu truoc?" -ForegroundColor Yellow
    }
    else {
        Write-Host "  [LOI]  $($muc.Key) - tim thay $so_lan lan, khong dam sua" -ForegroundColor Red
        $loi++
    }
}

# --- 3b. Đổi workspaceDir sang C:\work\_worktrees ----------------------------
#
# Orca đặt git worktree vào $env:USERPROFILE\orca\workspaces, tức đường dẫn có dấu
# tiếng Việt. Bằng chứng thực tế: `git worktree list` in ra đường dẫn escape octal
# ("Cung \304\220\341\273\251c L\306\260\306\241ng"). Dời sang C:\work\_worktrees để
# ăn khớp với workspace chính và bỏ hẳn lớp lỗi đường dẫn có dấu.
#
# Dùng regex thay vì khớp chuỗi chính xác: giá trị cũ chứa tên người dùng có dấu,
# hardcode vào .ps1 là tự chuốc đúng lỗi encoding đang muốn tránh.
$ws_moi     = 'C:\work\_worktrees'
$ws_moi_json = $ws_moi.Replace('\', '\\')      # JSON escape: C:\\work\\_worktrees
$mau_ws     = '"workspaceDir":"(?<gt>(?:[^"\\]|\\.)*)"'
$khop_ws    = [regex]::Matches($noi_dung, $mau_ws)

if ($khop_ws.Count -eq 1) {
    $ws_cu = $khop_ws[0].Groups['gt'].Value
    if ($ws_cu -eq $ws_moi_json) {
        Write-Host "  [BO QUA] workspaceDir - da tro toi $ws_moi tu truoc" -ForegroundColor Yellow
    }
    else {
        $noi_dung = [regex]::Replace($noi_dung, $mau_ws, ('"workspaceDir":"' + $ws_moi_json + '"'))
        Write-Host "  [OK]   workspaceDir -> $ws_moi" -ForegroundColor Green
        Write-Host "         (cu: $($ws_cu.Replace('\\','\')))" -ForegroundColor DarkGray
    }
}
elseif ($khop_ws.Count -eq 0) {
    Write-Host '  [BO QUA] workspaceDir - khong tim thay khoa nay' -ForegroundColor Yellow
}
else {
    Write-Host "  [LOI]  workspaceDir - tim thay $($khop_ws.Count) lan, khong dam sua" -ForegroundColor Red
    $loi++
}

# --- 4. Kiểm tra JSON còn hợp lệ rồi mới ghi ----------------------------------
try {
    $null = $noi_dung | ConvertFrom-Json
}
catch {
    Write-Host "  [LOI] JSON hong sau khi sua, KHONG ghi de. Chi tiet: $_" -ForegroundColor Red
    exit 1
}

# Ghi UTF-8 khong BOM (Electron doc BOM se hong)
[System.IO.File]::WriteAllText($duong_dan, $noi_dung, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "  Da ghi $duong_dan" -ForegroundColor Green

# --- 5. Tạo sẵn thư mục workspace cho git worktree ----------------------------
if (-not (Test-Path $ws_moi)) {
    New-Item -ItemType Directory -Force -Path $ws_moi | Out-Null
    Write-Host "  Da tao thu muc workspace: $ws_moi" -ForegroundColor Green
}

Write-Host ''
if ($loi -gt 0) {
    Write-Host "  Xong, nhung co $loi muc khong sua duoc." -ForegroundColor Yellow
}
else {
    Write-Host '  Xong. Mo lai Orca de ap dung.' -ForegroundColor Cyan
}
Write-Host "  Muon hoan tac: chep de $ban_luu ve $duong_dan (khi Orca dang tat)."
Write-Host ''
