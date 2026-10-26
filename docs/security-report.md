# Security report — CampHere (campus-app)

**Date:** 2026-10-26 · **Scope:** full repo (Flutter app, Serverpod server, configs, CI) and the running Flutter web build
**Tester:** manual, agent-driven · **Automated engine:** Strix (see "Automated scanning" at the bottom)

## How this was tested

The plan was to run [Strix](https://github.com/usestrix/strix) (autonomous
pentest agents) against the live API. That run is **blocked in the current
environment**: the Strix CLI needs Docker (absent here) plus an LLM key
(`STRIX_LLM` / `LLM_API_KEY`), or a Strix Cloud token — none exist yet. The
workflow at `.github/workflows/security.yml` runs the automated scan on every
PR once those secrets are added; the runbook is at the bottom of this file.

What was done instead, manually:

1. **Live checks** against the running Flutter web build (HTTP headers,
   client-side storage, CDN dependencies).
2. **White-box review** of every endpoint in
   `campus_quiz_server/lib/src/` (events, notices, attendance, sharing,
   greeting) with the protocol definition in hand.
3. **Secrets sweep** of all git-tracked files.
4. **Design review** of the auth model (anonymous + email IDPs, JWT), the
   RSVP flow, and the share-code space.

## Findings

### Fixed during this pass

| # | Severity | Finding | Evidence | Fix |
|---|----------|---------|----------|-----|
| 1 | **High** | `NoticesEndpoint.publish` accepted **anonymous** notice publishing — anyone could inject notices into the campus board | Endpoint had no `session.authenticated` check | Now throws `NoticeException('UNAUTHENTICATED')`; role-gating lands with the admin surface |
| 2 | **Medium** | `ShareEndpoint.createShare` was anonymous and unbounded — a script could flood `shared_item` and bury the code space | No auth check, no payload cap, no per-user limit | Requires a signed-in account (anonymous accounts count and are traceable), payload capped at 8 KB, 50 shares/hour/account, `createdBy` recorded |
| 3 | **Medium** | **Committed credentials**: a database password and Redis password in `.github/workflows/tests.yml`, a database password in `.vscode/tasks.json`, and a Redis password in `docker-compose.yaml` | `git grep` — all three were readable by anyone with repo access | Removed from all three files; CI now generates ephemeral secrets per run; compose requires `SERVERPOD_PASSWORD_redis` from the environment. **The removed passwords must still be rotated** — they live in git history |
| 4 | **Low** | `AttendanceEndpoint.upsert` accepted unvalidated counters (e.g. `attended > total`, negatives) | No range checks | Now rejected: `attended < 0`, `total < 0` and `attended > total` all throw `AttendanceException('INVALID_COUNTERS')`. The write UI that landed with it clamps the same way, so a student cannot enter a count that would make the dashboard nonsense |
| 5 | **Low** | RSVP capacity check has a **time-of-check/time-of-use race** — two concurrent RSVPs can both pass the `goingCount >= capacity` test | `events_endpoint.dart` counts, then inserts, without a transaction lock | Documented; fix is a serializable transaction or a seat-reservation row on insert. Capacity over-run by ±1 is the blast radius |

### Open (accepted for the hackathon build, must fix before real users)

| # | Severity | Finding | Remediation path |
|---|----------|---------|------------------|
| 6 | **Medium** | No transport security: the phone/web build talks to the server over plain HTTP (`assets/config.json` → `http://192.168.1.13:8080`), and the dev server has no TLS. On shared campus Wi-Fi, RSVP traffic is sniffable | Terminate TLS at a reverse proxy (Caddy/nginx) and switch `apiUrl` to `https://` before any deployment beyond a trusted test network |
| 7 | **Medium** | **Missing security headers** on the web build: only `x-content-type-options: nosniff` is set — no CSP, no `X-Frame-Options`, no HSTS | Add headers at the proxy; a minimal CSP is `default-src 'self'; media-src 'self' https://d2ol7oe51mr4n9.cloudfront.net https://d8j0ntlcm91z4.cloudfront.net; font-src 'self' data:; style-src 'self' 'unsafe-inline'` |
| 8 | **Low** | Share codes are 6 chars from a 31-symbol alphabet (~887M combinations) with **no expiry and no rate limit** on `resolveShare` | Codes cannot be enumerated quickly (≈10 days at 1k req/s for full space), but add an expiry (`expiresAt` + cleanup) and per-IP rate limiting at the proxy for production |
| 9 | **Low** | Anonymous accounts are unlimited by design (one tap → full RSVP rights). Convenient for a demo; an attacker can mint identities at will | Acceptable for the pilot; production wants email verification before RSVP or a CAPTCHA on account creation |
| 10 | **Info** | Serverpod dev mode enables the **insights server** (port 8081) and permissive CORS | Dev-only defaults; do not expose the dev server to the internet |

### What came back clean

- **No hardcoded secrets** in tracked files — no LLM keys (`sk-or-`, `gsk_`,
  `nvapi-`), no cloud keys, no PEM blocks. LLM keys arrive via `--dart-define`
  at build time and never enter the repo.
- **No SQL injection surface**: all queries go through Serverpod's
  parameterized ORM; there are no raw-SQL string builds anywhere in `lib/`.
- **No IDOR found**: attendance and RSVP rows are always filtered by the
  authenticated `authUserId`; share resolution is by random code, not by
  sequential id.
- **Client storage**: the behavior store is sealed with **AES-256-GCM**
  (`lib/security/vault.dart`) — a 256-bit key held in the platform credential
  store, fresh 96-bit nonce per write, authentication tag verified on read.
  A tampered or foreign-key blob is discarded, not trusted.
- **Share payloads are rendered as text** in Flutter's canvas renderer —
  there is no HTML sink, so stored-content XSS does not apply to the app
  itself.

## Automated scanning (Strix)

`.github/workflows/security.yml` runs Strix on every PR (diff-scoped,
`quick`) and weekly (full, `standard`), and uploads SARIF to GitHub code
scanning. To enable it, add two repository secrets:

```
STRIX_LLM    = <LiteLLM model id, e.g. openai/gpt-5.4>
LLM_API_KEY  = <provider key>
```

Runbook for a local scan (needs Docker + the two env vars above):

```bash
strix -n -t ./ --scan-mode standard --max-budget 20
# artifacts in strix_runs/<run-name>/: penetration_test_report.md,
# vulnerabilities/*.md, findings.sarif
```

Re-test after fixing: rerun the same command; the PR gate also re-scans
automatically on the next pull request.
