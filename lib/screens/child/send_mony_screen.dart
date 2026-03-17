import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/child_data.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isProcessing = false;
  bool _showSuccess = false;
  String? _warning;

  final List<double> _quickAmounts = [20, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final p = ChildData.profile;
    setState(() {
      if (amount <= 0) _warning = null;
      else if (amount > p.balance)
        _warning = '⚠️ Insufficient balance! You have ₹${p.balance.toStringAsFixed(0)}.';
      else if (p.spent + amount > p.spendingLimit)
        _warning = '🚫 Limit exceeded! Only ₹${p.remainingLimit.toStringAsFixed(0)} left today.';
      else
        _warning = null;
    });
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount > 0 && _warning == null;
  }

  Future<void> _send() async {
    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim().isEmpty ? 'Money sent' : _noteController.text.trim();
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final ok = ChildData.spendMoney(amount, note);
    setState(() {
      _isProcessing = false;
      _showSuccess = ok;
      if (ok) { _amountController.clear(); _noteController.clear(); }
    });
    if (ok) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _showSuccess = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ChildData.profile;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 24,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.pinkGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💸 Send Money',
                        style: TextStyle(color: Colors.white, fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900, fontSize: 24)),
                    const SizedBox(height: 4),
                    Text('Spend within your daily limit',
                        style: TextStyle(color: Colors.white.withOpacity(0.85),
                            fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                  const Text('🚀', style: TextStyle(fontSize: 36)),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Balance strip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.radiusLarge,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _chip('💰', '₹${p.balance.toStringAsFixed(0)}', 'Balance'),
                    Container(width: 1, height: 36, color: Colors.white24),
                    _chip('📤', '₹${p.spent.toStringAsFixed(0)}', 'Spent'),
                    Container(width: 1, height: 36, color: Colors.white24),
                    _chip('✅', '₹${p.remainingLimit.toStringAsFixed(0)}', 'Left Today'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Success banner
              if (_showSuccess)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.greenGradient,
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  child: const Row(children: [
                    Text('🎉', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Text('Money sent successfully!',
                        style: TextStyle(color: Colors.white, fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800, fontSize: 15)),
                  ]),
                ),

              // Quick amounts
              const Text('Quick Select',
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                      fontSize: 14, color: AppTheme.textDark)),
              const SizedBox(height: 10),
              Row(
                children: _quickAmounts.map((amt) {
                  final selected = _amountController.text == amt.toStringAsFixed(0);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () { _amountController.text = amt.toStringAsFixed(0); _validate(); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: selected ? AppTheme.primaryGradient : null,
                          color: selected ? null : Colors.white,
                          borderRadius: AppTheme.radiusSmall,
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Center(
                          child: Text('₹${amt.toStringAsFixed(0)}',
                              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                                  fontSize: 14, color: selected ? Colors.white : AppTheme.textDark)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Amount input
              const Text('Enter Amount',
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                      fontSize: 14, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: AppTheme.radiusMedium, boxShadow: AppTheme.softShadow),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                      fontSize: 22, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    prefixText: '₹  ',
                    prefixStyle: const TextStyle(fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700, fontSize: 22, color: AppTheme.primary),
                    hintText: '0',
                    hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 22, color: Colors.grey.shade300),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                  ),
                ),
              ),

              // Warning
              if (_warning != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.10),
                    borderRadius: AppTheme.radiusSmall,
                    border: Border.all(color: AppTheme.danger.withOpacity(0.35)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_warning!,
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 12,
                            fontWeight: FontWeight.w600, color: AppTheme.danger))),
                  ]),
                ),
              ],

              const SizedBox(height: 16),

              // Note input
              const Text('Add a Note (optional)',
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                      fontSize: 14, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: AppTheme.radiusMedium, boxShadow: AppTheme.softShadow),
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                      fontSize: 14, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. Snacks, Books, Games...',
                    hintStyle: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.notes_rounded, color: AppTheme.primary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _isValid && !_isProcessing ? _send : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValid ? AppTheme.primary : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
                    elevation: _isValid ? 4 : 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('🚀 Send Money',
                          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                              fontSize: 17, color: Colors.white)),
                ),
              ),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _chip(String emoji, String value, String label) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontFamily: 'Nunito',
          fontWeight: FontWeight.w900, fontSize: 13)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75),
          fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 10)),
    ]);
  }
}
