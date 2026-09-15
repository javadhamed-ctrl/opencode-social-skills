---
name: open-rubika
description: Use when the user asks to open or launch the "Rubika" (روبیکا) messenger application, or to find a contact/chat and send a message in Rubika on Windows. Opens the Rubika Web Chrome app window and drives it via low-level SendInput since synthetic key events do not reach Chrome. Also covers the faster API-based approach (rubpy) when UI automation is too slow.
---

# Open Rubika messenger & send messages

## Two approaches

### 1. UI Automation (slower, ~5-8 min/message)
Opens the Rubika Web Chrome app window and drives it via low-level SendInput. See sections below for the full recipe.

### 2. API — rubpy (faster, ~1 min/message)
Uses the unofficial `rubpy` Python library (`pip install rubpy`) to log in and send messages programmatically. **⚠️ Risk of temporary ban; only works for personal accounts without 2FA.**

Key details:
- `pip install rubpy` (v7.3.5+ works on Python 3.14)
- **Critical**: rubpy's DEFAULT_PLATFORM has `platform: 'PWA'`, `package: 'm.rubika.ir'`, `app_version: '2.4.6'` → server returns INVALID_INPUT. Must override to Web:
  ```python
  app.DEFAULT_PLATFORM.update({
      'app_version': '4.4.34',
      'platform': 'Web',
      'package': 'web.rubika.ir',
      'lang_code': 'fa',
  })
  ```
- API version is 6, encrypted with AES-CBC using `Crypto.passphrase(tmp_session)` where `tmp_session` is a 32-char lowercase random string.
- Flow: `Client("name", platform="PWA")` → `connect()` → `get_dcs()` → `send_code(phone)` → read SMS code → `sign_in(code, phone, phone_code_hash, public_key)` → `register_device(...)` → `send_message(object_guid, text)`.
- RSA keys generated via `Crypto.create_keys()`. The `public_key` goes into `sign_in()`, the `private_key` is used for `import_key` and message signing.
- After signIn, `auth` is decrypted via `Crypto.decrypt_RSA_OAEP(private_key, auth_enc)`, then `app.key = Crypto.passphrase(auth)`.
- To find a contact: call `get_contacts()` and search `original_update.first_name` / `last_name` for the Persian name (use unicode search, NOT console print — cp1256 console corrupts Persian).
- `send_message(object_guid=user_guid, text=message)` returns `status: OK` on success.

See `rubika-login-final.py` pattern in the workspace for a working end-to-end example.

## What this skill does (UI approach)

- Opens the Rubika Web window.
- Finds any contact/chat by name (search box → type name → click a dropdown hit row).
- Sends multi-line, Persian/RTL Unicode messages with a real Enter press.
- Verifies the recipient (chat header), verifies the draft, and verifies delivery (message in chat + emptied compose box).

## Tested status (UI)

| Network | Status |
|---|---|
| **Rubika (روبیکا)** — `web.rubika.ir` Chrome app | ✅ **tested end-to-end** — two real sends verified in chat: ابوالفضل احمدیان and مهدی حبیبی (= saved as «مهدیار حبیبی شاندیز»). |
| Bale (بله) and other networks | see the `open-bale` skill / repo README registry |

## Platform requirements

Identical to `open-bale` (vision-capable model recommended; `win32` MCP + Tesseract `fas/ara/eng`; PowerShell 5.1; interactive logged-in session; user-space permissions only).

## Launch Rubika

```powershell
Start-Process -FilePath "C:\Users\<you>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\Rubika.lnk"
```

The window is titled `Rubika - پیام رسان وب روبیکا`. It may open un-maximized or maximized — check current geometry with `win32 list_windows`.

## Find a contact & send a message (verified end-to-end recipe)

Verified on a 1600x900 display; Rubika window maximized at (-8,-8,1616x876). **All coordinates are session-specific — always re-derive by OCR/pixel.**

1. **Focus Rubika** and ensure it is the foreground window.
2. **Locate the search box**: it is in the **top-right area of the chat column** (right side of the window), next to a hamburger menu, with a magnifier icon and the placeholder «جستجو».
   - Verified position (maximized 1616-wide window): input `EditControl` named «جستجو», bounds ≈ (1203,33,334x42), center ≈ (1370,54).
3. **Focus the search input** (click it) and confirm with `win32 uia_get_focused` → `EditControl` named «جستجو» (class `input-field-input input-search-input …`).
4. **Type the name** with `type-unicode.ps1 -Text "<name>"`. Confirm via `uia_get_focused` that the `value` equals the name.
5. **Read the dropdown hit rows** — they appear **under the search box**. `win32 ocr_region_structured` on that area returns per-row coordinates (name + avatar). Click candidates can be listed twice (a chat + a contact, or the current selection) — pick the first hit row.
   - Verified example (maximized 1616-wide window): search input at y≈33-75, first hit row ≈ y180, second ≈ y245; clicks in the empty gap between input and rows do NOTHING (and dismiss the dropdown). Gap rows ≈ y80-165.
6. **Click the first hit row**; the chat opens (left pane turns from the green welcome screen to the conversation).
7. **Verify the recipient**: OCR the top of the chat pane — the header must show the expected name. Rubika app windows have **no omnibox**, so rely on header OCR (plus the fact the row came from searching the name). Never send if you are not sure.
8. **Copy the message**: `win32 clipboard_copy` the exact text — immediately before pasting.
9. **Focus the compose box**: click the white input at the bottom of the chat pane and confirm with `uia_get_focused` → `GroupControl` with class `composer_rich_textarea`. Verified center ≈ (562,812) in the maximized layout.
10. **Paste**: `type-unicode.ps1 -Paste`; the box expands to many lines when it holds a long message.
11. **Verify the draft** with OCR (the bottom area of the chat pane).
12. **Send**: `activate-send-enter.ps1 -WindowTitle "Rubika" -KeyName Enter`.
13. **Confirm sent**: OCR shows the message in the chat pane (with today's date separator above it), and the compose box returns to its empty single-line (~21px tall) size.

## Contact-searching protocol (learned live, verified 2026-09-15)

A rubika user may be **saved under a different name** than the one you search for (prefix/suffix in first or last name). The user teaches this general rule:

1. Query the full name you know. If only **CHANNEL rows appear** (each marked «... مشترک»), the person is not under that exact name.
2. Go through **search variants** — surname alone → first name alone → Latin/Arabic spellings — and show the user the resulting rows before assuming anything.
3. If several similar accounts appear, **present them numbered and ask the user which is their target**; never guess.
4. When the user reveals the saved alias, **save it** (repo memory) for future sessions.

Verified real case: «مهدی حبیبی» is saved in Rubika as **«مهدیار حبیبی شاندیز»**. Searching «مهدیار» puts the saved contact at the top of the dropdown inside a «گفتگوها و مخاطبین» (chats & contacts) group — click that first contact row (maximized coords ≈ (1450,168)); the chat header then reads «مهدیار حبیبی شاندیز» (RTL right side ≈ (976-1099,44)) with an «اطلاعات کاربر» button on the left. The «سلام مهدی جان! …» GitHub-announcement message was sent and verified in chat.

## Troubleshooting — Rubika-specific

- **Window/region OCR returns EMPTY or the screen looks blank/green at odd times** → Rubika's welcome state is a big green leafy illustration with almost no text, and OCR is unreliable on parts of this app. Use **full-screen OCR** (`win32 ocr_screen` / `ocr_screen_structured`) to locate UI text, then small **region OCR** around the found coordinates. Don't interpret "no text" as "no app".
- **Dropdown rows don't match clicking** → the y-gap between the search input and the first result contains nothing clickable; hit rows start ≈ 100px below the input. Use `ocr_region_structured` to get exact row coordinates.
- **The chat pane suddenly moves mid-session** → `activate-send-enter.ps1` calls SW_RESTORE, which **un-maximizes** a maximized window (geometry + all coordinates change). If you need the maximized layout again, re-maximize and re-derive coordinates.
- **Keys go nowhere / paste inserts nothing** → same as Bale: use the SendInput scripts, and copy to the clipboard immediately before each paste.
- **API approach gets INVALID_INPUT** → rubpy's DEFAULT_PLATFORM has wrong app_version/package/platform. Override `DEFAULT_PLATFORM` to `{app_version: '4.4.34', platform: 'Web', package: 'web.rubika.ir', lang_code: 'fa'}` before any API call. See the API section at the top of this file.

## Notes

- Report progress/success to the user in Persian.
- On the reference machine Rubika launches via `chrome_proxy.exe --profile-directory=Default --app-id=kdoebaimmlkaijikcapmkpnnbnmmbhke`.