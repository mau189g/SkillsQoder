---
name: appflowy
description: Use when the user asks to find, read, summarize, create or change anything in their AppFlowy workspace - pages, documents, databases and their rows, database views and dashboards (also embedded in documents), forms and their sharing links, comments, tasks or reminders - through the AppFlowy MCP server.
---

# Working in AppFlowy

The AppFlowy MCP server's tools carry their own parameter details. These rules cover how to use
them together.

## The connection

- A connection works in one workspace: the one the user chose when signing in. Call `get-self`
  to see who is connected and where. To work in another workspace, the user connects again and
  chooses it.
- Which tools you see depends on what the user allowed at sign-in. Reading needs `read`.
  Creating and adding, updating rows, tasks and reminders, moving pages, and configuring or
  sharing forms need `write`. Editing or deleting other existing content (page names, icons and
  trash, blocks, database properties, view settings, comment resolution, whole-document
  replacement, any deletion) and revoking or rotating a form's sharing link need `admin`. If a
  tool you need is missing, tell the user which permission to grant and ask them to reconnect.
- If AppFlowy answers that MCP is turned off, or needs a license, stop and tell the user: a
  workspace or server administrator has to change that. Do not retry in a loop.

## Finding things

- When the user names a page ("open the Q3 Planning doc"), call `search` with `fields: ["title"]`.
  When they describe what a page says, omit `fields` (or use `["content"]`).
- Use `get-spaces` to see the workspace's spaces, and `get-databases` to find a database before
  `get-database-fields` and `query-database`.
- IDs (`view_id`, block IDs, row IDs) always come from tool results. Never invent or guess one.

## Reading

- `fetch` returns a document as blocks by default. While `has_more` is true, call it again with
  `start_cursor` set to the returned `next_cursor` to read the rest. Ask for
  `body_format: "markdown"` when you need the whole page as one string, for example before
  rewriting it.
- Keep the `version` (from `fetch`) and the `block_hash` of each block you plan to change, and
  pass them back as `expected_version` / `expected_block_hash`, so an edit made by someone else in
  the meantime is refused instead of overwritten.

## Changing things

- Every tool that changes something requires `confirm: true`. Set it only after the user approved
  that specific change in this conversation; describe the change first (which page, what will be
  added or removed).
- Prefer the smallest change: `append-document-content` or `create-block` to add, `update-block`
  for one block, and `replace-document-content` only for a deliberate whole-page rewrite.
- Deleting (blocks, rows, properties, comments, reminders) cannot be undone from here. Confirm the
  exact items with the user, and name them in your confirmation question.
- After a change, read back what matters and report it with the page's name, so the user can
  check it in AppFlowy.
