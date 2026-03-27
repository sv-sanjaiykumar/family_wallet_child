import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'child/child_home_shell.dart';
import 'child/child_login_screen.dart';
import 'parent/parent_home_shell.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _bgController.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => _cardController.forward());
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF6C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Decorative circles ──────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _GlowCircle(size: 220, opacity: 0.15),
          ),
          Positioned(
            bottom: size.height * 0.38,
            left: -80,
            child: _GlowCircle(size: 180, opacity: 0.10),
          ),
          Positioned(
            bottom: -40,
            right: -30,
            child: _GlowCircle(size: 160, opacity: 0.12),
          ),

          // ── Content ─────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Logo / App title
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Family Vault',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Who\'s logging in today?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.80),
                      fontFamily: 'Nunito',
                    ),
                  ),

                  const Spacer(),

                  // ── Role cards ────────────────────────────────
                  SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Parent card
                            _RoleCard(
                              emoji: '👨',
                              title: 'Parent',
                              subtitle: 'Manage wallet, chores & limits',
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFF0F4FF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              titleColor: AppTheme.parentPrimary,
                              subtitleColor: AppTheme.parentTextMuted,
                              onTap: () =>
                                  _navigateTo(const ParentHomeShell()),
                              tags: const ['📊 Dashboard', '💸 Send Money', '✅ Chores'],
                            ),

                            const SizedBox(height: 16),

                            // Child card
                            _RoleCard(
                              emoji: '🧒',
                              title: 'Child',
                              subtitle: 'View wallet, goals & earn rewards',
                              gradient: AppTheme.primaryGradient,
                              titleColor: Colors.white,
                              subtitleColor: Colors.white70,
                              onTap: () =>
                                  _navigateTo(const ChildLoginScreen()),
                              tags: const ['🎮 Dashboard', '🎯 Goals', '⭐ Chores'],
                              isDark: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Text(
                    'Family Vault • Financial Learning for Kids',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.55),
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role Card ───────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;
  final List<String> tags;
  final bool isDark;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
    required this.tags,
    this.isDark = false,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: AppTheme.radiusLarge,
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? AppTheme.primary.withOpacity(0.30)
                    : Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.15)
                      : AppTheme.parentPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),

              const SizedBox(width: 18),

              // Text + tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: widget.titleColor,
                        fontFamily: 'Nunito',
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.subtitleColor,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.18)
                                : AppTheme.parentPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.white
                                  : AppTheme.parentPrimary,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: widget.isDark
                    ? Colors.white.withOpacity(0.60)
                    : AppTheme.parentPrimary.withOpacity(0.50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Glow circle decoration ──────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
