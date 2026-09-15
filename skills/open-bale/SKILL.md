---
name: open-bale
description: Use when the user asks to open or launch the "Bale" (بله) messenger application, or to find a contact/chat and send a message in Bale on Windows. Opens the Bale Web Chrome app window and drives it via low-level SendInput since synthetic key events do not reach Chrome.
---

# Open Bale messenger & send messages

The user's "Bale" (بله) messenger is installed as a **Chrome App** on their Windows machine — there is no native `bale.exe`. It is launched through a Chrome App Store shortcut. The web app (`web.bale.ai`) runs inside Chrome, which **ignores synthetic key events** (`win32 press_key` / `type_text`), so real low-level SendInput is required for typing/pasting.

## API-based approach (Bot API) — faster than UI automation

- **Endpoint:** `https://tapi.bale.ai/bot<token>/method` (Telegram Bot API compatible)
- **Prerequisite:** Bot token from BotFather in Bale Web (search "@BotFather" → `/newbot`)
- **Library:** `pip install python-telegram-bot` (v20+)
- **Usage:**
  ```python
  import asyncio
  from telegram import Bot
  
  bot = Bot(token="YOUR_BALE_BOT_TOKEN", base_url="https://tapi.bale.ai")
  await bot.send_message(chat_id=USER_CHAT_ID, text="پیام شما")
  ```
- **Limitation:** Can ONLY message users who already started chat with bot (sent /start). No proactive messaging to arbitrary users.
- **Workaround:** Use UI automation (below) or have recipients message bot first.
- **Verified:** Endpoint responds (403 without token, 404 wrong path). Format matches Telegram Bot API exactly.
- **No personal MTProto API:** Telethon with Bale unverified; Bale uses custom MTProto servers. Bot API is the only confirmed programmatic path.

## General rule (applies to EVERY social network)

To find any contact/chat quickly, use ONE of these two paths (try 2 when 1 is not obvious):
1. **Click the search (magnifier) icon** and type the name.
2. **Click the "contacts" icon/page** — it usually opens a contact list WITH a search box.

Other universal rules:
- **Never paste without copying first** — set the clipboard right before pasting.
- **Send with Enter** (Shift+Enter = newline) — do not hunt for a send button.
- **Verify the recipient** (chat header shows the right name) before sending.

## Launch

1. Launch the shortcut (with `Start-Process`; do NOT guess an exe name):

```powershell
Start-Process -FilePath "C:\Users\Parspano\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\Bale Web.lnk"
```

2. Note the window title/geometry — it may appear as `Bale Web` or `Bale Web (2)` and can resize/move between sessions (`win32 list_windows` for current bounds; absolutely-positioned icons change, so re-derive each session).

## Helpers (REPLACES win32 press_key/type_text for Chrome)

Run via `powershell -NoProfile -ExecutionPolicy Bypass -File ...` (execution policy blocks direct calls):

- `C:\Users\Parspano\AppData\Local\Temp\opencode\type-unicode.ps1`
  - `-Text "متن"` — SendInput Unicode typing (Persian works); `\n` → Shift+Enter.
  - `-Paste` — SendInput Ctrl+V (only after setting the clipboard; pastes current clipboard).
  - `-BackspaceCount N` — clear stray text before typing.
- `C:\Users\Parspano\AppData\Local\Temp\opencode\activate-send-enter.ps1`
  - `-WindowTitle "Bale Web" -KeyName Enter` — activates the window, then SendInput Enter (send).

## Find a contact & send a message (verified end-to-end recipe)

1. **Focus Bale** and make sure it is the foreground window.
2. **Open search**: click the magnifier icon at the top of the chat-list column. Its absolute position is unstable — probe with OCR/pixel scan of the top-of-column band (examples that worked: maximized ⇒ ~(1368,53); 903-wide right-side window ⇒ ~(1460,51)). Confirm the placeholder «جستجوی کانال، گروه و پیام...» appeared.
3. **Focus the search input** (click near the placeholder) and verify with `win32 uia_get_focused` → `EditControl` (class `e8AzTv`, bounds ~(1220,50,230x24), center ~(1335,62)).
4. **Type the name** with `type-unicode.ps1 -Text "<name>"`; re-check the field `value` via `uia_get_focused` — it must contain the name exactly once.
5. **Click the first result** row (its center ≈ name row y≈190 in a 903-wide layout); the chat opens.
6. **Verify the recipient**: `win32 ocr_window` — the header line must show the expected name, and optionally `uia_find_control` on the omnibox `Address and search bar` shows `web.bale.ai/chat?uid=...` (a different uid = different chat). Compound chat headers can garble; the subtitle (last seen, e.g. «دیروز ساعت ۲۳:۵۲ اینجا بوده») plus the full-window OCR usually disambiguate. Never send if the header is wrong.
7. **Copy the message**: `win32 clipboard_copy` the exact text — this MUST be right before the paste step.
8. **Focus the compose box**: click at ~(900,800); verify with `uia_get_focused` → `GroupControl` `editable-message-text` (bounds ~(811,796,321x19)).
9. **Paste**: `type-unicode.ps1 -Paste`; the box grows (e.g. to ~(811,586,321x240)).
10. **Verify the draft** with OCR (bottom-left region of the pane shows the message body).
11. **Send**: `activate-send-enter.ps1 -WindowTitle "Bale Web" -KeyName Enter`.
12. **Confirm sent**: OCR shows the message in the chat pane, and the compose box returns to its empty single-line bounds (~19px tall).

## Do NOT

- Use `win32 press_key`/`type_text` to type into Bale — keys go nowhere.
- Hunt for a visible "send" button — Enter is the send key.
- Click ~(1150,805) on the compose bar — it can open a Chrome microphone permission dialog (dismiss via its X near the top-right of the window); text sending needs no permissions.
- Click blind coordinates for the search icon — re-derive by OCR/pixel scan each session.

## Notes

- Shortcut target is `C:\Program Files\Google\Chrome\Application\chrome_proxy.exe --profile-directory="Profile 1" --app-id=mncmhfnjabifclfceohglnjfnmaiajlf`.
- Report progress/success to the user in Persian.