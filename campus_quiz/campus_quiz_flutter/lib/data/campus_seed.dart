import 'package:campus_quiz_client/campus_quiz_client.dart';

/// The signed-in student shown across the profile surfaces.
///
/// Replace with the values from the Serverpod auth session once the account
/// screens are wired to a real profile endpoint.
class CampusProfile {
  const CampusProfile({
    required this.name,
    required this.handle,
    required this.initials,
    required this.avatarUrl,
    required this.term,
    required this.going,
    required this.interested,
    required this.clubs,
    required this.weekActivity,
    required this.categoryCounts,
  });

  final String name;
  final String handle;
  final String initials;
  final String avatarUrl;
  final String term;
  final int going;
  final int interested;
  final int clubs;

  /// RSVPs registered per day, Monday first.
  final List<int> weekActivity;

  final Map<EventCategory, int> categoryCounts;
}

/// One point of the weekly activity curve.
class WeekPoint {
  const WeekPoint({
    required this.label,
    required this.value,
    required this.isToday,
  });

  final String label;
  final int value;
  final bool isToday;
}

/// The sample feed used when the Serverpod backend is unreachable.
///
/// The entries mirror the development seeder in
/// `campus_quiz_server/lib/src/events/event_seeder.dart` so the UI shows the
/// same campus in preview mode as it does against a running server.
List<EventSummary> buildSampleFeed({DateTime? now}) {
  final today = now ?? DateTime.now();
  DateTime at(int daysFromNow, int hour, [int minute = 0]) => DateTime(
    today.year,
    today.month,
    today.day + daysFromNow,
    hour,
    minute,
  );

  /// A time later today, rounded up to the next half hour.
  DateTime laterToday(double hours) {
    final raw = today.add(Duration(minutes: (hours * 60).round()));
    final rounded = raw.minute <= 30 ? 30 : 60;
    return DateTime(raw.year, raw.month, raw.day, raw.hour, rounded);
  }

  /// Keeps a same-day event on today, inside a sensible evening window:
  /// anything later than nine o'clock is pulled back to nine, and once nine
  /// has passed the event slips to tomorrow morning rather than landing at
  /// two in the morning.
  DateTime sameDay(DateTime when, int fallbackHour) {
    if (when.day != today.day) return at(1, fallbackHour);
    final limit = DateTime(today.year, today.month, today.day, 21);
    if (when.isAfter(limit)) {
      return limit.isAfter(today) ? limit : at(1, fallbackHour);
    }
    return when;
  }

  EventSummary make(
    int index,
    String title,
    String description,
    DateTime startsAt,
    DateTime? endsAt,
    String location,
    String organizer,
    int? capacity,
    EventCategory category,
    int going,
    int interested,
  ) {
    return EventSummary(
      event: Event(
        id: UuidValue.fromString(
          '00000000-0000-4000-8000-${index.toString().padLeft(12, '0')}',
        ),
        title: title,
        description: description,
        startsAt: startsAt,
        endsAt: endsAt,
        location: location,
        organizer: organizer,
        capacity: capacity,
        category: category,
        createdAt: startsAt.subtract(const Duration(days: 6)),
      ),
      goingCount: going,
      interestedCount: interested,
    );
  }

  final feed = <EventSummary>[
    make(
      11,
      'Design Studio Open Hours',
      'The design block opens its doors for anyone who wants to print, draw '
          'or prototype. Supervisors are around to help.',
      sameDay(laterToday(2), 10),
      sameDay(laterToday(3), 11),
      'Studio 2, Design Block',
      'Design Collective',
      40,
      EventCategory.workshop,
      18,
      24,
    ),
    make(
      12,
      'Fireside Chat: Your First App',
      'Two alumni talk about what they shipped first, the mistakes that cost '
          'them, and what they would build again.',
      sameDay(laterToday(5), 16),
      sameDay(laterToday(6), 17),
      'Cafeteria Lawn',
      'Entrepreneurship Cell',
      120,
      EventCategory.tech,
      86,
      41,
    ),
    make(
      1,
      'Sunrise Yoga on the Quad',
      'A gentle hour of yoga on the central lawn, led by the campus wellness '
          'club. Mats provided.',
      at(1, 6, 30),
      at(1, 7, 30),
      'Central Quad',
      'Wellness Club',
      40,
      EventCategory.sports,
      31,
      18,
    ),
    make(
      13,
      'Breakfast Run and Coffee',
      'A five-kilometre loop around the campus track, finishing with filter '
          'coffee at the canteen. All paces welcome.',
      at(1, 7, 30),
      at(1, 8, 30),
      'Track, Behind Block D',
      'Athletics Club',
      null,
      EventCategory.sports,
      27,
      15,
    ),
    make(
      2,
      'Campus Hackathon 2026',
      'Twenty-four hours to build something useful. Teams of up to four '
          'people, mentors on site, and a demo session to wrap it up.',
      at(2, 10),
      at(3, 18),
      'Main Auditorium',
      'Coding Club',
      200,
      EventCategory.tech,
      148,
      64,
    ),
    make(
      14,
      'Library Study Sprint',
      'Three focused hours in the reading room with the lights low and phones '
          'away. Everyone works on their own thing.',
      at(2, 13),
      at(2, 16),
      'Central Library, Floor 2',
      'Library Committee',
      80,
      EventCategory.academic,
      34,
      29,
    ),
    make(
      3,
      'Intro to Machine Learning',
      'A hands-on introduction to building and training small models. Bring a '
          'laptop; no prior machine learning experience needed.',
      at(3, 14),
      at(3, 16),
      'Lab 2, Computing Block',
      'AI Collective',
      60,
      EventCategory.workshop,
      57,
      22,
    ),
    make(
      15,
      'Robotics Lab Open House',
      'The robotics lab opens its workbenches: line-following bots, a drone '
          'you can fly, and the students who built them.',
      at(3, 11),
      at(3, 13),
      'Robotics Lab, Block E',
      'Robotics Society',
      50,
      EventCategory.tech,
      41,
      33,
    ),
    make(
      4,
      'Photography Walk: Old Town',
      'A guided walk through the old town for anyone interested in street '
          'photography. Cameras optional.',
      at(4, 7),
      at(4, 9),
      'Meet at the Main Gate',
      'Photography Club',
      null,
      EventCategory.community,
      26,
      41,
    ),
    make(
      16,
      'Football Trials — Open Selection',
      'Open trials for the university side. Bring boots and a dark top; the '
          'coaches will take anyone who turns up.',
      at(4, 16),
      at(4, 18),
      'University Stadium',
      'Sports Council',
      60,
      EventCategory.sports,
      22,
      47,
    ),
    make(
      5,
      'Inter-college Football Final',
      'The annual sports final between the host university and three visiting '
          'colleges. Spectators welcome from the north stand.',
      at(5, 16),
      at(5, 19),
      'University Stadium',
      'Sports Council',
      500,
      EventCategory.sports,
      312,
      97,
    ),
    make(
      6,
      'Placement Preparation Seminar',
      'Recruiters walk through the selection process, common interview '
          'questions and how to prepare your CV.',
      at(6, 11),
      at(6, 13),
      'Seminar Hall 3',
      'Placement Cell',
      120,
      EventCategory.academic,
      103,
      38,
    ),
    make(
      17,
      'General Aptitude Quiz',
      'A timed departmental quiz on quant, reasoning and reading. First '
          'year scores go on the notice board on Friday.',
      at(5, 13),
      at(5, 15),
      'Exam Hall 2',
      'Academic Committee',
      150,
      EventCategory.academic,
      96,
      52,
    ),
    make(
      18,
      'Short Film Screening',
      'Eight student-made short films, one of them a winner at the regional '
          'festival. Introductions by the directors.',
      at(6, 19),
      at(6, 21),
      'Auditorium, Block A',
      'Film Society',
      180,
      EventCategory.cultural,
      112,
      67,
    ),
    make(
      7,
      'Cultural Night',
      'Music, dance and food from every cultural society on campus. Open to '
          'all students and staff.',
      at(7, 18),
      at(7, 22),
      'Central Plaza',
      'Cultural Society',
      800,
      EventCategory.cultural,
      541,
      188,
    ),
    make(
      19,
      'Blood Donation Drive',
      'The college health unit is hosting a donation camp with the city '
          'blood bank. Donors get a certificate and a full breakfast.',
      at(7, 10),
      at(7, 14),
      'Health Centre, Block C',
      'NSS Unit',
      70,
      EventCategory.community,
      44,
      19,
    ),
    make(
      8,
      'Open Mic Night',
      'Ten minutes per act. Poetry, stand-up, instruments and anything in '
          'between. Sign-ups close at eight.',
      at(8, 17),
      at(8, 20),
      'Student Centre Basement',
      'Dramatic Society',
      90,
      EventCategory.cultural,
      76,
      29,
    ),
    make(
      9,
      'Undergraduate Research Symposium',
      'Final-year and masters students present their research posters to '
          'faculty and fellow students.',
      at(10, 9),
      at(10, 15),
      'Research Wing, Block C',
      'Graduate Council',
      150,
      EventCategory.academic,
      121,
      44,
    ),
    make(
      10,
      'Startup Pitch Night',
      'Five early-stage teams pitch to a panel of alumni investors. Doors '
          'open at seven, pitches start at half past.',
      at(12, 19),
      at(12, 22),
      'Innovation Hub',
      'Entrepreneurship Cell',
      100,
      EventCategory.tech,
      88,
      51,
    ),
  ];

  return feed;
}

/// The profile shown while the account screens are not connected to a real
/// profile endpoint.
const CampusProfile sampleProfile = CampusProfile(
  name: 'Aditya Dubey',
  handle: '@aditya.dubey',
  initials: 'AD',
  avatarUrl:
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&h=160&fit=crop&crop=faces&q=80&auto=format',
  term: 'Autumn 2026',
  going: 18,
  interested: 11,
  clubs: 6,
  weekActivity: [2, 4, 1, 6, 3, 5, 2],
  categoryCounts: {
    EventCategory.academic: 5,
    EventCategory.tech: 4,
    EventCategory.sports: 3,
    EventCategory.cultural: 3,
    EventCategory.workshop: 2,
    EventCategory.community: 1,
  },
);

/// The day labels under the weekly activity curve.
const List<WeekPoint> sampleWeek = [
  WeekPoint(label: 'Monday', value: 2, isToday: false),
  WeekPoint(label: 'Tuesday', value: 4, isToday: false),
  WeekPoint(label: 'Wednesday', value: 1, isToday: true),
  WeekPoint(label: 'Thursday', value: 6, isToday: false),
  WeekPoint(label: 'Friday', value: 3, isToday: false),
  WeekPoint(label: 'Saturday', value: 5, isToday: false),
  WeekPoint(label: 'Sunday', value: 2, isToday: false),
];

/// A notice published on the campus digital notice board.
class CampusNotice {
  const CampusNotice({
    required this.title,
    required this.body,
    required this.category,
    required this.office,
    required this.date,
    this.pinned = false,
  });

  final String title;
  final String body;
  final String category;
  final String office;
  final String date;
  final bool pinned;
}

/// The sample notices shown when the backend is unreachable.
const List<CampusNotice> sampleNotices = [
  CampusNotice(
    title: 'Mid-semester examination schedule published',
    body:
        'The timetable for the odd-semester mid-semester examinations is now '
        'on the portal. Hall tickets unlock 48 hours before your first paper.',
    category: 'Exams',
    office: 'Examination Cell',
    date: 'Today',
    pinned: true,
  ),
  CampusNotice(
    title: 'Infosys on-campus drive — register by Thursday',
    body:
        'Eligibility: 7.0 CGPA and above, all branches. Pre-placement talk on '
        'Wednesday at 10 am in Seminar Hall 3. Carry a printed resume.',
    category: 'Placement',
    office: 'Placement Cell',
    date: 'Today',
    pinned: true,
  ),
  CampusNotice(
    title: 'Library extends hours for exam week',
    body:
        'The reading halls will stay open until 2 am from Monday. The '
        'discussion rooms move to first-come booking after 6 pm.',
    category: 'Admin',
    office: 'Central Library',
    date: 'Yesterday',
  ),
  CampusNotice(
    title: 'Hackathon team registrations are open',
    body:
        'Teams of up to four, mentors on site, demo session on Sunday '
        'evening. Register through the coding club desk in the Computing '
        'Block.',
    category: 'Clubs',
    office: 'Coding Club',
    date: '2 days ago',
  ),
  CampusNotice(
    title: 'Bus route 4 timing change from Monday',
    body:
        'Route 4 departs the main gate 15 minutes earlier at 8:05 am for the '
        'rest of the term. Evening drops are unchanged.',
    category: 'Admin',
    office: 'Transport Office',
    date: '3 days ago',
  ),
  CampusNotice(
    title: 'Hostel mess menu for November is out',
    body:
        'The updated monthly menu is pinned in every block and on the mess '
        'noticeboard. Special diet requests go to the warden by Friday.',
    category: 'General',
    office: 'Hostel Office',
    date: '4 days ago',
  ),
  CampusNotice(
    title: 'Photography walk: old town, this Saturday',
    body:
        'Meet at the main gate at 7 am. Cameras optional; the club has six '
        'spares. Registrations close Friday evening.',
    category: 'Clubs',
    office: 'Photography Club',
    date: '5 days ago',
  ),
  CampusNotice(
    title: 'Revaluation window closes on Friday',
    body:
        'Applications for odd-semester answer-sheet revaluation close at 4 pm '
        'Friday. Forms are accepted only through the portal.',
    category: 'Exams',
    office: 'Examination Cell',
    date: '6 days ago',
  ),
];

/// One subject's attendance record.
class AttendanceSubject {
  const AttendanceSubject({
    required this.name,
    required this.code,
    required this.attended,
    required this.total,
  });

  final String name;
  final String code;
  final int attended;
  final int total;

  double get percent => total == 0 ? 0 : attended / total * 100;
}

/// The student's attendance summary used by the attendance section.
class AttendanceRecord {
  const AttendanceRecord({required this.subjects, required this.weekTrend});

  final List<AttendanceSubject> subjects;
  final List<double> weekTrend;

  int get attended => subjects.fold(0, (sum, s) => sum + s.attended);

  int get total => subjects.fold(0, (sum, s) => sum + s.total);

  double get percent => total == 0 ? 0 : attended / total * 100;

  List<AttendanceSubject> get atRisk =>
      subjects.where((s) => s.percent < 75).toList();
}

/// The sample attendance shown when the backend is unreachable.
const AttendanceRecord sampleAttendance = AttendanceRecord(
  subjects: [
    AttendanceSubject(
      name: 'Data Structures & Algorithms',
      code: 'CS-201',
      attended: 34,
      total: 38,
    ),
    AttendanceSubject(
      name: 'Database Management Systems',
      code: 'CS-202',
      attended: 31,
      total: 36,
    ),
    AttendanceSubject(
      name: 'Operating Systems',
      code: 'CS-203',
      attended: 26,
      total: 35,
    ),
    AttendanceSubject(
      name: 'Discrete Mathematics',
      code: 'MA-204',
      attended: 33,
      total: 34,
    ),
    AttendanceSubject(
      name: 'Software Engineering',
      code: 'CS-205',
      attended: 29,
      total: 32,
    ),
    AttendanceSubject(
      name: 'Technical Communication',
      code: 'HS-206',
      attended: 24,
      total: 28,
    ),
  ],
  weekTrend: [86, 92, 74, 88, 95, 82, 0],
);

/// A piece of work a student owes a course.
class CampusAssignment {
  const CampusAssignment({
    required this.id,
    required this.subject,
    required this.code,
    required this.title,
    required this.detail,
    required this.due,
    this.marks = 20,
    this.submitted = false,
  });

  final String id;
  final String subject;
  final String code;
  final String title;
  final String detail;
  final DateTime due;
  final int marks;
  final bool submitted;

  bool get isOverdue => !submitted && due.isBefore(DateTime.now());

  CampusAssignment copyWith({bool? submitted}) => CampusAssignment(
    id: id,
    subject: subject,
    code: code,
    title: title,
    detail: detail,
    due: due,
    marks: marks,
    submitted: submitted ?? this.submitted,
  );
}

/// A society or club a student can join.
class CampusClub {
  const CampusClub({
    required this.id,
    required this.name,
    required this.category,
    required this.blurb,
    required this.schedule,
    required this.venue,
    required this.members,
    this.joined = false,
  });

  final String id;
  final String name;
  final String category;
  final String blurb;
  final String schedule;
  final String venue;
  final int members;
  final bool joined;

  /// Two-letter mark used on the club's badge.
  String get initials {
    final words = name
        .split(' ')
        .where((w) => w.isNotEmpty && w[0].toUpperCase() == w[0])
        .toList();
    if (words.isEmpty) return name.substring(0, 1).toUpperCase();
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  CampusClub copyWith({bool? joined, int? members}) => CampusClub(
    id: id,
    name: name,
    category: category,
    blurb: blurb,
    schedule: schedule,
    venue: venue,
    members: members ?? this.members,
    joined: joined ?? this.joined,
  );
}

/// The assignment desk: what is due, and when.
List<CampusAssignment> buildSampleAssignments({DateTime? now}) {
  final today = now ?? DateTime.now();
  DateTime at(int daysFromNow, int hour, [int minute = 0]) => DateTime(
    today.year,
    today.month,
    today.day + daysFromNow,
    hour,
    minute,
  );

  return [
    CampusAssignment(
      id: 'as-1',
      subject: 'Data Structures & Algorithms',
      code: 'CS-201',
      title: 'Problem set 4 — graphs and shortest paths',
      detail:
          'Six exercises on Dijkstra, Bellman-Ford and union-find. Submit as a '
          'single PDF; code is optional but earns the bonus mark.',
      due: at(0, 23),
      marks: 20,
    ),
    CampusAssignment(
      id: 'as-2',
      subject: 'Technical Communication',
      code: 'HS-206',
      title: 'Lab report — the 90-second explainer',
      detail:
          'Record a two-minute walkthrough of one of your lab experiments. '
          'Keep the structure: problem, method, result, what you would change.',
      due: at(1, 18),
      marks: 10,
    ),
    CampusAssignment(
      id: 'as-3',
      subject: 'Database Management Systems',
      code: 'CS-202',
      title: 'SQL aggregation assignment',
      detail:
          'Nine queries over the library lending schema, including two window '
          'functions and one recursive CTE.',
      due: at(2, 20),
      marks: 20,
    ),
    CampusAssignment(
      id: 'as-4',
      subject: 'Operating Systems',
      code: 'CS-203',
      title: 'Process scheduling simulation',
      detail:
          'Implement round robin, SJF and MLFQ in the provided skeleton, then '
          'compare average turnaround time across three workloads.',
      due: at(3, 19),
      marks: 25,
      submitted: true,
    ),
    CampusAssignment(
      id: 'as-5',
      subject: 'Discrete Mathematics',
      code: 'MA-204',
      title: 'Proof sheet 3 — induction and counting',
      detail:
          'Prove four statements by induction, then answer the counting '
          'questions in part B.',
      due: at(5, 17),
      marks: 15,
    ),
    CampusAssignment(
      id: 'as-6',
      subject: 'Software Engineering',
      code: 'CS-205',
      title: 'Requirements and user stories',
      detail:
          'Turn the campus app brief into user stories with acceptance '
          'criteria, and mark the three riskiest assumptions.',
      due: at(7, 21),
      marks: 20,
    ),
    CampusAssignment(
      id: 'as-7',
      subject: 'Data Structures & Algorithms',
      code: 'CS-201',
      title: 'Problem set 3 — trees and heaps',
      detail:
          'Implement a binary heap with a priority queue wrapper, plus the '
          'hand-written proofs for questions 4 and 5.',
      due: at(-1, 21),
      marks: 20,
    ),
    CampusAssignment(
      id: 'as-8',
      subject: 'Design Fundamentals',
      code: 'DS-110',
      title: 'Poster critique — one good argument, two weak ones',
      detail:
          'Pick three student posters from the showcase and write a critique '
          'of 400 words.',
      due: at(9, 18),
      marks: 10,
      submitted: true,
    ),
  ];
}

/// The societies desk: who is running what, and when they meet.
List<CampusClub> buildSampleClubs() {
  return const [
    CampusClub(
      id: 'cl-1',
      name: 'Coding Club',
      category: 'Technology',
      blurb:
          'Builds, breaks and benchmarks. Weekly problem-solving nights and a '
          'term-long project sprint with mentors from the industry.',
      schedule: 'Tuesdays · 6:30 pm',
      venue: 'Computing Block, Lab 2',
      members: 148,
    ),
    CampusClub(
      id: 'cl-2',
      name: 'AI Collective',
      category: 'Technology',
      blurb:
          'Reading group for papers worth your evening, plus a hands-on lab '
          'where the same models get rebuilt from scratch.',
      schedule: 'Thursdays · 5:00 pm',
      venue: 'Seminar Hall 3',
      members: 92,
    ),
    CampusClub(
      id: 'cl-3',
      name: 'Wellness Club',
      category: 'Sports',
      blurb:
          'Sunrise yoga on the quad, evening runs along the track, and a '
          'physio visit every Wednesday for anyone training.',
      schedule: 'Daily · 6:30 am',
      venue: 'Central Quad',
      members: 214,
    ),
    CampusClub(
      id: 'cl-4',
      name: 'The Quad Players',
      category: 'Cultural',
      blurb:
          'Open-mic theatre and street theatre. Rehearsals are ruthless, the '
          'audience is forgiving, everyone ends up on stage by December.',
      schedule: 'Fridays · 7:00 pm',
      venue: 'Open Air Theatre',
      members: 76,
    ),
    CampusClub(
      id: 'cl-5',
      name: 'Photography Society',
      category: 'Cultural',
      blurb:
          'Darkroom sessions, photo walks around the campus, and a yearly '
          'exhibition that fills the atrium walls for a week.',
      schedule: 'Wednesdays · 4:30 pm',
      venue: 'Arts Block, Studio 1',
      members: 88,
    ),
    CampusClub(
      id: 'cl-6',
      name: 'Debate Union',
      category: 'Academic',
      blurb:
          'British parliamentary format every other week. You argue a side '
          'you did not pick, on a motion you did not write.',
      schedule: 'Alternate Saturdays · 4:00 pm',
      venue: 'Seminar Hall 1',
      members: 64,
    ),
    CampusClub(
      id: 'cl-7',
      name: 'Eco Club',
      category: 'Community',
      blurb:
          'Campus garden, waste audits and the annual monsoon drain '
          'restoration drive with the municipal ward.',
      schedule: 'Saturdays · 8:00 am',
      venue: 'Behind the Hostel Block',
      members: 51,
    ),
    CampusClub(
      id: 'cl-8',
      name: 'Business Collective',
      category: 'Academic',
      blurb:
          'Case study sprints, mock interviews, and a trading simulation that '
          'survives exactly one week every semester.',
      schedule: 'Mondays · 6:00 pm',
      venue: 'Management Block, Room 204',
      members: 133,
    ),
  ];
}
