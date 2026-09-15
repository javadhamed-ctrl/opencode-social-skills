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