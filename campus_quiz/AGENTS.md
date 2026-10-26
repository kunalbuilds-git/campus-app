# Flutter & Serverpod project

This project is a Flutter app (frontend) backed by a Serverpod server (backend). Always build the app's backend with Serverpod.
Build for multiple users, use Serverpod's built-in authentication, which is already set up in `lib/server.dart`.

The user starts the server and Flutter app with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself. The Flutter app is started along with it, or can be launched from the MCP tool `spawn_flutter_app`.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload both the server and the Flutter app.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `tail_flutter_logs` to read the raw stdout/stderr of the Flutter app.
- `hot_reload` / `hot_restart` to reload or restart the server and the Flutter app. ALWAYS call `hot_restart` after doing changes in the Flutter app that may not work with normal hot reload (which is automatically applied).
- `spawn_flutter_app` to start a Flutter app declared under `serverpod: flutter_apps:` in the server `pubspec.yaml`.
- `get_flutter_app_dtd` (Dart tooling daemon) for connecting to the app through the `dart` MCP.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `campus_quiz_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

Tests need no Docker. `config/test.yaml` sets `database.dataPath`, so Serverpod starts and manages the test database (an embedded PostgreSQL) itself, and the project's `docker-compose.yaml` is not used for it. Just run `dart test` in the server package.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically). Will also hot restart Flutter app
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for any issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP) to connect to the app
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

The app is launched from `campus_quiz_flutter/lib/driver.dart`, which starts the Flutter driver extension with text entry emulation turned off so the app stays usable by hand. To let the driver type, set `enableTextEntryEmulation: true` there and `hot_restart` the app.

## The app we are building

A campus events app. Students browse the events published by clubs and
departments, open an event to see the details, and RSVP as `going` or
`interested`.

Content is seeded on the server instead of managed through an admin UI, so
there is no authoring screen in the app. Authentication is optional: a visitor
gets an anonymous Serverpod account with one tap and can RSVP immediately, and
an email account can be added later for an identity that follows them to
another device. Both kinds of account are authenticated for the RSVP
endpoints.

Backend layout:

- `campus_quiz_server/lib/src/events/` — the models (`*.spy.yaml`), the
  `events` endpoint, and the seeder.
- `campus_quiz_server/lib/src/auth/` — the identity provider endpoints.
  `EmailIdpEndpoint` and `JwtRefreshEndpoint` come with the Serverpod starter;
  `AnonymousIdpEndpoint` was added for the guest flow.
- `campus_quiz_server/lib/server.dart` — auth setup, web routes, and the
  development seeding call.

Conventions to follow:

- Models live in `*.spy.yaml` files. After changing a model or an endpoint,
  regenerate with `serverpod generate` (or let `serverpod start` do it) so
  `campus_quiz_client` stays in sync. The client package is generated code
  and is committed.
- The seeder only inserts when the event table is empty, so restarting the
  server never changes existing data.

## The Flutter product screens

The starter demo screens are replaced. `main.dart` routes three surfaces by
name (`/`, `/chat`, `/profile`):

- `/` — Landing page. Scrolling scrubs a fixed background video frame by
  frame while three text panels cross-fade. Panels are driven by a cue table
  in `landing_screen.dart` (each owns `[fadeInStart, fadeInEnd, fadeOutStart,
  fadeOutEnd]` in 0..1 page progress, with deliberate dead zones between
  panels). Scroll input is a root `Listener` (wheel + drag + inertia), not a
  ScrollView, so the panel CTAs stay clickable.
- `/chat` — Event finder. Dark surface over a looping video with a glass
  composer card whose desktop geometry is measured against a 1560x1008
  reference frame (unit `u = min(width/1560, height/1008)`; the placeholder,
  chip strip, model label, paperclip and send circle are absolutely placed).
  Replies come from `lib/data/campus_assistant.dart`, a deterministic matcher
  over the events feed.
- `/profile` — Profile dashboard. Liquid-glass panels (`widgets/glass.dart`,
  backdrop blur + white gradients) over `assets/images/campus_bg.jpg`, with an
  animated weekly activity chart (`widgets/wave_chart.dart`: the stroke draws
  first, the fill wipes in behind it).

Design tokens live in `lib/theme/brand.dart`: paper `#F2F0EC`, ink `#0D0C0B`,
ember accent `#E8632A`, and the bundled Inter / Inter Tight variable fonts in
`assets/fonts/` (fractional weights like 410 or 520 go through
`FontVariation('wght', …)`).

`lib/data/campus_repository.dart` wraps the endpoints and degrades to the
bundled sample data (`lib/data/campus_seed.dart`, mirroring the seeders)
whenever the server is unreachable, so the UI can be previewed without
`serverpod start` (`flutter run -d web-server --web-port 8085` from
`campus_quiz_flutter`).

Beyond events, the backend now carries:

- `lib/src/notices/` — the `Notice` model, `notices` endpoint (pinned-first
  listing + publish) and the development `NoticeSeeder`.
- `lib/src/attendance/` — `AttendanceEntry` per student (auth user + subject
  unique), `attendance` endpoint (`myAttendance`, `upsert`).
- `lib/src/sharing/` — `SharedItem` + `share` endpoint: `createShare`
  allocates a six-character code (AirDrop-style sharing between students),
  `resolveShare` looks it up. Payloads are JSON (`notice` or `event`).

The app has two behaviour layers on top:

- **Share sheet** (`widgets/share_sheet.dart`) — QR + six-character code per
  notice, and a type-a-code importer on the notice board.
- **Personalisation engine** (`lib/data/behavior_engine.dart`) — a small
  on-device behavioural model (decayed category affinity, section frequency,
  hour histogram) persisted with shared_preferences. It drives the "For you"
  card on My board and the insight line in the guide's opening state. Note
  widget tests must mock `SharedPreferences` (or rely on the engine's
  try/catch fallbacks).

`assets/config.json` currently points at the host's LAN address
(`http://192.168.1.13:8080`) so a phone on the same Wi-Fi reaches the dev
server; `flutter build apk --release` produces an installable APK. The
embedded-Postgres test database (`dart test` in the server package) needs a
working download of the native binary — if the runner dies silently during
"loading", check that download first. Smoke tests for the three screens live in
`campus_quiz_flutter/test/screens_smoke_test.dart` and load the bundled fonts
first — widget tests otherwise render the Ahem font (one em per glyph), which
breaks every text-dependent layout assertion.

Layout gotchas learned here: never combine `BorderRadius` with a non-uniform
`Border` (the paint-time assert silently drops the rest of the decoration);
`Container(alignment:)` inside an unbounded Row expands to the max width —
use `Row(mainAxisSize: min)` for pill shapes.
