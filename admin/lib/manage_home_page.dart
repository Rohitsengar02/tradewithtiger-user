import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/cloudinary_service.dart';
import 'services/home_page_settings_service.dart';
import 'services/course_service.dart';
import 'components/media_library_dialog.dart';

class ManageHomePage extends StatefulWidget {
  const ManageHomePage({super.key});

  @override
  State<ManageHomePage> createState() => _ManageHomePageState();
}

class _ManageHomePageState extends State<ManageHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _service = HomePageSettingsService();
  final _courseService = CourseService();
  bool _isLoading = false;

  // Header Section
  final _headerTitleController = TextEditingController();
  final _headerSubtitleController = TextEditingController();
  final _headerVideoController = TextEditingController();

  // Lists
  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _bundles = [];
  List<Map<String, dynamic>> _learningPaths = [];
  List<Map<String, dynamic>> _premiumTiers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final data = await _service.getHomePageSettingsOnce();
    setState(() {
      _headerTitleController.text =
          data['headerTitle'] ?? "Let's find your\nbest course!";
      _headerSubtitleController.text = data['headerSubtitle'] ?? "Hey there!";
      _headerVideoController.text = data['headerVideoUrl'] ?? '';

      _mentors = List<Map<String, dynamic>>.from(data['mentors'] ?? []);
      _bundles = List<Map<String, dynamic>>.from(data['bundles'] ?? []);
      _learningPaths = List<Map<String, dynamic>>.from(
        data['learningPaths'] ?? [],
      );
      _premiumTiers = List<Map<String, dynamic>>.from(
        data['premiumTiers'] ?? [],
      );
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.updateHomePageSettings({
        'headerTitle': _headerTitleController.text,
        'headerSubtitle': _headerSubtitleController.text,
        'headerVideoUrl': _headerVideoController.text,
        'mentors': _mentors,
        'bundles': _bundles,
        'learningPaths': _learningPaths,
        'premiumTiers': _premiumTiers,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Home Builder"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A89FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF4A89FF),
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
          indicatorColor: const Color(0xFF4A89FF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Header & Hero", icon: Icon(Iconsax.video_circle)),
            Tab(text: "Top Mentors", icon: Icon(Iconsax.teacher)),
            Tab(text: "Popular Bundles", icon: Icon(Iconsax.box_1)),
            Tab(text: "Learning Path", icon: Icon(Iconsax.route_square)),
            Tab(text: "Premium Tiers", icon: Icon(Iconsax.crown_1)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent swipe conflict
                children: [
                  _buildHeaderTab(isDark),
                  _buildListTab(
                    "Mentors",
                    "Showcase your top instructors",
                    _mentors,
                    (item, onSave) => _MentorDialog(item: item, onSave: onSave),
                    (newItem) => _addItem(_mentors, newItem),
                    (item) => _deleteItem(_mentors, item),
                    isDark,
                  ),
                  _buildListTab(
                    "Bundles",
                    "Highlight course packages",
                    _bundles,
                    (item, onSave) => _BundleDialog(
                      item: item,
                      courseService: _courseService,
                      onSave: onSave,
                    ),
                    (newItem) => _addItem(_bundles, newItem),
                    (item) => _deleteItem(_bundles, item),
                    isDark,
                  ),
                  _buildListTab(
                    "Learning Path",
                    "Guide students through levels",
                    _learningPaths,
                    (item, onSave) => _PathDialog(item: item, onSave: onSave),
                    (newItem) => _addItem(_learningPaths, newItem),
                    (item) => _deleteItem(_learningPaths, item),
                    isDark,
                  ),
                  _buildListTab(
                    "Premium Tiers",
                    "Configure subscription plans",
                    _premiumTiers,
                    (item, onSave) => _TierDialog(item: item, onSave: onSave),
                    (newItem) => _addItem(_premiumTiers, newItem),
                    (item) => _deleteItem(_premiumTiers, item),
                    isDark,
                  ),
                ],
              ),
            ),
    );
  }

  void _updateItem(
    List<Map<String, dynamic>> list,
    Map<String, dynamic> oldItem,
    Map<String, dynamic> newItem,
  ) {
    setState(() {
      final index = list.indexOf(oldItem);
      if (index != -1) {
        list[index] = newItem;
      }
    });
  }

  void _addItem(List<Map<String, dynamic>> list, Map<String, dynamic> newItem) {
    setState(() {
      list.add(newItem);
    });
  }

  void _deleteItem(List<Map<String, dynamic>> list, Map<String, dynamic> item) {
    setState(() {
      list.remove(item);
    });
  }

  // --- Header Tab ---
  Widget _buildHeaderTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            "Header Configuration",
            "Customize the main hero section of the app.",
            isDark,
          ),
          const SizedBox(height: 24),
          _buildCard(
            isDark,
            child: Column(
              children: [
                _buildTextField(
                  controller: _headerSubtitleController,
                  label: "Subtitle (e.g. Hey User!)",
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _headerTitleController,
                  label: "Main Title (Use \\n for breaks)",
                  isDark: isDark,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  "Background Video",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _headerVideoController,
                  label: "Video URL",
                  isDark: isDark,
                  prefixIcon: Icons.link,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.video);
                    if (result != null && result.files.single.bytes != null) {
                      setState(() => _isLoading = true);
                      final url = await CloudinaryService().uploadFile(
                        result.files.single.bytes!,
                        result.files.single.name,
                        folder: 'home_header',
                      );
                      if (url != null) {
                        _headerVideoController.text = url;
                      }
                      setState(() => _isLoading = false);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Video"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.grey.shade100,
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Generic List Builder ---
  Widget _buildListTab(
    String title,
    String subtitle,
    List<Map<String, dynamic>> list,
    Widget Function(
      Map<String, dynamic> item,
      Function(Map<String, dynamic>) onSave,
    )
    dialogBuilder,
    Function(Map<String, dynamic>) onAdd,
    Function(Map<String, dynamic>) onDelete,
    bool isDark,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => dialogBuilder({}, (newItem) {
              onAdd(newItem); // Use onAdd for new items
            }),
          );
        },
        backgroundColor: const Color(0xFF4A89FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add $title", style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(title, subtitle, isDark),
          const SizedBox(height: 24),
          if (list.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  "No items yet. Add one!",
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ),
            ),

          ...list.map(
            (item) => _buildItemCard(
              item,
              isDark,
              onEdit: () => showDialog(
                context: context,
                builder: (c) => dialogBuilder(item, (newItem) {
                  _updateItem(list, item, newItem); // Use update for existing
                }),
              ),
              onDelete: () => onDelete(item),
            ),
          ),
          const SizedBox(height: 80), // Fab space
        ],
      ),
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> item,
    bool isDark, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Row(
        children: [
          // Image Preview if available
          if (item['imageUrl'] != null &&
              item['imageUrl'].toString().isNotEmpty)
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(item['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (item['icon'] != null) // For icon based
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(
                  item['color'] ?? 0xFF4A89FF,
                ).withValues(alpha: 0.2),
              ),
              child: Icon(
                IconData(item['icon'], fontFamily: 'MaterialIcons'),
                color: Color(item['color'] ?? 0xFF4A89FF),
              ),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? item['name'] ?? 'Untitled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['role'] ??
                      item['level'] ??
                      item['price'] ??
                      item['courses'] ??
                      '',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Iconsax.edit, color: Color(0xFF4A89FF)),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Iconsax.trash, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: isDark ? Colors.white54 : Colors.grey)
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ================= DIALOGS =================

class _MentorDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onSave;
  const _MentorDialog({required this.item, required this.onSave});
  @override
  State<_MentorDialog> createState() => _MentorDialogState();
}

class _MentorDialogState extends State<_MentorDialog> {
  final _name = TextEditingController();
  final _role = TextEditingController(); // "What they teach"
  final _image = TextEditingController();
  int _color = 0xFF4A89FF;

  @override
  void initState() {
    _name.text = widget.item['name'] ?? '';
    _role.text = widget.item['role'] ?? '';
    _image.text = widget.item['imageUrl'] ?? '';
    _color = widget.item['color'] ?? 0xFF4A89FF;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDialog(
      context,
      "Edit Mentor",
      [
        _buildDialogTextField(_name, "Mentor Name"),
        _buildDialogTextField(_role, "What they teach (e.g. Crypto Expert)"),
        _buildImagePicker(_image),
        _ColorPicker(
          selectedColor: _color,
          onSelect: (c) => setState(() => _color = c),
        ),
      ],
      () => widget.onSave({
        'name': _name.text,
        'role': _role.text,
        'imageUrl': _image.text,
        'color': _color,
      }),
    );
  }
}

class _BundleDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final CourseService courseService;
  final Function(Map<String, dynamic>) onSave;
  const _BundleDialog({
    required this.item,
    required this.courseService,
    required this.onSave,
  });
  @override
  State<_BundleDialog> createState() => _BundleDialogState();
}

class _BundleDialogState extends State<_BundleDialog> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _image = TextEditingController(); // Background
  int _color = 0xFF6366F1;
  List<String> _selectedCourseIds = [];
  String _selectedCoursesText = ""; // e.g. "15 Platinum Courses"

  @override
  void initState() {
    _title.text = widget.item['title'] ?? '';
    _price.text = widget.item['price'] ?? '';
    _image.text = widget.item['imageUrl'] ?? '';
    _color = widget.item['color'] ?? 0xFF6366F1;
    _selectedCourseIds = List<String>.from(widget.item['courseIds'] ?? []);
    _updateCoursesCountText();
    super.initState();
  }

  void _updateCoursesCountText() {
    // Or allow custom text, but auto-generating is also nice.
    // User requested "Pop up to select multiple courses".
    setState(() {
      _selectedCoursesText = "${_selectedCourseIds.length} Premium Courses";
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildDialog(
      context,
      "Edit Bundle",
      [
        _buildDialogTextField(_title, "Bundle Title"),
        _buildDialogTextField(_price, "Price Display (e.g. ₹9999)"),

        // Custom Course Selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: _showCourseSelectionDialog,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.list),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCourseIds.isEmpty
                          ? "Select Courses"
                          : "${_selectedCourseIds.length} Courses Selected",
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),

        _buildImagePicker(_image, label: "Background Image"),
        _ColorPicker(
          selectedColor: _color,
          onSelect: (c) => setState(() => _color = c),
        ),
      ],
      () => widget.onSave({
        'title': _title.text,
        'courses': _selectedCoursesText,
        'courseIds': _selectedCourseIds,
        'price': _price.text,
        'imageUrl': _image.text,
        'color': _color,
      }),
    );
  }

  void _showCourseSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: widget.courseService.getCourses(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;

            // Temporary selection set
            final Set<String> tempSelected = Set.from(_selectedCourseIds);

            return StatefulBuilder(
              builder: (context, setStateSB) {
                return AlertDialog(
                  title: const Text("Select Courses"),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final id = docs[index].id;
                        final isSel = tempSelected.contains(id);
                        return CheckboxListTile(
                          title: Text(data['title'] ?? 'Untitled'),
                          value: isSel,
                          onChanged: (v) {
                            setStateSB(() {
                              if (v == true)
                                tempSelected.add(id);
                              else
                                tempSelected.remove(id);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Done"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        this.setState(() {
                          _selectedCourseIds = tempSelected.toList();
                          _updateCoursesCountText();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PathDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onSave;
  const _PathDialog({required this.item, required this.onSave});
  @override
  State<_PathDialog> createState() => _PathDialogState();
}

class _PathDialogState extends State<_PathDialog> {
  final _name = TextEditingController();
  final _level = TextEditingController();
  int _icon = Icons.star.codePoint;
  int _color = 0xFF645AFF;
  int _bgColor = 0xFFFFFFFF;

  @override
  void initState() {
    _name.text = widget.item['name'] ?? '';
    _level.text = widget.item['level'] ?? '';
    _icon = widget.item['icon'] ?? Icons.star.codePoint;
    _color = widget.item['color'] ?? 0xFF645AFF;
    _bgColor = widget.item['bgColor'] ?? 0x1A645AFF; // Transparent default
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDialog(
      context,
      "Edit Learning Path Node",
      [
        _buildDialogTextField(_name, "Node Name (e.g. Technical)"),
        _buildDialogTextField(_level, "Level (e.g. Beginner)"),

        // Icon Selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    Icons.analytics,
                    Icons.security,
                    Icons.currency_bitcoin,
                    Icons.star,
                    Icons.psychology,
                    Icons.trending_up,
                  ].map((ic) {
                    return GestureDetector(
                      onTap: () => setState(() => _icon = ic.codePoint),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _icon == ic.codePoint
                              ? Colors.blue.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _icon == ic.codePoint
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(ic, color: Colors.black),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),

        const Text("Icon Color"),
        _ColorPicker(
          selectedColor: _color,
          onSelect: (c) => setState(() => _color = c),
        ),
        const SizedBox(height: 8),
        const Text("Background Color (Transparent)"),
        _ColorPicker(
          selectedColor: _bgColor,
          onSelect: (c) => setState(() => _bgColor = c),
        ),
      ],
      () => widget.onSave({
        'name': _name.text,
        'level': _level.text,
        'icon': _icon,
        'color': _color,
        'bgColor': _bgColor,
      }),
    );
  }
}

class _TierDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onSave;
  const _TierDialog({required this.item, required this.onSave});
  @override
  State<_TierDialog> createState() => _TierDialogState();
}

class _TierDialogState extends State<_TierDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  int _colorStart = 0xFF6366F1;
  int _colorEnd = 0xFF8B5CF6;

  @override
  void initState() {
    _name.text = widget.item['name'] ?? '';
    _price.text = widget.item['price'] ?? '';
    _desc.text = widget.item['desc'] ?? '';
    _colorStart = widget.item['colorStart'] ?? 0xFF6366F1;
    _colorEnd = widget.item['colorEnd'] ?? 0xFF8B5CF6;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDialog(
      context,
      "Edit Premium Tier",
      [
        _buildDialogTextField(_name, "Tier Name"),
        _buildDialogTextField(_price, "Price"),
        _buildDialogTextField(_desc, "Description"),
        const Text("Gradient Start Config"),
        _ColorPicker(
          selectedColor: _colorStart,
          onSelect: (c) => setState(() => _colorStart = c),
        ),
        const SizedBox(height: 8),
        const Text("Gradient End Config"),
        _ColorPicker(
          selectedColor: _colorEnd,
          onSelect: (c) => setState(() => _colorEnd = c),
        ),
      ],
      () => widget.onSave({
        'name': _name.text,
        'price': _price.text,
        'desc': _desc.text,
        'colorStart': _colorStart,
        'colorEnd': _colorEnd,
      }),
    );
  }
}

// --- Helper Widgets ---

Widget _buildDialog(
  BuildContext context,
  String title,
  List<Widget> children,
  VoidCallback onSave,
) {
  return AlertDialog(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancel"),
      ),
      ElevatedButton(
        onPressed: () {
          onSave();
          Navigator.pop(context, true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A89FF),
          foregroundColor: Colors.white,
        ),
        child: const Text("Save"),
      ),
    ],
  );
}

Widget _buildDialogTextField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Widget _buildImagePicker(
  TextEditingController controller, {
  String label = "Image URL",
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MediaLibraryButton(
            onSelect: (url) async {
              controller.text = url;
            },
            type: 'image',
          ),
        ],
      ),
      const SizedBox(height: 12),
    ],
  );
}

class MediaLibraryButton extends StatelessWidget {
  final Function(String) onSelect;
  final String type;
  const MediaLibraryButton({
    super.key,
    required this.onSelect,
    required this.type,
  });
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (c) => MediaLibraryDialog(
            onSelect: (url) async {
              onSelect(url);
            },
            allowedType: type,
          ),
        );
      },
      icon: const Icon(Iconsax.gallery, size: 16),
      label: const Text("Select from Library", style: TextStyle(fontSize: 12)),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final int selectedColor;
  final Function(int) onSelect;
  const _ColorPicker({required this.selectedColor, required this.onSelect});

  final List<int> colors = const [
    0xFF4A89FF, 0xFFFF6D6D, 0xFF00D2FF, 0xFF6366F1, 0xFFEC4899,
    0xFFF59E0B, 0xFF10B981, 0xFF94A3B8, 0xFF1A1A2E, 0xFFFFFFFF,
    0x1A645AFF, // Transparentish
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((c) {
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(c),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              boxShadow: selectedColor == c
                  ? [
                      BoxShadow(
                        color: Color(c).withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: selectedColor == c
                ? Icon(
                    Icons.check,
                    color: c == 0xFFFFFFFF ? Colors.black : Colors.white,
                    size: 16,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
