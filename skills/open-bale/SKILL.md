---
name: open-bale
description: Use when the user asks to open or launch the "Bale" (بله) messenger application, or to find a contact/chat and send a message in Bale on Windows. Opens the Bale Web Chrome app window and drives it via low-level SendInput since synthetic key events do not reach Chrome.
---

# Open Bale messenger & send messages

Bale (بله) is a Persian messenger that runs as a Chrome app (`web.bale.ai`). Chrome **ignores synthetic key events** (`win32 press_key` / `type_text` send keys nowhere), so real low-level SendInput is used for typing and pasting. The scripts in the `scripts/` folder of this skill provide that.

## General rule (applies to EVERY social network)

To find any contact/chat quickly, use ONE of these two paths (try 2 when 1 is not obvious):

1. **Click the search (magnifier) icon** and type the name.
2. **Click the "contacts" icon/page** — it usually opens a contact list WITH a search box.

Other universal rules:
- **Never paste without copying first.** Ctrl+V only pastes what was previously copied (Ctrl+C). When using a scripted paste, ALWAYS set the clipboard right before pasting.
- **Send with Enter** (Shift+Enter = newline) — do not hunt for a send button.
- **Verify the recipient** (the chat header shows the right name) before sending — never send to the wrong person.

## Requirements

- Windows + PowerShell 5.1 (or later).
- opencode with the `win32` MCP server (`win32-mcp-server`), which provides mouse/window/OCR/clipboard/UIA tools.
- Tesseract OCR with Persian (`fas`) and/or Arabic (`ara`) language data for reading the RTL UI.

## Install

1. Copy `skills/open-bale/` → `~/.config/opencode/skills/open-bale/` (opencode loads it automatically).
2. Copy `scripts/` anywhere stable (e.g. `C:\Users\<you>\AppData\Local\Temp\opencode\`), or keep it next to the skill.
3. Edit the script paths below to match your install location.
4. Run the scripts with `powershell -NoProfile -ExecutionPolicy Bypass -File <path>` (Windows execution policy blocks direct calls).

## Launch Bale

```powershell
Start-Process -FilePath "C:\Users\<you>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\Bale Web.lnk"
```

The window may appear as `Bale Web` or `Bale Web (2)` (e.g. when a previous instance exists) and can resize/move between sessions. Always check current geometry with `win32 list_windows` — **do not trust absolute icon coordinates from a previous session**.

## Find a contact & send a message (verified end-to-end recipe)

The search icon's absolute position is NOT stable (the window resizes/moves). Re-derive it by OCR/pixel-scanning the top band of the chat-list column. Working reference points (from real sessions): a maximized window ⇒ search icon ~(1368,53); a 903px-wide right-side window ⇒ ~(1460,51). The "۵/5" styling of the magnifier is often OCR'd as a digit — click candidates and confirm the placeholder appears.

1. **Focus Bale** and ensure it is the foreground window.
2. **Open search**: click the magnifier icon; confirm the placeholder «جستجوی کانال، گروه و پیام...» appeared.
3. **Focus the search input** (click near the placeholder) and confirm with `win32 uia_get_focused` → an `EditControl` (search field) is focused.
4. **Type the name** with `type-unicode.ps1 -Text "<name>"`. Re-check the field's `value` via `uia_get_focused` — it must equal the name, typed exactly once (the helper sends each Unicode char by `KEYEVENTF_UNICODE`).
5. **Click the first result** row; the chat opens.
6. **Verify the recipient**: `win32 ocr_window` — the header line must show the expected name; also `win32 uia_find_control` on the omnibox (`Address and search bar`) shows `web.bale.ai/chat?uid=...` (a different `uid` = a different chat). Compound headers can garble under OCR — the subtitle ("last seen" / «... اینجا بوده») plus full-window OCR usually disambiguate. Never send if you are not sure.
7. **Copy the message**: `win32 clipboard_copy` the exact text — immediately before pasting.
8. **Focus the compose box** (click it) and confirm with `uia_get_focused` → `GroupControl` `editable-message-text`.
9. **Paste**: `type-unicode.ps1 -Paste`; the box expands to ~7 lines when it holds a long message.
10. **Verify the draft** with OCR (capture the bottom-left region of the pane).
11. **Send**: `activate-send-enter.ps1 -WindowTitle "Bale Web" -KeyName Enter`.
12. **Confirm sent**: OCR shows the message in the chat pane, and the compose box returns to its empty single-line size.

## Troubleshooting

- **Keys go nowhere** → you are using `win32 press_key`/`type_text`; switch to the SendInput scripts.
- **Paste inserts nothing** → clipboard was empty/old; copy (Ctrl+C / `win32 clipboard_copy`) IMMEDIATELY before pasting.
- **Wrong/no search icon at old coordinates** → the window geometry changed; re-derive the icon position (OCR/pixel scan) for the current window.
- **A Chrome permission popup appears** («web.bale.ai wants to ...») → it is not needed for text; dismiss it with its X.

## Scripts

### `type-unicode.ps1`
Low-level SendInput Unicode typing that reaches Chrome.
- `-Text "متن"` — types Persian/any Unicode; `\n` becomes Shift+Enter (newline).
- `-Paste` — SendInput Ctrl+V (pastes the *current* clipboard; set clipboard first).
- `-BackspaceCount N` — presses Backspace N times (clear a stray character before typing).
- `-DelayMs N` — pause between keys (default 20).
- `-KeyName` variants for `activate-send-enter.ps1`: `Enter` (default), `Space`, `Tab`.

## Notes

- Report progress/success to the user in Persian.
- On the reference machine Bale launches the shortcut target `C:\Program Files\Google\Chrome\Application\chrome_proxy.exe --profile-directory="Profile 1" --app-id=mncmhfnjabifclfceohglnjfnmaiajlf`.