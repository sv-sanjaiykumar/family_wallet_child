import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/child_data.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parent/limit_progress_bar.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  void _showAddChildSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddChildSheet(onAdd: () => setState(() {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildData.profile;
    final goals = ChildData.goals;

    return Scaffold(
      backgroundColor: AppTheme.parentSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.parentPrimary,
        automaticallyImplyLeading: false,
        title: const Text(
          'Child Profile',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded,
                color: Colors.white, size: 22),
            onPressed: _showAddChildSheet,
            tooltip: 'Add Child',
          ),
          const SizedBox(width: 4),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Hero header ──────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.parentGradient,
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white.withOpacity(0.60), width: 3),
                    ),
                    child: Center(
                      child: Text(child.avatarEmoji,
                          style: const TextStyle(fontSize: 44)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${child.level} • ${child.streakDays} day streak 🔥',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.80),
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _StatChip(
                        label: 'Balance',
                        value: '₹${child.balance.toInt()}',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      _StatChip(
                        label: 'XP',
                        value: '${child.xp}/${child.xpToNextLevel}',
                        icon: Icons.bolt_rounded,
                      ),
                      _StatChip(
                        label: 'Badges',
                        value: '${child.badges.length}',
                        icon: Icons.emoji_events_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── XP progress ──────────────────────────
                  _SectionTitle('XP Progress'),
                  const SizedBox(height: 12),
                  LimitProgressBarSlim(
                    label: 'Level ${child.level} → ${child.level + 1}',
                    value: child.xp.toDouble(),
                    max: child.xpToNextLevel.toDouble(),
                  ),

                  const SizedBox(height: 24),

                  // ── Spending limit ────────────────────────
                  _SectionTitle('Spending Limit'),
                  const SizedBox(height: 12),
                  LimitProgressBar(
                    icon: Icons.tune_rounded,
                    label: 'Daily Limit',
                    value: child.spent,
                    max: child.spendingLimit,
                  ),

                  const SizedBox(height: 24),

                  // ── Badges ────────────────────────────────
                  _SectionTitle('Earned Badges'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusMedium,
                      boxShadow: AppTheme.parentSoftShadow,
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: child.badges.map((badge) {
                        return Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.parentPrimary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(badge,
                                style: const TextStyle(fontSize: 26)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Savings Goals ──────────────────────────
                  _SectionTitle('Savings Goals'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusMedium,
                      boxShadow: AppTheme.parentSoftShadow,
                    ),
                    child: Column(
                      children: List.generate(goals.length, (i) {
                        final goal = goals[i];
                        return Column(
                          children: [
                            if (i > 0)
                              const Divider(
                                  height: 1,
                                  indent: 16,
                                  color: Color(0xFFEAEEF4)),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(goal.emoji,
                                      style:
                                          const TextStyle(fontSize: 28)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              goal.title,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.parentTextDark,
                                                fontFamily: 'Nunito',
                                              ),
                                            ),
                                            Text(
                                              goal.isCompleted
                                                  ? '✅ Done'
                                                  : '₹${goal.saved.toInt()} / ₹${goal.target.toInt()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: goal.isCompleted
                                                    ? AppTheme.parentSuccess
                                                    : AppTheme.parentTextMuted,
                                                fontFamily: 'Nunito',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 6,
                                                color: AppTheme.parentPrimary
                                                    .withOpacity(0.10),
                                              ),
                                              FractionallySizedBox(
                                                widthFactor:
                                                    goal.progressPercent,
                                                child: Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    gradient: goal.isCompleted
                                                        ? AppTheme
                                                            .parentGreenGradient
                                                        : AppTheme
                                                            .parentGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  // ── Login Credentials ─────────────────────
                  _SectionTitle('Login Credentials'),
                  const SizedBox(height: 4),
                  Text(
                    'Set the username & password your child uses to log in',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.parentTextMuted,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SetCredentialsCard(),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat chip (inside header) ───────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.75),
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section title ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppTheme.parentTextDark,
        fontFamily: 'Nunito',
      ),
    );
  }
}

// ── Add Child bottom sheet ──────────────────────────────────────

class _AddChildSheet extends StatefulWidget {
  final VoidCallback onAdd;
  const _AddChildSheet({required this.onAdd});

  @override
  State<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<_AddChildSheet> {
  final _nameController = TextEditingController();
  final _emojis = ['🧒', '👧', '👦', '🧑', '👶', '🧒‍♀️'];
  int _selectedEmoji = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3EE),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add a Child',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.parentTextDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose an avatar and enter a name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.parentTextMuted,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 20),

          // Emoji picker
          Row(
            children: List.generate(_emojis.length, (i) {
              final isSelected = _selectedEmoji == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedEmoji = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.parentPrimary.withOpacity(0.10)
                          : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.parentPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(_emojis[i],
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Name input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: AppTheme.radiusMedium,
            ),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.parentTextDark,
                fontFamily: 'Nunito',
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_rounded,
                    color: AppTheme.parentPrimary, size: 20),
                hintText: 'Child\'s name',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.parentTextMuted,
                  fontFamily: 'Nunito',
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _nameController.text.trim().isNotEmpty
                    ? AppTheme.parentGradient
                    : null,
                color: _nameController.text.trim().isEmpty
                    ? const Color(0xFFDDE3EE)
                    : null,
                borderRadius: AppTheme.radiusMedium,
              ),
              child: ElevatedButton(
                onPressed: _nameController.text.trim().isEmpty
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        widget.onAdd();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${_emojis[_selectedEmoji]} ${_nameController.text.trim()} added!',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: AppTheme.parentSuccess,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium),
                ),
                child: const Text(
                  'Add Child',
                  style: TextStyle(
                    fontSize: 16,
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

// ── Set Credentials Card ────────────────────────────────────────

class _SetCredentialsCard extends StatefulWidget {
  const _SetCredentialsCard();

  @override
  State<_SetCredentialsCard> createState() => _SetCredentialsCardState();
}

class _SetCredentialsCardState extends State<_SetCredentialsCard> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _prefillUsername();
  }

  Future<void> _prefillUsername() async {
    final saved = await AuthService.instance.getSavedUsername();
    if (saved != null && mounted) {
      setState(() => _userCtrl.text = saved);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _userCtrl.text.trim().length >= 3 &&
      _passCtrl.text.length >= 6 &&
      _passCtrl.text == _confirmCtrl.text;

  Future<void> _save() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (user.length < 3) {
      setState(() => _error = 'Username must be at least 3 characters');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    HapticFeedback.mediumImpact();
    await AuthService.instance.setChildCredentials(
        username: user, password: pass);

    setState(() {
      _loading = false;
      _done = true;
      _passCtrl.clear();
      _confirmCtrl.clear();
    });

    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _done = false) : null);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Login credentials saved!',
                style: TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: AppTheme.parentSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.parentSoftShadow,
        border: Border.all(
          color: AppTheme.parentPrimary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.parentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.key_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Child Login Setup',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.parentTextDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SheetField(
            controller: _userCtrl,
            hint: 'e.g. aarav2015',
            icon: Icons.person_rounded,
            label: 'Username',
            onChanged: (_) => setState(() {
              _error = null;
              _done = false;
            }),
          ),
          const SizedBox(height: 12),
          _PasswordSheetField(
            controller: _passCtrl,
            hint: 'Min. 6 characters',
            label: 'Password',
            obscure: _obscurePass,
            onToggle: () => setState(() => _obscurePass = !_obscurePass),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 12),
          _PasswordSheetField(
            controller: _confirmCtrl,
            hint: 'Re-enter password',
            label: 'Confirm Password',
            obscure: _obscureConfirm,
            onToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onChanged: (_) => setState(() => _error = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFEF5350), size: 15),
                const SizedBox(width: 6),
                Text(_error!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF5350),
                      fontFamily: 'Nunito',
                    )),
              ],
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: _isValid ? AppTheme.parentGradient : null,
                color: _isValid ? null : const Color(0xFFDDE3EE),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: ElevatedButton(
                onPressed: _isValid && !_loading ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _done
                                ? Icons.check_circle_rounded
                                : Icons.save_rounded,
                            color: _isValid
                                ? Colors.white
                                : AppTheme.parentTextMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _done ? 'Saved!' : 'Save Credentials',
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
        ],
      ),
    );
  }
}

// ── Small form helpers ──────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String label;
  final ValueChanged<String>? onChanged;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.parentTextMuted,
              fontFamily: 'Nunito',
            )),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: AppTheme.radiusMedium,
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.parentTextDark,
                fontFamily: 'Nunito'),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(icon, color: AppTheme.parentPrimary, size: 18),
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.parentTextMuted,
                  fontFamily: 'Nunito'),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordSheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;

  const _PasswordSheetField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.parentTextMuted,
              fontFamily: 'Nunito',
            )),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: AppTheme.radiusMedium,
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.parentTextDark,
                fontFamily: 'Nunito'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_rounded,
                  color: AppTheme.parentPrimary, size: 18),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppTheme.parentTextMuted,
                  size: 18,
                ),
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.parentTextMuted,
                  fontFamily: 'Nunito'),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
