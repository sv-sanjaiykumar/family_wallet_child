import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/child_data.dart';
import '../../models/parent_data.dart';
import '../../theme/app_theme.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  double? _selectedQuick;
  bool _isLoading = false;

  static const List<double> _quickAmounts = [100, 500, 1000, 2000];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _amountController.addListener(() => setState(() => _selectedQuick = null));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double? get _enteredAmount {
    final v = double.tryParse(_amountController.text.trim());
    if (_selectedQuick != null) return _selectedQuick;
    return v;
  }

  bool get _isValid => (_enteredAmount ?? 0) > 0;

  void _selectQuick(double amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedQuick = amount;
      _amountController.text = amount.toInt().toString();
    });
    _focusNode.unfocus();
  }

  Future<void> _confirm() async {
    final amount = _enteredAmount;
    if (amount == null || amount <= 0) return;
    _focusNode.unfocus();
    final confirmed = await _showConfirmSheet(amount);
    if (confirmed == true) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));
      ParentData.addMoney(amount);
      setState(() {
        _isLoading = false;
        _amountController.clear();
        _selectedQuick = null;
      });
      if (mounted) _showSuccessSheet(amount);
    }
  }

  Future<bool?> _showConfirmSheet(double amount) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        amount: amount,
        childName: ChildData.profile.name,
        childEmoji: ChildData.profile.avatarEmoji,
        currentBalance: ChildData.profile.balance,
      ),
    );
  }

  void _showSuccessSheet(double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => _SuccessSheet(
        amount: amount,
        newBalance: ChildData.profile.balance,
        childName: ChildData.profile.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildData.profile;

    return Scaffold(
      backgroundColor: AppTheme.parentSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.parentPrimary,
        title: const Text(
          'Add Money',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Child wallet card ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.parentGradient,
                borderRadius: AppTheme.radiusLarge,
                boxShadow: AppTheme.parentCardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(child.avatarEmoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${child.balance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Quick amounts ─────────────────────────────────
            const _Label('Quick Amount'),
            const SizedBox(height: 12),
            Row(
              children: _quickAmounts.map((amount) {
                final isSelected = _selectedQuick == amount;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: amount != _quickAmounts.last ? 10 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => _selectQuick(amount),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? AppTheme.parentGradient
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: AppTheme.radiusMedium,
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFDDE3EE),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? AppTheme.parentCardShadow
                              : AppTheme.parentSoftShadow,
                        ),
                        child: Column(
                          children: [
                            Text(
                              '₹${amount.toInt()}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.parentTextDark,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Custom amount input ───────────────────────────
            const _Label('Or Enter Custom Amount'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusMedium,
                boxShadow: AppTheme.parentSoftShadow,
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppTheme.parentPrimary.withOpacity(0.50)
                      : const Color(0xFFDDE3EE),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _amountController,
                focusNode: _focusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.parentTextDark,
                  fontFamily: 'Nunito',
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.parentPrimary,
                    fontFamily: 'Nunito',
                  ),
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.parentTextMuted.withOpacity(0.50),
                    fontFamily: 'Nunito',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 18),
                ),
                onTap: () => setState(() => _selectedQuick = null),
              ),
            ),

            const SizedBox(height: 36),

            // ── Send Button ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _isValid ? _pulseAnim.value : 1.0,
                  child: child,
                ),
                child: GestureDetector(
                  onTap: _isValid && !_isLoading ? _confirm : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: _isValid
                          ? AppTheme.parentGradient
                          : null,
                      color: _isValid ? null : const Color(0xFFDDE3EE),
                      borderRadius: AppTheme.radiusMedium,
                      boxShadow: _isValid ? AppTheme.parentCardShadow : [],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.send_rounded,
                                  color: _isValid
                                      ? Colors.white
                                      : AppTheme.parentTextMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isValid
                                      ? 'Send ₹${(_enteredAmount ?? 0).toInt()} to ${ChildData.profile.name}'
                                      : 'Enter Amount to Continue',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _isValid
                                        ? Colors.white
                                        : AppTheme.parentTextMuted,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info note
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppTheme.parentTextMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Money will be added instantly to ${ChildData.profile.name}\'s wallet',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.parentTextMuted,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Label widget ────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.parentTextMuted,
        fontFamily: 'Nunito',
      ),
    );
  }
}

// ── Confirm bottom sheet ────────────────────────────────────────

class _ConfirmSheet extends StatelessWidget {
  final double amount;
  final String childName;
  final String childEmoji;
  final double currentBalance;

  const _ConfirmSheet({
    required this.amount,
    required this.childName,
    required this.childEmoji,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE3EE),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.parentGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(childEmoji,
                  style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Confirm Transfer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.parentTextDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.parentTextMuted,
                fontFamily: 'Nunito',
              ),
              children: [
                const TextSpan(text: 'Send '),
                TextSpan(
                  text: '₹${amount.toInt()}',
                  style: const TextStyle(
                    color: AppTheme.parentPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                TextSpan(text: ' to $childName\'s wallet?'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New balance will be ₹${(currentBalance + amount).toInt()}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.parentSuccess,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDDE3EE), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.parentTextMuted,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.parentGradient,
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusMedium,
                      ),
                    ),
                    child: const Text(
                      'Confirm & Send',
                      style: TextStyle(
                        fontSize: 15,
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
        ],
      ),
    );
  }
}

// ── Success bottom sheet ────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final double amount;
  final double newBalance;
  final String childName;

  const _SuccessSheet({
    required this.amount,
    required this.newBalance,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.parentGreenGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Money Sent! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.parentTextDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toInt()} has been added to $childName\'s wallet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.parentTextMuted,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New balance: ₹${newBalance.toInt()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.parentSuccess,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.parentGradient,
                borderRadius: AppTheme.radiusMedium,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium,
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 15,
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
    );
  }
}
