---
name: open-eitaa
description: Use when the user asks to open or launch the "Eitaa" (ایتا) messenger application, or to find a contact/chat and send a message in Eitaa on Windows. Opens the Eitaa Desktop app and drives it via UIA/OCR plus low-level SendInput.
---

# Open Eitaa messenger & send messages

Eitaa (ایتا) is a Persian messenger. On Windows it is a **native Qt desktop app** (Process `Eitaa`), so — unlike Chrome-based Bale/Rubika — keystrokes and clipboard paste DO reach its fields (`win32 type_text` and the `type-unicode.ps1` SendInput helper both work), and **UI Automation exposes the fields AND the focused compose box's full value**. This skill documents the Eitaa-specific layout and traps.

## What this skill does

- Opens the Eitaa Desktop window.
- Finds a contact/chat by name (search field at the top of the chat-list column).
- Sends multi-line, Persian/RTL Unicode messages with a real Enter press.
- Verifies the recipient (**window title shows the open chat's name** + in-pane header) and delivery (focused compose value becomes empty and single-line).

## Tested status

| Network | Status |
|---|---|
| **Eitaa (ایتا)** — native Qt desktop app | ✅ **tested end-to-end** — two real sends verified in chat: ابوالفضل احمدیان and مهدی حبیبی (= saved as «مهدیار حبیبی شاندیز», the SAME alias as in Rubika). |
| Bale (بله) and Rubika (روبیکا) | see the `open-bale` / `open-rubika` skills and the repo README registry |

## Platform requirements

Identical to `open-bale`/`open-rubika` (`win32` MCP + Tesseract `fas`; PowerShell 5.1; interactive logged-in session; user-space permissions). Eitaa must be **logged in** already.

## Launch Eitaa

```powershell
Start-Process "C:\Users\<you>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Eitaa Desktop\Eitaa.lnk"
```

The window is a native Qt app. Its title is **`<chat name> @ <username> (N)`** — e.g. `ایتا @ جواد حامد` when no chat is open, then it **changes to the open chat's name** (e.g. `ابوالفضل احمدیان @ جواد حامد`). Never match the window by the literal «ایتا».

## Find a contact & send a message (verified end-to-end recipe)

Verified on a 1600x900 display; Eitaa maximized at (-8,-8,1616x876). **All coordinates are session-specific — always re-derive by OCR/pixel.**

1. **Focus Eitaa** (`focus_window`) and verify it is foreground (full-screen OCR). While Eitaa is maximized it covers the whole screen — keep the agent's own window minimized.
2. **Search field**: at the **top of the chat-list column** (right of the left icon rail). It is a `QTextEdit` `EditControl` at ≈ `(95,41,457x22)`, center `(323,52)`.
3. **Type the name**. Both `win32 type_text` (paste method, copies to clipboard itself) and `type-unicode.ps1 -Text "<name>"` reach Qt fields. IMPORTANT: **OCR cannot read the tiny search field** — do NOT verify the query by reading the field; verify by FULL-SCREEN OCR of the results below it (e.g. «نتیجه‌ای برای «...» پیدا نشد» or the result rows).
4. **Read the results** with full-screen / structured OCR. A filter-chips row `سراسری | عمومی | شخصی | عناوین | گفتگوها` sits ≈ y88-93 under the field; the first hit row starts ≈ y120, rows are ~28-35px tall (two-line rows for channels). Typing the full name narrows results; a query that returns only CHANNEL rows means the person isn't under that name — try surname alone → first name alone → Latin/Arabic spellings (see `open-rubika` for the full search-variant protocol).
5. **Pick the row WITHOUT guessing**: click immediately, then confirm. If several similar results appear but exactly ONE matches the target name 100%, that one is the target (user-refined rule — no need to ask). Ask the user only when multiple results match exactly or none matches.
6. **Verify recipient BEFORE sending** — two independent proofs:
   - **Window title** now shows the open chat's name, e.g. `مهدیار حبیبی شاندیز @ جواد حامد`. (This is verification #1.)
   - **Chat header** in the pane shows the name + «آخرین بازدید ...» (the last-seen line only appears on PERSON chats, not channels).
7. **Copy the message**: `win32 clipboard_copy` the exact text — immediately before pasting.
8. **Focus the compose box**: `EditControl` `QTextEdit` at ≈ `(664,823,556x28)`, center `(942,837)`. Confirm with `uia_get_focused`.
9. **Paste**: `type-unicode.ps1 -Paste` (SendInput Ctrl+V). A long draft makes the box expand upward (~206px tall).
10. **Verify the draft** — unlike the search field, the focused compose **does expose its value via UIA**: `uia_get_focused` returns the ENTIRE draft text (with `\n` and links intact) — use that instead of OCR.
11. **Send with Enter**: `send-key.ps1 -KeyName Enter`. This helper injects ONLY the key (no window find/activate/SW_RESTORE) so the geometry stays put. Do NOT use `activate-send-enter.ps1`: its `StartsWith(prefix)` title match breaks when the Persian title is passed through the PowerShell CLI, and its `SW_RESTORE` un-maximizes the app.
12. **Confirm sent**: `uia_get_focused` on the compose shows `value: ""` and the box returns to single-line 28px; full-screen OCR shows the message in the chat pane (and the search-list preview updates to the first line of the message).

## Troubleshooting — Eitaa-specific

- **The tiny search field OCRs as empty even when it has text** → always read the query state from the RESULTS area or the «بدون نتیجه» message, not the field itself. The search `QTextEdit` also reports `value: ""` via UIA.
- **Mid-session clicks/typing go nowhere (or hit the DEFAULT list)** → the opencode UI was restored on top (the `question` tool does this). Re-minimize opencode, re-focus Eitaa, and verify with full-screen OCR before continuing.
- **The window title is Persian → can't be passed as a CLI arg** → never pass Persian window titles to PowerShell scripts; instead re-focus via `focus_window` (accepts the title directly) and use key-only helpers like `send-key.ps1`.
- **«اعلانهای سرویس» chat opens by itself** → that's the default first list item; it happens when a click lands while the search results have collapsed. Re-derive the row coordinates and re-click.
- **Behavior after a send** → Eitaa keeps the window maximized with `send-key.ps1` (no restore side effects), so coordinates remain valid for the next action.

## Notes

- Report progress/success to the user in Persian.
- Verified 2026-09-15 on this machine: process name `Eitaa`, AppID `Eitaa.EitaaDesktop`, window class `TWidget`, fields `QTextEdit`.
- On this machine the contact «مهدی حبیبی» is saved under the alias «مهدیار حبیبی شاندیز» in **both** Eitaa and Rubika — a user-confirmed alias is person-specific and likely identical across networks. Save revealed aliases for future sessions.