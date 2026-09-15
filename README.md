# opencode-social-skills

Reusable opencode skills for driving **social networks** (messengers and social apps) in Chrome/desktop apps through the **`win32` desktop-automation MCP** on Windows.

The shipped skills are **Bale (بله)**, **Rubika (روبیکا)**, **Eitaa (ایتا)** and **Soroush Plus (سروش پلاس)** — opening the messenger, finding any contact, and sending a message — **all verified end-to-end on a real machine**. The repo also documents the **general principles** that apply to every network, so each new network is mostly "same rules, new app".

## Tested networks

| Network | Status | What was verified |
|---|---|---|
| **Bale (بله)** — Chrome app `web.bale.ai` | ✅ **tested end-to-end** | launch; contact search by name (مهدی حبیبی، ابوالفضل احمدیان); recipient verification (header + chat `uid`); multi-line Persian (RTL) message sent via real Enter; send confirmed (emptied compose box) |
| **Rubika (روبیکا)** — Chrome app `web.rubika.ir` | ✅ **tested end-to-end** | launch; contact search by name (ابوالفضل احمدیان، and «مهدی حبیبی» found via the saved alias «مهدیار حبیبی شاندیز» under the «گفتگوها و مخاطبین» search group); dropdown hit rows located via region OCR; recipient verification (chat header); multi-line Persian (RTL) message sent via real Enter; send confirmed (message visible in chat + emptied compose box) |
| **Eitaa (ایتا)** — native Qt desktop app | ✅ **tested end-to-end** | launch; contact search by name (ابوالفضل احمدیان; «مهدی حبیبی» found as the single result «مهدیار حبیبی شاندیز» — same cross-network alias); recipient verification via **window title** (`<chat> @ جواد حامد`) + in-pane header; draft verified via the focused `QTextEdit` **value**; send via `send-key.ps1` (no window restore); send confirmed (compose value empty + message in chat) |
| **Soroush Plus (سروش پلاس)** — Chrome app `web.splus.ir` | ✅ **tested end-to-end** | launch; contact search by name («مهدی حبیبی» is under his PLAIN name here, not the Rubika/Eitaa alias); DOM inputs exposed via UIA (search + composer values are readable — draft verified without OCR); full-screen OCR for results; send via `send-key.ps1`; send confirmed (message visible in chat + composer `value:""`). NOTE: **ابوالفضل احمدیان has no account** on سروش+ (searches only surface other people/kannels) — correctly aborted per the user |

A network is added to this list **only after it is genuinely tested in a real session** with the same general method (search icon or contacts page → type the name → copy→paste → Enter → verify recipient and delivery).

## Features

- **`skills/open-bale`** — complete, working recipe for Bale Web (Chrome app):
  - launch the Bale Web window;
  - find any contact/chat (search-by-name with a verified fallback principle);
  - send a Persian/Unicode multi-line message reliably with real Enter;
  - recipient/draft/send verification at every step.
- **`skills/open-rubika`** — verified recipe for Rubika Web (Chrome app): same general method in a different app (search box top-right, dropdown hit rows found by region OCR, `composer_rich_textarea` compose field, Enter-to-send).
- **`skills/open-eitaa`** — verified recipe for the native Qt Eitaa Desktop app: fields and the compose value are exposed via UIA (draft verified without OCR), the **window title shows the open chat's name** (recipient check #1), and sends use the restore-free `send-key.ps1`.
- **`skills/open-soroush`** — verified recipe for Soroush Plus Web (Chrome app, RTL layout): **DOM inputs are exposed via UIA too** (search value + composer `value:` = full draft), full-screen OCR for the results dropdown, and Enter-to-send via `send-key.ps1`.
- **`scripts/`** — reusable PowerShell helpers that solve the hardest part: Chrome **ignores** synthetic key events, so all typing/pasting uses real low-level SendInput:
  - `type-unicode.ps1` — SendInput Unicode typing (Persian works), Shift+Enter newlines, scripted clipboard-paste, backspaces;
  - `activate-send-enter.ps1` — bring a window to the foreground (match by title prefix) and press a key (Enter = send);
  - `send-key.ps1` — key-injection ONLY (Enter/Space/Tab), no window activation or SW_RESTORE — for apps whose titles are Persian or where geometry must not change.
- **`docs/SOCIAL-NETWORK-PRINCIPLES.md`** — the *one general rule* that applies to every network: find the contact via the search icon or the contacts page; copy before pasting; send with Enter; verify the recipient; never trust stale coordinates.

## Requirements (platform)

### 1. A model with image-processing / vision capability

- The model used by opencode must support **image input** (screenshots). The model used to build and test this project is **`opencode/big-pickle`**.
- **Why vision matters:** the agent reads screenshots to interpret UI state that OCR cannot (icons, RTL layout, statuses), and to visually confirm what it clicked.
- The included **OCR + UIA workflow keeps the skill functional even with a text-only model**, but a vision-capable model makes verification and icon-finding noticeably more reliable.

### 2. MCP server (must be installed)

- **`win32` MCP** — from the `win32-mcp-server` Python package (mcp SDK pinned to 1.x). In `opencode`:
  - `{ "server": "win32", "cmd": "python -m win32_mcp_server", ... }`.
  - It provides the 53 tools the skill relies on: full-screen/region/window **OCR** (`ocr_screen`, `ocr_region`, `ocr_window`), window control (`list_windows`, `focus_window`, `get_window_snapshot`), mouse (`click`, `click_text`, `drag`, `scroll`), keyboard (`press_key`, `type_text`, `hotkey`), clipboard (`clipboard_copy`/`clipboard_paste`), **UI Automation** (`uia_get_focused`, `uia_find_control`, `uia_inspect_window`, `uia_set_control_value`), process control, and more.
- **Tesseract OCR** with the **`fas` (Persian)**, `ara`, and `eng` language data — the RTL UI is read entirely through Tesseract; without `fas` the recipes fail on Persian text.
- **PowerShell 5.1+** (ships with Windows) + the two scripts in `scripts/` — no extra install; a custom SendInput layer because synthetic key events never reach Chrome.

### 3. Permissions / accesses required

- An **interactive Windows desktop session** — the machine must be unlocked and the messenger app on screen (the agent drives the UI as a human would).
- **opencode tool permissions** for the `win32` MCP tools **and** for **Bash** (the recipe invokes PowerShell via `powershell -NoProfile -ExecutionPolicy Bypass -File ...`).
- The agent must be able to: **inject mouse/keyboard input**, **read/set the clipboard**, **enumerate and focus windows**, **launch processes**, **capture screenshots**, and **run local OCR**.
- The messenger must already be **logged in** — the skill needs **no passwords, tokens, or API keys**; it drives the existing logged-in session exactly like a human assistant.
- **No administrator rights** are needed (SendInput/UIA run in user space; `-ExecutionPolicy Bypass` avoids changing the policy permanently).

### 4. Capabilities & convenience for the user

- **Open** any supported messenger and **find any contact/chat instantly** (search icon or contacts page — the same two paths on every network).
- **Send multi-line, Persian/RTL Unicode messages** with a real Enter press (no more hunting for send buttons).
- **Never send to the wrong person** — the recipient is verified from the chat header (and chat `uid` where available) before sending.
- **Fully verifiable at every step** (OCR + UIA + clipboard checks) — not fire-and-forget automation.
- **One method reused across all networks** → each new network is quick to add and test.
- **Delegates repetitive daily messaging** to the agent (e.g. routine announcements, follow-ups), freeing the user's time.

## Usage

```bash
# 1. Install the skill (opencode auto-discovers ~/.config/opencode/skills)
copy skills\open-bale    ~\.config\opencode\skills\open-bale
copy skills\open-rubika  ~\.config\opencode\skills\open-rubika
copy skills\open-eitaa   ~\.config\opencode\skills\open-eitaa
copy skills\open-soroush ~\.config\opencode\skills\open-soroush

# 2. Copy the scripts somewhere stable and point the skill's recipe at them
copy scripts\*.ps1      %LOCALAPPDATA%\Temp\opencode\

# 3. In a conversation, just ask (in Persian or English):
#    "بله را باز کن و این پیام را برای مهدی حبیبی بفرست"
```

See `skills/open-bale/SKILL.md` for the full step-by-step recipe and troubleshooting.

## How it works

1. The agent clicks the chat-list **search icon** (position re-derived every session — the window moves between `Bale Web`/`Bale Web (2)` states; for Eitaa the search field is a `QTextEdit` at the top of the chat-list column).
2. It types the contact name with `type-unicode.ps1` (SendInput Unicode) — synthetic `press_key`/`type_text` do not reach Chrome (and for Eitaa the tiny search field can't be OCR-verified, so the results area is read instead).
3. It clicks the result and **verifies the recipient** before anything else (OCR header + chat `uid`; for Eitaa the window title itself becomes `<chatName> @ <user>`).
4. The message is copied to the clipboard (`win32 clipboard_copy`) **immediately before** a SendInput Ctrl+V.
5. The draft is verified (OCR, or — in Eitaa/Soroush+ — the focused compose box's UIA `value`), then **Enter** is sent (`activate-send-enter.ps1`, or `send-key.ps1` where SW_RESTORE must be avoided), and the emptied compose box confirms delivery.

## Author & how this project was built

**Author:** Javad Hamed

This project was built via **AI-assisted coding** on the **opencode** platform (https://opencode.ai) with the **`opencode/big-pickle`** model. The workflow was pair/vibe coding: a human taught the agent the messenger's real behavior on a Windows machine, the agent captured every verified working step and turned it into this skill, and the general principles were abstracted from that session so future networks can reuse them.

The recipes here were **genuinely tested and verified**: seven real end-to-end sends — two in Bale (different recipients), two in Rubika (ابوالفضل احمدیان and «مهدی حبیبی» reached via his saved alias «مهدیار حبیبی شاندیز»), two in Eitaa (the same two recipients) and one in Soroush+ («مهدی حبیبی», plain name) — each including recipient verification, draft validation, and send confirmation via the emptied compose box. One non-send outcome is also recorded for Soroush+: «ابوالفضل احمدیان» has no account there, so it was correctly aborted instead of guessing.

## License

MIT — see [LICENSE](LICENSE).---

â­گ **If you found this project useful, please give it a star!** It helps others discover it and motivates continued development.

â­گ **ط§ع¯ط± ط§غŒظ† ظ¾ط±ظˆعکظ‡ ط¨ط±ط§غŒطھط§ظ† ظ…ظپغŒط¯ ط¨ظˆط¯طŒ ظ„ط·ظپط§ظ‹ ط¨ظ‡ ط¢ظ† ط³طھط§ط±ظ‡ (Star) ط¨ط¯ظ‡غŒط¯!** ط§غŒظ† ع©ط§ط± ط¨ظ‡ ط¯غŒع¯ط±ط§ظ† ط¯ط± ع©ط´ظپ ظ¾ط±ظˆعکظ‡ ع©ظ…ع© ظ…غŒâ€Œع©ظ†ط¯ ظˆ ط§ظ†ع¯غŒط²ظ‡ظ” طھظˆط³ط¹ظ‡ظ” ط¨غŒط´طھط± ط±ط§ ظپط±ط§ظ‡ظ… ظ…غŒâ€Œط¢ظˆط±ط¯.

