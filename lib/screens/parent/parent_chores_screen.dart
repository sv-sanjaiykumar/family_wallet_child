import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/child_data.dart';
import '../../models/parent_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/parent/parent_chore_card.dart';

class ParentChoresScreen extends StatefulWidget {
  const ParentChoresScreen({super.key});

  @override
  State<ParentChoresScreen> createState() => _ParentChoresScreenState();
}

class _ParentChoresScreenState extends State<ParentChoresScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ParentChore> get _pendingApproval => ParentData.parentChores
      .where((c) => c.approvalStatus == ChoreApprovalStatus.completed)
      .toList();

  List<ParentChore> get _allChores => ParentData.parentChores;

  void _approve(ParentChore chore) {
    HapticFeedback.mediumImpact();
    final success = ParentData.approveChore(chore.id);
    if (success) {
      setState(() {});
      _showSnack('✅ Chore approved! ₹${chore.reward.toInt()} sent to ${ChildData.profile.name}', AppTheme.parentSuccess);
    }
  }

  void _reject(ParentChore chore) {
    HapticFeedback.lightImpact();
    final success = ParentData.rejectChore(chore.id);
    if (success) {
      setState(() {});
      _showSnack('❌ Chore rejected — reset to pending', AppTheme.parentWarning);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _pendingApproval.length;

    return Scaffold(
      backgroundColor: AppTheme.parentSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.parentPrimary,
        title: const Text(
          'Chores & Rewards',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Approve'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.parentPrimary,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'All Chores'),
            const Tab(text: 'Create'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingApprovalTab(
            chores: _pendingApproval,
            onApprove: _approve,
            onReject: _reject,
          ),
          _AllChoresTab(chores: _allChores),
          _CreateChoreTab(onCreate: () => setState(() {})),
        ],
      ),
    );
  }
}

// ── Tab 1: Pending Approval ─────────────────────────────────────

class _PendingApprovalTab extends StatelessWidget {
  final List<ParentChore> chores;
  final ValueChanged<ParentChore> onApprove;
  final ValueChanged<ParentChore> onReject;

  const _PendingApprovalTab({
    required this.chores,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (chores.isEmpty) {
      return _EmptyState(
        icon: Icons.task_alt_rounded,
        message: 'No chores awaiting approval',
        sub: 'Completed chores from your child will appear here',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: chores
          .map((c) => ParentChoreCard(
                chore: c,
                showActions: true,
                onApprove: () => onApprove(c),
                onReject: () => onReject(c),
              ))
          .toList(),
    );
  }
}

// ── Tab 2: All Chores ───────────────────────────────────────────

class _AllChoresTab extends StatelessWidget {
  final List<ParentChore> chores;
  const _AllChoresTab({required this.chores});

  @override
  Widget build(BuildContext context) {
    if (chores.isEmpty) {
      return _EmptyState(
        icon: Icons.checklist_rounded,
        message: 'No chores yet',
        sub: 'Create your first chore in the Create tab',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: chores
          .map((c) => ParentChoreCard(chore: c, showActions: false))
          .toList(),
    );
  }
}

// ── Tab 3: Create Chore ─────────────────────────────────────────

class _CreateChoreTab extends StatefulWidget {
  final VoidCallback onCreate;
  const _CreateChoreTab({required this.onCreate});

  @override
  State<_CreateChoreTab> createState() => _CreateChoreTabState();
}

class _CreateChoreTabState extends State<_CreateChoreTab> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rewardController = TextEditingController();
  int _selectedIconIndex = 0;
  bool _loading = false;

  static const List<_IconOption> _iconOptions = [
    _IconOption(icon: Icons.cleaning_services_rounded, color: Color(0xFF4FC3F7), label: 'Clean'),
    _IconOption(icon: Icons.menu_book_rounded, color: Color(0xFFFF85A1), label: 'Study'),
    _IconOption(icon: Icons.soup_kitchen_rounded, color: Color(0xFF6C63FF), label: 'Dishes'),
    _IconOption(icon: Icons.bed_rounded, color: Color(0xFF00C9A7), label: 'Bed'),
    _IconOption(icon: Icons.local_florist_rounded, color: Color(0xFF4CAF50), label: 'Plants'),
    _IconOption(icon: Icons.delete_outline_rounded, color: Color(0xFFFF9A3C), label: 'Trash'),
    _IconOption(icon: Icons.pets_rounded, color: Color(0xFFFFD166), label: 'Pets'),
    _IconOption(icon: Icons.shopping_bag_rounded, color: Color(0xFFEF5350), label: 'Shopping'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
      (double.tryParse(_rewardController.text.trim()) ?? 0) > 0;

  Future<void> _submit() async {
    if (!_isValid) return;
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final opt = _iconOptions[_selectedIconIndex];
    ParentData.createChore(
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'Complete this task to earn the reward'
          : _descController.text.trim(),
      reward: double.parse(_rewardController.text.trim()),
      icon: opt.icon,
      iconColor: opt.color,
    );

    setState(() {
      _loading = false;
      _titleController.clear();
      _descController.clear();
      _rewardController.clear();
      _selectedIconIndex = 0;
    });
    widget.onCreate();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Chore created!',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: AppTheme.parentSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon picker
          const _FieldLabel('Choose Icon'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.radiusMedium,
              boxShadow: AppTheme.parentSoftShadow,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _iconOptions.length,
              itemBuilder: (_, i) {
                final opt = _iconOptions[i];
                final isSelected = _selectedIconIndex == i;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedIconIndex = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? opt.color.withOpacity(0.15)
                          : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? opt.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(opt.icon, color: opt.color, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? opt.color : AppTheme.parentTextMuted,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const _FieldLabel('Chore Title *'),
          const SizedBox(height: 8),
          _InputField(
            controller: _titleController,
            hint: 'e.g. Wash the dishes',
            icon: Icons.title_rounded,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Description
          const _FieldLabel('Description (optional)'),
          const SizedBox(height: 8),
          _InputField(
            controller: _descController,
            hint: 'e.g. Clean all dishes after dinner',
            icon: Icons.notes_rounded,
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // Reward
          const _FieldLabel('Reward Amount (₹) *'),
          const SizedBox(height: 8),
          _InputField(
            controller: _rewardController,
            hint: '0',
            icon: Icons.currency_rupee_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 32),

          // Submit
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: _isValid ? AppTheme.parentGradient : null,
                color: _isValid ? null : const Color(0xFFDDE3EE),
                borderRadius: AppTheme.radiusMedium,
                boxShadow: _isValid ? AppTheme.parentCardShadow : [],
              ),
              child: ElevatedButton(
                onPressed: _isValid && !_loading ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_task_rounded,
                              color: _isValid
                                  ? Colors.white
                                  : AppTheme.parentTextMuted,
                              size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Create Chore',
                            style: TextStyle(
                              fontSize: 16,
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Shared small widgets ────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusMedium,
        boxShadow: AppTheme.parentSoftShadow,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.parentTextDark,
          fontFamily: 'Nunito',
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.parentPrimary, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.parentTextMuted,
            fontFamily: 'Nunito',
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              child: Icon(icon, color: AppTheme.parentPrimary, size: 38),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.parentTextDark,
                fontFamily: 'Nunito',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.parentTextMuted,
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

class _IconOption {
  final IconData icon;
  final Color color;
  final String label;
  const _IconOption({required this.icon, required this.color, required this.label});
}
