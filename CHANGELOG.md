# Changelog

All notable, user-facing changes to Better Hacker News are documented here.
Docs and refactors are not listed. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the version
numbers match `manifest.json` and the add-on store listings.

Add an entry to **Unreleased** in the commit that makes the change, not at
release time.

## [Unreleased]

## [1.1] - 2026-11-11

### Fixed

- Downvoting a comment no longer reloads the page. The vote is sent in the
  background and the arrows update in place, as upvotes and unvotes already did.
- Unvoting reverses the vote cast on the current page, so downvoting and then
  unvoting no longer leaves the author's vote tally one lower than it should be.

### Changed

- New extension icons.

## [1.0] - 2026-11-11

First release under the Better Hacker News name, published to addons.mozilla.org.

### Fixed

- Comment usernames render again after Hacker News dropped the `hnuser` class
  from its markup.
