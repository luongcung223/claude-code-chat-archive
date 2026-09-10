$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Home2    = "C:\Users\Cung Đức Lương"
$Projects = Join-Path $Home2 ".claude\projects"
$Out      = Join-Path $Home2 "chat-archive"

# Dọn sạch rồi tạo lại cây thư mục.
#
# CHỈ xoá những gì script này sinh ra. Tuyệt đối KHÔNG xoá cả $Out: thư mục đó
# giờ là một git repo và có chứa scripts/ — xoá cả cây sẽ mất luôn .git (toàn bộ
# lịch sử commit) và mất chính script này.
$Generated = @(
  "$Out\transcripts",
  "$Out\config",
  "$Out\README.md",
  "$Out\.gitignore"
)
foreach ($g in $Generated) {
  if (Test-Path -LiteralPath $g) { Remove-Item -LiteralPath $g -Recurse -Force }
}
$null = New-Item -ItemType Directory -Path $Out -Force
$null = New-Item -ItemType Directory -Path "$Out\transcripts\jsonl" -Force
$null = New-Item -ItemType Directory -Path "$Out\transcripts\markdown" -Force
$null = New-Item -ItemType Directory -Path "$Out\config\memory" -Force

$utf8 = New-Object System.Text.UTF8Encoding($false)

# --- Redaction ---------------------------------------------------------
$Patterns = @(
  @{ re = 'sk-ant-[A-Za-z0-9_-]{15,}';                    tag = '[REDACTED-ANTHROPIC-KEY]' },
  @{ re = 'as_ey[A-Za-z0-9._-]{30,}';                     tag = '[REDACTED-JWT]' },
  @{ re = 'gh[pousr]_[A-Za-z0-9]{20,}';                   tag = '[REDACTED-GITHUB-TOKEN]' },
  @{ re = 'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}'; tag = '[REDACTED-JWT]' },
  @{ re = 'AKIA[0-9A-Z]{16}';                             tag = '[REDACTED-AWS-KEY]' },
  @{ re = 'xox[baprs]-[A-Za-z0-9-]{10,}';                 tag = '[REDACTED-SLACK-TOKEN]' }
)
$script:RedactCount = 0
function Redact([string]$s) {
  if ([string]::IsNullOrEmpty($s)) { return $s }
  foreach ($p in $Patterns) {
    $m = [regex]::Matches($s, $p.re)
    if ($m.Count -gt 0) {
      $script:RedactCount += $m.Count
      $s = [regex]::Replace($s, $p.re, $p.tag)
    }
  }
  return $s
}

# --- Trích text từ content block ---------------------------------------
function Render-Content($content) {
  $sb = New-Object System.Text.StringBuilder
  if ($content -is [string]) {
    [void]$sb.AppendLine($content)
    return $sb.ToString()
  }
  foreach ($b in @($content)) {
    switch ($b.type) {
      'text' {
        if ($b.text) { [void]$sb.AppendLine($b.text); [void]$sb.AppendLine() }
      }
      'thinking' {
        if ($b.thinking) {
          [void]$sb.AppendLine('<details><summary>💭 suy nghĩ</summary>')
          [void]$sb.AppendLine()
          [void]$sb.AppendLine($b.thinking)
          [void]$sb.AppendLine()
          [void]$sb.AppendLine('</details>')
          [void]$sb.AppendLine()
        }
      }
      'tool_use' {
        $inp = ''
        try { $inp = ($b.input | ConvertTo-Json -Depth 12 -Compress) } catch { $inp = '<unserializable>' }
        if ($inp.Length -gt 4000) { $inp = $inp.Substring(0,4000) + ' …(cắt bớt)' }
        [void]$sb.AppendLine("<details><summary>🔧 <code>$($b.name)</code></summary>")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine('```json')
        [void]$sb.AppendLine($inp)
        [void]$sb.AppendLine('```')
        [void]$sb.AppendLine()
        [void]$sb.AppendLine('</details>')
        [void]$sb.AppendLine()
      }
      'tool_result' {
        $txt = ''
        if ($b.content -is [string]) {
          $txt = $b.content
        } else {
          foreach ($c in @($b.content)) { if ($c.type -eq 'text') { $txt += $c.text + "`n" } }
        }
        if ($txt.Length -gt 4000) { $txt = $txt.Substring(0,4000) + "`n…(cắt bớt)" }
        if ($txt.Trim()) {
          [void]$sb.AppendLine('<details><summary>📄 kết quả</summary>')
          [void]$sb.AppendLine()
          [void]$sb.AppendLine('```')
          [void]$sb.AppendLine($txt)
          [void]$sb.AppendLine('```')
          [void]$sb.AppendLine()
          [void]$sb.AppendLine('</details>')
          [void]$sb.AppendLine()
        }
      }
      'image' { [void]$sb.AppendLine('*(ảnh — không lưu trong bản markdown)*'); [void]$sb.AppendLine() }
    }
  }
  return $sb.ToString()
}

# --- Xử lý từng phiên --------------------------------------------------
$index = @()

Get-ChildItem -Path $Projects -Directory | ForEach-Object {
  $projDir  = $_
  $projName = if ($projDir.Name -like '*Downloads') { 'downloads' } else { 'home' }

  Get-ChildItem -Path $projDir.FullName -Filter '*.jsonl' -File | ForEach-Object {
    $src   = $_
    $short = $src.BaseName.Substring(0,8)
    $stem  = "$projName-$short"

    $lines = [System.IO.File]::ReadAllLines($src.FullName, [System.Text.Encoding]::UTF8)

    # 1) bản .jsonl đã redact
    $clean = foreach ($l in $lines) { Redact $l }
    [System.IO.File]::WriteAllLines("$Out\transcripts\jsonl\$stem.jsonl", $clean, $utf8)

    # 2) bản markdown
    $md        = New-Object System.Text.StringBuilder
    $firstUser = $null
    $firstTs   = $null
    $lastTs    = $null
    $nUser     = 0
    $nAsst     = 0
    $body      = New-Object System.Text.StringBuilder

    foreach ($l in $clean) {
      if (-not $l.Trim()) { continue }
      try { $o = $l | ConvertFrom-Json } catch { continue }
      if ($o.type -ne 'user' -and $o.type -ne 'assistant') { continue }
      if ($o.isMeta) { continue }

      if ($o.timestamp) {
        if (-not $firstTs) { $firstTs = $o.timestamp }
        $lastTs = $o.timestamp
      }

      $text = Render-Content $o.message.content
      if (-not $text.Trim()) { continue }

      if ($o.type -eq 'user') {
        # bỏ qua tool_result thuần (đó là output cho assistant, đã render trong khối trên)
        $isToolResultOnly = $false
        if ($o.message.content -isnot [string]) {
          $types = @($o.message.content | ForEach-Object { $_.type }) | Sort-Object -Unique
          if ($types.Count -eq 1 -and $types[0] -eq 'tool_result') { $isToolResultOnly = $true }
        }
        if ($isToolResultOnly) { [void]$body.Append($text); continue }

        $nUser++
        if (-not $firstUser -and $o.origin.kind -eq 'human' -and $o.message.content -is [string]) {
          $firstUser = $o.message.content
        }
        $tag = if ($o.isSidechain) { '👤 Người dùng *(subagent)*' } else { '👤 Người dùng' }
        [void]$body.AppendLine("### $tag")
        [void]$body.AppendLine()
        [void]$body.Append($text)
        [void]$body.AppendLine()
      } else {
        $nAsst++
        [void]$body.AppendLine('### 🤖 Claude')
        [void]$body.AppendLine()
        [void]$body.Append($text)
        [void]$body.AppendLine()
      }
      [void]$body.AppendLine('---')
      [void]$body.AppendLine()
    }

    if (-not $firstUser) { $firstUser = '(không xác định)' }
    $title = ($firstUser -replace '\s+', ' ').Trim()
    if ($title.Length -gt 90) { $title = $title.Substring(0,90) + '…' }

    $dateStr = if ($firstTs) { ([datetime]$firstTs).ToLocalTime().ToString('yyyy-MM-dd HH:mm') } else { '?' }
    $endStr  = if ($lastTs)  { ([datetime]$lastTs).ToLocalTime().ToString('yyyy-MM-dd HH:mm') } else { '?' }

    [void]$md.AppendLine("# $title")
    [void]$md.AppendLine()
    [void]$md.AppendLine("| | |")
    [void]$md.AppendLine("|---|---|")
    [void]$md.AppendLine("| Session ID | ``$($src.BaseName)`` |")
    [void]$md.AppendLine("| Thư mục làm việc | ``$projName`` |")
    [void]$md.AppendLine("| Bắt đầu | $dateStr |")
    [void]$md.AppendLine("| Kết thúc | $endStr |")
    [void]$md.AppendLine("| Lượt hỏi / trả lời | $nUser / $nAsst |")
    [void]$md.AppendLine()
    [void]$md.AppendLine("> Bản JSONL gốc: [``transcripts/jsonl/$stem.jsonl``](../jsonl/$stem.jsonl)")
    [void]$md.AppendLine()
    [void]$md.AppendLine('---')
    [void]$md.AppendLine()
    [void]$md.Append($body.ToString())

    [System.IO.File]::WriteAllText("$Out\transcripts\markdown\$stem.md", $md.ToString(), $utf8)

    $index += [pscustomobject]@{
      Stem  = $stem
      Title = $title
      Date  = $dateStr
      Proj  = $projName
      Turns = $nUser
      Size  = [math]::Round($src.Length / 1KB)
    }
    Write-Host "  ✔ $stem  ($nUser lượt)  $title"
  }
}

# --- config -------------------------------------------------------------
Copy-Item "$Home2\.claude\CLAUDE.md" "$Out\config\CLAUDE.md" -Force
Get-ChildItem "$Projects\C--Users-Cung---c-L--ng\memory" -Filter '*.md' -File |
  ForEach-Object { Copy-Item $_.FullName "$Out\config\memory\$($_.Name)" -Force }

# --- README -------------------------------------------------------------
$rows = ($index | Sort-Object Date | ForEach-Object {
  "| $($_.Date) | [$($_.Title)](transcripts/markdown/$($_.Stem).md) | $($_.Proj) | $($_.Turns) |"
}) -join "`n"

$readme = @"
# Lưu trữ hội thoại Claude Code

Toàn bộ transcript các phiên làm việc với Claude Code trên máy này, kèm cấu hình cá nhân.
Xuất ngày $(Get-Date -Format 'dd/MM/yyyy').

## Các phiên

| Ngày | Chủ đề | Thư mục | Lượt hỏi |
|---|---|---|---|
$rows

## Cấu trúc

- §transcripts/markdown/§ — bản dễ đọc, tool call và suy nghĩ gập trong thẻ §<details>§
- §transcripts/jsonl/§ — bản gốc đầy đủ, mỗi dòng một message
- §config/CLAUDE.md§ — hướng dẫn cá nhân áp dụng cho mọi project
- §config/memory/§ — bộ nhớ dài hạn của Claude Code
- §scripts/§ — script PowerShell dựng repo này và các tiện ích liên quan
  (xem [§scripts/README.md§](scripts/README.md))

> §transcripts/§, §config/§, §README.md§ và §.gitignore§ được **sinh tự động** bởi
> §scripts/build-archive.ps1§ — sửa tay ở đó sẽ mất khi chạy lại script.
> §scripts/§ và §.git/§ không bị script đụng tới.

## Về bảo mật

Trước khi commit, toàn bộ nội dung đã được quét và thay thế các chuỗi khớp mẫu
API key / token / JWT bằng nhãn §[REDACTED-*]§. File §key.super.txt§ và
§settings.json§ **không** được đưa vào repo này.

Dù vậy đây là repo **public** — transcript vẫn chứa đường dẫn máy, tên file cá nhân
và chi tiết cấu hình. Cân nhắc trước khi chia sẻ rộng.
"@
# § là ký tự thay thế cho backtick (backtick là ký tự escape của PowerShell trong here-string)
$readme = $readme.Replace([char]167, [char]96)
[System.IO.File]::WriteAllText("$Out\README.md", $readme, $utf8)

$gitignore = @"
key.super.txt
settings.json
*.credentials.json
.credentials.json
"@
[System.IO.File]::WriteAllText("$Out\.gitignore", $gitignore, $utf8)

Write-Host ""
Write-Host "Xong: $($index.Count) phiên, đã redact $($script:RedactCount) chuỗi nhạy cảm."
