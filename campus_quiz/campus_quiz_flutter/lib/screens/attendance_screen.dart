import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/campus_repository.dart';
import '../data/campus_seed.dart';
import '../navigation.dart';
import '../theme/brand.dart';
import '../widgets/glass.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/glass_page_backdrop.dart';
import '../widgets/wave_chart.dart';

/// The student's attendance.
///
/// One number for the term, per-subject bars, and the week's trend — the same
/// frosted language as the rest of the app. The counts are the student's own,
/// so they can be corrected: tap a subject to update what was attended and
/// how many classes were held.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final CampusRepository _repo = CampusRepository();

  AttendanceRecord _record = sampleAttendance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final record = await _repo.attendance();
    if (!mounted) return;
    setState(() => _record = record);
  }

  /// Opens the editor for one subject and writes the corrected counts back.
  Future<void> _edit(AttendanceSubject subject) async {
    final edited = await showModalBottomSheet<_AttendanceEdit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121820),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => _AttendanceEditor(subject: subject),
    );
    if (edited == null || !mounted) return;

    final saved = await _repo.setAttendance(
      code: edited.code,
      name: edited.name,
      attended: edited.attended,
      total: edited.total,
    );
    if (!mounted) return;

    setState(() {
      _record = AttendanceRecord(
        subjects: [
          for (final row in _record.subjects)
            if (row.code == edited.code)
              AttendanceSubject(
                name: edited.name,
                code: edited.code,
                attended: edited.attended,
                total: edited.total,
              )
            else
              row,
        ],
        weekTrend: _record.weekTrend,
      );
    });

    if (!saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${edited.name}: ${edited.attended} of ${edited.total} classes.',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B1B1E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;

    return Scaffold(
      backgroundColor: const Color(0xFF04121B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GlassPageBackdrop(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GlassNavBar(
                    dark: true,
                    brand: 'CampHere',
                    links: campLinks,
                    linkRoutes: campRoutes,
                    trailing: _HeaderCta(
                      label: "Ask what's on",
                      onTap: () => Navigator.of(context).pushNamed('/chat'),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 860;
                      final content = _Content(
                        record: record,
                        wide: wide,
                        onEdit: _edit,
                      );
                      if (wide) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: content,
                          ),
                        );
                      }
                      return content;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.record,
    required this.wide,
    required this.onEdit,
  });

  final AttendanceRecord record;
  final bool wide;
  final ValueChanged<AttendanceSubject> onEdit;

  @override
  Widget build(BuildContext context) {
    final headline = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance'.toUpperCase(),
          style: AppType.inter(
            11,
            weight: 500,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Where the term stands.',
          style: AppType.tight(
            30,
            weight: 500,
            color: Colors.white,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a subject to correct what was attended.',
          style: AppType.inter(
            13,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );

    final overall = _OverallCard(record: record);
    final subjects = Column(
      children: [
        for (final subject in record.subjects)
          _SubjectRow(subject: subject, onEdit: () => onEdit(subject)),
      ],
    );
    final trend = _TrendCard(record: record);

    final body = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [overall, const SizedBox(height: 16), subjects],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: trend),
            ],
          )
        : Column(
            children: [
              overall,
              const SizedBox(height: 16),
              trend,
              const SizedBox(height: 16),
              subjects,
            ],
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headline,
          const SizedBox(height: 22),
          body,
        ],
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final risky = record.atRisk.length;

    return GlassSurface(
      radius: 24,
      blur: 24,
      tint: Colors.white.withValues(alpha: 0.11),
      tintTop: Colors.white.withValues(alpha: 0.16),
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            record.percent.toStringAsFixed(0),
            style: AppType.tight(
              84,
              weight: 500,
              color: Colors.white,
              letterSpacing: -4,
              height: 0.95,
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Text(
              '% overall',
              style: AppType.inter(
                16,
                weight: 400,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Meta(value: '${record.attended}', label: 'classes attended'),
              const SizedBox(height: 6),
              _Meta(value: '${record.total}', label: 'held this term'),
              const SizedBox(height: 6),
              _Meta(
                value: '$risky',
                label: risky == 1 ? 'subject below 75%' : 'subjects below 75%',
                accent: risky > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.value, required this.label, this.accent = false});

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppType.inter(
            17,
            weight: 600,
            color: accent ? Brand.emberLight : Colors.white,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppType.inter(
            13,
            color: Colors.white.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject, required this.onEdit});

  final AttendanceSubject subject;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final percent = subject.percent;
    final risky = percent < 75;

    return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassSurface(
            radius: 18,
            blur: 20,
            tint: Colors.white.withValues(alpha: 0.085),
            tintTop: Colors.white.withValues(alpha: 0.12),
            sheen: false,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject.name,
                        style: AppType.inter(
                          14.5,
                          weight: 600,
                          color: Colors.white,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ),
                    Text(
                      subject.code,
                      style: AppType.inter(
                        12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _EditButton(onTap: onEdit),
                    const SizedBox(width: 12),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: AppType.inter(
                        16,
                        weight: 600,
                        color: risky ? Brand.emberLight : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(
                        height: 5,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      FractionallySizedBox(
                        widthFactor: (percent / 100).clamp(0.02, 1),
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: risky
                                  ? [Brand.emberLight, Brand.ember]
                                  : [
                                      Colors.white.withValues(alpha: 0.9),
                                      Colors.white.withValues(alpha: 0.65),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${subject.attended} of ${subject.total} classes · '
                  '${_shortfallLabel(subject)}',
                  style: AppType.inter(
                    12,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 340.ms,
          curve: Curves.easeOutCubic,
        );
  }

  String _shortfall(AttendanceSubject subject) {
    // Classes needed so that attended+x >= 0.75 * (total+x).
    final need = (0.75 * subject.total - subject.attended) / 0.25;
    if (need <= 0) return 'none';
    return need.ceil().toString();
  }

  /// Reads like a sentence instead of a subtraction.
  String _shortfallLabel(AttendanceSubject subject) {
    final need = _shortfall(subject);
    if (need == 'none') return 'comfortably above 75%';
    final classes = need == '1' ? 'class' : 'classes';
    return 'short by $need $classes to reach 75%';
  }
}

/// The small pencil that opens the counter editor for a subject.
class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Icon(
            Icons.edit_outlined,
            size: 13,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

/// The corrected counts for one subject.
class _AttendanceEdit {
  const _AttendanceEdit({
    required this.code,
    required this.name,
    required this.attended,
    required this.total,
  });

  final String code;
  final String name;
  final int attended;
  final int total;
}

/// The counter sheet: what was attended, and how many classes were held.
///
/// The two counters are kept honest against each other — you cannot attend
/// more classes than were held — and the percentage updates as they move.
class _AttendanceEditor extends StatefulWidget {
  const _AttendanceEditor({required this.subject});

  final AttendanceSubject subject;

  @override
  State<_AttendanceEditor> createState() => _AttendanceEditorState();
}

class _AttendanceEditorState extends State<_AttendanceEditor> {
  late int _attended = widget.subject.attended;
  late int _total = widget.subject.total;

  void _bumpAttended(int delta) {
    setState(() => _attended = (_attended + delta).clamp(0, _total));
  }

  void _bumpTotal(int delta) {
    setState(() {
      _total = (_total + delta).clamp(0, 200);
      if (_attended > _total) _attended = _total;
    });
  }

  double get _percent => _total == 0 ? 0 : _attended / _total * 100;

  /// Classes still needed to reach 75%.
  int get _shortfall {
    final need = (0.75 * _total - _attended) / 0.25;
    return need <= 0 ? 0 : need.ceil();
  }

  @override
  Widget build(BuildContext context) {
    final risky = _percent < 75;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        26,
        24,
        26 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update attendance',
            style: AppType.inter(
              17,
              weight: 600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.subject.name} · ${widget.subject.code}',
            style: AppType.inter(
              13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 22),
          _CounterRow(
            label: 'Classes attended',
            value: _attended,
            onDown: () => _bumpAttended(-1),
            onUp: () => _bumpAttended(1),
            canDown: _attended > 0,
            canUp: _attended < _total,
          ),
          const SizedBox(height: 12),
          _CounterRow(
            label: 'Classes held',
            value: _total,
            onDown: () => _bumpTotal(-1),
            onUp: () => _bumpTotal(1),
            canDown: _total > 0,
            canUp: _total < 200,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Text(
                  '${_percent.toStringAsFixed(0)}%',
                  style: AppType.inter(
                    26,
                    weight: 600,
                    color: risky ? Brand.emberLight : Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _shortfall == 0
                        ? 'Comfortably above 75%'
                        : 'Short by $_shortfall ${_shortfall == 1 ? 'class' : 'classes'} to reach 75%',
                    style: AppType.inter(
                      13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _SheetButton(
                  label: 'Cancel',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetButton(
                  label: 'Save',
                  primary: true,
                  onTap: () => Navigator.of(context).pop(
                    _AttendanceEdit(
                      code: widget.subject.code,
                      name: widget.subject.name,
                      attended: _attended,
                      total: _total,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One counter: a label, the number, and the two buttons that move it.
class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onDown,
    required this.onUp,
    required this.canDown,
    required this.canUp,
  });

  final String label;
  final int value;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final bool canDown;
  final bool canUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppType.inter(
              14,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ),
        _StepButton(
          icon: Icons.remove_rounded,
          enabled: canDown,
          onTap: onDown,
        ),
        SizedBox(
          width: 52,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppType.inter(
              19,
              weight: 600,
              color: Colors.white,
            ),
          ),
        ),
        _StepButton(icon: Icons.add_rounded, enabled: canUp, onTap: onUp),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.2 : 0.08),
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: Colors.white.withValues(alpha: enabled ? 0.9 : 0.3),
          ),
        ),
      ),
    );
  }
}

/// The two buttons at the foot of the sheet.
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: primary ? Brand.ember : Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: primary
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            label,
            style: AppType.inter(
              14,
              weight: 600,
              color: primary
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}

/// The number of days in the trend that carry a real figure.
int _elapsedDays(List<double> trend) {
  var count = trend.length;
  for (var i = trend.length - 1; i >= 0; i--) {
    if (trend[i] > 0) {
      count = i + 1;
      break;
    }
    count = i;
  }
  return count < 2 ? trend.length : count;
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GlassSurface(
      radius: 24,
      blur: 24,
      tint: Colors.white.withValues(alpha: 0.11),
      tintTop: Colors.white.withValues(alpha: 0.16),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'This week',
                style: AppType.inter(
                  14,
                  weight: 600,
                  color: Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
              const Spacer(),
              Text(
                'attended % per day',
                style: AppType.inter(
                  12,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          WaveChart(
            values: record.weekTrend,
            height: 170,
            strokeWidth: 3,
            // Zero means "no class that day", not zero attendance: draw the
            // week only up to the last day that has actually happened.
            visiblePoints: _elapsedDays(record.weekTrend),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in days)
                Text(
                  day,
                  style: AppType.inter(
                    12,
                    weight: 500,
                    color: Colors.white.withValues(alpha: 0.66),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCta extends StatelessWidget {
  const _HeaderCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Brand.ember,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppType.inter(13.5, weight: 500, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
