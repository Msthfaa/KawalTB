import 'dart:async';
import 'dart:ui';
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
  bool _loading = false;
  String? _error;
  final _searchCtrl = TextEditingController();
  bool _showSearchAreaButton = false;
  bool _isSatellite = false; 
  
  // Filters
  static const _filters = ['Semua', 'Rumah Sakit', 'Klinik', 'Puskesmas'];
  int _filterIndex = 0;

  StreamSubscription<Position>? _positionStream;

  // ── Animation Controllers ───────────────────────────────────────────────────
  late AnimationController _cardCtrl;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic),
    );
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut),
    );
    
    _startLocationStream();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
           _searchInArea();
        }
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
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
      duration: const Duration(milliseconds: 800),
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

  // ── User Location Stream ───────────────────────────────────────────────────
  Future<void> _startLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }
    if (perm == LocationPermission.deniedForever) return;

    final initialPos = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _myLocation = LatLng(initialPos.latitude, initialPos.longitude);
      });
      _buildMarkers();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _myLocation = LatLng(position.latitude, position.longitude);
        });
        _buildMarkers();
      }
    });
  }

  // ── Fetch Data ──────────────────────────────────────────────────────────────
  Future<void> _searchInArea() async {
    if (!mounted) return;
    setState(() {
      _showSearchAreaButton = false;
      _loading = true;
      _error = null;
    });

    try {
      final bounds = _mapController.camera.visibleBounds;
      final minLat = bounds.southWest.latitude;
      final maxLat = bounds.northEast.latitude;
      final minLng = bounds.southWest.longitude;
      final maxLng = bounds.northEast.longitude;

      final data = await FaskesService.instance.fetchInBounds(minLat, maxLat, minLng, maxLng);
      
      if (!mounted) return;
      setState(() {
        _allFaskes = data;
        _loading = false;
      });
      _applyFilter();
      
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tidak ada faskes di area ini.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: ${e.toString()}';
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allFaskes.where((f) {
        final matchCat = _filterIndex == 0 || f.category == _filters[_filterIndex];
        final matchQ = q.isEmpty || f.name.toLowerCase().contains(q);
        return matchCat && matchQ;
      }).toList();
    });
    _buildMarkers();
  }


  // ── Marker Builder ──────────────────────────────────
  void _buildMarkers() {
    final markers = <Marker>[];

    for (final f in _filtered) {
      final isSelected = _selected?.id == f.id;
      final category = f.category;

      Color pinColor;
      IconData iconData;
      if (category == 'Rumah Sakit') {
        pinColor = const Color(0xFFE53935);
      } else if (category == 'Klinik') {
        pinColor = const Color(0xFF1E88E5);
      } else {
        pinColor = const Color(0xFF43A047);
      }
      
      // Select icons that look more premium
      iconData = Icons.local_hospital_rounded;

      markers.add(Marker(
        point: LatLng(f.latitude, f.longitude),
        width: isSelected ? 65.0 : 45.0,
        height: isSelected ? 65.0 : 45.0,
        child: GestureDetector(
          onTap: () => _selectFaskes(f),
          child: AnimatedScale(
            scale: isSelected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isSelected ? 6 : 5),
                  decoration: BoxDecoration(
                    color: isSelected ? pinColor : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: pinColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(
                      color: isSelected ? Colors.white : pinColor,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: isSelected ? Colors.white : pinColor,
                    size: isSelected ? 24 : 16,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: pinColor,
                      shape: BoxShape.circle,
                    ),
                  )
              ],
            ),
          ),
        ),
      ));
    }

    // User Location Marker
    if (_myLocation != null) {
      markers.add(Marker(
        point: _myLocation!,
        width: 24,
        height: 24,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
        ),
      ));
    }

    setState(() => _markers = markers);
  }

  void _selectFaskes(FaskesModel f) {
    setState(() {
      _selected = f;
      _showSearchAreaButton = false; // Hide search button when card is open
    });
    _buildMarkers(); 
    _cardCtrl.forward(from: 0);
    // Center slightly below the marker so the card doesn't cover it
    _animatedMapMove(LatLng(f.latitude - 0.005, f.longitude), 14.5);
  }

  void _dismissCard() {
    _cardCtrl.reverse().then((_) {
      if (mounted) {
        setState(() {
          _selected = null;
        });
        _buildMarkers(); 
      }
    });
  }

  Future<void> _goToMyLocation() async {
    if (_myLocation != null) {
      _animatedMapMove(_myLocation!, 14.5);
    }
  }

  Future<void> _launchDirections(FaskesModel f) async {
    final intentUri = Uri.parse('google.navigation:q=${f.latitude},${f.longitude}&mode=d');
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${f.latitude},${f.longitude}');
    
    try {
      final launched = await launchUrl(intentUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
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
          // 1. Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _surabayaCenter,
              initialZoom: 12.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && !_showSearchAreaButton && _selected == null) {
                  setState(() => _showSearchAreaButton = true);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite 
                  ? 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}'
                  : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.kawaltb',
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),

          // 2a. Smooth Gradient Blur Background (Behind Header)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 160,
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
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
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.85),
                            Colors.white.withOpacity(0.4),
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

          // 2b. Premium Header Panel Content
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PremiumSearchBar(
                  controller: _searchCtrl,
                  onChanged: (_) => _applyFilter(),
                ),
                const SizedBox(height: 12),
                _PremiumFilterChips(
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

          // 3. Compact "Cari di area ini" Button
          if (_showSearchAreaButton && _selected == null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 150, // Just below glass header
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _searchInArea,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.saved_search, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          const Text(
                            'Cari di area ini',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Result Count Indicator (Bottom Left)
          if (!_loading && _error == null && _filtered.isNotEmpty && _selected == null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${_filtered.length} Faskes',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading overlay
          if (_loading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
            ),

          if (_error != null)
            Center(child: _ErrorCard(error: _error!, onRetry: _searchInArea)),

          // Map Control FABs
          Positioned(
            right: 16,
            bottom: _selected != null ? 320 : (MediaQuery.of(context).padding.bottom + 95), // Move up if card is shown or above navbar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'mapStyle',
                  onPressed: () {
                    setState(() {
                      _isSatellite = !_isSatellite;
                    });
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Icon(_isSatellite ? Icons.map_rounded : Icons.satellite_alt_rounded, size: 20),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'locateMe',
                  onPressed: _goToMyLocation,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),

          // Tap-away overlay
          if (_selected != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismissCard,
                behavior: HitTestBehavior.translucent,
              ),
            ),

          // Selected Faskes Floating Card
          if (_selected != null)
            Positioned(
              bottom: 24,
              left: 12,
              right: 12,
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: _PremiumFaskesCard(
                    faskes: _selected!,
                    onDismiss: _dismissCard,
                    onPhone: () => _launchPhone(_selected!.emergencyContact),
                    onDirections: () => _launchDirections(_selected!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Components
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumSearchBar extends StatelessWidget {
  const _PremiumSearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
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
          hintText: 'Cari fasilitas kesehatan...',
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.search_rounded, color: AppColors.primary),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _PremiumFilterChips extends StatelessWidget {
  const _PremiumFilterChips({
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
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected 
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Coba Lagi'),
          )
        ],
      ),
    );
  }
}

class _PremiumFaskesCard extends StatelessWidget {
  const _PremiumFaskesCard({
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
        return const Color(0xFF1E88E5);
      case 'Puskesmas':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _catColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.local_hospital_rounded, color: _catColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faskes.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              faskes.category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _catColor,
                              ),
                            ),
                            if (faskes.acceptsBpjs) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: const Text(
                                  'BPJS',
                                  style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Close Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onDismiss,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Key Info Row
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.access_time_rounded,
                      title: 'Jam Buka',
                      subtitle: faskes.operatingHours,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.phone_rounded,
                      title: 'Telepon',
                      subtitle: faskes.emergencyContact,
                    ),
                  ),
                ],
              ),
              
              if (faskes.tbServices.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Layanan TBC',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: faskes.tbServices.map((svc) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        svc.serviceName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPhone,
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Hubungi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDirections,
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: const Text('Rute'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
