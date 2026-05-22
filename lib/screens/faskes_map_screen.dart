import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../models/faskes_model.dart';
import '../services/faskes_service.dart';

class FaskesMapScreen extends StatefulWidget {
  const FaskesMapScreen({super.key});

  @override
  State<FaskesMapScreen> createState() => _FaskesMapScreenState();
}

class _FaskesMapScreenState extends State<FaskesMapScreen>
    with TickerProviderStateMixin {
  // ── Map Controller ──────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  static const _surabayaCenter = LatLng(-7.2575, 112.7521);

  // ── State ───────────────────────────────────────────────────────────────────
  List<FaskesModel> _allFaskes = [];
  List<FaskesModel> _filtered = [];
  List<Marker> _markers = [];
  FaskesModel? _selected;
  LatLng? _myLocation;
  bool _loading = true;
  String? _error;
  int _filterIndex = 0;
  final _searchCtrl = TextEditingController();

  // ── Animation Controllers ───────────────────────────────────────────────────
  late AnimationController _cardCtrl;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  static const _filters = ['Semua', 'Rumah Sakit', 'Klinik', 'Puskesmas'];

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutBack),
    );
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut),
    );
    
    _fetchFaskes();
    _initMyLocation();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Animated Map Move ────────────────────────────────────────────────────────
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  // ── User Location Initialization ─────────────────────────────────────────────
  Future<void> _initMyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _myLocation = LatLng(pos.latitude, pos.longitude);
        });
        _buildMarkers();
      }
    } catch (_) {}
  }

  // ── Fetch Data ──────────────────────────────────────────────────────────────
  Future<void> _fetchFaskes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await FaskesService.instance.fetchAll();
      setState(() {
        _allFaskes = data;
        _loading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allFaskes.where((f) {
        final matchCat =
            _filterIndex == 0 || f.category == _filters[_filterIndex];
        final matchQ = q.isEmpty || f.name.toLowerCase().contains(q);
        return matchCat && matchQ;
      }).toList();
    });
    _buildMarkers();
  }

  // ── Marker Builder (Funky Custom Pin Design) ──────────────────────────────────
  void _buildMarkers() {
    final markers = <Marker>[];

    // 1. Faskes Markers
    for (final f in _filtered) {
      final isSelected = _selected?.id == f.id;
      final category = f.category;

      Color pinColor;
      String emoji;
      if (category == 'Rumah Sakit') {
        pinColor = AppColors.primary;
        emoji = '🏥';
      } else if (category == 'Klinik') {
        pinColor = const Color(0xFF7C3AED); // Funky Violet
        emoji = '🩺';
      } else {
        pinColor = const Color(0xFF0EA5E9); // Funky Cyan
        emoji = '🏠';
      }

      markers.add(Marker(
        point: LatLng(f.latitude, f.longitude),
        width: isSelected ? 70.0 : 54.0,
        height: isSelected ? 70.0 : 54.0,
        child: GestureDetector(
          onTap: () => _selectFaskes(f),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Bottom pointer arrow
              Positioned(
                bottom: 0,
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: pinColor,
                  size: isSelected ? 26 : 20,
                ),
              ),
              // Main Circular Pin Body
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: pinColor.withOpacity(isSelected ? 0.45 : 0.2),
                      blurRadius: isSelected ? 12 : 6,
                      spreadRadius: isSelected ? 4 : 0,
                      offset: const Offset(0, 3),
                    )
                  ],
                  border: Border.all(
                    color: pinColor,
                    width: isSelected ? 3.5 : 2.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Center(
                    child: AnimatedScale(
                      scale: isSelected ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    }

    // 2. User Pulse Marker
    if (_myLocation != null) {
      markers.add(Marker(
        point: _myLocation!,
        width: 30,
        height: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glowing outer ring (representing GPS accuracy/pulse)
            _PulseCircle(),
            // Clean white base
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            // Vibrant blue core dot
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ));
    }

    setState(() => _markers = markers);
  }

  void _selectFaskes(FaskesModel f) {
    setState(() => _selected = f);
    _buildMarkers(); // Redraw with highlighted marker
    _cardCtrl.forward(from: 0);
    _animatedMapMove(LatLng(f.latitude, f.longitude), 15);
  }

  void _dismissCard() {
    _cardCtrl.reverse().then((_) {
      if (mounted) {
        setState(() => _selected = null);
        _buildMarkers(); // Restore regular markers
      }
    });
  }

  Future<void> _goToMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }
    if (perm == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    final newLoc = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _myLocation = newLoc;
    });
    _buildMarkers();
    _animatedMapMove(newLoc, 14.5);
  }

  Future<void> _launchDirections(FaskesModel f) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${f.latitude},${f.longitude}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'[^0-9+]'), ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. OpenStreetMap rendering using CartoDB Voyager tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _surabayaCenter,
              initialZoom: 12.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.kawaltb',
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // 2. Beautiful gradient overlay for top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 230,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.85),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // 3. Funky header control panel (Search + Filters)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchBar(
                  controller: _searchCtrl,
                  onChanged: (_) => _applyFilter(),
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  filters: _filters,
                  selectedIndex: _filterIndex,
                  onSelected: (i) {
                    setState(() => _filterIndex = i);
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),

          // 4. Loading / Error Overlay
          if (_loading)
            const Center(
              child: Card(
                elevation: 6,
                shape: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3.5,
                  ),
                ),
              ),
            ),
          if (_error != null)
            Center(child: _ErrorCard(error: _error!, onRetry: _fetchFaskes)),

          // 5. Playful Counter Badge
          if (!_loading && _error == null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 124,
              left: 16,
              child: _CountBadge(count: _filtered.length),
            ),

          // 6. Funky Locate-me FAB
          Positioned(
            right: 16,
            bottom: _selected != null ? 350 : 110,
            child: _LocateMeButton(onTap: _goToMyLocation),
          ),

          // 7. Funky Glassmorphism Bento Card
          if (_selected != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: _FaskesBentoCard(
                    faskes: _selected!,
                    onDismiss: _dismissCard,
                    onPhone: () => _launchPhone(_selected!.emergencyContact),
                    onDirections: () => _launchDirections(_selected!),
                  ),
                ),
              ),
            ),

          // 8. Tap-away overlay to dismiss bento card
          if (_selected != null)
            Positioned.fill(
              bottom: 320,
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
// Pulsing GPS Location Indicator
// ─────────────────────────────────────────────────────────────────────────────
class _PulseCircle extends StatefulWidget {
  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 8, end: 26).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _animation.value,
          height: _animation.value,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(
              ((26 - _animation.value) / 18).clamp(0.0, 0.4),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playful glassmorphic Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Cari Rumah Sakit, Klinik, Puskesmas... 🔍',
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Colorful Filter Chips
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

  static const _chipColors = [
    AppColors.primary,
    AppColors.primary,
    Color(0xFF7C3AED), // Violet
    Color(0xFF0EA5E9), // Cyan
  ];

  static const _emojis = ['✨ Semua', '🏥 RS', '🩺 Klinik', '🏠 Puskesmas'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, gap) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = i == selectedIndex;
          final color = _chipColors[i < _chipColors.length ? i : 0];
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? color : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? color : AppColors.border,
                  width: sel ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: sel
                        ? color.withOpacity(0.25)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  _emojis[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: sel ? Colors.white : AppColors.textSecondary,
                  ),
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
// Playful Count Badge
// ─────────────────────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            '$count Faskes TB Terdekat 📍',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Funky Location FAB
// ─────────────────────────────────────────────────────────────────────────────
class _LocateMeButton extends StatelessWidget {
  const _LocateMeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Card
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
              )
            ],
            border: Border.all(color: AppColors.error.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.error,
                size: 54,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal memuat data 😥',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                error,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Funky Glassmorphism Bento Card
// ─────────────────────────────────────────────────────────────────────────────
class _FaskesBentoCard extends StatelessWidget {
  const _FaskesBentoCard({
    required this.faskes,
    required this.onDismiss,
    required this.onPhone,
    required this.onDirections,
  });
  final FaskesModel faskes;
  final VoidCallback onDismiss;
  final VoidCallback onPhone;
  final VoidCallback onDirections;

  Color get _catColor {
    switch (faskes.category) {
      case 'Klinik':
        return const Color(0xFF7C3AED); // Violet
      case 'Puskesmas':
        return const Color(0xFF0EA5E9); // Cyan
      default:
        return AppColors.primary; // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
          )
        ],
        border: Border(
          top: BorderSide(
            color: _catColor.withOpacity(0.35),
            width: 4.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle lookalike
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _catColor,
                      _catColor.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _catColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faskes.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Badge(label: faskes.category, color: _catColor),
                        if (faskes.acceptsBpjs) ...[
                          const SizedBox(width: 6),
                          const _BpjsBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Mini service tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _catColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _catColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${faskes.tbServices.length} Layanan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _catColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Operating Hours & Emergency Contact Grid
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.access_time_rounded,
                  label: 'Jam Operasional',
                  value: faskes.operatingHours,
                  color: AppColors.primary,
                  bg: AppColors.primarySurface,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.phone_rounded,
                  label: 'Kontak Darurat',
                  value: faskes.emergencyContact,
                  color: const Color(0xFF0EA5E9),
                  bg: const Color(0xFFEFF9FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TBC Services List
          if (faskes.tbServices.isNotEmpty) ...[
            const Text(
              'Layanan TBC Tersedia 💉',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: faskes.tbServices.length,
                separatorBuilder: (context, gap) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final svc = faskes.tbServices[i];
                  return Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          svc.serviceName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          svc.description,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Call to Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPhone,
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text(
                    'Hubungi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _catColor,
                    side: BorderSide(color: _catColor, width: 2),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text(
                    'Petunjuk Arah',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _catColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    elevation: 4,
                    shadowColor: _catColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

// ─────────────────────────────────────────────────────────────────────────────
// Playful Stickers/Badges
// ─────────────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _BpjsBadge extends StatelessWidget {
  const _BpjsBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFF59E0B),
            width: 1.2,
          ),
        ),
        child: const Text(
          'BPJS ✓',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFFD97706),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Funky Information Tile
// ─────────────────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });
  final IconData icon;
  final String label, value;
  final Color color, bg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}
