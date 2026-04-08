import 'package:flutter/material.dart';
import '../../models/parent_data.dart';
import '../../theme/app_theme.dart';

/// A chore card for the Parent module.
///
/// Supports two modes:
/// - [showActions] = true  → shows Approve ✅ / Reject ❌ buttons (for completed chores)
/// - [showActions] = false → shows status badge only (all chores list)
class ParentChoreCard extends StatefulWidget {
  final ParentChore chore;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ParentChoreCard({
    super.key,
    required this.chore,
    this.showActions = false,
    this.onApprove,
    this.onReject,
  });

  @override
  State<ParentChoreCard> createState() => _ParentChoreCardState();
}

class _ParentChoreCardState extends State<ParentChoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  // ── Status helpers ────────────────────────────────────────────

  Color get _statusColor {
    switch (widget.chore.approvalStatus) {
      case ChoreApprovalStatus.pending:
        return AppTheme.parentWarning;
      case ChoreApprovalStatus.completed:
        return AppTheme.parentPrimary;
      case ChoreApprovalStatus.approved:
        return AppTheme.parentSuccess;
      case ChoreApprovalStatus.rejected:
        return AppTheme.parentDanger;
    }
  }

  String get _statusLabel {
    switch (widget.chore.approvalStatus) {
      case ChoreApprovalStatus.pending:
        return 'Pending';
      case ChoreApprovalStatus.completed:
        return 'Awaiting Approval';
      case ChoreApprovalStatus.approved:
        return 'Approved';
      case ChoreApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  IconData get _statusIcon {
    switch (widget.chore.approvalStatus) {
      case ChoreApprovalStatus.pending:
        return Icons.hourglass_top_rounded;
      case ChoreApprovalStatus.completed:
        return Icons.pending_actions_rounded;
      case ChoreApprovalStatus.approved:
        return Icons.check_circle_rounded;
      case ChoreApprovalStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.parentCardBg,
            borderRadius: AppTheme.radiusMedium,
            boxShadow: AppTheme.parentSoftShadow,
            border: Border.all(
              color: widget.chore.approvalStatus == ChoreApprovalStatus.completed
                  ? AppTheme.parentPrimary.withOpacity(0.30)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: icon + title + status badge ──────────
              Row(
                children: [
                  // Icon bubble
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.chore.iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.chore.icon,
                      color: widget.chore.iconColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chore.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.parentTextDark,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.chore.description,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.parentTextMuted,
                            fontFamily: 'Nunito',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Reward chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppTheme.parentGreenGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${widget.chore.reward.toInt()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Status badge ──────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon,
                            size: 13, color: _statusColor),
                        const SizedBox(width: 5),
                        Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _statusColor,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Approve / Reject Buttons ──────────────────────
              if (widget.showActions &&
                  widget.chore.approvalStatus ==
                      ChoreApprovalStatus.completed) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFEAEEF4)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Reject
                    Expanded(
                      child: _ActionButton(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        color: AppTheme.parentDanger,
                        gradient: AppTheme.parentAmberGradient,
                        isFilled: false,
                        onTap: widget.onReject,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Approve
                    Expanded(
                      child: _ActionButton(
                        label: 'Approve',
                        icon: Icons.check_rounded,
                        color: AppTheme.parentSuccess,
                        gradient: AppTheme.parentGreenGradient,
                        isFilled: true,
                        onTap: widget.onApprove,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small action button inside the chore card ─────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final bool isFilled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.isFilled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isFilled ? gradient : null,
          color: isFilled ? null : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: isFilled
              ? null
              : Border.all(color: color.withOpacity(0.40), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isFilled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isFilled ? Colors.white : color,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
