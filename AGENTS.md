# Better Hacker News

Manifest V2 extension for Firefox/Chrome that rewrites Hacker News pages client-side. Fork of the unmaintained HNES, updated for current HN markup (notably HN dropping the `.hnuser` class). No build system, bundler, package manager, or tests: the repo is the extension.

## Load and verify

- Firefox: `about:debugging` → This Firefox → Load Temporary Add-on → `manifest.json`.
- Chrome stable no longer runs MV2; Firefox is the practical target.
- No build/watch step: edit files in place, reload the add-on, then reload the HN tab (scripts run at `document_start`/`document_end`).
- No automated tests. Reload the add-on and exercise the page type you touched: `/` (story list), `/item?id=…` (comments), `/threads`, `/user?id=…`, `/login`. Most checks work logged out; downvoting, creating polls, and topcolor need an account with karma.
- `style.css` hides `<body>` until `HN.init()` completes. Any uncaught error before the final `$(document).ready` in `js/hn.js` leaves the HN page blank — check the console first when nothing renders.

## Package and release

`./zip.sh` builds `dist/better-hacker-news-{firefox,chrome}-<version>.zip`. It derives the slug and version from `manifest.json` with `python3`, zips from the repo root (manifest must be at the zip root for AMO), then copies the Firefox zip as the Chrome one. `dist/` is gitignored. Bump `version` in `manifest.json` for a release.

The zip excludes only an explicit list (`.git`, `dist`, `screenshots`, `notes`, `zip.sh`, `AGENTS.md`, `CHANGELOG.md`, non-minified jQuery); any new root-level file, including this one, ships to users. Keep additions small and don't put scratch files at the root.

## Changelog and releases

`CHANGELOG.md` is the source of truth for what changed in each version. It follows Keep a Changelog with an empty `## [Unreleased]` heading at the top.

- **When making a user-visible change**, add a bullet to `## [Unreleased]` in the same commit. Docs, refactors and internal changes are not listed.
- **To cut a release**: move the `Unreleased` bullets into a new `## [<version>] - <date>` section, bump `version` in `manifest.json`, then `./zip.sh`.
- Tag the commit the zips were built from (`git tag v<version>`) and publish it with `gh release create v<version>` using the changelog section as the notes and both `dist/` zips as assets. That page is the public record of the release.
- Paste the same notes into the version's release-notes field on addons.mozilla.org: AMO is where most users see them, and a GitHub release is invisible from there.
- Never re-use a version number: AMO rejects re-uploading a version that already exists, so a rebuild always needs a bump.

Do not change `browser_specific_settings.gecko.id` (`better-hacker-news@digitalquery.github.io`); AMO keys the listing to it.

## Code map

- `js/hn.js` — all logic: `HN` object, `HNComments` class, `InlineReply`, `CommentTracker`. Single 1.9k-line script, no modules; end of file calls `HN.init()` (unless host is `hckrnews.com`).
- `background.js` — broker for the background page's `localStorage`.
- `manifest.json` — MV2; CSS at `document_start`, JS at `document_end`; also injected into `hckrnews.com` for unread counts.
- `style.css` — all styling, built around HN's legacy table markup.
- `dist/` — built zips only; never edit by hand.
- Extension APIs are called as `chrome.*`; that namespace works in Firefox MV2 too, so don't convert calls to `browser.*`.

### Routing

`HN.init()` dispatches on `window.location.pathname`. HN serves many pages at `/x`, so it first identifies those from `document.title` (`/threads`, `/more`, `/edit`, `/reply`, `/login`, `/confirm`, `/news`). Add new page handling there, and add the path to `postPagesRE` if it is a story list.

### Comments

`HN.doCommentsList()` parses HN's table markup; `HNComments` (`markupToNodeList` → `nodeListToTree` → `renderComment`) rebuilds the thread into `#hnes-comments`. Usernames are found via `.comhead a[href^="user?id="]`; do not reintroduce selectors that depend on `.hnuser`. `HNComments.apply()` bails with a console warning if none of `table.comment-tree`, `table.itemlist`, or `table.comments-table` exist — that is the first place to look when a markup change makes comments disappear.

### Storage

- User tags and upvote tallies: background `localStorage`, keyed by username, JSON `{votes, tag}`; legacy bare-number values auto-migrate in `HN.addInfoToUsers`.
- New-comment tracking: background `localStorage`, keyed by story ID, `{id, num, last_comment_id, expire}`.
- Collapsed comments: `chrome.storage.local`, keyed by comment ID.
- Content scripts cannot use localStorage directly; go through `HN.getLocalStorage` / `HN.setLocalStorage`.

## Gotchas

- `background.js` defines the expired-entry cleanup IIFE but never invokes it (no trailing `()`), so stale entries are only replaced, not purged. Invoking it as-is would throw: it `JSON.parse`s every `localStorage` value, including non-JSON ones.
- `manifest.json` lists `templates/comment.html` as web-accessible, but no such file exists — comment markup is the inline `<template>` in `HNComments`.
- `HN.injectCSS()` (login page) references a nonexistent `news.css`.
- jQuery 3.2.1 and linkify are vendored; `hn.js` uses ES2015 syntax with no transpiler. Keep new code in `js/hn.js` or add an explicit `manifest.json` entry.
