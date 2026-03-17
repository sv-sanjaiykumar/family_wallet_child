import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/child_data.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  bool get _isCredit => transaction.type == TransactionType.credit;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays == 0) return 'Today, ${_timeStr(date)}';
    if (diff.inDays == 1) return 'Yesterday, ${_timeStr(date)}';
    return '${date.day} ${_monthName(date.month)}, ${_timeStr(date)}';
  }

  String _timeStr(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          // ── Icon Circle ─────────────────────────────────
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _isCredit
                  ? AppTheme.secondary.withOpacity(0.12)
                  : AppTheme.danger.withOpacity(0.10),
              borderRadius: AppTheme.radiusSmall,
            ),
            child: Icon(
              transaction.icon,
              color: _isCredit ? AppTheme.secondary : AppTheme.danger,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          // ── Label + Date ─────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.label,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatDate(transaction.date),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Amount ───────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Amount with +/- prefix
              Text(
                '${_isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: _isCredit ? AppTheme.secondary : AppTheme.danger,
                ),
              ),
              const SizedBox(height: 4),
              // Type badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isCredit
                      ? AppTheme.secondary.withOpacity(0.12)
                      : AppTheme.danger.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _isCredit ? '↓ Credit' : '↑ Debit',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _isCredit ? AppTheme.secondary : AppTheme.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Date Section Header ──────────────────────────────────────
class TransactionDateHeader extends StatelessWidget {
  final String label;

  const TransactionDateHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppTheme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
