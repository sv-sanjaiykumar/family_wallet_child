import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/child_data.dart';
import '../../widgets/balance_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeIn,
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ChildData.profile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            // ── Gradient App Bar ───────────────────────────
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: _buildHeader(profile),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Balance Card ───────────────────────────────
            SliverToBoxAdapter(
              child: BalanceCard(profile: profile),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Level & XP ─────────────────────────────────
            SliverToBoxAdapter(child: _buildLevelSection(profile)),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Badges ─────────────────────────────────────
            SliverToBoxAdapter(child: _buildBadgesSection(profile)),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Quick Stats ────────────────────────────────
            SliverToBoxAdapter(child: _buildQuickStats(profile)),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Recent Chores ──────────────────────────────
            SliverToBoxAdapter(child: _buildRecentChores()),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(ChildProfile profile) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
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
              Text(
                'Hey, ${profile.name}! 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.streakDays}-day saving streak!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                profile.avatarEmoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Level & XP ─────────────────────────────────────────────
  Widget _buildLevelSection(ChildProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.amberGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '⭐ Level ${profile.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Money Saver',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${profile.xp} / ${profile.xpToNextLevel} XP',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: profile.xpPercent,
                minHeight: 12,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFD166),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${profile.xpToNextLevel - profile.xp} XP to Level ${profile.level + 1} 🚀',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badges ─────────────────────────────────────────────────
  Widget _buildBadgesSection(ChildProfile profile) {
    final badgeLabels = [
      'First Save',
      'Chore Master',
      'Money Wise',
      'Star Saver',
      'On Fire',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏅 My Badges',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: profile.badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final badge = profile.badges[index];
                final label = index < badgeLabels.length
                    ? badgeLabels[index]
                    : 'Badge ${index + 1}';
                return Container(
                  width: 72,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: AppTheme.radiusMedium,
                    boxShadow: AppTheme.softShadow,
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.10),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(badge, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Stats ────────────────────────────────────────────
  Widget _buildQuickStats(ChildProfile profile) {
    final completedChores =
        ChildData.chores.where((c) => c.status == ChoreStatus.completed).length;
    final totalChores = ChildData.chores.length;
    final completedGoals =
        ChildData.goals.where((g) => g.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Quick Stats',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '✅',
                  value: '$completedChores/$totalChores',
                  label: 'Chores Done',
                  gradient: AppTheme.greenGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  emoji: '🎯',
                  value: '$completedGoals/${ChildData.goals.length}',
                  label: 'Goals Done',
                  gradient: AppTheme.primaryGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  emoji: '💸',
                  value: '₹${profile.spent.toStringAsFixed(0)}',
                  label: 'Spent Today',
                  gradient: AppTheme.pinkGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent Chores ──────────────────────────────────────────
  Widget _buildRecentChores() {
    final pendingChores =
        ChildData.chores.where((c) => c.status == ChoreStatus.pending).toList();
    if (pendingChores.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📋 Pending Chores',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '${pendingChores.length} remaining',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pendingChores.take(2).map((chore) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: AppTheme.radiusMedium,
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: chore.iconColor.withOpacity(0.12),
                        borderRadius: AppTheme.radiusSmall,
                      ),
                      child: Icon(chore.icon,
                          color: chore.iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chore.title,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Earn ₹${chore.reward.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        '🪙 Pending',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final LinearGradient gradient;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
