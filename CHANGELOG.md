## 2.1.0 - 2026-08-04

- Verify compatibility with Flutter 3.44 and Dart 3.12 while retaining the
  Dart 3 / Flutter 3.10 consumer floor.
- Add right-side and automatic RTL drawer support with `KFDrawerDirection`
  (#1, #13).
- Add opt-in pinned-footer and centered-scrollable menu layouts (#28, #25).
- Make controller page and item changes reactive; add item mutation and alias
  selection helpers (#5).
- Add optional page history with `goBack`, `replacePage`, and `clearHistory`
  (#6).
- Add controller-free `content`, drawer state callbacks, drag configuration,
  semantics labeling, and customizable shadow color (#10).
- Fix `disableContentTap: false`, controller replacement and disposal,
  runtime property updates, drag normalization, and unconstrained page layout.
- Compose page selection with item `onPressed` and add `closeOnTap`.
- Add strict analysis, CI, widget tests, current documentation, and a modern
  example without string-based class construction.
- Refresh the example platform projects for current Android, iOS, macOS,
  Linux, web, and Windows tooling, including Flutter's UIScene lifecycle.
- Correct package metadata and publish ignores.

## 2.0.0 - 2025-07-21

- Split drawer, controller, and item classes into separate files.
- Fix menu tap and page change behavior.
- Improve custom item callback handling.
- Refactor package structure.

## 1.2.1 - 2021-11-27

- Fix nullable border radius handling.

## 1.2.0 - 2020-08-09

- Add null safety support.

## 1.1.2 - 2019-07-22

- Publish the stable pre-null-safety version.

## 1.0.0 - 2019-03-20

- Publish the initial release.
