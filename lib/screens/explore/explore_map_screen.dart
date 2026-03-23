import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/config/constants.dart';
import 'package:touch_grass/models/post_model.dart';
import 'package:touch_grass/providers/posts_provider.dart';
import 'package:touch_grass/services/location_service.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  GoogleMapController? _mapController;
  int _filterDays = 7; // 1 = Today, 7 = Week, 30 = Month
  bool _myLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    context.read<PostsProvider>().subscribeToPublicPosts();
    _initLocationPermission();
  }

  Future<void> _initLocationPermission() async {
    final enabled = await LocationService().ensurePermission();
    if (!mounted) return;
    setState(() => _myLocationEnabled = enabled);
  }

  Set<Marker> _buildMarkers(List<PostModel> posts) {
    final now = DateTime.now();
    final filtered = posts.where((p) {
      if (!p.hasLocation) return false;
      final diff = now.difference(p.createdAt).inDays;
      return diff <= _filterDays;
    });

    return filtered.map((p) {
      return Marker(
        markerId: MarkerId(p.postId),
        position: LatLng(p.latitude!, p.longitude!),
        infoWindow: InfoWindow(
          title: p.caption.isNotEmpty ? p.caption : 'Grass touched 🌿',
          snippet: p.locationName.isNotEmpty ? p.locationName : null,
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostsProvider>().publicPosts;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(
                AppConstants.defaultMapLat,
                AppConstants.defaultMapLng,
              ),
              zoom: AppConstants.defaultMapZoom,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: _buildMarkers(posts),
            myLocationButtonEnabled: _myLocationEnabled,
            myLocationEnabled: _myLocationEnabled,
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _FilterChips(
              selected: _filterDays,
              onChanged: (d) => setState(() => _filterDays = d),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _chip(context, 'Today', 1),
            const SizedBox(width: 6),
            _chip(context, 'This Week', 7),
            const SizedBox(width: 6),
            _chip(context, 'This Month', 30),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, int days) {
    return FilterChip(
      label: Text(label),
      selected: selected == days,
      onSelected: (_) => onChanged(days),
    );
  }
}
