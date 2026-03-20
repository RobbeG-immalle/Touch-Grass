import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/config/constants.dart';
import 'package:touch_grass/providers/posts_provider.dart';
import 'package:touch_grass/providers/settings_provider.dart';
import 'package:touch_grass/services/location_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final _captionCtrl = TextEditingController();
  String _visibility = AppConstants.visibilityFriends;
  bool _includeLocation = false;
  double? _lat;
  double? _lng;
  String _locationName = '';
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _visibility =
        context.read<SettingsProvider>().defaultVisibility;
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (xFile != null) {
      setState(() => _image = File(xFile.path));
    }
  }

  Future<void> _toggleLocation(bool value) async {
    if (value) {
      setState(() => _fetchingLocation = true);
      final pos = await LocationService().getCurrentPosition();
      if (pos != null) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
          _locationName =
              '${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)}';
        });
      }
      setState(() {
        _includeLocation = pos != null;
        _fetchingLocation = false;
      });
    } else {
      setState(() {
        _includeLocation = false;
        _lat = null;
        _lng = null;
        _locationName = '';
      });
    }
  }

  Future<void> _post() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo first')),
      );
      return;
    }

    final posts = context.read<PostsProvider>();
    final ok = await posts.createPost(
      imageFile: _image!,
      caption: _captionCtrl.text.trim(),
      visibility: _visibility,
      latitude: _includeLocation ? _lat : null,
      longitude: _includeLocation ? _lng : null,
      locationName: _includeLocation ? _locationName : '',
    );

    if (!mounted) return;
    if (ok) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌿 Posted! Streak updated.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(posts.error ?? 'Failed to post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: posts.isLoading ? null : _post,
            child: const Text(
              'Post',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker area
              GestureDetector(
                onTap: () => _showImageSourceSheet(),
                child: Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add photo',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: _showImageSourceSheet,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Caption
              TextField(
                controller: _captionCtrl,
                maxLines: 3,
                maxLength: 280,
                decoration: const InputDecoration(
                  hintText: 'Write a caption... (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Visibility
              _SectionLabel('Visibility'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: AppConstants.visibilityFriends,
                    label: Text('Friends'),
                    icon: Icon(Icons.group),
                  ),
                  ButtonSegment(
                    value: AppConstants.visibilityPublic,
                    label: Text('Public'),
                    icon: Icon(Icons.public),
                  ),
                ],
                selected: {_visibility},
                onSelectionChanged: (s) =>
                    setState(() => _visibility = s.first),
              ),
              const SizedBox(height: 16),

              // Location
              _SectionLabel('Location'),
              SwitchListTile(
                value: _includeLocation,
                onChanged: _fetchingLocation ? null : _toggleLocation,
                title: const Text('Include my location'),
                subtitle: _fetchingLocation
                    ? const Text('Getting location…')
                    : _locationName.isEmpty
                        ? null
                        : Text(_locationName),
                secondary: _fetchingLocation
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.location_on_outlined),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              if (posts.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  onPressed: _post,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Share your grass moment'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
