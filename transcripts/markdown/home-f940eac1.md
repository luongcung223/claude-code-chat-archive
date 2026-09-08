# thiết lập cho claude chỉ làm việc trên máy này mà không ảnh hưởng đến hay tạo artifact của…

| | |
|---|---|
| Session ID | `f940eac1-3116-4455-b5c8-e076e1035913` |
| Thư mục làm việc | `home` |
| Bắt đầu | 2026-09-07 09:15 |
| Kết thúc | 2026-09-07 09:18 |
| Lượt hỏi / trả lời | 11 / 13 |

> Bản JSONL gốc: [`transcripts/jsonl/home-f940eac1.jsonl`](../jsonl/home-f940eac1.jsonl)

---

### 👤 Người dùng

thiết lập cho claude chỉ làm việc trên máy này mà không ảnh hưởng đến hay tạo artifact của tài khoản max 20x chung nhé

---

### 🤖 Claude

Tôi sẽ xem cấu hình hiện tại trước.


---

### 🤖 Claude

<details><summary>🔧 <code>PowerShell</code></summary>

```json
{"command":"$p=\"$env:USERPROFILE\\.claude\"; ls $p -Force | Select-Object Mode,Length,Name; \"---\"; ls \"$p\\settings.json\",\"$p\\settings.local.json\" -ErrorAction SilentlyContinue | Select-Object FullName,Length","description":"List .claude directory contents"}
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>PowerShell</code></summary>

```json
{"command":"$p=\"$env:USERPROFILE\\.claude\\settings.json\"; if(Test-Path $p){\"=== settings.json ===\"; Get-Content $p -Raw} else {\"no settings.json\"}; $q=\"$env:USERPROFILE\\.claude.json\"; if(Test-Path $q){\"=== .claude.json size ===\"; (Get-Item $q).Length}","description":"Read global settings.json"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
Exit code 1
Mode   Length Name         
----   ------ ----         
d-----        backups      
d-----        cache        
d-----        downloads    
d-----        hooks        
d-----        plugins      
d-----        projects     
d-----        sessions     
-a---- 24     .last-cleanup
-a---- 921    history.jsonl
-a---- 617    settings.json
---
       617
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
=== settings.json ===
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Grep|Glob|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 C:\\Users\\Cung Äá»©c LÆ°Æ¡ng\\.claude\\hooks\\chia-viec.py",
            "timeout": 10
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 C:\\Users\\Cung Äá»©c LÆ°Æ¡ng\\.claude\\hooks\\chia-viec.py",
            "timeout": 10
          }
        ]
      }
    ]
  },
  "autoUpdatesChannel": "latest",
  "theme": "dark"
}

=== .claude.json size ===
2214
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>Skill</code></summary>

```json
{"skill":"update-config","args":"Lock this machine\u0027s Claude Code to local-only: deny Artifact/DesignSync/cloud-session tools and disable non-essential traffic so nothing is created on the shared Max 20x account"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
Launching skill: update-config
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>Read</code></summary>

```json
{"file_path":"C:\\Users\\Cung Đức Lương\\.claude\\settings.json"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
1	{
2	  "hooks": {
3	    "PreToolUse": [
4	      {
5	        "matcher": "Read|Grep|Glob|Bash",
6	        "hooks": [
7	          {
8	            "type": "command",
9	            "command": "python3 C:\\Users\\Cung Đức Lương\\.claude\\hooks\\chia-viec.py",
10	            "timeout": 10
11	          }
12	        ]
13	      }
14	    ],
15	    "UserPromptSubmit": [
16	      {
17	        "hooks": [
18	          {
19	            "type": "command",
20	            "command": "python3 C:\\Users\\Cung Đức Lương\\.claude\\hooks\\chia-viec.py",
21	            "timeout": 10
22	          }
23	        ]
24	      }
25	    ]
26	  },
27	  "autoUpdatesChannel": "latest",
28	  "theme": "dark"
29	}
30	
```

</details>


---

### 🤖 Claude

Cấu hình hiện có (hooks, theme) sẽ được giữ nguyên. Tôi sao lưu rồi bổ sung các khoá khoá-cứng phần cloud.


---

### 🤖 Claude

<details><summary>🔧 <code>PowerShell</code></summary>

```json
{"command":"$p=\"$env:USERPROFILE\\.claude\\settings.json\"; Copy-Item $p \"$p.bak-20260907\" -Force; \"backup -\u003e $p.bak-20260907\"","description":"Back up settings.json"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
backup -> C:\Users\Cung Đức Lương\.claude\settings.json.bak-20260907
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>Edit</code></summary>

```json
{"replace_all":false,"file_path":"C:\\Users\\Cung Đức Lương\\.claude\\settings.json","old_string":"  \"autoUpdatesChannel\": \"latest\",\n  \"theme\": \"dark\"\n}","new_string":"  \"autoUpdatesChannel\": \"latest\",\n  \"theme\": \"dark\",\n\n  \"enableArtifact\": false,\n  \"disableArtifact\": true,\n\n  \"disableRemoteControl\": true,\n  \"remoteControlAtStartup\": false,\n  \"autoUploadSessions\": false,\n  \"isolatePeerMachines\": true,\n  \"crossSessionInbound\": \"refuse\",\n\n  \"syncClaudeAiSkills\": false,\n  \"syncClaudeAiPlugins\": false,\n  \"disableClaudeAiConnectors\": true,\n\n  \"inputNeededNotifEnabled\": false,\n  \"agentPushNotifEnabled\": false,\n  \"feedbackDrafts\": \"off\",\n  \"feedbackSurveyRate\": 0,\n\n  \"attribution\": {\n    \"sessionUrl\": false\n  },\n\n  \"permissions\": {\n    \"deny\": [\n      \"Artifact\",\n      \"ArtifactComments\",\n      \"ArtifactData\",\n      \"ArtifactCheck\",\n      \"DesignSync\"\n    ]\n  },\n\n  \"env\": {\n    \"CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC\": \"1\",\n    \"DISABLE_TELEMETRY\": \"1\",\n    \"DISABLE_ERROR_REPORTING\": \"1\"\n  }\n}"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
The file C:\Users\Cung Đức Lương\.claude\settings.json has been updated successfully. (file state is current in your context — no need to Read it back)
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>PowerShell</code></summary>

```json
{"command":"$p=\"$env:USERPROFILE\\.claude\\settings.json\"; try { $j = Get-Content $p -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop; \"JSON OK\"; \"keys: \" + (($j.PSObject.Properties.Name) -join \", \"); \"hook cmd: \" + $j.hooks.PreToolUse[0].hooks[0].command } catch { \"JSON INVALID: $_\" }","description":"Validate settings.json syntax and confirm hooks intact"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
JSON OK
keys: hooks, autoUpdatesChannel, theme, enableArtifact, disableArtifact, disableRemoteControl, remoteControlAtStartup, autoUploadSessions, isolatePeerMachines, crossSessionInbound, syncClaudeAiSkills, syncClaudeAiPlugins, disableClaudeAiConnectors, inputNeededNotifEnabled, agentPushNotifEnabled, feedbackDrafts, feedbackSurveyRate, attribution, permissions, env
hook cmd: python3 C:\Users\Cung Đức Lương\.claude\hooks\chia-viec.py
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>PowerShell</code></summary>

```json
{"command":"$m=\"$env:USERPROFILE\\.claude\\projects\\C--Users-Cung---c-L--ng\\memory\"; if(Test-Path \"$m\\MEMORY.md\"){Get-Content \"$m\\MEMORY.md\" -Raw -Encoding UTF8} else {\"no MEMORY.md\"}","description":"Check memory index"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
no MEMORY.md
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>Write</code></summary>

```json
{"file_path":"C:\\Users\\Cung Đức Lương\\.claude\\projects\\C--Users-Cung---c-L--ng\\memory\\local-only-shared-max-account.md","content":"---\nname: local-only-shared-max-account\ndescription: User shares a Max 20x Claude account with others and wants this machine\u0027s Claude Code kept local-only (no artifacts, no cloud sessions, no claude.ai sync)\nmetadata:\n  type: project\n---\n\nThe Claude account signed in on this machine is a **shared Max 20x account** used by several people. On 2026-09-07 the user asked that Claude Code on this machine work purely locally and never create objects on that shared account.\n\n`~/.claude/settings.json` was locked down accordingly: `enableArtifact: false`, `disableRemoteControl: true`, `autoUploadSessions: false`, `syncClaudeAiSkills/Plugins: false`, `disableClaudeAiConnectors: true`, `crossSessionInbound: \"refuse\"`, push notifications off, and `permissions.deny` for the Artifact/DesignSync tools.\n\n**Why:** anything written to the account (artifacts, cloud sessions, synced skills/plugins, design projects) is visible to and mutable by the other people on the plan.\n\n**How to apply:** don\u0027t propose artifacts, cloud/remote sessions, claude.ai skill or plugin sync, or Remote Control for this machine — they are switched off deliberately, not by accident. Deliver work as local files instead. Note that token usage still draws on the shared plan\u0027s quota; that cannot be changed from settings.\n"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
File created successfully at: C:\Users\Cung Đức Lương\.claude\projects\C--Users-Cung---c-L--ng\memory\local-only-shared-max-account.md
```

</details>


---

### 🤖 Claude

<details><summary>🔧 <code>Write</code></summary>

```json
{"file_path":"C:\\Users\\Cung Đức Lương\\.claude\\projects\\C--Users-Cung---c-L--ng\\memory\\MEMORY.md","content":"- [Local-only on a shared Max 20x account](local-only-shared-max-account.md) — this machine must not create artifacts or cloud objects on the shared plan.\n"}
```

</details>


---

### 👤 Người dùng

<details><summary>📄 kết quả</summary>

```
File created successfully at: C:\Users\Cung Đức Lương\.claude\projects\C--Users-Cung---c-L--ng\memory\MEMORY.md (file state is current in your context — no need to Read it back)
```

</details>


---

### 🤖 Claude

Đã cấu hình xong trong `C:\Users\Cung Đức Lương\.claude\settings.json` (JSON đã validate, hooks `chia-viec.py` và theme giữ nguyên; bản sao lưu ở `settings.json.bak-20260907`).

**Chặn tạo artifact / object trên tài khoản**
- `enableArtifact: false` + `disableArtifact: true` — tắt tool Artifact.
- `permissions.deny`: `Artifact`, `ArtifactComments`, `ArtifactData`, `ArtifactCheck`, `DesignSync` — chặn ở tầng permission luôn, phòng khi phiên bản nào đó bỏ qua key trên.

**Chặn phiên cloud / đồng bộ hai chiều**
- `disableRemoteControl: true`, `remoteControlAtStartup: false` — không có claude.ai/code, không Remote Control.
- `autoUploadSessions: false` — không mirror transcript lên claude.ai.
- `crossSessionInbound: "refuse"`, `isolatePeerMachines: true` — phiên của người khác trên cùng tài khoản không nhắn/điều khiển được máy này.
- `syncClaudeAiSkills/syncClaudeAiPlugins: false`, `disableClaudeAiConnectors: true` — không kéo skill/plugin/MCP connector từ tài khoản chung xuống.

**Giảm dấu vết phụ**
- `inputNeededNotifEnabled` / `agentPushNotifEnabled: false` — không đẩy notification lên mobile của tài khoản chung.
- `feedbackDrafts: "off"`, `feedbackSurveyRate: 0`, `attribution.sessionUrl: false` (không gắn link session claude.ai vào commit/PR).
- `env`: `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, `DISABLE_TELEMETRY`, `DISABLE_ERROR_REPORTING` = `1`.

**Hai điểm cần lưu ý:**
1. Cần **khởi động lại Claude Code** để các key này có hiệu lực (settings đọc lúc launch).
2. Điều này **không** tách được phần quota: máy này vẫn đăng nhập bằng chính tài khoản Max 20x đó, nên token tiêu thụ vẫn trừ vào hạn mức chung và vẫn hiện trong usage của tài khoản. Không có setting nào đổi được — muốn tách hẳn thì phải đăng nhập tài khoản riêng hoặc dùng API key riêng (`claude /login`).

Tôi cũng đã ghi lại ràng buộc này vào memory để lần sau không đề xuất artifact/cloud session cho máy này.


---

