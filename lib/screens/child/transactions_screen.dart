import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/child_data.dart';
import '../../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  int _filterIndex = 0; // 0=All, 1=Credit, 2=Debit
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  final List<String> _filters = ['All', '↓ Received', '↑ Spent'];

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

  List<Transaction> get _filteredTransactions {
    switch (_filterIndex) {
      case 1:
        return ChildData.transactions
            .where((t) => t.type == TransactionType.credit)
            .toList();
      case 2:
        return ChildData.transactions
            .where((t) => t.type == TransactionType.debit)
            .toList();
      default:
        return ChildData.transactions;
    }
  }

  double get _totalReceived => ChildData.transactions
      .where((t) => t.type == TransactionType.credit)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalSpent => ChildData.transactions
      .where((t) => t.type == TransactionType.debit)
      .fold(0, (sum, t) => sum + t.amount);

  // Group transactions by date label
  Map<String, List<Transaction>> get _groupedTransactions {
    final Map<String, List<Transaction>> grouped = {};
    for (final txn in _filteredTransactions) {
      final label = _dateGroupLabel(txn.date);
      grouped.putIfAbsent(label, () => []).add(txn);
    }
    return grouped;
  }

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day} ${_monthName(date.month)}';
  }

  String _monthName(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedTransactions;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Summit Strip ─────────────────────────────
            SliverToBoxAdapter(child: _buildSummaryStrip()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Filter ────────────────────────────────────
            SliverToBoxAdapter(child: _buildFilterTabs()),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Grouped Transaction List ───────────────────
            if (_filteredTransactions.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sections = grouped.entries.toList();
                    final widgets = <Widget>[];
                    for (final section in sections) {
                      widgets.add(TransactionDateHeader(label: section.key));
                      widgets.addAll(section.value
                          .map((t) => TransactionTile(transaction: t)));
                    }
                    return widgets[index];
                  },
                  childCount: grouped.entries.fold(
                    0,
                    (sum, e) => sum! + e.value.length + 1, // +1 for header
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
        gradient: AppTheme.blueGradient,
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
                '📜 Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${ChildData.transactions.length} total transactions',
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
            child: const Text('💳', style: TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }

  // ── Summary Strip ─────────────────────────────────────────
  Widget _buildSummaryStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.10),
                borderRadius: AppTheme.radiusMedium,
                border:
                    Border.all(color: AppTheme.secondary.withOpacity(0.30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('↓ Total Received',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '+₹${_totalReceived.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.08),
                borderRadius: AppTheme.radiusMedium,
                border:
                    Border.all(color: AppTheme.danger.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('↑ Total Spent',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.danger,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '-₹${_totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppTheme.danger,
                    ),
                  ),
                ],
              ),
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
            Color activeColor = AppTheme.primary;
            if (index == 1) activeColor = AppTheme.secondary;
            if (index == 2) activeColor = AppTheme.danger;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _filterIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : Colors.transparent,
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  child: Center(
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text('📭', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your spending history will show here.',
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
