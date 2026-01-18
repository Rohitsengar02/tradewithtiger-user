import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'add_lesson_page.dart';
import 'services/course_service.dart';
import 'services/cloudinary_service.dart';
import 'services/gemini_service.dart';
import 'components/media_library_dialog.dart';

class CreateCoursePage extends StatefulWidget {
  final VoidCallback onBack;
  final String? courseId;
  final Map<String, dynamic>? initialData;

  const CreateCoursePage({
    super.key,
    required this.onBack,
    this.courseId,
    this.initialData,
  });

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  // Use generic Map for curriculum to support detailed structure
  final List<Map<String, dynamic>> _curriculum = [];
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _durationController;
  late TextEditingController _levelController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _thumbnailUrlController;
  late TextEditingController _introVideoUrlController;
  late TextEditingController _videoThumbnailUrlController;

  final List<String> _availableBadges = [
    'Best Seller',
    'Highest Rated',
    'New',
    'Trending',
    'Featured',
    'Beginner Friendly',
  ];
  List<String> _selectedBadges = [];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};

    _titleController = TextEditingController(text: data['title'] ?? '');
    _subtitleController = TextEditingController(text: data['subtitle'] ?? '');
    _durationController = TextEditingController(text: data['duration'] ?? '');
    _levelController = TextEditingController(text: data['level'] ?? '');
    _descriptionController = TextEditingController(
      text: data['description'] ?? '',
    );
    _priceController = TextEditingController(
      text: data['price']?.toString() ?? '',
    );
    _discountPriceController = TextEditingController(
      text: data['discountPrice']?.toString() ?? '',
    );
    _thumbnailUrlController = TextEditingController(
      text: data['thumbnailUrl'] ?? '',
    );
    _introVideoUrlController = TextEditingController(
      text: data['introVideoUrl'] ?? '',
    );
    _videoThumbnailUrlController = TextEditingController(
      text: data['videoThumbnailUrl'] ?? '',
    );
    if (data['badges'] != null) {
      _selectedBadges = List<String>.from(data['badges']);
    }

    if (data['curriculum'] != null) {
      for (var item in data['curriculum']) {
        if (item is Map) {
          _curriculum.add(Map<String, dynamic>.from(item));
        }
      }
    }

    _isPublished = data['isPublished'] ?? true;
    _isFeatured = data['isFeatured'] ?? false;
    _allowComments = data['allowComments'] ?? true;
  }

  // Settings State
  bool _isPublished = true;
  bool _isFeatured = false;
  bool _allowComments = true;
  bool _isUploadingThumbnail = false;
  bool _isGeneratingAI = false;
  Uint8List? _thumbnailBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _durationController.dispose();
    _levelController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _thumbnailUrlController.dispose();
    _introVideoUrlController.dispose();
    _videoThumbnailUrlController.dispose();
    super.dispose();
  }

  void _publishCourse() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publishing course...')));

      try {
        final courseData = {
          'title': _titleController.text,
          'subtitle': _subtitleController.text,
          'duration': _durationController.text,
          'level': _levelController.text,
          'description': _descriptionController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'discountPrice': double.tryParse(_discountPriceController.text),
          'introVideoUrl': _introVideoUrlController.text,
          'videoThumbnailUrl': _videoThumbnailUrlController.text,
          'thumbnailUrl': _thumbnailUrlController.text,
          'isPublished': _isPublished,
          'isFeatured': _isFeatured,
          'allowComments': _allowComments,
          'badges': _selectedBadges,
          'curriculum': _curriculum,
        };

        if (widget.courseId != null) {
          await CourseService().updateCourse(widget.courseId!, courseData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course updated successfully!'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        } else {
          await CourseService().createCourse(courseData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course published successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (mounted) {
          Future.delayed(const Duration(seconds: 1), widget.onBack);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
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

      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;

      if (fileBytes != null) {
        setState(() => _thumbnailBytes = fileBytes); // Show local preview

        // Upload to Cloudinary
        final url = await CloudinaryService().uploadFile(
          fileBytes,
          fileName,
          folder: 'course_thumbnails',
        );

        if (url != null) {
          setState(() {
            _thumbnailUrlController.text = url;
            _isUploadingThumbnail = false;
          });
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

  Future<void> _pickAndUploadVideoThumbnail() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      if (!mounted) return;
      setState(() => _isUploadingThumbnail = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading video thumbnail...')),
      );

      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;

      if (fileBytes != null) {
        final url = await CloudinaryService().uploadFile(
          fileBytes,
          fileName,
          folder: 'course_video_thumbnails',
        );

        if (url != null) {
          setState(() {
            _videoThumbnailUrlController.text = url;
            _isUploadingThumbnail = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video thumbnail uploaded!')),
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

  Future<void> _generateWithAI() async {
    final TextEditingController promptController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          title: Text(
            "AI Course Generator ✨",
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter a topic, and our AI will create a full course outline for you.",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: promptController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "e.g., Advanced Forex Trading Strategies...",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _runAiGeneration(promptController.text);
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A89FF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runAiGeneration(String topic) async {
    if (topic.isEmpty) return;

    setState(() => _isGeneratingAI = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI is working its magic... ✨')),
    );

    try {
      final data = await GeminiService().generateCourseOutline(topic);

      setState(() {
        _titleController.text = data['title'] ?? '';
        _subtitleController.text = data['subtitle'] ?? '';
        _durationController.text = data['duration'] ?? '';
        _levelController.text = data['level'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _priceController.text = data['price']?.toString() ?? '';
        _discountPriceController.text = data['discountPrice']?.toString() ?? '';

        _curriculum.clear();
        if (data['curriculum'] != null) {
          for (var item in data['curriculum']) {
            if (item is Map) {
              _curriculum.add(Map<String, dynamic>.from(item));
            }
          }
        }
        _isGeneratingAI = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course generated successfully! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGeneratingAI = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editCurriculumItem(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLessonPage(
          onBack: () => Navigator.pop(context),
          lessonData: _curriculum[index],
          onSave: (updatedData) {
            setState(() {
              _curriculum[index] = updatedData;
            });
          },
        ),
      ),
    );
  }

  void _showAddCurriculumDialog(BuildContext context, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLessonPage(
          onBack: () => Navigator.pop(context),
          onSave: (newData) {
            setState(() {
              _curriculum.add(newData);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back & Title
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  // Use expanded to avoid overflow
                  child: Text(
                    widget.courseId != null
                        ? "Edit Course"
                        : "Create New Course",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                // AI Button
                ElevatedButton.icon(
                  onPressed: _isGeneratingAI ? null : _generateWithAI,
                  icon: _isGeneratingAI
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, color: Colors.white),
                  label: Text(
                    _isGeneratingAI ? "Generating..." : "AI Generate",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E44AD), // Purple for AI
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Form Layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildBasicInfo(context, isDark),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildMediaSection(context, isDark),
                            const SizedBox(height: 24),
                            _buildSettingsSection(context, isDark),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildBasicInfo(context, isDark),
                      const SizedBox(height: 24),
                      _buildMediaSection(context, isDark),
                      const SizedBox(height: 24),
                      _buildSettingsSection(context, isDark),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          _buildSectionTitle("Course Details", isDark),
          const SizedBox(height: 24),
          _buildTextField(
            "Course Title",
            "e.g. Masterclass in Technical Analysis",
            isDark,
            controller: _titleController,
            validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "Subtitle",
            "A short, catchy tagline for your course",
            isDark,
            controller: _subtitleController,
            validator: (v) =>
                v?.isEmpty == true ? 'Subtitle is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Duration",
                  "e.g. 4h 30m",
                  isDark,
                  controller: _durationController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Level",
                  "e.g. Beginner",
                  isDark,
                  controller: _levelController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "About Course",
            "Write a detailed description explaining what students will learn...",
            isDark,
            maxLines: 5,
            controller: _descriptionController,
            validator: (v) =>
                v?.isEmpty == true ? 'Description is required' : null,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Price (₹)",
                  "4999",
                  isDark,
                  controller: _priceController,
                  isNumeric: true,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Required';
                    if (double.tryParse(v!) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Discount Price (₹)",
                  "2999",
                  isDark,
                  controller: _discountPriceController,
                  isNumeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle("Curriculum & Content", isDark),
          const SizedBox(height: 8),
          Text(
            "Manage your lessons, videos, and resources.",
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
          ),
          const SizedBox(height: 24),

          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _curriculum.removeAt(oldIndex);
                _curriculum.insert(newIndex, item);
              });
            },
            children: [
              for (int i = 0; i < _curriculum.length; i++)
                Container(
                  key: ValueKey(
                    _curriculum[i]['title'],
                  ), // Ensure unique keys if parsing same prompts
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildCurriculumItem(
                    _curriculum[i], // Pass map
                    i, // index to edit
                    isDark,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showAddCurriculumDialog(context, isDark),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text("Add New Lesson"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                side: BorderSide(
                  color: const Color(0xFF4A89FF).withValues(alpha: 0.5),
                ),
                foregroundColor: const Color(0xFF4A89FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: -0.1),
    );
  }

  Widget _buildMediaSection(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          _buildSectionTitle("Course Thumbnail", isDark),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isUploadingThumbnail ? null : _pickAndUploadThumbnail,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                image: _thumbnailBytes != null
                    ? DecorationImage(
                        image: MemoryImage(_thumbnailBytes!),
                        fit: BoxFit.cover,
                      )
                    : (_thumbnailUrlController.text.isNotEmpty)
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A89FF,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.image,
                            size: 32,
                            color: Color(0xFF4A89FF),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Click to Upload Thumbnail",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Recommended size: 1280x720",
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey[500],
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
                      _thumbnailUrlController.text = url;
                      _thumbnailBytes =
                          null; // Clear local preview if remote selected
                    });
                  },
                  allowedType: 'image',
                ),
              );
            },
            icon: const Icon(Iconsax.gallery),
            label: const Text("Select from Library"),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            "Intro Video URL (Optional)",
            "https://...",
            isDark,
            controller: _introVideoUrlController,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle("Course Video Thumbnail (Optional)", isDark),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickAndUploadVideoThumbnail,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: _videoThumbnailUrlController.text.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam,
                          size: 48,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Video Thumbnail Uploaded",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(
                            () => _videoThumbnailUrlController.clear(),
                          ),
                          child: const Text("Remove"),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.video_library,
                          size: 32,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Click to Upload Video Thumbnail",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[800],
                            fontWeight: FontWeight.w600,
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
                      _videoThumbnailUrlController.text = url;
                    });
                  },
                  allowedType: 'video',
                ),
              );
            },
            icon: const Icon(Iconsax.gallery),
            label: const Text("Select from Library"),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildSettingsSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: [
              _buildSectionTitle("Settings", isDark),
              const SizedBox(height: 16),
              _buildSwitchTile(
                "Publish Course",
                "Make visible to students",
                _isPublished,
                isDark,
                (val) => setState(() => _isPublished = val),
              ),
              _buildSwitchTile(
                "Featured",
                "Show on home page",
                _isFeatured,
                isDark,
                (val) => setState(() => _isFeatured = val),
              ),
              _buildSwitchTile(
                "Allow Comments",
                "Enable discussion",
                _allowComments,
                isDark,
                (val) => setState(() => _allowComments = val),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Badges", isDark),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableBadges.map((badge) {
                  final isSelected = _selectedBadges.contains(badge);
                  return FilterChip(
                    label: Text(badge),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedBadges.add(badge);
                        } else {
                          _selectedBadges.remove(badge);
                        }
                      });
                    },
                    selectedColor: const Color(
                      0xFF4A89FF,
                    ).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF4A89FF),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF4A89FF)
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _publishCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A89FF),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: const Color(0xFF4A89FF).withValues(alpha: 0.4),
              elevation: 10,
            ),
            child: Text(
              widget.courseId != null ? "Update Course" : "Publish Course",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    bool isDark, {
    int maxLines = 1,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool isNumeric = false,
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
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
              : [],
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white24 : Colors.grey[400],
              fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildCurriculumItem(
    Map<String, dynamic> lesson,
    int index,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            color: isDark ? Colors.white24 : Colors.grey,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.video,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'] ?? 'Untitled Lesson',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                if (lesson['duration'] != null && lesson['duration'].isNotEmpty)
                  Text(
                    lesson['duration'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editCurriculumItem(index),
            icon: Icon(
              Iconsax.edit,
              size: 18,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _curriculum.removeAt(index);
              });
            },
            icon: const Icon(Iconsax.trash, size: 18, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
