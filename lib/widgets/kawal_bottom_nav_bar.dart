import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// ─── Nav item data ─────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<_NavItem> _navItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Beranda',
  ),
  _NavItem(
    icon: Icons.medical_information_outlined,
    activeIcon: Icons.medical_information_rounded,
    label: 'Diagnosa',
  ),
  _NavItem(
    icon: Icons.alarm_outlined,
    activeIcon: Icons.alarm_rounded,
    label: 'Alarm',
  ),
  _NavItem(
    icon: Icons.location_on_outlined,
    activeIcon: Icons.location_on_rounded,
    label: 'Maps',
  ),
  _NavItem(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profil',
  ),
];

// ─── Public widget ─────────────────────────────────────────────────────────────

/// A premium glassmorphism floating pill-shaped bottom navigation bar.
///
/// Usage:
/// ```dart
/// KawalBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (i) => setState(() => _currentIndex = i),
/// )
/// ```
class KawalBottomNavBar extends StatefulWidget {
  const KawalBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<KawalBottomNavBar> createState() => _KawalBottomNavBarState();
}

class _KawalBottomNavBarState extends State<KawalBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  // Tracks position for the sliding active indicator
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();

    _scaleControllers = List.generate(
      _navItems.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _scaleAnimations = _scaleControllers
        .map(
          (c) => Tween<double>(begin: 1.0, end: 1.18).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOutBack),
          ),
        )
        .toList();

    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _indicatorAnimation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic),
    );

    // Kick off the initial scale for the active item
    _scaleControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(KawalBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Scale down old, scale up new
      _scaleControllers[_previousIndex].reverse();
      _scaleControllers[widget.currentIndex].forward();

      // Slide the active indicator
      _indicatorAnimation = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(parent: _indicatorController, curve: Curves.easeInOutCubic),
      );
      _indicatorController
        ..reset()
        ..forward();

      _previousIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90 + MediaQuery.of(context).padding.bottom,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // ── Smooth Gradient Blur Background (fading up) ────────────
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.black, Colors.transparent],
                  stops: [0.0, 0.75, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white.withOpacity(0.95),
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Nav Items Row (The Floating Pill) ───────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ── Sliding active pill indicator ───────────────────────
                      Positioned.fill(
                        top: 10,
                        bottom: 10,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Replicate spaceAround: center of item i =
                            //   navWidth * (2i + 1) / (2 * n)
                            final navWidth = constraints.maxWidth;
                            final n = _navItems.length;
                            return AnimatedBuilder(
                              animation: _indicatorAnimation,
                              builder: (context, _) {
                                final i = _indicatorAnimation.value;
                                final centerX = navWidth * (2 * i + 1) / (2 * n);
                                const indicatorW = 48.0;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Transform.translate(
                                    offset: Offset(centerX - indicatorW / 2, 0),
                                    child: Container(
                                      width: indicatorW,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.primary, AppColors.primaryLight],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.35),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // ── Nav items ───────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_navItems.length, (i) {
                          final isActive = widget.currentIndex == i;
                          return _NavItemWidget(
                            item: _navItems[i],
                            isActive: isActive,
                            scaleAnimation: _scaleAnimations[i],
                            onTap: () => widget.onTap(i),
                          );
                        }),
                      ),
                    ],
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

// ─── Individual nav item ───────────────────────────────────────────────────────

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.scaleAnimation,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: scaleAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  size: 22,
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.white : AppColors.textSecondary,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
