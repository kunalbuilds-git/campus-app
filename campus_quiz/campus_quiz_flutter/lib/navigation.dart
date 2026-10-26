/// The surfaces of CampHere, in the order they appear in the top bar.
///
/// Every screen shares this list so the navigation never drifts: the
/// landing page, the board, the guide and the dashboard all point at the
/// same names and the same routes.
library;

const List<String> campLinks = [
  'Home',
  'Events',
  'Notices',
  'Assignments',
  'Clubs',
  'Attendance',
  'My board',
];

const List<String> campRoutes = [
  '/',
  '/events',
  '/notices',
  '/assignments',
  '/clubs',
  '/attendance',
  '/profile',
];

/// The sections that also live in the dashboard sidebar and the mobile dock.
const List<String> campSidebarItems = [
  'Home',
  'Events',
  'Notice board',
  'Assignments',
  'Clubs',
  'Attendance',
  'My events',
];

const List<String> campSidebarRoutes = [
  '/',
  '/events',
  '/notices',
  '/assignments',
  '/clubs',
  '/attendance',
  '/profile',
];
