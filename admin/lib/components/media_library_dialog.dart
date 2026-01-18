import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../services/cloudinary_service.dart';

class MediaLibraryDialog extends StatefulWidget {
  final Future<void> Function(String url) onSelect;
  final String allowedType; // "image", "video", "pdf", "all"

  const MediaLibraryDialog({
    super.key,
    required this.onSelect,
    this.allowedType = 'all',
  });

  @override
  State<MediaLibraryDialog> createState() => _MediaLibraryDialogState();
}

class _MediaLibraryDialogState extends State<MediaLibraryDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Set initial tab based on allowedType
    if (widget.allowedType == 'image') _tabController.index = 1;
    if (widget.allowedType == 'video') _tabController.index = 2;
    if (widget.allowedType == 'pdf') _tabController.index = 3;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  Future<void> _pickAndUpload() async {
    FileType pickType = FileType.any;
    String typeFilter = 'other'; // "image", "video", "pdf", "other"

    int tabIndex = _tabController.index;

    // Override if we are selecting from a tab
    if (tabIndex == 1) {
      // Images
      pickType = FileType.image;
      typeFilter = 'image';
    } else if (tabIndex == 2) {
      // Videos
      pickType = FileType.video;
      typeFilter = 'video';
    } else if (tabIndex == 3) {
      // Docs
      pickType = FileType.any;
      typeFilter = 'pdf';
    } else {
      // "All" tab: fallback to allowedType
      if (widget.allowedType == 'image') {
        pickType = FileType.image;
        typeFilter = 'image';
      } else if (widget.allowedType == 'video') {
        pickType = FileType.video;
        typeFilter = 'video';
      } else if (widget.allowedType == 'pdf') {
        pickType = FileType.any;
        typeFilter = 'pdf';
      }
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: pickType,
      allowedExtensions: (pickType == FileType.custom || (tabIndex == 3))
          ? ['pdf', 'doc', 'docx']
          : null,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() => _isUploading = true);

      try {
        final file = result.files.single;

        // Auto-detect type
        String finalType = typeFilter;
        if (tabIndex == 0 && widget.allowedType == 'all') {
          final ext = file.extension?.toLowerCase() ?? '';
          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext))
            finalType = 'image';
          else if (['mp4', 'mov', 'avi', 'webm'].contains(ext))
            finalType = 'video';
          else if (['pdf'].contains(ext))
            finalType = 'pdf';
          else
            finalType = 'other';
        }

        final url = await CloudinaryService().uploadFile(
          file.bytes!,
          file.name,
          folder: "library/$finalType",
        );

        if (url != null) {
          await FirebaseFirestore.instance.collection('media').add({
            'url': url,
            'name': file.name,
            'type': finalType,
            'createdAt': FieldValue.serverTimestamp(),
            'size': file.size,
          });

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Upload successful!")));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Upload failed: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Media Library",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "Select items from your uploads",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUpload,
                      icon: _isUploading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(_isUploading ? "Uploading..." : "Upload New"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A89FF),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4A89FF),
              unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
              indicatorColor: const Color(0xFF4A89FF),
              tabs: const [
                Tab(text: "All", icon: Icon(Iconsax.grid_3)),
                Tab(text: "Images", icon: Icon(Iconsax.image)),
                Tab(text: "Videos", icon: Icon(Iconsax.video)),
                Tab(text: "Documents", icon: Icon(Iconsax.document)),
              ],
            ),
            const SizedBox(height: 24),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMediaGrid("all"),
                  _buildMediaGrid("image"),
                  _buildMediaGrid("video"),
                  _buildMediaGrid("pdf"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(String type) {
    Query query = FirebaseFirestore.instance
        .collection('media')
        .orderBy('createdAt', descending: true);

    if (type != 'all') {
      query = query.where('type', isEqualTo: type);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No media.", style: TextStyle(color: Colors.grey)),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final url = data['url'] as String;
            final itemType = data['type'] as String;
            final name = data['name'] ?? 'Untitled';

            return _MediaItem(
              url: url,
              type: itemType,
              name: name,
              onTap: () {
                widget.onSelect(url);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class _MediaItem extends StatelessWidget {
  final String url;
  final String type;
  final String name;
  final VoidCallback onTap;

  const _MediaItem({
    required this.url,
    required this.type,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          color: Colors.grey.withValues(alpha: 0.1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            if (type == 'image')
              Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (c, o, s) =>
                    const Center(child: Icon(Icons.error)),
              )
            else if (type == 'video')
              Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    url.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '.jpg'),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.video_library,
                          size: 40,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              )
            else
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.document, size: 40, color: Colors.orange),
                    Text(
                      "DOC",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: Colors.black54,
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
