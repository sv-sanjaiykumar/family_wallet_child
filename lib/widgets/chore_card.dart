import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/child_data.dart';

class ChoreCard extends StatefulWidget {
  final Chore chore;
  final VoidCallback onCompleted;

  const ChoreCard({
    super.key,
    required this.chore,
    required this.onCompleted,
  });

  @override
  State<ChoreCard> createState() => _ChoreCardState();
}

class _ChoreCardState extends State<ChoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
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

  bool get _isCompleted => widget.chore.status == ChoreStatus.completed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _isCompleted ? null : _onTapDown,
        onTapUp: _isCompleted ? null : _onTapUp,
        onTapCancel: _isCompleted ? null : () => _controller.forward(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: AppTheme.radiusMedium,
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color: _isCompleted
                  ? AppTheme.secondary.withOpacity(0.4)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── Icon Circle ─────────────────────────
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? AppTheme.secondary.withOpacity(0.12)
                        : widget.chore.iconColor.withOpacity(0.12),
                    borderRadius: AppTheme.radiusSmall,
                  ),
                  child: Icon(
                    _isCompleted
                        ? Icons.check_circle_rounded
                        : widget.chore.icon,
                    color: _isCompleted
                        ? AppTheme.secondary
                        : widget.chore.iconColor,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                // ── Text ─────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chore.title,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textDark,
                          decoration: _isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.chore.description,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Reward chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: _isCompleted
                              ? AppTheme.greenGradient
                              : AppTheme.amberGradient,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _isCompleted
                              ? '✅ Earned ₹${widget.chore.reward.toStringAsFixed(0)}'
                              : '🪙 Reward: ₹${widget.chore.reward.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ── Action Button ─────────────────────────
                if (!_isCompleted)
                  GestureDetector(
                    onTap: () => _showConfirmDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: AppTheme.radiusSmall,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text('✔', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 2),
                          Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Text('🎉', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
        title: const Text(
          '🎉 Mark as Done?',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Did you complete "${widget.chore.title}"?\nYou\'ll earn ₹${widget.chore.reward.toStringAsFixed(0)}!',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: AppTheme.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Not yet',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onCompleted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusSmall,
              ),
            ),
            child: const Text(
              'Yes! Claim Reward 🪙',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
