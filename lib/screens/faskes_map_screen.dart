import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/faskes_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FaskesMapScreen
// ─────────────────────────────────────────────────────────────────────────────

class FaskesMapScreen extends StatefulWidget {
  const FaskesMapScreen({super.key});

  @override
  State<FaskesMapScreen> createState() => _FaskesMapScreenState();
}

class _FaskesMapScreenState extends State<FaskesMapScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedFilter = 0;
  FaskesModel? _selectedFaskes;
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _cardController;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  static const _filters = ['Semua', 'Rumah Sakit', 'Klinik', 'Puskesmas'];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _cardController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<FaskesModel> get _filteredList {
    final query = _searchController.text.toLowerCase();
    return dummyFaskesList.where((f) {
      final matchFilter =
          _selectedFilter == 0 || f.category == _filters[_selectedFilter];
      final matchSearch =
          query.isEmpty || f.name.toLowerCase().contains(query);
      return matchFilter && matchSearch;
    }).toList();
  }

  void _selectFaskes(FaskesModel f) {
    setState(() => _selectedFaskes = f);
    _cardController.forward(from: 0);
  }

  void _dismissCard() {
    _cardController.reverse().then((_) {
      if (mounted) setState(() => _selectedFaskes = null);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── 1. Map Placeholder ───────────────────────────────────────────
          const _MapPlaceholder(),

          // ── 2. Top gradient scrim ────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.95),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Top floating controls ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(controller: _searchController, onChanged: (_) => setState(() {})),
                const SizedBox(height: 10),
                _FilterChips(
                  filters: _filters,
                  selectedIndex: _selectedFilter,
                  onSelected: (i) => setState(() => _selectedFilter = i),
                ),
              ],
            ),
          ),

          // ── 4. Dummy markers (simulate map pins) ─────────────────────────
          _DummyMarkers(
            filteredList: _filteredList,
            selectedFaskes: _selectedFaskes,
            onMarkerTap: _selectFaskes,
          ),

          // ── 5. Locate-me FAB ─────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: _selectedFaskes != null ? 290 : 100,
            child: _LocateMeButton(),
          ),

          // ── 6. Bento detail card (slides up) ─────────────────────────────
          if (_selectedFaskes != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: _FaskesBentoCard(
                    faskes: _selectedFaskes!,
                    onDismiss: _dismissCard,
                  ),
                ),
              ),
            ),

          // ── 7. Dismiss overlay (tap outside card) ────────────────────────
          if (_selectedFaskes != null)
            Positioned.fill(
              bottom: 270,
              child: GestureDetector(
                onTap: _dismissCard,
                behavior: HitTestBehavior.translucent,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3A2A), Color(0xFF1D6B3E), Color(0xFF145230)],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw a grid of city-block-like rectangles
    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final rect = Rect.fromLTWH(x + 6, y + 6, step - 14, step - 14);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          blockPaint,
        );
      }
    }

    // Horizontal roads
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vertical roads
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Main arterial roads (thicker)
    final arterialPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.38, size.width * 0.6, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width, size.height * 0.48);
    canvas.drawPath(path, arterialPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(size.width * 0.32, size.height * 0.3, size.width * 0.28, size.height * 0.7)
      ..lineTo(size.width * 0.3, size.height);
    canvas.drawPath(path2, arterialPaint);
  }

  @override
  bool shouldRepaint(_MapGridPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Cari rumah sakit atau klinik...',
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          suffixIcon: Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chips
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.30)
                        : Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dummy Map Markers
// ─────────────────────────────────────────────────────────────────────────────

class _DummyMarkers extends StatelessWidget {
  const _DummyMarkers({
    required this.filteredList,
    required this.selectedFaskes,
    required this.onMarkerTap,
  });
  final List<FaskesModel> filteredList;
  final FaskesModel? selectedFaskes;
  final ValueChanged<FaskesModel> onMarkerTap;

  // Fixed positions on screen to simulate map pins
  static const _positions = [
    (left: 0.38, top: 0.38),
    (left: 0.22, top: 0.50),
    (left: 0.60, top: 0.55),
    (left: 0.50, top: 0.42),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        for (int i = 0; i < filteredList.length && i < _positions.length; i++)
          Positioned(
            left: _positions[i].left * size.width,
            top: _positions[i].top * size.height,
            child: _MapMarker(
              faskes: filteredList[i],
              isSelected: selectedFaskes?.id == filteredList[i].id,
              onTap: () => onMarkerTap(filteredList[i]),
            ),
          ),
      ],
    );
  }
}

class _MapMarker extends StatefulWidget {
  const _MapMarker({
    required this.faskes,
    required this.isSelected,
    required this.onTap,
  });
  final FaskesModel faskes;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_MapMarker> createState() => _MapMarkerState();
}

class _MapMarkerState extends State<_MapMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _markerColor {
    switch (widget.faskes.category) {
      case 'Rumah Sakit':
        return AppColors.primary;
      case 'Klinik':
        return const Color(0xFF7C3AED);
      case 'Puskesmas':
        return const Color(0xFF0EA5E9);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSelected)
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _markerColor.withValues(alpha: 0.20),
                ),
              ),
            )
          else
            const SizedBox(width: 48, height: 48),
          Transform.translate(
            offset: const Offset(0, -24),
            child: AnimatedScale(
              scale: widget.isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: _markerColor.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locate-me FAB
// ─────────────────────────────────────────────────────────────────────────────

class _LocateMeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Hook up to map controller later
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bento Detail Card
// ─────────────────────────────────────────────────────────────────────────────

class _FaskesBentoCard extends StatelessWidget {
  const _FaskesBentoCard({required this.faskes, required this.onDismiss});
  final FaskesModel faskes;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header row ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon avatar
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faskes.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _CategoryBadge(category: faskes.category),
                        const SizedBox(width: 6),
                        if (faskes.acceptsBpjs) const _BpjsBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      faskes.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  faskes.address,
                  style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Bento grid: Hours + Contact ───────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _BentoInfoTile(
                  icon: Icons.access_time_rounded,
                  label: 'Jam Operasional',
                  value: faskes.operatingHours,
                  color: AppColors.primary,
                  bgColor: AppColors.primarySurface,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BentoInfoTile(
                  icon: Icons.phone_rounded,
                  label: 'Kontak Darurat',
                  value: faskes.emergencyContact,
                  color: const Color(0xFF0EA5E9),
                  bgColor: const Color(0xFFEFF9FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Distance tile (full width) ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_walk_rounded, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${faskes.distance} dari lokasi Anda',
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${faskes.tbFacilities.length} Fasilitas TBC',
                  style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── CTA buttons ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('Hubungi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: const Text('Petunjuk Arah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BentoInfoTile extends StatelessWidget {
  const _BentoInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final String category;

  Color get _color {
    switch (category) {
      case 'Rumah Sakit': return AppColors.primary;
      case 'Klinik': return const Color(0xFF7C3AED);
      case 'Puskesmas': return const Color(0xFF0EA5E9);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(fontSize: 10, color: _color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BpjsBadge extends StatelessWidget {
  const _BpjsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
      ),
      child: const Text(
        'BPJS ✓',
        style: TextStyle(
          fontSize: 10,
          color: Color(0xFFD97706),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
