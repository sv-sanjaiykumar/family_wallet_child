import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/parent_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parent/limit_progress_bar.dart';

class SpendingLimitsScreen extends StatefulWidget {
  const SpendingLimitsScreen({super.key});

  @override
  State<SpendingLimitsScreen> createState() => _SpendingLimitsScreenState();
}

class _SpendingLimitsScreenState extends State<SpendingLimitsScreen> {
  late double _dailyLimit;
  late double _weeklyLimit;
  bool _saved = false;

  static const double _dailyMin = 50;
  static const double _dailyMax = 1000;
  static const double _weeklyMin = 200;
  static const double _weeklyMax = 5000;

  @override
  void initState() {
    super.initState();
    _dailyLimit = ParentData.spendingLimit.dailyLimit;
    _weeklyLimit = ParentData.spendingLimit.weeklyLimit;
  }

  bool get _hasChanges =>
      _dailyLimit != ParentData.spendingLimit.dailyLimit ||
      _weeklyLimit != ParentData.spendingLimit.weeklyLimit;

  void _save() {
    HapticFeedback.mediumImpact();
    ParentData.setDailyLimit(_dailyLimit);
    ParentData.setWeeklyLimit(_weeklyLimit);
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Spending limits updated!',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.parentSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final limits = ParentData.spendingLimit;

    return Scaffold(
      backgroundColor: AppTheme.parentSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.parentPrimary,
        title: const Text(
          'Spending Limits',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.parentPrimary.withOpacity(0.08),
                borderRadius: AppTheme.radiusMedium,
                border: Border.all(
                  color: AppTheme.parentPrimary.withOpacity(0.20),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: AppTheme.parentPrimary, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Set daily & weekly maximums. Your child\'s spending will be blocked once the limit is reached.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.parentTextDark,
                        fontFamily: 'Nunito',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Current Usage ─────────────────────────────────
            _SectionTitle('Current Usage'),
            const SizedBox(height: 14),
            LimitProgressBar(
              icon: Icons.wb_sunny_rounded,
              label: 'Daily Limit',
              value: limits.dailyUsed,
              max: _dailyLimit,
            ),
            const SizedBox(height: 12),
            LimitProgressBar(
              icon: Icons.calendar_view_week_rounded,
              label: 'Weekly Limit',
              value: limits.weeklyUsed,
              max: _weeklyLimit,
            ),

            const SizedBox(height: 28),

            // ── Daily limit slider ────────────────────────────
            _SectionTitle('Set Daily Limit'),
            const SizedBox(height: 14),
            _LimitSliderCard(
              icon: Icons.wb_sunny_rounded,
              label: 'Daily Limit',
              value: _dailyLimit,
              min: _dailyMin,
              max: _dailyMax,
              color: AppTheme.parentPrimary,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _dailyLimit = v);
              },
            ),

            const SizedBox(height: 16),

            // ── Weekly limit slider ───────────────────────────
            _SectionTitle('Set Weekly Limit'),
            const SizedBox(height: 14),
            _LimitSliderCard(
              icon: Icons.calendar_view_week_rounded,
              label: 'Weekly Limit',
              value: _weeklyLimit,
              min: _weeklyMin,
              max: _weeklyMax,
              color: const Color(0xFF9C27B0),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _weeklyLimit = v);
              },
            ),

            const SizedBox(height: 32),

            // ── Preset quick buttons ──────────────────────────
            _SectionTitle('Quick Presets'),
            const SizedBox(height: 14),
            _PresetsRow(
              label: 'Daily',
              presets: const [100, 200, 300, 500],
              selected: _dailyLimit,
              color: AppTheme.parentPrimary,
              onSelect: (v) => setState(() => _dailyLimit = v.toDouble()),
            ),
            const SizedBox(height: 10),
            _PresetsRow(
              label: 'Weekly',
              presets: const [500, 1000, 2000, 3000],
              selected: _weeklyLimit,
              color: const Color(0xFF9C27B0),
              onSelect: (v) => setState(() => _weeklyLimit = v.toDouble()),
            ),

            const SizedBox(height: 36),

            // ── Save button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: _hasChanges
                      ? AppTheme.parentGradient
                      : null,
                  color: _hasChanges ? null : const Color(0xFFDDE3EE),
                  borderRadius: AppTheme.radiusMedium,
                  boxShadow: _hasChanges ? AppTheme.parentCardShadow : [],
                ),
                child: ElevatedButton(
                  onPressed: _hasChanges ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _saved
                            ? Icons.check_circle_rounded
                            : Icons.save_rounded,
                        color: _hasChanges
                            ? Colors.white
                            : AppTheme.parentTextMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _saved ? 'Saved!' : 'Save Limits',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _hasChanges
                              ? Colors.white
                              : AppTheme.parentTextMuted,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Section title ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppTheme.parentTextDark,
        fontFamily: 'Nunito',
      ),
    );
  }
}

// ── Slider card ─────────────────────────────────────────────────

class _LimitSliderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  const _LimitSliderCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.parentSoftShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.parentTextDark,
                  fontFamily: 'Nunito',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${value.toInt()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.12),
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: ((max - min) / (min == 50 ? 50 : 100)).round(),
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${min.toInt()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.parentTextMuted,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                '₹${max.toInt()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.parentTextMuted,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Preset row ──────────────────────────────────────────────────

class _PresetsRow extends StatelessWidget {
  final String label;
  final List<int> presets;
  final double selected;
  final Color color;
  final ValueChanged<int> onSelect;

  const _PresetsRow({
    required this.label,
    required this.presets,
    required this.selected,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.parentTextMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        ...presets.map((p) {
          final isSelected = selected == p.toDouble();
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => onSelect(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '₹$p',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color:
                            isSelected ? Colors.white : color,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
