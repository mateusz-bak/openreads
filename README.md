# Openreads Progress

A personal fork of [Openreads](https://github.com/mateusz-bak/openreads) by
[mateusz-bak](https://github.com/mateusz-bak), with one feature added: **tracking
the page you're currently on.**

All credit for the app goes upstream. This fork exists only because I wanted this
one thing, and logging progress in the notes field wasn't working for me.

## What's different

Stock Openreads stores a book's total page count, but has nowhere to record how
far into it you are. This fork adds that:

- Books marked **In progress** show a progress bar on the book detail screen.
- Tap the bar to enter your current page. It shows `120 / 300 · 40%`.
- Books without a known page count still accept a page number; they just show
  the number without a bar or percentage.
- Pages beyond the book's length are clamped to the total.

Progress is stored in a new `current_page` database column (schema v9). Existing
databases migrate automatically, and backups from stock Openreads still restore
correctly.

## Changes to upstream

| File | Change |
| --- | --- |
| `lib/model/book.dart` | Added the `currentPage` field |
| `lib/database/database_provider.dart` | Schema v9 and its migration |
| `lib/ui/book_screen/widgets/book_progress_detail.dart` | New progress bar widget |
| `lib/ui/book_screen/widgets/quick_progress_dialog.dart` | New page entry dialog |
| `lib/ui/book_screen/book_screen.dart` | Wired the above into the detail screen |
| `android/app/build.gradle` | Changed the application ID |

The application ID is `software.mdev.bookstracker.progress` rather than
upstream's `software.mdev.bookstracker`, so this installs alongside the official
app instead of conflicting with it. The two keep separate libraries — move your
data across with Openreads' own backup export and import.

## Installing

Releases carry a signed APK, so [Obtainium](https://github.com/ImranR98/Obtainium)
can track this repository and handle updates.

## License

GPL-2.0, same as upstream.
