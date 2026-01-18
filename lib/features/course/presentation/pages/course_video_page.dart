import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
            _buildSettingItem(
              icon: Icons.high_quality_rounded,
              title: "Video Quality",
              trailing: "Auto (1080p)",
              onTap: () {},
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
                  Center(
                    child: Container(
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
                          Colors.black.withValues(alpha: 0.8),
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
                            Text(
                              "${_formatDuration(value.position)} / ${_formatDuration(value.duration)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.subtitles_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 16),
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
    if (_lessons.isEmpty) return const SizedBox.shrink();

    final currentLesson = _lessons[_currentLessonIndex];
    final resources =
        (currentLesson['resources'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];

    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No resources for this lesson",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return GestureDetector(
          onTap: () async {
            final url = resource['url'];
            if (url != null && url.isNotEmpty) {
              final uri = Uri.parse(url);
              try {
                debugPrint('Attempting to launch: $url');
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  debugPrint('launchUrl returned false');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not launch resource link'),
                      ),
                    );
                  }
                }
              } catch (e) {
                debugPrint('Error launching url: $e');
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
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
                        resource['name'] ?? "Unknown Resource",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
                const Icon(
                  Icons.download_for_offline_rounded,
                  color: Color(0xFF4A89FF),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    if (_lessons.isEmpty) return const SizedBox.shrink();

    final currentLesson = _lessons[_currentLessonIndex];
    final notes = currentLesson['notes'] as String?;

    if (notes == null || notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No notes for this lesson",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: MarkdownBody(
          data: notes,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF1A1A1E),
            ),
            h1: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1E),
            ),
            h2: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1E),
            ),
            h3: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1E),
            ),
            listBullet: const TextStyle(color: Color(0xFF1A1A1E)),
          ),
        ),
      ),
    );
  }

  Widget _buildQATab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .doc(
                  widget.course['id'] ?? 'unknown_course_id',
                ) // Ensure course ID is passed
                .collection('qa')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final questions = snapshot.data?.docs ?? [];

              if (questions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.message_question,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No questions yet",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      TextButton(
                        onPressed: _showAskQuestionDialog,
                        child: const Text("Be the first to ask"),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final qData = questions[index].data() as Map<String, dynamic>;
                  final qId = questions[index].id;

                  return GestureDetector(
                    onTap: () => _showQADetails(qId, qData),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  qData['userAvatar'] ??
                                      "https://ui-avatars.com/api/?name=${qData['userName'] ?? 'User'}",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                qData['userName'] ?? "Anonymous",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeago.format(
                                  (qData['timestamp'] as Timestamp?)
                                          ?.toDate() ??
                                      DateTime.now(),
                                ),
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            qData['text'] ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Iconsax.message,
                                size: 16,
                                color: Colors.blue.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${qData['replyCount'] ?? 0} Replies",
                                style: TextStyle(
                                  color: Colors.blue.shade400,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms),
                  );
                },
              );
            },
          ),
        ),
        Padding(
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
        ),
      ],
    );
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
