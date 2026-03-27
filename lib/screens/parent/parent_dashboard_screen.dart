import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/child_data.dart';
import '../../models/parent_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parent/summary_card.dart';
import '../../widgets/parent/spending_chart.dart';
import 'add_money_screen.dart';
import 'spending_limits_screen.dart';
import 'parent_chores_screen.dart';
import 'notifications_screen.dart';
import '../../screens/role_selection_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  void _refresh() => setState(() {});

  void _push(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen))
        .then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final profile = ChildData.profile;
    final parent = ParentData.profile;
    final unread = ParentData.notifications.where((n) => !n.isRead).length;
    final recentTxns = ChildData.transactions.take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.parentSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.parentPrimary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(parent, profile, unread),
            ),
            actions: [
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 26),
                    if (unread > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF5350),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _push(const NotificationsScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 22),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const RoleSelectionScreen()),
                    (_) => false,
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary Cards ───────────────────────────
                  ParentSummaryCard(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Total Sent to ${profile.name}',
                    value:
                        '₹${parent.totalMoneySent.toStringAsFixed(0)}',
                    gradient: AppTheme.parentGradient,
                    delta: '+₹500',
                    isDeltaPositive: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ParentSummaryCardCompact(
                        icon: Icons.wallet_rounded,
                        label: 'Child Wallet',
                        value:
                            '₹${profile.balance.toStringAsFixed(0)}',
                        gradient: AppTheme.parentGreenGradient,
                      ),
                      const SizedBox(width: 12),
                      ParentSummaryCardCompact(
                        icon: Icons.bar_chart_rounded,
                        label: 'Monthly Spend',
                        value: '₹${ChildData.transactions.where((t) => t.type == TransactionType.debit && DateTime.now().difference(t.date).inDays <= 30).fold(0.0, (s, t) => s + t.amount).toStringAsFixed(0)}',
                        gradient: AppTheme.parentIndigoGradient,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Quick Actions ────────────────────────────
                  _SectionTitle(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.add_circle_rounded,
                        label: 'Add Money',
                        color: AppTheme.parentPrimary,
                        onTap: () => _push(const AddMoneyScreen()),
                      ),
                      _QuickAction(
                        icon: Icons.tune_rounded,
                        label: 'Set Limits',
                        color: AppTheme.parentWarning,
                        onTap: () =>
                            _push(const SpendingLimitsScreen()),
                      ),
                      _QuickAction(
                        icon: Icons.checklist_rounded,
                        label: 'Chores',
                        color: AppTheme.parentSuccess,
                        onTap: () =>
                            _push(const ParentChoresScreen()),
                      ),
                      _QuickAction(
                        icon: Icons.notifications_rounded,
                        label: 'Alerts',
                        color: AppTheme.parentDanger,
                        onTap: () =>
                            _push(const NotificationsScreen()),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Weekly Chart ─────────────────────────────
                  _SectionTitle(title: 'Weekly Spending'),
                  const SizedBox(height: 14),
                  _Card(
                    child: WeeklySpendingChart(
                      data: ParentData.weeklySpending,
                      height: 150,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Category Breakdown ───────────────────────
                  _SectionTitle(title: 'Spending Breakdown'),
                  const SizedBox(height: 14),
                  _Card(
                    child: SpendingDonutChart(
                      categories: ParentData.spendingCategories,
                      size: 140,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Recent Transactions ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle(title: 'Recent Transactions'),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.parentPrimary,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _Card(
                    child: Column(
                      children: List.generate(recentTxns.length, (i) {
                        final txn = recentTxns[i];
                        final isCredit =
                            txn.type == TransactionType.credit;
                        return Column(
                          children: [
                            if (i > 0)
                              const Divider(
                                  height: 1, color: Color(0xFFEAEEF4)),
                            _TransactionRow(
                                txn: txn, isCredit: isCredit),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ParentProfile parent, ChildProfile child, int unread) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.parentGradient),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    parent.avatarEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${parent.name.split(' ').first} 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  Text(
                    'Managing ${child.name}\'s wallet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.80),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section title ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppTheme.parentTextDark,
        fontFamily: 'Nunito',
      ),
    );
  }
}

// ── White card wrapper ──────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.parentSoftShadow,
      ),
      child: child,
    );
  }
}

// ── Quick action button ─────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.parentTextDark,
                fontFamily: 'Nunito',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Transaction row ─────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  final Transaction txn;
  final bool isCredit;

  const _TransactionRow({required this.txn, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final color =
        isCredit ? AppTheme.parentSuccess : const Color(0xFFEF5350);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(txn.icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.parentTextDark,
                    fontFamily: 'Nunito',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(txn.date),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.parentTextMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}
