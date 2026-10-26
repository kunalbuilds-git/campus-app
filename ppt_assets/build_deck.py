#!/usr/bin/env python3
"""Builds the CampHere deck in the Team_Sudo format: 16:9, dark warm
editorial, kicker + headline + support, stat callouts, card grids, numbered
phases, screenshot slides."""

from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

W, H = Inches(13.333), Inches(7.5)

CREAM = RGBColor(0xF5, 0xEF, 0xE3)
MUTED = RGBColor(0xB0, 0xA5, 0x94)
DIM = RGBColor(0x8C, 0x81, 0x71)
EMBER = RGBColor(0xE8, 0x86, 0x54)
GREEN = RGBColor(0x8F, 0xAE, 0x7C)
RED = RGBColor(0xC1, 0x54, 0x3D)

BG = "/Users/aditya/Campus-app/ppt_assets/bg.png"
BG_WARM = "/Users/aditya/Campus-app/ppt_assets/bg_warm.png"
SHOTS = "/Users/aditya/Campus-app/screenshots"

prs = Presentation()
prs.slide_width = W
prs.slide_height = H
BLANK = prs.slide_layouts[6]


def slide(bg=BG):
    s = prs.slides.add_slide(BLANK)
    s.shapes.add_picture(bg, 0, 0, width=W, height=H)
    return s


def box(s, x, y, w, h):
    tb = s.shapes.add_textbox(x, y, w, h)
    tf = tb.text_frame
    tf.word_wrap = True
    return tf


def put(tf, text, size, color=CREAM, bold=False, font="Calibri",
        align=PP_ALIGN.LEFT, space_after=0, first=False, spacing=None):
    p = tf.paragraphs[0] if (first and not tf.paragraphs[0].runs) else tf.add_paragraph()
    p.alignment = align
    if space_after:
        p.space_after = Pt(space_after)
    if spacing is not None:
        p.line_spacing = spacing
    r = p.add_run()
    r.text = text
    r.font.size = Pt(size)
    r.font.bold = bold
    r.font.name = font
    r.font.color.rgb = color
    return p


def kicker(s, text, x=Inches(0.6), y=Inches(0.42), color=EMBER):
    tf = box(s, x, y, Inches(9), Inches(0.3))
    put(tf, text.upper(), 10.5, color, bold=True, first=True)


def headline(s, text, x=Inches(0.6), y=Inches(0.72), size=33,
             color=CREAM, w=Inches(12.1)):
    tf = box(s, x, y, w, Inches(0.75))
    put(tf, text, size, color, bold=True, first=True)


def support(s, text, x=Inches(0.6), y=Inches(1.32), w=Inches(11.6)):
    tf = box(s, x, y, w, Inches(0.6))
    put(tf, text, 14.5, MUTED, first=True, spacing=1.15)


def rule(s, x=Inches(0.6), y=Inches(1.18), w=Inches(12.1)):
    from pptx.enum.shapes import MSO_SHAPE
    line = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, x, y, w, Pt(1.2))
    line.fill.solid()
    line.fill.fore_color.rgb = RGBColor(0x3A, 0x35, 0x2D)
    line.line.fill.background()


def card(s, x, y, w, h, title, body, accent=CREAM, title_size=15.5,
         body_size=11.5):
    from pptx.enum.shapes import MSO_SHAPE
    c = s.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, x, y, w, h)
    c.adjustments[0] = 0.055
    c.fill.solid()
    c.fill.fore_color.rgb = RGBColor(0x1C, 0x19, 0x15)
    c.line.color.rgb = RGBColor(0x3A, 0x35, 0x2D)
    c.line.width = Pt(1)
    c.shadow.inherit = False
    tf = c.text_frame
    tf.word_wrap = True
    tf.margin_left = Inches(0.22)
    tf.margin_right = Inches(0.22)
    tf.margin_top = Inches(0.18)
    put(tf, title, title_size, accent, bold=True, first=True)
    put(tf, body, body_size, MUTED, spacing=1.12, space_after=0)
    return c


def screenshot(s, path, x, y, w, label=None):
    pic = s.shapes.add_picture(path, x, y, width=w)
    if label:
        tf = box(s, x, y + pic.height + Inches(0.06), w, Inches(0.3))
        put(tf, label, 9.5, DIM, first=True, align=PP_ALIGN.CENTER)
    return pic


def footer(s, text):
    tf = box(s, Inches(0.6), Inches(7.02), Inches(12), Inches(0.3))
    put(tf, text, 9.5, DIM, first=True)


# ---------------------------------------------------------------- 1 · TITLE
s = slide(BG_WARM)
tf = box(s, Inches(0.6), Inches(1.5), Inches(7.2), Inches(1.4))
put(tf, "CAMPHERE", 66, CREAM, bold=True, first=True)
tf = box(s, Inches(0.62), Inches(2.75), Inches(6.6), Inches(0.9))
put(tf, "Every corner of campus, in one quiet app.", 22, MUTED, first=True,
    spacing=1.1)
tf = box(s, Inches(0.62), Inches(3.62), Inches(6.6), Inches(0.5))
put(tf, "Ask what's on.  It's already found.", 14.5, EMBER, bold=True,
    first=True)

meta = [
    ("TEAM", "Pseudo College's"),
    ("THEME", "Campus Life & Student Tools"),
    ("TEAM MEMBERS", "Aditya Dubey  ·  Kunal Avvanshi"),
    ("COLLEGE", "IILM Grid Noida"),
]
y = 4.55
for label, value in meta:
    tf = box(s, Inches(0.62), Inches(y), Inches(2.1), Inches(0.3))
    put(tf, label, 8.5, DIM, bold=True, first=True)
    tf = box(s, Inches(0.62), Inches(y + 0.2), Inches(6.2), Inches(0.35))
    put(tf, value, 12.5, CREAM, bold=True, first=True)
    y += 0.56

screenshot(s, f"{SHOTS}/07_home_phone.png", Inches(8.55), Inches(0.72),
           Inches(2.35))
tf = box(s, Inches(7.6), Inches(6.78), Inches(5.1), Inches(0.35))
put(tf, "Working prototype  ·  Flutter (web now, Android next)", 9.5, DIM,
    first=True, align=PP_ALIGN.CENTER)

# ------------------------------------------------------------- 2 · PROBLEM
s = slide()
kicker(s, "The problem")
headline(s, "Campus life runs on scattered updates")
support(s, "Every day a student reconstructs their campus from fragments — "
           "the corridor board, four WhatsApp groups, three portals and "
           "whoever they happen to bump into. Things fall through.")
rule(s)
stats = [
    ("7+", "places a student checks daily", EMBER),
    ("40+", "clubs & societies posting separately", CREAM),
    ("3", "portals, each with its own login", CREAM),
    ("1", "unified place to look: none", RED),
]
x = 0.6
for value, label, color in stats:
    tf = box(s, Inches(x), Inches(2.5), Inches(2.9), Inches(1.0))
    put(tf, value, 40, color, bold=True, first=True)
    tf = box(s, Inches(x), Inches(3.35), Inches(2.85), Inches(0.8))
    put(tf, label, 13, MUTED, bold=True, first=True, spacing=1.1)
    x += 3.08
card(s, Inches(0.6), Inches(4.6), Inches(5.9), Inches(1.9),
     "The cost of missing one update",
     "A placement talk you never heard about. A hackathon team you didn't "
     "join. An exam-room change you found out at the door. On a campus, "
     "information asymmetry is a real academic cost.")
card(s, Inches(6.83), Inches(4.6), Inches(5.9), Inches(1.9),
     "And nobody is at fault",
     "The offices publish. The clubs publish. The groups forward. The "
     "system works everywhere except at the single point where it matters: "
     "one student, one evening, one feed.")

# --------------------------------------------------- 3 · WHY FIXES FAIL
s = slide()
kicker(s, "Why the usual fixes fail")
headline(s, "Every existing answer asks the student to do the work")
support(s, "The tools campus already uses were built for broadcasting, not "
           "for a person deciding what to do tonight.")
rule(s)
grid = [
    ("WhatsApp groups",
     "The default notice board. Also the default noise board — 200 unread "
     "messages bury the one that mattered yesterday."),
    ("Paper & corridor boards",
     "Accurate, official — and only visible if you physically walk past "
     "them on the right day."),
    ("College portals",
     "Authoritative but inert. Login walls, desktop-first layouts, and "
     "nothing that pushes back when something is due."),
    ("Word of mouth",
     "Reaches whoever stands near the right person. Everyone else finds "
     "out afterwards."),
]
x, y = 0.6, 2.15
for i, (t, b) in enumerate(grid):
    card(s, Inches(x), Inches(y), Inches(5.9), Inches(1.95), t, b)
    if i % 2 == 0:
        x += 6.23
    else:
        x = 0.6
        y += 2.2

# ------------------------------------------------------------- 4 · PREMISE
s = slide(BG_WARM)
kicker(s, "The premise")
tf = box(s, Inches(1.1), Inches(2.2), Inches(11.1), Inches(2.2))
put(tf, "\u201cIf the campus already produces every update a student needs, "
        "the app shouldn't ask them to hunt for it — it should hand it "
        "over.\u201d", 30, CREAM, bold=True, first=True, font="Cambria",
    spacing=1.15)
tf = box(s, Inches(1.1), Inches(4.45), Inches(10), Inches(0.4))
put(tf, "— the question CampHere is an answer to", 13, DIM, first=True)
for i, t in enumerate(["No portals to open", "No groups to scroll",
                       "No noticeboards to walk past"]):
    tf = box(s, Inches(1.1 + i * 3.8), Inches(5.35), Inches(3.6), Inches(0.4))
    put(tf, t, 14, EMBER, bold=True, first=True)

# ----------------------------------------------------------- 5 · SOLUTION
s = slide()
kicker(s, "The solution")
headline(s, "CampHere — a campus that answers when asked")
support(s, "One app holds the feed, the notices, the attendance and your "
           "own board, and one guide searches all of it in plain language.")
rule(s)
screenshot(s, f"{SHOTS}/01_home.png", Inches(0.6), Inches(2.1),
           Inches(7.4), "Home — the editorial landing with the live feed")
feats = [
    ("Ask anything", "An intra-app guide that searches events, societies, "
     "seats and your board."),
    ("Notice board", "Every office and society, pinned first."),
    ("Attendance", "The term at a glance, before it becomes a problem."),
]
y = 2.1
for t, b in feats:
    card(s, Inches(8.35), Inches(y), Inches(4.35), Inches(1.42), t, b,
         accent=EMBER, title_size=13.5, body_size=10.5)
    y += 1.57

# ------------------------------------------------------- 6 · WHAT'S INSIDE
s = slide()
kicker(s, "What's inside")
headline(s, "Five surfaces, one design language")
support(s, "Liquid glass over real footage; paper-and-ink editorial for the "
           "front door. Fixed compositions, one ember accent.")
rule(s)
shots = [
    (f"{SHOTS}/02_notices.png", "Notice board — pinned first, filtered by office"),
    (f"{SHOTS}/03_attendance.png", "Attendance — term, subjects, weekly trend"),
    (f"{SHOTS}/04_profile.png", "My board — RSVPs, societies, the week"),
]
x = 0.6
for path, label in shots:
    screenshot(s, path, Inches(x), Inches(2.15), Inches(4.0), label)
    x += 4.12
footer(s, "Plus the guide (slide 7) and the home feed (slide 5) — five "
          "surfaces in total, all responsive down to phones.")

# ---------------------------------------------------- 7 · THE CAMPUS GUIDE
s = slide(BG_WARM)
kicker(s, "The campus guide")
headline(s, "An intra-app assistant that searches the whole app")
support(s, "Not a chatbot bolted on the side — the guide reads the live "
           "feed, the societies, the seats left and your own board, and "
           "answers with the events attached as cards.")
rule(s)
screenshot(s, f"{SHOTS}/06_chat_live.png", Inches(0.6), Inches(2.15),
           Inches(7.4), "\u201cWhat is on tonight?\u201d — answered from the live feed")
tf = box(s, Inches(8.35), Inches(2.3), Inches(4.4), Inches(3.4))
put(tf, "It answers from data, not vibes.", 15.5, EMBER, bold=True, first=True)
for line in [
    "tonight · tomorrow · this weekend",
    "free food, seats left, fixtures",
    "societies and what they run",
    "\u201cwhat's on my board?\u201d — with a tap straight to it",
]:
    put(tf, "·  " + line, 12.5, MUTED, spacing=1.15, space_after=4)
tf = box(s, Inches(8.35), Inches(5.6), Inches(4.4), Inches(0.8))
put(tf, "Keep the question. We'll find it.", 14.5, CREAM, bold=True,
    first=True)

# ---------------------------------------------------- 8 · HOW IT WORKS · FIND
s = slide()
kicker(s, "How it works · find")
headline(s, "Four steps from a question to an answer")
support(s, "The guide spends most of its life doing nothing dramatic — it "
           "searches, and only then does it speak.")
rule(s)
steps = [
    ("01", "The question", "Typed or tapped — the chips pre-fill the "
     "questions students actually ask."),
    ("02", "The intent", "Tonight, tomorrow, food, fixtures, societies, "
     "seats, or \u201cmy board\u201d — matched locally, offline-safe."),
    ("03", "The search", "Keyword scoring across titles, societies, "
     "locations and categories over the live feed."),
    ("04", "The answer", "A short line in plain language, with the matching "
     "events as cards and an action to jump deeper."),
]
x = 0.6
for num, t, b in steps:
    tf = box(s, Inches(x), Inches(2.25), Inches(2.85), Inches(0.7))
    put(tf, num, 26, EMBER, bold=True, first=True)
    card(s, Inches(x), Inches(2.95), Inches(2.85), Inches(2.7), t, b,
         title_size=14, body_size=11)
    x += 3.08

# ------------------------------------------------- 9 · HOW IT WORKS · ANSWER
s = slide()
kicker(s, "How it works · answer")
headline(s, "Three providers. The student never feels one fail.")
support(s, "The guide speaks to three OpenAI-compatible LLM endpoints — "
           "Groq, OpenRouter and NVIDIA NIM — behind one router.")
rule(s)
chain = [
    ("Groq", "llama-3.3-70b — first pick, lowest latency", GREEN),
    ("OpenRouter", "llama-3.3-70b:free — second in line", CREAM),
    ("NVIDIA NIM", "llama-3.1-70b — the third line", CREAM),
    ("Local search", "the always-works fallback — no keys, no network", EMBER),
]
y = 2.2
for name, desc, color in chain:
    card(s, Inches(0.6), Inches(y), Inches(6.4), Inches(0.88), name, desc,
         accent=color, title_size=13.5, body_size=10.5)
    y += 1.03
behind = [
    ("Health probing", "While the screen is open, a background ping checks "
     "every provider that is cooling down — before the next question."),
    ("Cooldowns, not errors", "A timeout or rate limit cools a provider "
     "down (30s → 10min) and the router moves on. No spinner of doom, no "
     "error toast — the typing state just continues."),
    ("One answer", "Whichever provider answers first wins. The student sees "
     "a single reply, never the plumbing."),
]
x = 7.35
y = 2.2
for t, b in behind:
    card(s, Inches(x), Inches(y), Inches(5.35), Inches(1.32), t, b,
         title_size=13, body_size=10.5)
    y += 1.47

# ------------------------------------------------------- 10 · DESIGN RULE
s = slide(BG_WARM)
kicker(s, "The rule that governs every design decision")
headline(s, "Liquid, not loud", size=40)
support(s, "Every surface is frosted glass over something real — a scrubbed "
           "video on the front door, a photograph behind the dashboards — "
           "with one ember accent doing all the pointing.")
rule(s)
points = [
    ("Fixed compositions", "The landing never scrolls content; scrolling "
     "scrubs the film. Dashboards sit on measured reference frames."),
    ("One accent", "Ember points at exactly one thing per view — the send, "
     "the pin, the risk."),
    ("Type carries it", "Inter variable, optical sizes, fractional weights — "
     "no decorative fonts anywhere."),
    ("Motion with manners", "Surfaces settle once; the chart draws itself "
     "then fills; nothing loops except the live dot."),
]
y = 2.3
for t, b in points:
    tf = box(s, Inches(0.9), Inches(y), Inches(3.3), Inches(0.4))
    put(tf, t, 15, CREAM, bold=True, first=True)
    tf = box(s, Inches(4.3), Inches(y), Inches(8.2), Inches(0.9))
    put(tf, b, 12.5, MUTED, first=True, spacing=1.12)
    y += 1.06
screenshot(s, f"{SHOTS}/07_home_phone.png", Inches(10.35), Inches(2.2),
           Inches(2.2), "Phone — same rules")

# ------------------------------------------------------------ 11 · STACK
s = slide()
kicker(s, "Tech stack")
headline(s, "Built entirely from proven, available parts")
support(s, "Nothing here needs a research lab — the synthesis is the product.")
rule(s)
stack = [
    ("App", "Flutter 3.47 — one codebase shipping web today and Android "
     "next; liquid-glass surfaces via backdrop blur, variable Inter."),
    ("Backend", "Serverpod 4 + PostgreSQL — generated, typed clients; "
     "events with categories, RSVPs and capacity; anonymous + email auth."),
    ("Guide", "OpenAI-compatible chat APIs — Groq, OpenRouter, NVIDIA NIM "
     "behind one failover router with background health probing."),
    ("Data", "The guide always answers inside the app's reality: the live "
     "feed, the societies and the student's board ship with every request."),
    ("Media", "All-intra video for frame-accurate scroll scrubbing; "
     "seamless-carved film grain; variable fonts bundled locally."),
    ("Testing", "Widget smoke tests with real fonts loaded, plus scripted "
     "browser runs at desktop, tablet and phone sizes."),
]
x, y = 0.6, 2.15
for i, (t, b) in enumerate(stack):
    card(s, Inches(x), Inches(y), Inches(5.9), Inches(1.38), t, b,
         accent=EMBER, title_size=13.5, body_size=10.5)
    if i % 2 == 0:
        x += 6.23
    else:
        x = 0.6
        y += 1.53

# ----------------------------------------------------- 12 · FEASIBILITY
s = slide()
kicker(s, "Feasibility")
headline(s, "Everything already exists. Nobody pointed it at a campus.")
support(s, "Each part of CampHere is documented, stable technology. The "
           "working prototype — not a mockup — proves the composition.")
rule(s)
facts = [
    ("Scrubbed video", "All-intra H.264 seeking lands on exact frames — the "
     "same trick film sites use, driving the landing."),
    ("Typed backend", "Serverpod generates the client from the server "
     "models; RSVPs are upsert-safe with capacity rules server-side."),
    ("Provider chain", "All three LLM providers implement the same chat "
     "schema, so one router speaks to all of them."),
    ("Offline-first UI", "Every surface degrades to bundled sample data, so "
     "the app demos with or without the server up."),
]
y = 2.3
for t, b in facts:
    tf = box(s, Inches(0.9), Inches(y), Inches(3.4), Inches(0.4))
    put(tf, t, 15, EMBER, bold=True, first=True)
    tf = box(s, Inches(4.4), Inches(y), Inches(8.1), Inches(0.9))
    put(tf, b, 12.5, MUTED, first=True, spacing=1.12)
    y += 1.02

# --------------------------------------------------------- 13 · THE GAP
s = slide()
kicker(s, "Where the gap is")
headline(s, "Nobody combines all four")
support(s, "Portals have the data but no conversation. Chatbots can talk "
           "but don't know the campus. Groups have attention but no "
           "structure. CampHere is the only place all four meet.")
rule(s)
rows = [
    ("", "Whole-app search", "Live feed data", "Survives outages", "Glass, fixed UI"),
    ("College portals", "\u2713", "\u2713", "\u2713", "\u2717"),
    ("Generic chatbots", "\u2713", "\u2717", "\u2713", "\u2717"),
    ("WhatsApp groups", "\u2717", "\u2713", "\u2717", "\u2717"),
    ("CampHere", "\u2713", "\u2713", "\u2713", "\u2713"),
]
y = 2.35
for i, row in enumerate(rows):
    xs = [0.6, 4.7, 7.15, 9.6, 11.5]
    for j, cell in enumerate(row):
        color = CREAM if i == 0 else (MUTED if j == 0 else DIM)
        if i == 4:
            color = EMBER if j != 0 else CREAM
        size = 12 if i == 0 else (13.5 if j == 0 else 16)
        tf = box(s, Inches(xs[j]), Inches(y), Inches(4.0 if j == 0 else 1.6),
                 Inches(0.4))
        bold = (i == 0) or (i == 4) or (j == 0)
        put(tf, cell, size, color, bold=bold, first=True)
    y += 0.78
footer(s, "CampHere = the guide's whole-app search, the feed it reads, the "
          "failover chain that keeps it up, and a UI worth looking at.")

# --------------------------------------------- 14 · WORKING PROTOTYPE
s = slide()
kicker(s, "Working prototype")
headline(s, "Built and running, not a mockup")
support(s, "Flutter web build, verified in scripted browser runs at "
           "desktop, tablet and phone sizes — the same code that ships to "
           "Android next.")
rule(s)
screenshot(s, f"{SHOTS}/01_home.png", Inches(0.6), Inches(2.1),
           Inches(5.9), "Home — scroll scrubs the film")
screenshot(s, f"{SHOTS}/05_chat.png", Inches(6.75), Inches(2.1),
           Inches(5.9), "The guide — ask what's on")
phone_w = Inches(1.18)
screenshot(s, f"{SHOTS}/08_notices_phone.png", Inches(0.6), Inches(4.42),
           phone_w, "Notices · phone")
screenshot(s, f"{SHOTS}/09_attendance_phone.png", Inches(2.08), Inches(4.42),
           phone_w, "Attendance · phone")
tf = box(s, Inches(3.7), Inches(4.75), Inches(9), Inches(1.6))
put(tf, "Under the hood:", 13.5, CREAM, bold=True, first=True)
for line in [
    "Screens: home · guide · notice board · attendance · my board",
    "Backend: events + RSVP + auth endpoints, integration-tested server-side",
    "Guide: multi-provider LLM chain with silent failover + local search",
]:
    put(tf, "·  " + line, 11.5, MUTED, spacing=1.15)

# --------------------------------------------------------- 15 · REFERENCES
s = slide()
kicker(s, "Research & references")
headline(s, "What this is built on")
support(s, "The engineering stands on documented platforms; the product "
           "decisions stand on our own campus.")
rule(s)
refs = [
    ("Platform docs",
     "Flutter engine & video_player seeking docs · Serverpod 4 "
     "(ORM, auth IDPs, code generation) · OpenAI chat-completions schema as "
     "implemented by OpenRouter, Groq and NVIDIA NIM."),
    ("Design research",
     "Liquid-glass material guidance (backdrop blur, translucent layers, "
     "specular highlights) · editorial grid and typographic scale practice "
     "from print · Apple HIG motion principles."),
    ("Campus research",
     "Our own survey of how notices, fixtures and club events actually "
     "reach students at IILM — the scatter this app exists to fix."),
    ("Prototype learning",
     "Six browser-verified iterations taught the layout rules now encoded "
     "in the design tokens: uniform borders for rounded glass, "
     "content-sized pills, real fonts in widget tests."),
]
y = 2.3
for t, b in refs:
    tf = box(s, Inches(0.9), Inches(y), Inches(3.4), Inches(0.4))
    put(tf, t, 15, CREAM, bold=True, first=True)
    tf = box(s, Inches(4.4), Inches(y), Inches(8.1), Inches(1.0))
    put(tf, b, 12, MUTED, first=True, spacing=1.12)
    y += 1.06

# ---------------------------------------------------------- 16 · THANK YOU
s = slide(BG_WARM)
tf = box(s, Inches(0.6), Inches(2.5), Inches(12), Inches(1.2))
put(tf, "CAMPHERE", 60, CREAM, bold=True, first=True, align=PP_ALIGN.CENTER)
tf = box(s, Inches(0.6), Inches(3.8), Inches(12), Inches(0.5))
put(tf, "Ask what's on.  It's already found.", 18, EMBER, bold=True,
    first=True, align=PP_ALIGN.CENTER)
tf = box(s, Inches(0.6), Inches(4.6), Inches(12), Inches(0.5))
put(tf, "Pseudo College's  ·  IILM Grid Noida", 14, MUTED, first=True,
    align=PP_ALIGN.CENTER)
tf = box(s, Inches(0.6), Inches(5.05), Inches(12), Inches(0.5))
put(tf, "Aditya Dubey  ·  Kunal Avvanshi", 14, MUTED, first=True,
    align=PP_ALIGN.CENTER)

out = "/Users/aditya/Campus-app/docs/pitch/CampHere_Pitch.pptx"
prs.save(out)
print("saved", out, "slides:", len(prs.slides.__iter__.__self__._sldIdLst))
