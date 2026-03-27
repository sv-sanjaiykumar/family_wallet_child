import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// An animated progress bar used to display spending limit usage.
///
/// Colour shifts from green → amber → red as [value] approaches [max].
/// Shows label, usage text (e.g. "₹340 of ₹1500"), and an optional
/// alert badge when the limit is exceeded or nearly reached.
class LimitProgressBar extends StatefulWidget {
  /// Current amount used (e.g. ₹340)
  final double value;

  /// Maximum allowed amount (e.g. ₹1500)
  final double max;

  /// Title label (e.g. "Daily Limit" / "Weekly Limit")
  final String label;

  /// Icon displayed next to the label
  final IconData icon;

  /// Show alert badge when usage ≥ [alertThreshold] (0.0 – 1.0)
  final double alertThreshold;

  const LimitProgressBar({
    super.key,
    required this.value,
    required this.max,
    required this.label,
    required this.icon,
    this.alertThreshold = 0.85,
  });

  @override
  State<LimitProgressBar> createState() => _LimitProgressBarState();
}

class _LimitProgressBarState extends State<LimitProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: _fraction,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(LimitProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value || old.max != widget.max) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: _fraction,
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _fraction => (widget.value / widget.max).clamp(0.0, 1.0);
  bool get _isExceeded => widget.value >= widget.max;
  bool get _isNearLimit => _fraction >= widget.alertThreshold;

  /// Colour shifts: green → amber → red based on fraction
  Color _barColor(double fraction) {
    if (fraction >= 1.0) return AppTheme.parentDanger;
    if (fraction >= 0.85) return AppTheme.parentWarning;
    if (fraction >= 0.60) return const Color(0xFFFFD54F); // soft yellow
    return AppTheme.parentSuccess;
  }

  Color _bgTrackColor(double fraction) =>
      _barColor(fraction).withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    final remaining = (widget.max - widget.value).clamp(0, widget.max);

    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, _) {
        final fraction = _progressAnim.value;
        final barColor = _barColor(fraction);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.parentCardBg,
            borderRadius: AppTheme.radiusMedium,
            boxShadow: AppTheme.parentSoftShadow,
            border: _isNearLimit
                ? Border.all(
                    color: barColor.withOpacity(0.35),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: barColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.parentTextDark,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),

                  // Alert badge
                  if (_isExceeded)
                    _Badge(
                      label: 'Exceeded',
                      color: AppTheme.parentDanger,
                      icon: Icons.warning_rounded,
                    )
                  else if (_isNearLimit)
                    _Badge(
                      label: 'Near Limit',
                      color: AppTheme.parentWarning,
                      icon: Icons.notifications_active_rounded,
                    )
                  else
                    _Badge(
                      label:
                          '${((1 - fraction) * 100).toStringAsFixed(0)}% left',
                      color: AppTheme.parentSuccess,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Progress track ────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Stack(
                  children: [
                    // Track
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: _bgTrackColor(fraction),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    // Fill
                    FractionallySizedBox(
                      widthFactor: fraction.clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              barColor.withOpacity(0.7),
                              barColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Usage text ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₹${widget.value.toInt()} ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: barColor,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        TextSpan(
                          text: 'of ₹${widget.max.toInt()} used',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.parentTextMuted,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _isExceeded
                        ? 'Limit reached!'
                        : '₹${remaining.toInt()} remaining',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _isExceeded
                          ? AppTheme.parentDanger
                          : AppTheme.parentTextMuted,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Small badge chip ──────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

/// A slim inline version — useful inside list tiles or compact layouts.
class LimitProgressBarSlim extends StatelessWidget {
  final double value;
  final double max;
  final String label;

  const LimitProgressBarSlim({
    super.key,
    required this.value,
    required this.max,
    required this.label,
  });

  double get _fraction => (value / max).clamp(0.0, 1.0);

  Color get _color {
    if (_fraction >= 1.0) return AppTheme.parentDanger;
    if (_fraction >= 0.85) return AppTheme.parentWarning;
    return AppTheme.parentSuccess;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.parentTextMuted,
                fontFamily: 'Nunito',
              ),
            ),
            Text(
              '₹${value.toInt()} / ₹${max.toInt()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _color,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: _color.withOpacity(0.12),
              ),
              FractionallySizedBox(
                widthFactor: _fraction,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
