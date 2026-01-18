import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          home: const AdminConnectBoard(),
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
                      1,
                      "Reports",
                      Iconsax.chart_21,
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
                    _buildMobileMenuItem(
                      5,
                      "Invoices",
                      Iconsax.receipt,
                      isDark,
                    ),
                    _buildMobileMenuItem(
                      7,
                      "Feedback",
                      Iconsax.message_question,
                      isDark,
                    ),
                    _buildMobileMenuItem(
                      6,
                      "Settings",
                      Iconsax.setting_2,
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
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(isDesktop, isTablet),
            const SizedBox(height: 24),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildSalesReportsChart()),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildProductStatisticChart()),
                ],
              )
            else ...[
              _buildSalesReportsChart(),
              const SizedBox(height: 24),
              _buildProductStatisticChart(),
            ],
            const SizedBox(height: 24),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildCustomerGrowthChart()),
                  const SizedBox(width: 24),
                  // Placeholder for another widget or list
                  Expanded(flex: 2, child: _buildRecentTransactionsTable()),
                ],
              )
            else ...[
              _buildCustomerGrowthChart(),
              const SizedBox(height: 24),
              _buildRecentTransactionsTable(),
            ],
          ],
        ),
      );
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
                    _buildMenuItem(1, "Reports", Iconsax.chart_21),
                    _buildMenuItem(2, "Courses", Iconsax.video_play),
                    _buildMenuItem(3, "Students", Iconsax.people),
                  ]),
                  const SizedBox(height: 24),
                  _buildMenuSection("FINANCIAL", [
                    _buildMenuItem(4, "Transactions", Iconsax.card),
                    _buildMenuItem(5, "Invoices", Iconsax.receipt),
                  ]),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  _buildMenuSection("TOOLS", [
                    _buildMenuItem(6, "Settings", Iconsax.setting_2),
                    _buildMenuItem(7, "Feedback", Iconsax.message_question),
                    _buildMenuItem(8, "Home Builder", Iconsax.home_hashtag),
                  ]),
                  const SizedBox(height: 24),
                  _buildThemeToggle(),
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

  Widget _buildStatsGrid(bool isDesktop, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> cards = [
          _buildStatCard(
            title: "Total Sales",
            value: "₹612,917",
            subtitle: "Sales vs last month",
            percentage: "+2.08%",
            icon: Iconsax.wallet_2,
            isPrimary: true,
          ),
          _buildStatCard(
            title: "Total Orders",
            value: "34,760",
            subtitle: "Orders vs last month",
            percentage: "+12.4%",
            icon: Iconsax.box,
            isPrimary: false,
          ),
          _buildStatCard(
            title: "Active Users",
            value: "14,987",
            subtitle: "Users vs last month",
            percentage: "-2.08%",
            isNegative: true,
            icon: Iconsax.profile_2user,
            isPrimary: false,
          ),
          _buildStatCard(
            title: "Sold Courses",
            value: "12,987",
            subtitle: "Courses vs last month",
            percentage: "+12.1%",
            icon: Iconsax.book_1,
            isPrimary: false,
          ),
        ];

        if (constraints.maxWidth < 700) {
          return Column(
            children: cards
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: e,
                  ),
                )
                .toList(),
          );
        } else {
          return Row(
            children: cards
                .map(
                  (e) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: e,
                    ),
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required String percentage,
    required IconData icon,
    bool isPrimary = false,
    bool isNegative = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isPrimary
        ? const Color(0xFF4A89FF)
        : (isDark ? const Color(0xFF2C2C3E) : Colors.white);

    final Color textColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1A1A2E));

    final Color subTextColor = isPrimary
        ? Colors.white.withValues(alpha: 0.6)
        : (isDark ? Colors.white54 : Colors.grey[400]!);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isPrimary && !isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF5F6FA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNegative
                      ? (isPrimary
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFFF6D6D).withValues(alpha: 0.1))
                      : (isPrimary
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFF00B087).withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    color: isPrimary
                        ? Colors.white
                        : (isNegative
                              ? const Color(0xFFFF6D6D)
                              : const Color(0xFF00B087)),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.8)
                  : (isDark ? Colors.white60 : Colors.grey[500]),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSalesReportsChart() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Habits",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    "Track your customer habits",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey[200]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      "This year",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1A1A2E),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                        ];
                        if (value.toInt() < titles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              titles[value.toInt()],
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}K",
                          style: TextStyle(
                            color: isDark ? Colors.white24 : Colors.grey[300],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[100],
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 30, 20),
                  _makeBarGroup(1, 45, 35),
                  _makeBarGroup(2, 28, 42),
                  _makeBarGroup(3, 15, 30),
                  _makeBarGroup(4, 55, 48), // Highlight
                  _makeBarGroup(5, 38, 25),
                  _makeBarGroup(6, 42, 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: const Color(0xFFE0E0E0),
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        BarChartRodData(
          toY: y2,
          color: const Color(0xFF4A89FF),
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
      barsSpace: 4,
    );
  }

  Widget _buildProductStatisticChart() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Course Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          Text(
            "Students by interest",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF4A89FF),
                        value: 40,
                        title: '',
                        radius: 20,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFFF6D6D),
                        value: 30,
                        title: '',
                        radius: 15,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF00B087),
                        value: 15,
                        title: '',
                        radius: 15,
                      ),
                      PieChartSectionData(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        value: 15,
                        title: '',
                        radius: 12,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "9,829",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      "Total Students",
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F7F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "+5.34%",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF00B087),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildLegendItem(
            "Trading",
            "2,487",
            "+1.8%",
            const Color(0xFF4A89FF),
          ),
          const SizedBox(height: 12),
          _buildLegendItem("Crypto", "1,828", "+2.3%", const Color(0xFFFF6D6D)),
          const SizedBox(height: 12),
          _buildLegendItem(
            "Options",
            "1,463",
            "-0.4%",
            const Color(0xFF00B087),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerGrowthChart() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Student Locations",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          Text(
            "Global reach",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        color: const Color(0xFF4A89FF),
                        title: '40%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: 30,
                        color: const Color(0xFF6C63FF),
                        title: '30%',
                        radius: 45,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: 15,
                        color: const Color(0xFFFF9F43),
                        title: '15%',
                        radius: 40,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: 15,
                        color: const Color(0xFFFF6D6D),
                        title: '15%',
                        radius: 40,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildCountryLegend("India", const Color(0xFF4A89FF)),
                    const SizedBox(height: 8),
                    _buildCountryLegend("USA", const Color(0xFF6C63FF)),
                    const SizedBox(height: 8),
                    _buildCountryLegend("UAE", const Color(0xFFFF9F43)),
                    const SizedBox(height: 8),
                    _buildCountryLegend("UK", const Color(0xFFFF6D6D)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountryLegend(String country, Color color) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          country,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String title,
    String value,
    String percent,
    Color color,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(Iconsax.flash, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: percent.startsWith('+')
                ? const Color(0xFFE5F7F2)
                : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            percent,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: percent.startsWith('+')
                  ? const Color(0xFF00B087)
                  : const Color(0xFFFF6D6D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsTable() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Transactions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: isDark ? Colors.white10 : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFF5F6FA),
                        child: const Icon(
                          Iconsax.receipt,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Student #102$index",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            "Pro Bundle",
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        "₹14,999",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B087),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
