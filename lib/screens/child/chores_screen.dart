import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/child_data.dart';
import '../../widgets/chore_card.dart';

class ChoresScreen extends StatefulWidget {
  const ChoresScreen({super.key});

  @override
  State<ChoresScreen> createState() => _ChoresScreenState();
}

class _ChoresScreenState extends State<ChoresScreen>
    with SingleTickerProviderStateMixin {
  int _filterIndex = 0; // 0=All, 1=Pending, 2=Completed
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  final List<String> _filters = ['All', 'Pending', 'Done'];

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

  List<Chore> get _filteredChores {
    switch (_filterIndex) {
      case 1:
        return ChildData.chores
            .where((c) => c.status == ChoreStatus.pending)
            .toList();
      case 2:
        return ChildData.chores
            .where((c) => c.status == ChoreStatus.completed)
            .toList();
      default:
        return ChildData.chores;
    }
  }

  int get _pendingCount =>
      ChildData.chores.where((c) => c.status == ChoreStatus.pending).length;

  int get _completedCount =>
      ChildData.chores.where((c) => c.status == ChoreStatus.completed).length;

  double get _totalEarnable => ChildData.chores
      .where((c) => c.status == ChoreStatus.pending)
      .fold(0, (sum, c) => sum + c.reward);

  void _onChoreCompleted(Chore chore) {
    setState(() {
      ChildData.completeChore(chore.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉 ', style: TextStyle(fontSize: 18)),
            Text(
              'You earned ₹${chore.reward.toStringAsFixed(0)}!',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusSmall,
        ),
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

            // ── Stats Bar ────────────────────────────────
            SliverToBoxAdapter(child: _buildStatsBar()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Filter Tabs ───────────────────────────────
            SliverToBoxAdapter(child: _buildFilterTabs()),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Chore List ────────────────────────────────
            _filteredChores.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chore = _filteredChores[index];
                        return ChoreCard(
                          chore: chore,
                          onCompleted: () => _onChoreCompleted(chore),
                        );
                      },
                      childCount: _filteredChores.length,
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
          colors: [Color(0xFFFFD166), Color(0xFFFF9A3C)],
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
                '📋 My Chores',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete chores to earn rewards!',
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
            child: const Text('🧹', style: TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }

  // ── Stats Bar ─────────────────────────────────────────────
  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Pending',
              value: '$_pendingCount',
              emoji: '⏳',
              color: const Color(0xFFFFD166),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStat(
              label: 'Completed',
              value: '$_completedCount',
              emoji: '✅',
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniStat(
              label: 'Earnable',
              value: '₹${_totalEarnable.toStringAsFixed(0)}',
              emoji: '🪙',
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Tabs ───────────────────────────────────────────
  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusSmall,
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isActive = _filterIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _filterIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isActive ? AppTheme.amberGradient : null,
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  child: Center(
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isActive ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'All chores done!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re a chore champion! 🏆',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Card ────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
