# Social Network Principles

One general rule, learned from a real user while driving a messenger by hand, that applies to **every** social network (messengers, social apps, web UIs). Reuse it wherever you automate any network.

## 1. Find any contact/chat quickly — one of two paths

Use ONE of these (try 2 when 1 is not obvious):

1. **Click the search (magnifier) icon** and type the name.
2. **Click the "contacts" icon/page** — it usually opens a contact list WITH a search box.

Icons are often OCR-obscured (the magnifier was read as the digit "5"). When in doubt, probe candidate icon positions and confirm by the placeholder/input that appears.

## 2. Never paste without copying first

Ctrl+V only pastes what was previously copied (Ctrl+C). When you script a paste, **always set the clipboard immediately before pasting**. Pasting with an empty/stale clipboard silently does nothing and wastes many retries.

## 3. Send with Enter

In messengers, **Enter = send** and **Shift+Enter = newline**. Do not hunt for a send button — it is often an icon that OCR cannot read. Send by pressing Enter and then verify.

## 4. Verify the recipient before sending

The chat header must show the right name. Cross-check with the chat URL/thread id when available. Never send to the wrong person.

## 5. Coordinates are not stable

Web apps resize and move (a Chrome app window may switch between `App` / `App (2)` titles and different geometries). **Never trust absolute coordinates from a previous session** — re-derive interactive elements by OCR/pixel scan each session, and verify each step by what appeared (placeholder, focused control, draft content).

## 6. Search name variants; ask the user only when there is real ambiguity

A contact may be saved under a DIFFERENT name than the one you search (prefix/suffix variants such as «مهدی حبیبی» ↔ «مهدیار حبیبی شاندیز»), or have several accounts/similar names, or no account at all.

- After one query, if the target isn't found or is doubtful, step through the **surname alone → first name alone → Latin/Arabic spellings** until you're sure the contact doesn't exist.
- A query that returns only CHANNEL rows (often marked «... مشترک») means the person isn't under that exact name — vary the search, don't conclude "no account".
- **Ask the user** (numbering results by position) ONLY when NO result matches the target name exactly, or when MULTIPLE results match it exactly. If exactly ONE result matches the target 100%, it is the target — do not ask (user-refined rule, verified on Eitaa).
- Distinguish PERSONAL accounts from CHANNELS/GROUPS in the results and pick per the user's goal (e.g. in a personal messenger choose the person, not the same-named channel).
- **Save revealed aliases for future sessions.** A user-confirmed alias is person-specific and likely identical across networks (on one machine «مهدی حبیبی» = «مهدیار حبیبی شاندیز» in BOTH Rubika and Eitaa).

## 7. The agent's own UI can steal focus (restore trap)

Any opencode/agent UI action — notably the built-in **question** tool — RESTORES the agent's own window on top of the desktop. Subsequent clicks and keystrokes then go to the agent UI instead of the messenger (a click meant for a search result can land on the wrong default-list item). **After every such action: re-minimize the agent window and confirm with full-screen OCR that the target app is foreground** before continuing.

## 8. When the app is a native desktop app, UIA is your friend

Chrome-based apps ignore synthetic keystrokes (Bale/Rubika) — use SendInput helpers. Native apps (Eitaa = Qt) DO accept typed/pasted input, and often expose the **focused field's value via UIA** (`uia_get_focused` shows the whole draft text) — verify drafts through values instead of OCR. Note that even there, some small fields (the Eitaa search box) report an empty value and must be verified via the results area instead.