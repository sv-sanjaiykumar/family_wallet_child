import 'package:flutter/material.dart';
import '../../models/child_data.dart';
import '../../theme/app_theme.dart';

class ParentTransactionsScreen extends StatefulWidget {
  const ParentTransactionsScreen({super.key});

  @override
  State<ParentTransactionsScreen> createState() =>
      _ParentTransactionsScreenState();
}

class _ParentTransactionsScreenState extends State<ParentTransactionsScreen> {
  String _activeFilter = 'All';

  static const List<String> _filters = [
    'All',
    'Credit',
    'Debit',
    'This Week',
    'This Month',
  ];

  List<Transaction> get _filtered {
    final all = ChildData.transactions;
    switch (_activeFilter) {
      case 'Credit':
        return all.where((t) => t.type == TransactionType.credit).toList();
      case 'Debit':
        return all.where((t) => t.type == TransactionType.debit).toList();
      case 'This Week':
        return all
            .where((t) =>
                DateTime.now().difference(t.date).inDays <= 7)
            .toList();
      case 'This Month':
        return all
            .where((t) =>
                DateTime.now().difference(t.date).inDays <= 30)
            .toList();
      default:
        return all;
    }
  }

  /// Group transactions by date label
  Map<String, List<Transaction>> get _grouped {
    final result = <String, List<Transaction>>{};
    for (final txn in _filtered) {
      final label = _dateGroup(txn.date);
      result.putIfAbsent(label, () => []).add(txn);
    }
    return result;
  }

  String _dateGroup(DateTime dt) {
    final diff = DateTime.now().difference(dt).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 7) return 'This Week';
    return 'Earlier';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  // Summary stats
  double get _totalCredit => _filtered
      .where((t) => t.type == TransactionType.credit)
      .fold(0, (s, t) => s + t.amount);

  double get _totalDebit => _filtered
      .where((t) => t.type == TransactionType.debit)
      .fold(0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.parentSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.parentPrimary,
        title: const Text(
          'Transaction History',
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
      body: Column(
        children: [
          // ── Summary strip ──────────────────────────────────
          Container(
            color: AppTheme.parentPrimary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: 'Total In',
                    value: '₹${_totalCredit.toInt()}',
                    icon: Icons.arrow_downward_rounded,
                    color: AppTheme.parentSuccess,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryChip(
                    label: 'Total Out',
                    value: '₹${_totalDebit.toInt()}',
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFEF5350),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryChip(
                    label: 'Count',
                    value: '${_filtered.length}',
                    icon: Icons.receipt_long_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Filter chips ───────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final isActive = _activeFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isActive ? AppTheme.parentGradient : null,
                          color: isActive ? null : const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow:
                              isActive ? AppTheme.parentSoftShadow : [],
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : AppTheme.parentTextMuted,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Transaction list ───────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: groupKeys.length,
                    itemBuilder: (_, gi) {
                      final groupLabel = groupKeys[gi];
                      final txns = grouped[groupLabel]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 4),
                            child: Row(
                              children: [
                                Text(
                                  groupLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.parentTextMuted,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFEAEEF4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Transactions in group
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppTheme.radiusMedium,
                              boxShadow: AppTheme.parentSoftShadow,
                            ),
                            child: Column(
                              children: List.generate(txns.length, (ti) {
                                final txn = txns[ti];
                                final isCredit =
                                    txn.type == TransactionType.credit;
                                final color = isCredit
                                    ? AppTheme.parentSuccess
                                    : const Color(0xFFEF5350);
                                return Column(
                                  children: [
                                    if (ti > 0)
                                      const Divider(
                                          height: 1,
                                          indent: 66,
                                          color: Color(0xFFEAEEF4)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          // Icon
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color:
                                                  color.withOpacity(0.10),
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            child: Icon(txn.icon,
                                                color: color, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          // Label + time
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  txn.label,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color:
                                                        AppTheme.parentTextDark,
                                                    fontFamily: 'Nunito',
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _formatTime(txn.date),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppTheme.parentTextMuted,
                                                    fontFamily: 'Nunito',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Amount
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: color,
                                                  fontFamily: 'Nunito',
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 3),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color:
                                                      color.withOpacity(0.10),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isCredit ? 'Credit' : 'Debit',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: color,
                                                    fontFamily: 'Nunito',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Summary chip ────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'Nunito',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.75),
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.parentPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppTheme.parentPrimary, size: 38),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.parentTextDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different filter',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.parentTextMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}
