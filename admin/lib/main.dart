import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dashboard_page.dart';
import 'courses_page.dart';
import 'create_course_page.dart';
import 'reports_page.dart';
import 'students_page.dart';
import 'transactions_page.dart';
import 'invoices_page.dart';
import 'feedback_page.dart';
import 'settings_page.dart';
import 'manage_home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
    ),
  );

  runApp(const TismAdminApp());
}

// Global ValueNotifier handles theme state
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class TismAdminApp extends StatelessWidget {
  const TismAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'TISM Admin',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F6FA),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A89FF),
              surface: const Color(0xFFF5F6FA),
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A89FF),
              brightness: Brightness.dark,
              surface: const Color(0xFF1A1A2E),
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.warning_2,
                          size: 60,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "System Update Required",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "New features have been installed.\nPlease strictly STOP and RESTART the app.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh),
                          label: const Text("I have restarted"),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData) {
                return const AdminConnectBoard();
              }
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}

class AdminConnectBoard extends StatefulWidget {
  const AdminConnectBoard({super.key});

  @override
  State<AdminConnectBoard> createState() => _AdminConnectBoardState();
}

class _AdminConnectBoardState extends State<AdminConnectBoard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isCreatingCourse = false;
  Map<String, dynamic>? _editingCourse;
  String? _editingCourseId;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1100;
    final bool isTablet =
        MediaQuery.of(context).size.width >= 700 &&
        MediaQuery.of(context).size.width < 1100;
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      key: _scaffoldKey,
      drawer: !isDesktop && !isMobile
          ? Drawer(child: _buildSidebarContent())
          : null, // Tablet drawer
      body: Row(
        children: [
          if (isDesktop) SizedBox(width: 260, child: _buildSidebarContent()),
          Expanded(
            child: Column(
              children: [Expanded(child: _buildBody(isDesktop, isTablet))],
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showMobileMenu(context),
              backgroundColor: const Color(0xFF4A89FF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isMobile
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C3E)
                  : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(0, Iconsax.element_4),
                  _buildBottomNavItem(1, Iconsax.chart_21),
                  const SizedBox(width: 48), // Space for FAB
                  _buildBottomNavItem(2, Iconsax.video_play),
                  _buildBottomNavItem(3, Iconsax.people),
                ],
              ),
            )
          : null,
      extendBody: true, // For FAB notch transparency
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF4A89FF) : Colors.grey,
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Navigation",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Menu Items Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMobileMenuItem(
                      0,
                      "Dashboard",
                      Iconsax.element_4,
                      isDark,
                    ),
                    _buildMobileMenuItem(
                      2,
                      "Courses",
                      Iconsax.video_play,
                      isDark,
                    ),
                    _buildMobileMenuItem(3, "Students", Iconsax.people, isDark),
                    _buildMobileMenuItem(
                      4,
                      "Transactions",
                      Iconsax.card,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildThemeToggle(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuItem(
    int index,
    String title,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A89FF)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDesktop, bool isTablet) {
    if (_selectedIndex == 1) return const ReportsPage();

    if (_selectedIndex == 2) {
      if (_isCreatingCourse) {
        return CreateCoursePage(
          onBack: () => setState(() {
            _isCreatingCourse = false;
            _editingCourse = null;
            _editingCourseId = null;
          }),
          courseId: _editingCourseId,
          initialData: _editingCourse,
        );
      }
      return CoursesPage(
        onCreateCourse: () => setState(() {
          _isCreatingCourse = true;
          _editingCourse = null;
          _editingCourseId = null;
        }),
        onEditCourse: (id, data) => setState(() {
          _isCreatingCourse = true;
          _editingCourseId = id;
          _editingCourse = data;
        }),
      );
    }

    if (_selectedIndex == 3) return const StudentsPage();
    if (_selectedIndex == 4) return const TransactionsPage();
    if (_selectedIndex == 5) return const InvoicesPage();
    if (_selectedIndex == 6)
      return const SettingsPage(); // Settings at index 6 based on menu
    if (_selectedIndex == 7) return const FeedbackPage();
    if (_selectedIndex == 8) return const ManageHomePage();

    if (_selectedIndex == 0) {
      return const DashboardPage();
    }

    return const Center(child: Text("Coming Soon"));
  }

  Widget _buildSidebarContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161622), Color(0xFF2C2C3E)],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A89FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.flash_15,
                          color: Color(0xFF4A89FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "TISM Admin",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  _buildMenuSection("MENU", [
                    _buildMenuItem(0, "Dashboard", Iconsax.element_4),
                    _buildMenuItem(2, "Courses", Iconsax.video_play),
                    _buildMenuItem(3, "Students", Iconsax.people),
                  ]),
                  const SizedBox(height: 24),
                  _buildMenuSection("FINANCIAL", [
                    _buildMenuItem(4, "Transactions", Iconsax.card),
                  ]),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  _buildMenuSection("TOOLS", [
                    _buildMenuItem(8, "Home Builder", Iconsax.home_hashtag),
                  ]),
                  const SizedBox(height: 24),
                  _buildThemeToggle(),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.logout,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildUpgradeCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDark ? Iconsax.moon : Iconsax.sun_1,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isDark ? "Dark Mode" : "Light Mode",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Switch(
            value: isDark,
            onChanged: (value) {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
            activeColor: const Color(0xFF4A89FF),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A89FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.security_user, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            "Admin Pro",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Access advanced analytics.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A89FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Upgrade Now",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
