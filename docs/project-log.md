# CampHere — project log

A running record of everything this repository went through, in order. Written
to be read top-to-bottom: each entry says what changed, why, and what it cost.

---

## Phase 0 — Setup (2026-10-25)

- Cloned `kunalbuilds-git/campus-app`. At that point the repo contained the
  stock Serverpod starter: a `campus_quiz` workspace with a greetings demo.
- The machine had no Dart/Flutter/Serverpod toolchain, so the environment was
  built first: Flutter 3.47.8 via Homebrew (satisfies the project's
  `^3.44.4` constraint), Serverpod CLI 4.0.4 via `dart pub global activate`,
  and `~/.pub-cache/bin` added to the PATH.
- `flutter analyze` passed on both packages out of the box.

## Phase 1 — Backend foundation arrives (2026-10-25, pulled)

- Pulled `main`, which brought PR #2: the **events** backend — `Event`,
  `EventCategory`, `EventSummary`, `Rsvp`, `RsvpStatus` models, the `events`
  endpoint (list/get/RSVP/cancel/my RSVPs with capacity enforcement), an
  anonymous + email auth setup, a development seeder with 12 sample campus
  events, integration tests, and the first database migration.
- This redefined the product: a campus **events** feed, not a quiz app.

## Phase 2 — The first product UI (2026-10-25/26)

- Replaced the starter demo screens with three designed surfaces, built
  against three reference specs and adapted to the events domain:
  - **Landing (`/`)** — an editorial, paper-and-ink page where scrolling
    scrubs a fixed background video frame by frame while three copy panels
    cross-fade. Mechanics per spec: a cue table per panel
    (`[fadeInStart, fadeInEnd, fadeOutStart, fadeOutEnd]`), deliberate dead
    zones where only the film plays, an eased playhead
    (`gap * 0.115` per frame), a boot preloader, and a progress hairline.
    Scroll input is a root `Listener` (wheel + drag + inertia) rather than a
    ScrollView, which keeps the panel CTAs clickable.
  - **Guide (`/chat`)** — a dark surface over looping footage with a glass
    composer card whose desktop geometry is measured against a 1560×1008
    reference frame (`u = min(width/1560, height/1008)`); placeholder band
    on top, 30-unit chip strip below, and the model label / paperclip /
    orange send circle absolutely placed (the send deliberately overhangs
    the chip row).
  - **Profile (`/profile`)** — a liquid-glass dashboard: frosted sidebar with
    an active pip, welcome header with tool buttons, mask-reveal headline,
    a weekly activity chart whose stroke draws itself and then fills, and a
    rail of event cards.
- Bundled **variable fonts** (Inter with `opsz` 14–32 + `wght` 100–900, and
  Inter Tight) so fractional weights like 410/520 render exactly; static
  TTFs cannot do this.
- Type system centralised in `lib/theme/brand.dart`: paper `#F2F0EC`, ink
  `#0D0C0B`, ember accent `#E8632A`.

### Bugs the browser pass caught (all fixed)

- `BorderRadius` + a **non-uniform `Border`** throws a paint-time assert in
  Flutter that silently drops the rest of the decoration — this is why a nav
  pill rendered as an empty black shape.
- `Container(alignment: …)` inside an unbounded Row expands to maximum width
  — the landing CTA stretched edge-to-edge until replaced with
  `Row(mainAxisSize: min)`.
- The reference's `vw` percentages were misread as divisors, briefly making
  the composer 100× oversized.
- `MediaQuery` reads in `initState` (a framework error) moved to
  `didChangeDependencies`.
- The embedded test database made `dart test` in the server package hang in
  this environment (native binary download); Flutter-side smoke tests became
  the working verification layer.

## Phase 3 — Rename, sections, pitch (2026-10-26)

- Product renamed **CampHere** (student-voted from Camp News / CampHere).
- Two new sections, requested as "what a campus app needs":
  - **Notice board (`/notices`)** — offices and societies, pinned first,
    category chips (Exams / Placement / Clubs / Admin / General).
  - **Attendance (`/attendance`)** — overall percentage, per-subject bars
    with a "short by N classes to reach 75%" calculation, and the weekly
    trend on the same draw-in chart.
- Navigation restructured to `Home · Notices · Attendance · My board` plus an
  ember **Ask what's on** CTA, carried by a shared floating liquid-glass
  head bar (`widgets/glass_nav_bar.dart`).
- Motion upgraded in the GSAP/anime.js spirit with `flutter_animate`
  (GSAP-equivalent for Flutter): page transitions (fade-through + rise,
  `easeOutCubic`), staggered message and card entrances, the live pulse dot.
  A latent entrance-choreography bug surfaced here: animation `Interval`s
  were being built with millisecond values instead of 0–1 fractions, which
  crashed every animated frame in debug — the beats are now proper fractions
  of the timeline.
- Smoke tests extended to all five screens, running at the reference
  viewport with the real fonts loaded (Flutter's default test font is Ahem,
  one em per glyph, which fakes layout failures).
- **Pitch deck** built (`CampHere_Pitch.pptx`, 16 slides) in the format of
  the team's reference deck: dark warm editorial, kicker → headline →
  support, stat callouts, card grids, numbered phases, screenshot slides.

## Phase 4 — Backend for the new sections (2026-10-26)

- Serverpod models + endpoints + migration `20261025224920947`:
  - `notices` — `Notice` model, pinned-first listing, `publish`, and a
    development seeder.
  - `attendance` — `AttendanceEntry` per auth-user per subject (unique),
    `myAttendance` + `upsert`.
- The client repository prefers the endpoints and falls back to bundled
  sample data whenever the server is unreachable, so every screen still
  renders standalone.

## Phase 5 — Sharing and personalisation (2026-10-26)

- **AirDrop-style sharing**: `SharedItem` + a `share` endpoint that mints a
  six-character code for a notice or an event. The notice board gained a
  share action (QR + code sheet) and a type-a-code importer, so any student
  can fling an item to any other without accounts or contacts.
- **Personalisation engine** (`lib/data/behavior_engine.dart`) — an on-device
  behavioural model: decayed category affinity (96-hour half-life), section
  frequency, and an hour-of-day histogram, recorded from section opens,
  guide searches and event interest, persisted locally. It drives the
  **For you** card on My board (with its "why" line) and the insight in the
  guide's greeting.
- **Android shipped**: platform folders aligned to `com.pseudocolleges`, and
  a release APK built (54.7 MB) with the LAN server address baked in.
- `assets/config.json` moved from `localhost` to the host's LAN address so a
  physical phone on the same Wi-Fi can reach the dev server.

## Phase 6 — Hardening, CI, docs (2026-10-26, this change)

- **AES-256-GCM at rest** (`lib/security/vault.dart`): the behaviour store is
  sealed before it touches disk; the key lives in the platform credential
  store (Keychain / Keystore), a fresh nonce per write, tag verified on
  read, tampered blobs discarded.
- **Security pass** (manual; Strix automation blocked locally without
  Docker/an LLM key, so it is wired into CI instead — see
  `docs/security-report.md`):
  - fixed: anonymous notice publishing (now requires auth),
  - fixed: unbounded anonymous share creation (auth + 8 KB payload cap +
    50/hour/account),
  - fixed: committed database/Redis passwords in CI, VS Code tasks and
    docker-compose (now runtime-generated or env-required; **rotation of the
    old values is still owed** — they remain in git history),
  - documented, not yet fixed: plain-HTTP transport, missing security
    headers, share-code expiry, the RSVP capacity race.
- **CI moved to the repo root** (the nested `.github` was invisible to
  GitHub): `ci.yml` runs server analyze + tests (ephemeral per-run secrets,
  cached embedded PostgreSQL), app analyze + smoke tests, and a web release
  build gate; `security.yml` runs Strix on every PR and weekly, with SARIF
  uploaded to GitHub code scanning.
- **Docs**: this log, the security report, and a README with a full setup
  guide and a demo video cut from the running app.

## Phase 7 — More surfaces, and the ones we had (2026-10-26)

The five surfaces became eight. The navigation was restructured to a single
list in `lib/navigation.dart` so the top bar, the dashboard sidebar and the
mobile dock can never drift apart:

- **Events (`/events`)** — the events desk, rebuilt as a ticketing surface
  rather than a feed: a seven-day strip, a category filter, and a seat button
  per event that RSVPs through the backend and falls back to the device when
  the server is unreachable.
- **Assignments (`/assignments`)** — what is owed and by when, grouped into
  overdue / due today / this week / submitted, with a one-tap hand-in.
- **Clubs (`/clubs`)** — the societies directory, searchable, filterable by
  kind, with member counts and a join control.

Both new lists are device-local for now (they read from the bundled seed and
remember what you did in `SharedPreferences`); the backend endpoints for them
are the next piece of work.

### Bugs this pass caught

- **The events desk opened on the wrong day, and then on an empty one.** The
  "open on the next day with something on" loop used the selected index as
  its own loop sentinel, so it could never select today — and the seed put
  exactly one event on each day, which made every day look empty. Fixed by
  using a separate `opened` flag, by giving the strip a count on every day,
  and by seeding a real week (two or three things a day instead of one).
- **The same-day seed events landed at 11:30 pm.** They are timed from "now"
  and clamped to nine o'clock, slipping to tomorrow morning once nine has
  passed.
- **The attendance screen was read-only.** The `upsert` endpoint had been
  ready for a while and nothing ever called it. There is now a counter sheet
  per subject — attended and held, kept honest against each other, with the
  percentage updating live — and the edit is kept on the device as well as
  the server, so a student who updates their count while the campus server is
  down does not lose it. The endpoint now rejects counters that make no
  sense (`attended > total`, negatives), which was the last open item from
  the security pass on that endpoint.

### What the tests now hold down

Sixteen tests across three suites: every screen builds at the reference
viewport with the real fonts, the events feed stays a calendar (every day
covered, nothing in the past, no duplicate identities), and the attendance
subjects are listed, painted and editable.

One trap worth recording: `flutter_animate` starts its controller from a
zero-delay timer, so in a widget test the fade needs a pump **with a
duration** to fire that timer and another one for the animation to advance.
Without the second pump the rows sit at opacity zero — in the tree, but
invisible — and the test passes while the screen is blank.

### CI

The two workflows were rewritten at the repository root: a format gate, the
full Flutter suite (not one file), server analysis and tests against an
embedded PostgreSQL with per-run ephemeral secrets, a release web build, job
timeouts, least-privilege permissions, and concurrency cancellation. The
Strix workflow now skips itself with a notice when its LLM secret is
missing, instead of failing red on every pull request from a fork.

## Where it stands

Eight surfaces (home, events, guide, notice board, assignments, clubs,
attendance, my board), a typed Serverpod backend for events, notices,
attendance and sharing, sharing between students, personalisation, encryption
at rest, an installable Android APK, CI with a security gate, and a pitch
deck. The known debts are listed in the security report and at the bottom of
the README.

