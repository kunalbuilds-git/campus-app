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

Frontend layout:

- `campus_quiz_flutter/lib/screens/` — `auth_gate` (signs the student in as a
  guest), `events_home_screen` (the feed with the category filter and the
  student's responses), `event_detail_screen` (the details and the response
  buttons), `account_screen` and `email_auth_screen` (the email account).
- `campus_quiz_flutter/lib/data/` — the `EventsRepository` and
  `AccountRepository` interfaces with their Serverpod implementations.
- `campus_quiz_flutter/lib/widgets/` and `lib/utils/` — the event card and the
  formatting helpers.

Frontend conventions to follow:

- The screens never call the Serverpod client directly; they use the
  repositories in `lib/data/`. That keeps the screens testable without a
  running server, and the widget tests in `campus_quiz_flutter/test/` use the
  in-memory fakes in `test/support/fakes.dart`.
- The client restores the stored session before the first screen runs
  (`await client.auth.initialize()` in `lib/client.dart`). Keep it that way:
  without it the app creates a new anonymous account on every cold start and
  the student's responses are left behind.
- The guest responses are moved to the email account by the account screen
  after a sign-in, because the server gives every identity its own rows.
