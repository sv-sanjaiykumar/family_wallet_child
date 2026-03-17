import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/child_data.dart';

class GoalCard extends StatefulWidget {
  final SavingsGoal goal;
  final int colorIndex;
  final Function(double amount) onAddMoney;

  const GoalCard({
    super.key,
    required this.goal,
    required this.colorIndex,
    required this.onAddMoney,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: widget.goal.progressPercent,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  LinearGradient get _gradient =>
      AppTheme.goalGradients[widget.colorIndex % AppTheme.goalGradients.length];

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient Header ───────────────────────────────
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Background circle decoration
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: -15,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              goal.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal.isCompleted
                                  ? '🎉 Goal Completed!'
                                  : '₹${goal.remaining.toStringAsFixed(0)} more to go',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (goal.isCompleted)
                        const Text('✅', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Progress Section ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${goal.saved.toStringAsFixed(0)} saved',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'of ₹${goal.target.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Animated progress bar
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (context, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: _progressAnim.value,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _gradient.colors.first,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Percent label
                Text(
                  '${(goal.progressPercent * 100).toStringAsFixed(0)}% complete',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _gradient.colors.first,
                  ),
                ),

                const SizedBox(height: 12),

                // Add money button
                if (!goal.isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddMoneySheet(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Money'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gradient.colors.first,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusSmall,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        elevation: 0,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.greenGradient,
                      borderRadius: AppTheme.radiusSmall,
                    ),
                    child: const Center(
                      child: Text(
                        '🎊 Goal Achieved!',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMoneySheet(BuildContext context) {
    double selectedAmount = 50;
    final maxAmount = widget.goal.remaining;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Add to ${widget.goal.emoji} ${widget.goal.title}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Remaining to goal: ₹${maxAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Amount display
              Center(
                child: Text(
                  '₹${selectedAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 42,
                    color: _gradient.colors.first,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Slider
              Slider(
                value: selectedAmount,
                min: 10,
                max: maxAmount.clamp(10, maxAmount),
                divisions: ((maxAmount - 10) / 10).floor().clamp(1, 100),
                activeColor: _gradient.colors.first,
                inactiveColor: Colors.grey.shade200,
                onChanged: (val) =>
                    setSheetState(() => selectedAmount = val.roundToDouble()),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onAddMoney(selectedAmount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gradient.colors.first,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save ₹${selectedAmount.toStringAsFixed(0)} 💰',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
