import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/child_data.dart';
import '../../widgets/goal_card.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _totalSaved =>
      ChildData.goals.fold(0, (sum, g) => sum + g.saved);

  double get _totalTarget =>
      ChildData.goals.fold(0, (sum, g) => sum + g.target);

  int get _completedGoals =>
      ChildData.goals.where((g) => g.isCompleted).length;

  void _onAddMoney(SavingsGoal goal, double amount) {
    final success = ChildData.addToGoal(goal.id, amount);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(success ? '💰 ' : '⚠️ ',
                style: const TextStyle(fontSize: 18)),
            Text(
              success
                  ? 'Added ₹${amount.toStringAsFixed(0)} to ${goal.title}!'
                  : 'Not enough balance!',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: success ? AppTheme.primary : AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSmall),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Summary Card ─────────────────────────────
            SliverToBoxAdapter(child: _buildSummaryCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Goals Label ───────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '🎯 My Goals',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Goals List ────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = ChildData.goals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GoalCard(
                        goal: goal,
                        colorIndex: index,
                        onAddMoney: (amount) => _onAddMoney(goal, amount),
                      ),
                    );
                  },
                  childCount: ChildData.goals.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C9A7), Color(0xFF00E676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎯 Savings Goals',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Save money to reach your dreams!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: AppTheme.radiusMedium,
            ),
            child: const Text('🐷', style: TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }

  // ── Summary Card ──────────────────────────────────────────
  Widget _buildSummaryCard() {
    final overallPercent =
        _totalTarget > 0 ? (_totalSaved / _totalTarget).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saved',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.80),
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_totalSaved.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _SummaryChip(
                      label: '$_completedGoals/${ChildData.goals.length} Goals',
                      emoji: '🎯',
                    ),
                    const SizedBox(height: 8),
                    _SummaryChip(
                      label:
                          '₹${(_totalTarget - _totalSaved).toStringAsFixed(0)} to go',
                      emoji: '🏁',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Overall Progress',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: overallPercent,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF00E676),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(overallPercent * 100).toStringAsFixed(0)}% of ₹${_totalTarget.toStringAsFixed(0)} saved',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Chip ──────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final String emoji;

  const _SummaryChip({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
