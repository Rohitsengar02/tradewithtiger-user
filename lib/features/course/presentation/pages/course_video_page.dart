import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tradewithtiger/features/home/presentation/widgets/web_sidebar.dart';

class CourseVideoPage extends StatefulWidget {
  final Map<String, dynamic> course;
  final int initialLessonIndex;
  final bool isEnrolled;

  const CourseVideoPage({
    super.key,
    required this.course,
    this.initialLessonIndex = 0,
    this.isEnrolled = false,
  });

  @override
  State<CourseVideoPage> createState() => _CourseVideoPageState();
}

class _CourseVideoPageState extends State<CourseVideoPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late int _currentLessonIndex;
  VideoPlayerController? _videoPlayerController;
  late TabController _tabController;
  bool _isInitialized = false;
  bool _isFullScreen = false;
  double _playbackSpeed = 1.0;

  late List<Map<String, dynamic>> _lessons;

  int _desktopTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize lessons from course data
    final rawLessons = widget.course['curriculum'] as List?;
    _lessons =
        rawLessons?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ??
        [];

    _currentLessonIndex = widget.initialLessonIndex;
    if (_lessons.isNotEmpty) {
      if (_currentLessonIndex >= _lessons.length || _currentLessonIndex < 0) {
        _currentLessonIndex = 0;
      }
      _initializeVideoPlayer(_lessons[_currentLessonIndex]['videoUrl'] ?? "");
    }

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoPlayerController?.pause();
    }
  }

  void _initializeVideoPlayer(String url) async {
    setState(() => _isInitialized = false);

    final oldController = _videoPlayerController;
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await _videoPlayerController!.initialize();
      if (!mounted) return;

      await oldController?.dispose();

      setState(() {
        _isInitialized = true;
      });
      _videoPlayerController!.setLooping(true);
      _videoPlayerController!.play();
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    _videoPlayerController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Video Settings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1E),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingItem(
              icon: Icons.speed_rounded,
              title: "Playback Speed",
              trailing: "${_playbackSpeed}x",
              onTap: () {
                Navigator.pop(context);
                _showSpeedSelector();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSpeedSelector() {
    final List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Playback Speed",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...speeds.map(
              (speed) => ListTile(
                title: Text(
                  "${speed}x",
                  style: TextStyle(
                    fontWeight: _playbackSpeed == speed
                        ? FontWeight.w900
                        : FontWeight.normal,
                    color: _playbackSpeed == speed
                        ? const Color(0xFF4A89FF)
                        : Colors.black,
                  ),
                ),
                trailing: _playbackSpeed == speed
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF4A89FF),
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _playbackSpeed = speed;
                    _videoPlayerController?.setPlaybackSpeed(speed);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Spacer(),
            Text(
              trailing,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A89FF),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _changeLesson(int index) {
    if (index != 0 && !widget.isEnrolled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enroll to unlock this lesson"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_currentLessonIndex == index) return;
    setState(() => _currentLessonIndex = index);
    final url = _lessons[index]['videoUrl'];
    if (url != null && url.isNotEmpty) {
      _initializeVideoPlayer(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return _buildDesktopLayout();
        }
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Main App Sidebar
          const SizedBox(
            width: 250,
            child: WebSidebar(activePage: "My Course"),
          ),

          // 2. Course Lessons Sidebar (Middle Column)
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: _buildDesktopLessonsSidebar(),
          ),

          // 3. Main Video & Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildVideoPlayerSection(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDesktopCourseInfo(), // Keep title/desc
                  const SizedBox(height: 40),
                  _buildDesktopTabsSection(), // Resources, Notes, QA
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop Helper Widgets

  Widget _buildDesktopCourseInfo() {
    final rating = widget.course['rating']?.toString() ?? "4.5";
    final students = widget.course['students']?.toString() ?? "0";
    final level = widget.course['level'] ?? "Beginner";
    final mentorName = widget.course['mentorName'] ?? "Expert Mentor";
    final mentorRole = widget.course['mentorRole'] ?? "Instructor";
    final mentorImage = widget.course['mentorImage'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (i) => const Icon(
                  Icons.star_rounded,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "$rating ($students)",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                level,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.course['title'] ?? 'Course Title',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.course['description'] ?? 'No description available.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: mentorImage != null
                  ? NetworkImage(mentorImage)
                  : const AssetImage("assets/images/mentor_1.png")
                        as ImageProvider,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  mentorRole,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: _buildVideoPlayerSection()),
          if (!_isFullScreen)
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLessonsTab(),
                          _buildResourcesTab(),
                          _buildNotesTab(),
                          _buildQATab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopLessonsSidebar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Course Content",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_lessons.length} Lessons",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _lessons.length,
            itemBuilder: (context, index) {
              bool isActive = _currentLessonIndex == index;
              bool isLocked = index != 0 && !widget.isEnrolled;

              return InkWell(
                onTap: () => _changeLesson(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.grey.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF6366F1)
                          : Colors.grey.shade200,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey.shade100
                              : (isActive
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isLocked
                              ? Icons.lock_outline_rounded
                              : (isActive
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded),
                          color: isLocked
                              ? Colors.grey
                              : (isActive
                                    ? Colors.white
                                    : const Color(0xFF64748B)),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _lessons[index]['title'] ?? "Lesson ${index + 1}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 13,
                                color: isLocked ? Colors.grey : Colors.black87,
                              ),
                            ),
                            if (!isLocked) ...[
                              const SizedBox(height: 4),
                              Text(
                                _lessons[index]['duration'] ?? "00:00",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTabsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildDesktopTabButton(0, "Resources", Icons.folder_open_rounded),
            const SizedBox(width: 20),
            _buildDesktopTabButton(1, "Notes", Icons.note_alt_outlined),
            const SizedBox(width: 20),
            _buildDesktopTabButton(2, "Q&A", Icons.forum_outlined),
          ],
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_desktopTabIndex),
            constraints: const BoxConstraints(minHeight: 300),
            child: _buildDesktopTabContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTabButton(int index, String label, IconData icon) {
    final isSelected = _desktopTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _desktopTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTabContent() {
    switch (_desktopTabIndex) {
      case 0:
        return _buildResourcesContent(isScrollable: false);
      case 1:
        return _buildNotesContent(isScrollable: false);
      case 2:
        return _buildQAContent(isScrollable: false);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildResourcesContent({bool isScrollable = false}) {
    if (_lessons.isEmpty) return const SizedBox.shrink();
    final currentLesson = _lessons[_currentLessonIndex];
    final resources =
        (currentLesson['resources'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];

    if (resources.isEmpty) {
      return _buildEmptyState(
        "No Resources Found",
        "This lesson doesn't have any downloadable materials attached.",
        Icons.folder_off_rounded,
      );
    }
    return ListView.builder(
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !isScrollable,
      padding: isScrollable ? const EdgeInsets.all(24) : EdgeInsets.zero,
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        final VoidCallback onDownload = () async {
          final url = resource['url'];
          if (url != null && url.isNotEmpty) {
            final uri = Uri.parse(url);
            try {
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not launch resource link'),
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Resource link is missing'),
                ),
              );
            }
          }
        };

        return GestureDetector(
          onTap: onDownload,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource['name'] ?? "Resource File",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        resource['size'] ?? "Unknown size",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesContent({bool isScrollable = false}) {
    if (_lessons.isEmpty) return const SizedBox.shrink();
    final currentLesson = _lessons[_currentLessonIndex];
    final notes = currentLesson['notes'] as String?;

    if (notes == null || notes.isEmpty) {
      return _buildEmptyState(
        "No Notes Available",
        "There are no study notes for this lesson yet.",
        Icons.note_alt_outlined,
      );
    }

    final content = Container(
      padding: const EdgeInsets.all(30),
      child: MarkdownBody(
        data: notes,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: Color(0xFF334155),
          ),
          h1: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
          h2: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          listBullet: const TextStyle(color: Color(0xFF334155)),
        ),
      ),
    );

    if (isScrollable) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _buildQAContent({bool isScrollable = false}) {
    final list = StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course['id'])
          .collection('qa')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _buildEmptyState(
            "No Discussions Yet",
            "Be the first to ask a question about this lesson!",
            Icons.forum_outlined,
          );
        }

        return ListView.builder(
          physics: isScrollable
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          shrinkWrap: !isScrollable,
          padding: isScrollable ? const EdgeInsets.all(24) : EdgeInsets.zero,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['text'] ?? 'Question'),
              subtitle: Text(
                timeago.format(
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showQADetails(docs[index].id, data),
            );
          },
        );
      },
    );

    final button = Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: _showAskQuestionDialog,
        icon: Icon(Iconsax.add),
        label: const Text("Ask a Question"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A1E),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

    if (isScrollable) {
      return Column(
        children: [
          Expanded(child: list),
          button,
        ],
      );
    }
    return Column(children: [list, button]);
  }

  Widget _buildEmptyState(String title, String desc, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized &&
              _videoPlayerController != null &&
              _videoPlayerController!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A89FF)),
            ),
          Positioned.fill(child: _buildVideoControls()),
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    if (_videoPlayerController == null) return const SizedBox.shrink();
    return ValueListenableBuilder(
      valueListenable: _videoPlayerController!,
      builder: (context, VideoPlayerValue value, child) {
        if (!value.isInitialized) return const SizedBox.shrink();
        final bool isPlaying = value.isPlaying;
        return GestureDetector(
          onTap: () {
            if (isPlaying) {
              _videoPlayerController!.pause();
            } else {
              _videoPlayerController!.play();
            }
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                if (!isPlaying)
                  Container(
                    color: Colors.black26,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              final newPos =
                                  value.position - const Duration(seconds: 10);
                              _videoPlayerController!.seekTo(
                                newPos < Duration.zero ? Duration.zero : newPos,
                              );
                            },
                            icon: const Icon(
                              Icons.replay_10_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            onPressed: () {
                              final newPos =
                                  value.position + const Duration(seconds: 10);
                              final duration = value.duration;
                              _videoPlayerController!.seekTo(
                                newPos > duration ? duration : newPos,
                              );
                            },
                            icon: const Icon(
                              Icons.forward_10_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          _videoPlayerController!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFF4A89FF),
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.white10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${_formatDuration(value.position)} / ${_formatDuration(value.duration)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    _videoPlayerController!.setVolume(
                                      value.volume > 0 ? 0 : 1,
                                    );
                                  },
                                  child: Icon(
                                    value.volume > 0
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _showSettingsMenu,
                                  child: const Icon(
                                    Icons.settings_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: _toggleFullScreen,
                                  child: Icon(
                                    _isFullScreen
                                        ? Icons.fullscreen_exit_rounded
                                        : Icons.fullscreen_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF4A89FF),
        indicatorWeight: 4,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: const Color(0xFF1A1A1E),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        tabs: const [
          Tab(text: "Lessons"),
          Tab(text: "Resources"),
          Tab(text: "Notes"),
          Tab(text: "Q&A"),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        bool isActive = _currentLessonIndex == index;
        // Lock logic: Only index 0 unlocked if not enrolled
        bool isLocked = index != 0 && !widget.isEnrolled;
        return GestureDetector(
          onTap: () => _changeLesson(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive ? const Color(0xFF4A89FF) : Colors.transparent,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4A89FF).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? Colors.grey.shade100
                        : (isActive
                              ? const Color(0xFF4A89FF)
                              : const Color(0xFF4A89FF).withOpacity(0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLocked
                        ? Icons.lock_outline_rounded
                        : (isActive
                              ? Icons.play_arrow_rounded
                              : Icons.play_circle_outline_rounded),
                    color: isLocked
                        ? Colors.grey
                        : (isActive ? Colors.white : const Color(0xFF4A89FF)),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lessons[index]['title'] ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isLocked
                              ? Colors.grey
                              : const Color(0xFF1A1A1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLocked
                            ? "Premium content"
                            : _lessons[index]['duration'] ?? "",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1),
        );
      },
    );
  }

  Widget _buildResourcesTab() {
    return _buildResourcesContent(isScrollable: true);
  }

  Widget _buildNotesTab() {
    return _buildNotesContent(isScrollable: true);
  }

  Widget _buildQATab() {
    return _buildQAContent(isScrollable: true);
  }

  void _showAskQuestionDialog() {
    final TextEditingController _questionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ask a Question",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _questionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_questionController.text.trim().isEmpty) return;

                    // TODO: Get actual user details from Auth Provider
                    // For now, we use a mock user or generic data
                    final user = {
                      'uid': 'user_123', // Replace with Auth UID
                      'name': 'Student', // Replace with Auth Name
                      'avatar': null, // Replace with Auth Photo URL
                    };

                    await FirebaseFirestore.instance
                        .collection('courses')
                        .doc(widget.course['id'] ?? 'unknown_course_id')
                        .collection('qa')
                        .add({
                          'text': _questionController.text.trim(),
                          'userId': user['uid'],
                          'userName': user['name'],
                          'userAvatar': user['avatar'],
                          'timestamp': FieldValue.serverTimestamp(),
                          'replyCount': 0,
                          'lessonId': _lessons.isNotEmpty
                              ? _lessons[_currentLessonIndex]['id'] ??
                                    _currentLessonIndex
                              : null, // Optional: Link to specific lesson
                        });

                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A89FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Post Question"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQADetails(String qId, Map<String, dynamic> qData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QADetailSheet(
        courseId: widget.course['id'] ?? 'unknown_course_id',
        questionId: qId,
        questionData: qData,
      ),
    );
  }
}

class _QADetailSheet extends StatefulWidget {
  final String courseId;
  final String questionId;
  final Map<String, dynamic> questionData;

  const _QADetailSheet({
    required this.courseId,
    required this.questionId,
    required this.questionData,
  });

  @override
  State<_QADetailSheet> createState() => _QADetailSheetState();
}

class _QADetailSheetState extends State<_QADetailSheet> {
  final TextEditingController _replyController = TextEditingController();

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return;

    // TODO: Get actual user details
    final user = {'uid': 'user_456', 'name': 'Reply User', 'avatar': null};

    final batch = FirebaseFirestore.instance.batch();
    final qRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('qa')
        .doc(widget.questionId);

    final replyRef = qRef.collection('answers').doc();

    batch.set(replyRef, {
      'text': _replyController.text.trim(),
      'userId': user['uid'],
      'userName': user['name'],
      'userAvatar': user['avatar'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(qRef, {'replyCount': FieldValue.increment(1)});

    await batch.commit();
    _replyController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Discussion",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Question & Answers
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Question Card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        widget.questionData['userAvatar'] ??
                            "https://ui-avatars.com/api/?name=${widget.questionData['userName'] ?? 'User'}",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.questionData['userName'] ?? "Anonymous",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeago.format(
                              (widget.questionData['timestamp'] as Timestamp?)
                                      ?.toDate() ??
                                  DateTime.now(),
                            ),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.questionData['text'] ?? "",
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "Replies",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .doc(widget.courseId)
                      .collection('qa')
                      .doc(widget.questionId)
                      .collection('answers')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final kReplies = snapshot.data!.docs;

                    return Column(
                      children: kReplies.map((doc) {
                        final rData = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  rData['userAvatar'] ??
                                      "https://ui-avatars.com/api/?name=${rData['userName'] ?? 'User'}",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rData['userName'] ?? "Anonymous",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            rData['text'] ?? "",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        timeago.format(
                                          (rData['timestamp'] as Timestamp?)
                                                  ?.toDate() ??
                                              DateTime.now(),
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Reply Input
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: "Write a reply...",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _postReply,
                  icon: Icon(Iconsax.send_1, color: Color(0xFF4A89FF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
