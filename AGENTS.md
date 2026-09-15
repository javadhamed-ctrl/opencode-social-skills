# Global instructions for working with this user

## User profile

- Name: Javad Hamed (جواد حامد)
- Experienced software developer (30 years)
- Uses modern AI-assisted ("pair"/vibe) coding heavily
- Language of UI/communication: Persian; keep technical content (code, README, filenames, comments) in English (GitHub audience)
- Runs Windows (PowerShell 5.1, no POSIX shell)

## GitHub publishing details (IMPORTANT — used whenever publishing a project)

- GitHub username (owner): `javadhamed-ctrl`
- Commit identity:
  - `user.name` = `Javad Hamed`
  - `user.email` = `javadhamed@gmail.com`
- Repo URL pattern: `https://github.com/javadhamed-ctrl/<repo>.git` (HTTPS)
- Default branch: `main`
- Existing published project: `sox-gui-windows` (a PowerShell + WPF GUI wrapper for SoX)

### Preferred workflow when the user asks to publish a new project

1. Prepare a clean project folder (copy only the relevant project files, never a whole third-party distribution).
2. Include `README.md` and a `LICENSE` (GPL-3.0 when the project wraps GPL software like SoX).
3. GitHub repo creation is done BY THE USER in the browser (they are a git beginner):
   - New repository → name → **Public** → description in the repo's `Description` box — do NOT tick any "Initialize this repository with..." option (must be empty so push works cleanly).
4. Do all local git work for them: `git init` → `git branch -M main` → set identity → stage intent-relevant files → commit with a short descriptive message.
5. `git remote add origin https://github.com/javadhamed-ctrl/<repo>.git` then `git push -u origin main`.
   - First push opens the Git Credential Manager sign-in window; warn the user to click Sign in / go to browser and complete login.
   - PowerShell prints git stderr as red "git :" errors — those are NOT failures; confirm success via the refs line and `git ls-remote`/`git status`.
6. README convention: short intro, feature list, requirements, usage, "Author & how this project was built" section crediting the author and stating the project was built via AI-assisted coding on the opencode platform (https://opencode.ai) with the `opencode/big-pickle` model, and statements about genuinely testing/verifying the project.
7. An image inside the README is nice but NOT required per feature/tab; one main screenshot is enough.

### When updating an existing published project

- The user says "update/publish" — commit and `git push` the local repo. Ask before committing if ambiguous; never push secrets.

## Desktop automation (installed MCP)

- MCP server `win32` is configured in opencode.jsonc → `python -m win32_mcp_server` (package `win32-mcp-server`, mcp SDK pinned to 1.x).
- Provides 53 tools incl. OCR (`find_text_on_screen`, `click_text`, `ocr_window`), screenshots, mouse/keyboard, window/process control.
- Tesseract OCR: user-local copy at `C:\Users\Parspano\AppData\Local\Tesseract-OCR` (first on user PATH), langs: `eng, fas, ara, osd` — use `lang` `fas` (or `ara`) for Persian UI text. A system copy also exists at `C:\Program Files\Tesseract-OCR`. Python is `C:\Python314\python.exe`.
- The assistant cannot read images; always use OCR/text tools over raw screenshots to "see".
- Trusted background: the user is teaching daily repetitive tasks (opening apps, sending messages in the Bale messenger) for delegation.
- GOAL: build a clean, GitHub-public skill that lets anyone drive social networks via this agent. The user teaches me step by step, one network at a time; I must learn ONE general rule that applies to every network and reuse it.

## Social networks — GENERAL RULES (learned from the user, apply to EVERY network)

1. To find any contact/chat quickly, use ONE of these two paths (try 2 when 1 is not obvious):
   - **Click the search (magnifier) icon** and type the name.
   - **Click the "contacts" icon/page** — it usually opens a contact list WITH a search box.
2. **Never paste without copying first.** Ctrl+V only pastes what was previously copied (Ctrl+C). When using a scripted paste, ALWAYS set the clipboard right before pasting.
3. **To send in messengers, always press Enter** — do not hunt for the send button (Enter = send in these apps; Shift+Enter = newline).
4. Before sending, VERIFY the recipient (chat header shows the right name) — never send to the wrong person.
5. **Search-variant protocol (user's lesson, applies to EVERY network):** a contact may be saved in the app under a DIFFERENT name than the one the user says (prefixes/suffixes: «مهدی» ↔ «مهدیار», «حبیبی» ↔ «حبیبی شاندیز»), or may have several accounts/similar names, or no account at all. So: (a) after one query, if the target isn't found/in doubt, try the surname ALONE, then the first name ALONE, then Latin/Arabic spellings — until sure the contact doesn't exist; (b) if several similar accounts appear but exactly ONE matches the target name 100%, DON'T ask — that one is the target (user refinement, verified on Eitaa); (c) only PRESENT numbered results and ask the user when NO result matches exactly OR multiple results match exactly — never guess in that case; (d) distinguish PERSONAL accounts from CHANNELS/GROUPS in the results and pick per the user's goal.
6. When the user reveals a saved-name alias (e.g. "مهدی حبیبی = مهدیار حبیبی شاندیز"), SAVE it (this file) for future sessions. NOTE: the SAME alias held in BOTH Rubika and Eitaa on this machine — treat a confirmed alias as person-specific and likely cross-network.
7. **opencode tool-state trap:** the `question` tool (and any opencode UI action) RESTORES the opencode window on top of the desktop → subsequent clicks/typing go to opencode, NOT the messenger. After every question, re-minimize opencode and verify with full-screen OCR that the target app is foreground before continuing.

## Bale (بله) on THIS machine — proven recipe (verified end-to-end)

- Bale = Chrome app window (opened via the `open-bale` skill). Watch WHATS states: window may resize/move between `Bale Web`/`Bale Web (2)` etc.; `list_windows` for current geometry.
- `win32 press_key`/`type_text` DON'T reach Chrome (keys go nowhere). Use REAL low-level injection instead:
  - Helpers (reusable): `C:\Users\Parspano\AppData\Local\Temp\opencode\type-unicode.ps1` (SendInput Unicode typing, Shift+Enter for `\n`, optional clipboard paste via SendInput ctrl+V, optional backspaces) and `activate-send-enter.ps1` (activate window by title prefix, then SendInput a key e.g. Enter). Run via `powershell -NoProfile -ExecutionPolicy Bypass -File ...`.
  - SendKeys from PowerShell also works for ASCII (`[System.Windows.Forms.SendKeys]::SendWait('a')`); clipboard-paste needs `win32_clipboard_copy` RIGHT BEFORE the paste.
  - Requesting the menu/search: click the search (magnifier) icon at the top of the chat-list column, then the placeholder «جستجوی کانال، گروه و پیام...» appears. IMPORTANT: absolute icon coords are NOT stable (the window resizes/moves between `Bale Web`/`Bale Web (2)`); re-derive each session by OCR/pixel scan of the top-of-column band (working examples: maximized window ⇒ ~(1368,53); 903-wide right-side window ⇒ ~(1460,51)). Verify with `uia_get_focused` (EditControl `e8AzTv`, bounds ~(1220,50,230x24)); input center ~(1335,62).
- Recipe: open search → type name (SendInput Unicode) → click first result → verify header via OCR/UIA → `win32_clipboard_copy` the message → paste with SendInput ctrl+V → verify draft via OCR → **Enter** to send → verify compose box emptied.
- Known dialog that appears sometimes: Chrome site-permission popup («web.bale.ai wants to ...») — dismiss with its X; not needed for text.

## Rubika (روبیکا) on THIS machine — proven recipe (verified end-to-end)

- Rubika = Chrome app window titled `Rubika - پیام رسان وب روبیکا`, opened via the `open-rubika` skill / shortcut `...Chrome Apps\Rubika.lnk` (`--app-id=kdoebaimmlkaijikcapmkpnnbnmmbhke`, profile `Default`).
- Same general rules + same SendInput helpers as Bale; rubika keys DON'T reach Chrome either.
- **Search box is at the top-RIGHT of the chat column** (next to a hamburger), magnifier + placeholder «جستجو». UIA `EditControl` «جستجو» (class `input-field-input input-search-input …`). Verified (1616-wide maximized): bounds ~(1203,33,334x42), center ~(1370,54).
- **Search-results dropdown appears UNDER the search box.** Get exact row coordinates with `ocr_region_structured` — first hit row ≈100px below the input (verified: rows ≈ y180/y245 when input is y33-75). Clicks in the gap do nothing & dismiss the dropdown.
- **OCR is unreliable on Rubika** (window-filtered/region OCR often returns EMPTY; the welcome screen is a big green leafy illustration with almost no text). Use FULL-SCREEN OCR (`ocr_screen`/`ocr_screen_structured`) to find text, then small region OCRs around it.
- Compose field: `uia_get_focused` → `GroupControl` class `composer_rich_textarea` (verified center ~(562,812) maximized; long drafts expand to many lines).
- Send = `activate-send-enter.ps1 -WindowTitle "Rubika" -KeyName Enter`; confirm by message visible in chat + composer empty single-line (~21px).
- **CAVEAT:** `activate-send-enter.ps1` uses SW_RESTORE → a MAXIMIZED window gets UN-maximized mid-flow (geometry + all coords change; Rubika went (1616x876) → (922x708) @(678,0)). Same for Bale. Re-check geometry after sending.
- Verified 2026-09-15: real send to ابوالفضل احمدیان (سلام ابوالفضل جان! + GitHub link message) confirmed in chat.
- **SAVED NAME ALIAS (user-confirmed):** the contact «مهدی حبیبی» is saved in Rubika as **«مهدیار حبیبی شاندیز»** — searching «مهدی حبیبی» or «حبیبی» does NOT surface him as a person. Verify-only pathway that WORKED: search «مهدیار» → the top of the dropdown shows a «گفتگوها و مخاطبین» group and the FIRST contact row there = «مهدیار حبیبی شاندیز» (maximized screen coords ~(1450,168)), click opens his chat (header reads «مهدیار حبیبی شاندیز» right side ~(976-1099,44) + «اطلاعات کاربر» left ~(218,44)). Message with greeting «سلام مهدی جان!» sent and confirmed in chat on 2026-09-15.
- Lesson learned (user): a query that returns only CHANNEL rows (each marked «... مشترک») means the PERSON isn't under that exact name; step through search variants instead (surname alone → first name alone → Latin/Arabic), asking the user to pick among similar-name results, before concluding the contact has no account.

## Eitaa (ایتا) on THIS machine — proven recipe (verified end-to-end 2026-09-15)

- Eitaa = **native Qt desktop app** (`Eitaa.EitaaDesktop` / process `Eitaa`), shortcut `...Start Menu\Programs\Eitaa Desktop\Eitaa.lnk`. Window class `TWidget`; fields are `QTextEdit` in UIA. Window title is `<ChatName> @ <Username> (N)` — it CHANGES when you open a chat («ایتا @ جواد حامد» → «ابوالفضل احمدیان @ جواد حامد»). Do NOT match by the literal «ایتا».
- **Window-title prefix = recipient verification #1:** after clicking a search row, the window title shows exactly the opened chat name (e.g. «مهدیار حبیبی شاندیز @ جواد حامد»). Combined with in-pane header OCR («آخرین بازدید ...» only appears on PERSON chats), this is solid proof before sending.
- Qt app → typing DOES reach fields (unlike Chrome): `win32_type_text` (paste method) AND `type-unicode.ps1` both work. UIA exposes the fields AND the **focused compose QTextEdit's VALUE** (full draft text incl. links, `\n` newlines) — use `uia_get_focused` to read/verify the draft instead of OCR. The SEARCH QTextEdit, however, reports `value: ""` even with text — verify search state via FULL-SCREEN OCR («بدون نتیجه / نتیجه‌ای برای ... پیدا نشد» or the results rows).
- **Layout (maximized 1616x876):** search field QTextEdit `(95,41,457x22)` center `(323,52)` at top of the chat-list column; filter chips row «سراسری | عمومی | شخصی | عناوین | گفتگوها» ≈ y88-93 under it; result rows start ≈ y120 (first row), ~28-35px each (two-line rows for channels). Compose QTextEdit `(664,823,556x28)` center `(942,837)`; expands upward (~206px) when a long draft is pasted, shrinks to 28px single-line after send (= delivery proof via `value:""` + height).
- Search results show MANY people/kannel rows per name (ابوالفضل احمدیان / ابوالفضل channel / ابوالفضل اعرابی / ابوالفضل نعیمی / سید ابوالفضل گل سرخی...) → row-1-click must be a FRESH row (state can change under you), then confirm via window title + header.
- **Send key:** use `send-key.ps1 -KeyName Enter` (KEY-injection only, NO window restore → geometry stays maximized). Do NOT use `activate-send-enter.ps1` for Eitaa: its `StartsWith(prefix)` match fails on Persian titles passed through the PowerShell CLI (mojibake «?��») and SW_RESTORE un-maximizes the window.
- **opencode overlay trap (double-confirmed):** the `question` tool restores the opencode window over the left half of the screen → my clicks/typing went to opencode, not Eitaa (the bad click even fell on the default-list first item «اعلانهای سرویس»). Always re-minimize opencode + full-screen OCR before continuing.
- Verified 2026-09-15, both sends end-to-end: **(1)** ابوالفضل احمدیان — search «ابوالفضل» (5 rows, exactly ONE exact match → NO question per user's rule) → click row1 → title «ابوالفضل احمدیان @ جواد حامد» + header «آخرین بازدید یک ماه پیش» → draft «سلام ابوالفضل جان! 👋 …sox-gui-windows GitHub + opencode links…» verified via focused-control value → Enter → compose empty + message in chat; **(2)** «مهدی حبیبی» → ONLY result «مهدیار حبیبی شاندیز» (تماس لغو شده) → title «مهدیار حبیبی شاندیز @ جواد حامد» → same body «سلام مهدی جان! 👋 …» → Enter → confirmed.
- **CROSS-NETWORK ALIAS CONFIRMED:** «مهدی حبیبی» is saved as «مهدیار حبیبی شاندیز» in BOTH Rubika and Eitaa — a user-confirmed alias is person-specific and likely identical across networks (though on Soroush+ he IS under the plain name «مهدی حبیبی» — verify per network, name-save styles differ).

## Soroush Plus (سروش پلاس) on THIS machine — proven recipe (verified 2026-09-15)

- Soroush+ = Chrome app window titled `سروش پلاس` (fixed title — it does NOT change per chat). Shortcut `...Chrome Apps\سروش پلاس.lnk` → `chrome_proxy.exe --profile-directory="Profile 1" --app-id=ogfbljmecljejhingpmdnjdlbcdnlgec`, site `web.splus.ir`. Same SendInput-only rule as Bale/Rubika (`press_key`/`type_text` DON'T reach Chrome).
- **Layout (maximized 1616x876, RTL):** chat LIST column on the RIGHT (x≈1200-1600), chat PANE on the LEFT (x≈0-1200). Filter chips «همه | شخصی | گروهها | کانالها» at y≈94. Bottom nav «گفتگوها | تماسها | هوشواره | خدمات | حساب من» at y≈820-840 (x≈1200-1600).
- **Search field «جستجو» = an actual INPUT at the top of the list column**: UIA `EditControl` automation_id `search-input`, class `form-control` — bounds (1315,33,270x40), center (1450,53); its **value is readable AND settable via UIA** (the typed query is always confirmed via the UIA value). Placeholder «جستجو» only OCRs with `high_contrast` + full-screen.
- **BEST feature vs Bale/Rubika: Soroush+ DOES expose DOM inputs via UIA.** The composer is `EditControl` «پیام», automation_id `editable-message-text`, class `form-control allow-selection touched`; `uia_get_focused` returns the FULL draft (with `\n`) — verify drafts via VALUE, no OCR needed.
- Search results dropdown: PEOPLE rows (meta «آخرین بازدید ...», no تعداد) then a «جستجوی سراسری» header, then CHANNELS (each with «مشترک» count). Click the person row → drop-down closes, chat opens. Recipient verification = chat-header OCR in the pane: «<name>» + «آخرین بازدید...» at ≈(x970-1130, y35-62) (no window-title change here).
- Composer: white box at bottom of LEFT pane ≈(555,830); expands UPWARD on long drafts (verified post-paste bounds (291,550,533x290), center (557,695)) then shrinks back to a single line after send (= delivery proof).
- **Region OCR is unreliable (returns EMPTY on app content) — use FULL-SCREEN OCR (`ocr_screen` fas) like Rubika; `high_contrast` for placeholders.**
- Chrome site-permission popup «web.splus.ir wants to Show notifications» may appear (bounds (1119,21,334x170)) — dismiss with Esc; not needed for text.
- Send = `send-key.ps1 -KeyName Enter`. Message visible in chat + composer UIA `value:""` = success.
- **Contacts on this machine (user's reach):** «مهدی حبیبی» IS found on Soroush+ under the PLAIN name (search «حبیبی» → single exactly-matching person row «مهدی حبیبی» / «آخرین بازدید خیلی وقت پیش» at ~(1460,392) → clicked → header verified → «سلام مهدی جان! 👋 …» sent and confirmed in chat 2026-09-15). **«ابوالفضل احمدیان» is NOT on سروش پلاس:** «ابوالفضل» → only person «ابوالفضل اکبرزاده» (+ channels); «احمدیان» → only «امیر حسین احمدیان یزدی» (+ channels) — per user, ABORTED (skipped) rather than guessing. Lesson → when global results show only channels + non-matching people, the contact has no account under ANY variant on that network.

## Rubika (روبیکا) — API-based approach via rubpy

- **Goal:** Send personal messages faster than UI automation (~1 min vs ~5-8 min). Uses unofficial `rubpy` library (⚠️ ban risk, no 2FA accounts).
- **`pip install rubpy`** (v7.3.5+ works on Python 3.14).
- **CRITICAL platform override:** rubpy DEFAULT_PLATFORM (`platform:'PWA'`, `package:'m.rubika.ir'`, `app_version:'2.4.6'`) → server returns INVALID_INPUT. Must override before any API call:
  ```python
  app.DEFAULT_PLATFORM.update({'app_version':'4.4.34','platform':'Web','package':'web.rubika.ir','lang_code':'fa'})
  ```
- **API format:** `api_version='6'`, `tmp_session=<32-char lowercase random>`, `data_enc=AES-CBC-encrypt({method,input,client}, key=Crypto.passphrase(tmp_session))`.
- **Login flow:** `Client("name", platform="PWA")` → `connect()` → `get_dcs()` → `send_code(phone)` → read SMS → `sign_in(code, phone, phone_code_hash, public_key)` (RSA via `Crypto.create_keys()`) → `register_device({'token_type':'Web','app_version':'WB_4.4.34',...})` → `get_contacts()` → `send_message(object_guid=guid, text=msg)`.
- **Finding contacts:** `get_contacts()` returns Update with `users[].original_update`. Search `first_name`/`last_name` using **unicode strings** (NOT console print — cp1256 corrupts Persian). Use `name.encode('utf-8').hex()` if needed.
- **Working example:** see `rubika-login-final.py` pattern and `rubika-send-message.py` (message to [REDACTED_CONTACT], phone [REDACTED_PHONE], guid [REDACTED_GUID], message_id [REDACTED_ID]).
- **Verification:** `send_message` returns `status: 'OK'` with `message_id` on success.
- **Other networks:** Bale (bot API only, no personal MTProto verified), Eitaa (`eitaapykit` only channels/groups), Soroush+ (no mature personal API). UI automation still needed for those.

## Bale (بله) — Bot API approach (Telegram-compatible)

- **Goal:** Send messages via Bot API at `https://tapi.bale.ai/bot<token>/method` (same format as Telegram Bot API).
- **Prerequisite:** A bot token from BotFather in Bale. Create manually: open Bale Web → search "@BotFather" → click result → send `/newbot` → follow prompts → copy token.
- **Python library:** `pip install python-telegram-bot` (v20+).
- **API usage:**
  ```python
  import asyncio
  from telegram import Bot
  
  bot = Bot(token="YOUR_BALE_BOT_TOKEN", base_url="https://tapi.bale.ai")
  await bot.send_message(chat_id=USER_CHAT_ID, text="پیام شما")
  ```
- **Limitation:** Bot API can ONLY message users who have already started a chat with the bot (sent /start or messaged it). Cannot proactively message arbitrary users.
- **Workaround for proactive messaging:** Use UI automation (proven recipe above) or have recipients message the bot first.
- **Finding chat_id:** After user messages bot, use `getUpdates` to find their `chat.id`.
- **Verified:** Bale Bot API endpoint responds (403 without token, 404 wrong path). Format matches Telegram Bot API exactly.
- **No personal MTProto API:** Telethon with Bale unverified; Bale uses custom MTProto servers. Bot API is the only confirmed programmatic path.

## Skills installed locally

- `open-bale`, `open-rubika`, `open-eitaa`, `open-soroush` in `~/.config/opencode/skills/`.
- `rubpy==7.3.5`, `eitaa==2.3.1` installed in Python 3.14.
- Working login script patterns in `C:\Users\Parspano\AppData\Local\Temp\opencode\` (`rubika-login-final.py`, `rubika-send-message.py`, etc.).