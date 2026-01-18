import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'services/cloudinary_service.dart';
import 'components/media_library_dialog.dart';

class AddLessonPage extends StatefulWidget {
  final VoidCallback onBack;
  final Map<String, dynamic>? lessonData;
  final ValueChanged<Map<String, dynamic>>? onSave;

  const AddLessonPage({
    super.key,
    required this.onBack,
    this.lessonData,
    this.onSave,
  });

  @override
  State<AddLessonPage> createState() => _AddLessonPageState();
}

class _AddLessonPageState extends State<AddLessonPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late TextEditingController _sequenceController;
  late TextEditingController _notesController;
  late TextEditingController _videoUrlController;
  late TextEditingController _thumbnailUrlController;

  String? _videoUrl;
  bool _isUploading = false;
  bool _isUploadingThumbnail = false;
  double _uploadProgress = 0.0;
  List<Map<String, String>> _resources = [];
  bool _isFreePreview = false;
  bool _isDraft = false;

  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize data
    final data = widget.lessonData ?? {};
    _titleController = TextEditingController(text: data['title'] ?? '');
    _durationController = TextEditingController(text: data['duration'] ?? '');
    _sequenceController = TextEditingController(
      text: data['sequence']?.toString() ?? '',
    );
    _notesController = TextEditingController(text: data['notes'] ?? '');
    _videoUrl = data['videoUrl'];
    _videoUrlController = TextEditingController(text: _videoUrl ?? '');
    _thumbnailUrlController = TextEditingController(
      text: data['thumbnail'] ?? '',
    );
    _isFreePreview = data['isFreePreview'] ?? false;
    _isDraft = data['isDraft'] ?? false;

    // Init video if exists
    if (_videoUrl != null && _videoUrl!.isNotEmpty) {
      _initializeVideo(_videoUrl!);
    }

    if (data['resources'] != null) {
      _resources = List<Map<String, String>>.from(
        (data['resources'] as List).map(
          (item) => Map<String, String>.from(item),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _durationController.dispose();
    _sequenceController.dispose();
    _notesController.dispose();
    _notesController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    _disposeVideo();
    super.dispose();
  }

  Future<void> _initializeVideo(String url) async {
    _disposeVideo();

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              "Error loading video",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );

      // Auto-fill duration if empty
      if (_durationController.text.isEmpty) {
        final duration = _videoPlayerController!.value.duration;
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        final formatted =
            "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

        _durationController.text = formatted;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Duration auto-filled: $formatted")),
        );
      }

      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  void _disposeVideo() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
  }

  void _saveLesson() {
    final lesson = {
      'title': _titleController.text,
      'duration': _durationController.text,
      'sequence': _sequenceController.text,
      'notes': _notesController.text,
      'videoUrl': _videoUrl,
      'thumbnail': _thumbnailUrlController.text,
      'resources': _resources,
      'isFreePreview': _isFreePreview,
      'isDraft': _isDraft,
    };

    if (widget.onSave != null) {
      widget.onSave!(lesson);
    }
    widget.onBack(); // Navigate back
  }

  Future<void> _pickAndUploadVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;

      if (fileBytes != null) {
        // Upload to Cloudinary with real progress simulation for now
        // (CloudinaryPublic doesn't expose stream progress easily in this package version,
        // so we use unlimited visual loader or partial simulation)

        // Simulate start
        setState(() => _uploadProgress = 0.1);

        final url = await CloudinaryService().uploadFile(
          fileBytes,
          fileName,
          folder: 'course_videos',
        );

        setState(() => _uploadProgress = 1.0); // Done

        if (url != null) {
          setState(() {
            _videoUrl = url;
            _videoUrlController.text = url;
            _isUploading = false;

            // Auto-generate thumbnail from Cloudinary video URL if empty
            if (_thumbnailUrlController.text.isEmpty &&
                url.contains('cloudinary.com')) {
              try {
                // Cloudinary allows changing extension to .jpg to get video frame
                String thumbUrl = url;
                if (thumbUrl.endsWith('.mp4')) {
                  thumbUrl = thumbUrl.replaceAll('.mp4', '.jpg');
                } else if (thumbUrl.endsWith('.mov')) {
                  thumbUrl = thumbUrl.replaceAll('.mov', '.jpg');
                } else if (thumbUrl.endsWith('.avi')) {
                  thumbUrl = thumbUrl.replaceAll('.avi', '.jpg');
                } else if (thumbUrl.endsWith('.webm')) {
                  thumbUrl = thumbUrl.replaceAll('.webm', '.jpg');
                } else {
                  // Fallback: append .jpg
                  thumbUrl = "$thumbUrl.jpg";
                }
                _thumbnailUrlController.text = thumbUrl;
              } catch (e) {
                // Ignore formatting errors
              }
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Uploaded to Cloudinary: $url")),
            );
          }
        } else {
          setState(() => _isUploading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Upload failed. Check .env credentials."),
              ),
            );
          }
        }
      } else {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickAndUploadThumbnail() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() => _isUploadingThumbnail = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Uploading thumbnail...')));

      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;

      if (fileBytes != null) {
        final url = await CloudinaryService().uploadFile(
          fileBytes,
          fileName,
          folder: 'lesson_thumbnails',
        );

        if (url != null) {
          setState(() {
            _thumbnailUrlController.text = url;
            _isUploadingThumbnail = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thumbnail uploaded!')),
            );
          }
        } else {
          setState(() => _isUploadingThumbnail = false);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Upload failed')));
          }
        }
      } else {
        setState(() => _isUploadingThumbnail = false);
      }
    }
  }

  Future<void> _pickAndAddResource() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _isUploading = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Uploading resource...')));

      try {
        final fileBytes = result.files.first.bytes;
        final fileName = result.files.first.name;

        if (fileBytes != null) {
          final url = await CloudinaryService().uploadFile(
            fileBytes,
            fileName,
            folder: 'course_resources',
          );

          if (url != null) {
            setState(() {
              _resources.add({
                "name": fileName,
                "size":
                    "${(result.files.first.size / 1024 / 1024).toStringAsFixed(2)} MB",
                "url": url,
              });
              _isUploading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resource uploaded successfully')),
              );
            }
          } else {
            throw Exception("Upload returned null");
          }
        }
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload resource: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          widget.lessonData == null ? "Add New Lesson" : "Edit Lesson",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _saveLesson,
              child: const Text(
                "Save Lesson",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF4A89FF),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A89FF),
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
          indicatorColor: const Color(0xFF4A89FF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Iconsax.document), text: "Details"),
            Tab(icon: Icon(Iconsax.video), text: "Video"),
            Tab(icon: Icon(Iconsax.folder_open), text: "Resources"),
            Tab(icon: Icon(Iconsax.note), text: "Notes"),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(isDark),
              _buildVideoTab(isDark),
              _buildResourcesTab(isDark),
              _buildNotesTab(isDark),
            ],
          ),
          if (_isUploading)
            Align(
              alignment: Alignment.bottomRight,
              child:
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(16),
                    width: 300,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _uploadProgress,
                                strokeWidth: 4,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade100,
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF4A89FF),
                                ),
                              ),
                              Text(
                                "${(_uploadProgress * 100).toInt()}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Uploading Video...",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Please do not close this window",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(
                    begin: 1,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildContainer(isDark, [
            _buildSectionTitle("Lesson Information", isDark),
            const SizedBox(height: 24),
            _buildTextField(
              "Lesson Title",
              "e.g., Intro to Candlesticks",
              isDark,
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Duration",
                    "MM:SS",
                    isDark,
                    controller: _durationController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    "Sequence No.",
                    "e.g., 1",
                    isDark,
                    controller: _sequenceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSwitchTile(
              "Free Preview",
              "Allow students to watch this lesson without purchasing",
              _isFreePreview,
              isDark,
              (v) => setState(() => _isFreePreview = v),
            ),
            _buildSwitchTile(
              "Draft Mode",
              "Hide this lesson from students",
              _isDraft,
              isDark,
              (v) => setState(() => _isDraft = v),
            ),
          ]),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildVideoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildContainer(isDark, [
            _buildSectionTitle("Video Content", isDark),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadVideo,
              child: Container(
                width: double.infinity,
                height: 300,
                padding: _chewieController != null
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child:
                    _chewieController != null &&
                        _chewieController!
                            .videoPlayerController
                            .value
                            .isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Chewie(controller: _chewieController!),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4A89FF,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.video_play,
                              size: 40,
                              color: Color(0xFF4A89FF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Upload Video File",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            "MP4, WebM up to 2GB",
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (c) => MediaLibraryDialog(
                    onSelect: (url) async {
                      setState(() {
                        _videoUrl = url;
                        _videoUrlController.text = url;
                      });
                      _initializeVideo(url);
                    },
                    allowedType: 'video',
                  ),
                );
              },
              icon: const Icon(Iconsax.gallery),
              label: const Text("Select Video from Library"),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              "Video URL",
              "https://vimeo.com/...",
              isDark,
              controller: _videoUrlController,
              onChanged: (v) => _videoUrl = v,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Lesson Thumbnail", isDark),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isUploadingThumbnail ? null : _pickAndUploadThumbnail,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                  ),
                  image: _thumbnailUrlController.text.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_thumbnailUrlController.text),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _isUploadingThumbnail
                    ? const Center(child: CircularProgressIndicator())
                    : _thumbnailUrlController.text.isNotEmpty
                    ? Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _pickAndUploadThumbnail,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.image,
                            size: 32,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Upload Thumbnail Image",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ]),
        ],
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildResourcesTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildContainer(isDark, [
          _buildSectionTitle("Downloadable Resources", isDark),
          const SizedBox(height: 8),
          Text(
            "Attach PDFs, Excel sheets, or Zip files for students.",
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
          ),
          const SizedBox(height: 24),

          // Attachments list
          for (int i = 0; i < _resources.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAttachmentItem(
                _resources[i]["name"]!,
                _resources[i]["size"]!,
                isDark,
                () {
                  setState(() {
                    _resources.removeAt(i);
                  });
                },
              ),
            ),

          if (_resources.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: Text(
                  "No resources added yet",
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey,
                  ),
                ),
              ),
            ),

          if (_resources.isNotEmpty) const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => _pickAndAddResource(),
            icon: const Icon(Iconsax.add),
            label: const Text("Add Resource"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => MediaLibraryDialog(
                  onSelect: (url) async {
                    setState(() {
                      _resources.add({
                        "name": "Library Item",
                        "size": "-",
                        "url": url,
                      });
                    });
                  },
                  allowedType: 'pdf',
                ),
              );
            },
            icon: const Icon(Iconsax.gallery),
            label: const Text("Add Resource from Library"),
          ),
        ]).animate().fadeIn().slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildNotesTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildContainer(isDark, [
        _buildSectionTitle("Lecture Notes", isDark),
        const SizedBox(height: 24),
        _buildTextField(
          "Article / Text Content",
          "Write your lecture notes here... supports Markdown.",
          isDark,
          maxLines: 15,
          controller: _notesController,
        ),
      ]).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildContainer(bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    bool isDark, {
    int maxLines = 1,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[800],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white24 : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? Colors.black12 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A89FF),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    bool isDark,
    ValueChanged<bool>? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF4A89FF),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(
    String name,
    String size,
    bool isDark,
    VoidCallback onDelete,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Iconsax.document_text,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
