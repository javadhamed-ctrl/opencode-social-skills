# opencode-social-skills

Reusable opencode skills for driving **social networks** (messengers and social apps) inside Chrome through the `win32` desktop-automation MCP on Windows.

The first shipped skill is **Bale (بله)** — opening the messenger, finding any contact, and sending a message — verified end-to-end on a real machine. The repo also documents the **general principles** that apply to every network, so adding the next network is mostly "same rules, new app".

## Features

- **`skills/open-bale`** — complete, working recipe for Bale Web (Chrome app):
  - launch the Bale Web window;
  - find any contact/chat (search-by-name, with a verified fallback principle);
  - send a Persian/Unicode message reliably with real Enter;
  - recipient/draft/send verification at every step.
- **`scripts/`** — two reusable PowerShell helpers that solve the hardest part: Chrome **ignores** synthetic key events, so all typing/pasting uses real low-level SendInput:
  - `type-unicode.ps1` — SendInput Unicode typing (Persian works), Shift+Enter newlines, scripted clipboard-paste, backspaces;
  - `activate-send-enter.ps1` — bring a window to the foreground and press a key (Enter = send).
- **`docs/SOCIAL-NETWORK-PRINCIPLES.md`** — the *one general rule* that applies to every network: find the contact via the search icon or the contacts page; copy before pasting; send with Enter; verify the recipient; never trust stale coordinates.

## Requirements

- Windows with PowerShell 5.1+.
- [opencode](https://opencode.ai) with the `win32` MCP server (`win32-mcp-server`): mouse, window, OCR, clipboard, UIA tools.
- Tesseract OCR with the `fas`/`ara` language data for reading Persian (RTL) UI text.

## Usage

```bash
# 1. Install the skill (opencode auto-discovers ~/.config/opencode/skills)
copy skills\open-bale   ~\.config\opencode\skills\open-bale

# 2. Copy the scripts somewhere stable and point the skill's recipe at them
copy scripts\*.ps1      %LOCALAPPDATA%\Temp\opencode\

# 3. In a conversation, just ask (in Persian or English):
#    "بله را باز کن و این پیام را برای مهدی حبیبی بفرست"
```

See `skills/open-bale/SKILL.md` for the full step-by-step recipe and troubleshooting.

## How it works

1. The agent clicks the chat-list **search icon** (position re-derived every session — the window moves between `Bale Web`/`Bale Web (2)` states).
2. It types the contact name with `type-unicode.ps1` (SendInput Unicode) — synthetic `press_key`/`type_text` do not reach Chrome.
3. It clicks the result and **verifies the recipient** before anything else (OCR header + chat `uid`).
4. The message is copied to the clipboard (`win32 clipboard_copy`) **immediately before** a SendInput Ctrl+V.
5. The draft is verified via OCR, then **Enter** is sent with `activate-send-enter.ps1`, and the emptied compose box confirms delivery.

## Author & how this project was built

**Author:** Javad Hamed

This project was built via **AI-assisted coding** on the **opencode** platform (https://opencode.ai) with the **`opencode/big-pickle`** model. The workflow was pair/vibe coding: a human taught the agent the messenger's real behavior on a Windows machine, the agent captured every verified working step and turned it into this skill, and the extra principles were abstracted from that single session so future networks can reuse them.

The recipes here were **genuinely tested and verified**: two real end-to-end sends in Bale succeeded (different recipients), including recipient verification, draft validation, and send confirmation via the emptied compose box.

## License

MIT — see [LICENSE](LICENSE).