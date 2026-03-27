import 'package:flutter/material.dart';
import '../../models/parent_data.dart';
import '../../theme/app_theme.dart';

// ── Weekly Bar Chart ───────────────────────────────────────────

class WeeklySpendingChart extends StatefulWidget {
  final List<WeeklySpend> data;
  final double height;

  const WeeklySpendingChart({
    super.key,
    required this.data,
    this.height = 160,
  });

  @override
  State<WeeklySpendingChart> createState() => _WeeklySpendingChartState();
}

class _WeeklySpendingChartState extends State<WeeklySpendingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxAmount =
        widget.data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(widget.data.length, (i) {
                  final item = widget.data[i];
                  final isSelected = _selectedIndex == i;
                  final heightFraction =
                      maxAmount == 0 ? 0.0 : item.amount / maxAmount;
                  final barH =
                      (widget.height - 24) * heightFraction * _anim.value;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIndex = isSelected ? null : i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Tooltip above selected bar
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.parentPrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${item.amount.toInt()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ),
                          // Bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: barH.clamp(4, double.infinity),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppTheme.parentCardGradient
                                  : LinearGradient(
                                      colors: [
                                        AppTheme.parentPrimary
                                            .withOpacity(0.85),
                                        AppTheme.parentPrimary
                                            .withOpacity(0.40),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),

            // Day labels
            Row(
              children: widget.data.map((item) {
                final i = widget.data.indexOf(item);
                final isSelected = _selectedIndex == i;
                return Expanded(
                  child: Center(
                    child: Text(
                      item.day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppTheme.parentPrimary
                            : AppTheme.parentTextMuted,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ── Category Pie / Donut Chart ─────────────────────────────────

class SpendingDonutChart extends StatefulWidget {
  final Map<String, double> categories;
  final double size;

  const SpendingDonutChart({
    super.key,
    required this.categories,
    this.size = 160,
  });

  @override
  State<SpendingDonutChart> createState() => _SpendingDonutChartState();
}

class _SpendingDonutChartState extends State<SpendingDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  int? _selectedSlice;

  static const List<Color> _palette = [
    Color(0xFF1A73E8),
    Color(0xFF00C853),
    Color(0xFFFFA726),
    Color(0xFFEF5350),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.categories.entries.toList();
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Row(
          children: [
            // Donut
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _DonutPainter(
                  entries: entries,
                  total: total,
                  animValue: _anim.value,
                  selectedSlice: _selectedSlice,
                  palette: _palette,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${total.toInt()}',
                        style: TextStyle(
                          fontSize: widget.size * 0.14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.parentTextDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: widget.size * 0.09,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.parentTextMuted,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(entries.length, (i) {
                  final e = entries[i];
                  final pct = ((e.value / total) * 100).toStringAsFixed(0);
                  return GestureDetector(
                    onTap: () => setState(
                        () => _selectedSlice = _selectedSlice == i ? null : i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _palette[i % _palette.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _selectedSlice == i
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: _selectedSlice == i
                                    ? AppTheme.parentPrimary
                                    : AppTheme.parentTextDark,
                                fontFamily: 'Nunito',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.parentTextMuted,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final double animValue;
  final int? selectedSlice;
  final List<Color> palette;

  _DonutPainter({
    required this.entries,
    required this.total,
    required this.animValue,
    required this.selectedSlice,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 26.0;
    const gap = 0.03; // radians gap between slices

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    double startAngle = -3.14159 / 2; // start at top

    for (int i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value / total) *
          2 *
          3.14159 *
          animValue;
      final isSelected = selectedSlice == i;

      final paint = Paint()
        ..color = palette[i % palette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 6 : strokeWidth
        ..strokeCap = StrokeCap.round;

      if (sweep > gap) {
        canvas.drawArc(
          rect,
          startAngle + gap / 2,
          sweep - gap,
          false,
          paint,
        );
      }
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.animValue != animValue || old.selectedSlice != selectedSlice;
}
