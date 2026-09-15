# open-soroush — Open سروش پلاس (Soroush Plus) Web

Opens the **Soroush+** messenger on Windows as a Chrome app window.

## Onboarding

Soroush+ is a **Chrome App** (like Bale/Rubika): it is an HTML/JS web app running in `chrome_proxy.exe`.
General rules and SendInput-only typing apply exactly as in Bale/Rubika.

## Open

Launch the Start-menu shortcut:

```
...Start Menu\Programs\Chrome Apps\سروش پلاس.lnk
```

Equivalent target:

```
chrome_proxy.exe --profile-directory="Profile 1" --app-id=ogfbljmecljejhingpmdnjdlbcdnlgec   (site: web.splus.ir)
```

The window is titled `سروش پلاس` (fixed — does NOT change per chat).

## Verify it is ready

```
win32_list_windows        # expect a maximized "سروش پلاس" window
win32_ocr_screen fas      # full-screen OCR shows the RTL layout (list on the RIGHT, pane on the LEFT)
```

## Layout (maximized 1616x876, RTL)

- Chat LIST column is on the **right** (x≈1200-1600); filter chips «همه | شخصی | گروهها | کانالها» ≈y90-100; bottom nav «گفتگوها | تماسها | هوشواره | خدمات | حساب من» ≈y820-840.
- Chat PANE is on the **left** (x≈0-1200); chat header (name + «آخرین بازدید...») at top-left ≈(x970-1130, y35-62); composer (white box) at bottom ≈(555,830), expands UPWARD on long drafts.
- Search field «جستجو» = an INPUT at the top of the list column — UIA `EditControl` automation_id `search-input`, class `form-control`, center ≈(1450,53).

## Sending a message (hands-on recipe)

1. Ensure the agent window (opencode) is MINIMIZED so clicks land on Soroush+.
2. **Search:** click the search input (1450,53) → type the name with `type-unicode.ps1 -Text "..."` (SendInput). Confirm the typed query via `win32_uia_get_focused` (search-input value).
3. **Pick the right row:** people rows have meta «آخرین بازدید ...»; channels say «مشترک». Per the user's rule, exactly ONE 100%-matching person row → click it without asking (e.g. مهدی حبیبی at ≈(1460,392)). If ambiguous, ask the user.
4. **Verify recipient:** full-screen OCR of the chat header «<name>» + «آخرین بازدید...» in the pane (no window-title change on this app).
5. **Compose:** click the composer ≈(555,830), then `win32_clipboard_copy` the message RIGHT BEFORE pasting with `type-unicode.ps1 -Paste`.
6. **Verify draft:** `win32_uia_get_focused` → `EditControl` «پیام» (automation_id `editable-message-text`) reports the FULL draft (with `\n`) — check the value instead of OCR.
7. **Send:** `send-key.ps1 -KeyName Enter`.
8. **Confirm:** message visible in chat + composer `value:""` and back to a single-line box.

## Troubleshooting / known behavior

- **Chrome site-permission popup** «web.splus.ir wants to Show notifications» (top ≈(1119,21,334x170)) may appear — dismiss with `win32_press_key escape`. Not needed for text sends.
- **Keys don't reach Chrome** — use the SendInput helpers (`type-unicode.ps1`, `send-key.ps1`), NOT `win32_press_key`/`win32_type_text`.
- **Region OCR is unreliable** on Soroush+ (often empty) — use FULL-SCREEN OCR (`ocr_screen fas`); add `high_contrast` to read light placeholders.
- **The agent's own window steals focus** — any `question` tool call restores opencode over the app; always re-minimize + re-verify foreground afterwards.
- Use `send-key.ps1` (key-injection only) — avoid `activate-send-enter.ps1` (its SW_RESTORE un-maximizes a maximized window and Persian title matching breaks through the CLI).

## Verified on this machine (2026-09-15)

- Real send to **مهدی حبیبی** (plain name here, NOT his Rubika/Eitaa alias «مهدیار حبیبی شاندیز»): search «حبیبی» → single exact match → chat opened → header verified → «سلام مهدی جان! 👋 …» sent and visible in chat.
- **ابوالفضل احمدیان is NOT on سروش پلاس:** «ابوالفضل» → only person «ابوالفضل اکبرزاده»; «احمدیان» → only «امیر حسین احمدیان یزدی» — aborted per user rather than guessing.