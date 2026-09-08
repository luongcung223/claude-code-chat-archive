---
name: local-only-shared-max-account
description: "User shares a Max 20x Claude account with others and wants this machine's Claude Code kept local-only (no artifacts, no cloud sessions, no claude.ai sync)"
metadata: 
  node_type: memory
  type: project
  originSessionId: f940eac1-3116-4455-b5c8-e076e1035913
  modified: 2026-09-07T02:18:11.276Z
---

The Claude account signed in on this machine is a **shared Max 20x account** used by several people. On 2026-09-07 the user asked that Claude Code on this machine work purely locally and never create objects on that shared account.

`~/.claude/settings.json` was locked down accordingly: `enableArtifact: false`, `disableRemoteControl: true`, `autoUploadSessions: false`, `syncClaudeAiSkills/Plugins: false`, `disableClaudeAiConnectors: true`, `crossSessionInbound: "refuse"`, push notifications off, and `permissions.deny` for the Artifact/DesignSync tools.

**Why:** anything written to the account (artifacts, cloud sessions, synced skills/plugins, design projects) is visible to and mutable by the other people on the plan.

**How to apply:** don't propose artifacts, cloud/remote sessions, claude.ai skill or plugin sync, or Remote Control for this machine — they are switched off deliberately, not by accident. Deliver work as local files instead. Note that token usage still draws on the shared plan's quota; that cannot be changed from settings.
