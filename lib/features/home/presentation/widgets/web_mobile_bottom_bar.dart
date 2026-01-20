import 'package:flutter/material.dart';
import 'package:tradewithtiger/features/community/presentation/pages/community_feed_page.dart';
import 'package:tradewithtiger/features/course/presentation/pages/explore_courses_page.dart';
import 'package:tradewithtiger/features/course/presentation/pages/my_courses_page.dart';
import 'package:tradewithtiger/features/home/presentation/pages/web_home_page.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/profile_page.dart';

class WebMobileBottomBar extends StatelessWidget {
  final String currentRoute;

  const WebMobileBottomBar({super.key, this.currentRoute = "HOME"});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 900) {
      return const SizedBox.shrink();
    }

    final bool isHome = currentRoute == "HOME";
    final Color backgroundColor = isHome
        ? const Color(0xFF1E293B)
        : Colors.white;
    final Color shadowColor = isHome
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(context, Icons.home_rounded, "HOME", isHome),
          _buildItem(context, Icons.shopping_bag_outlined, "SHOP", isHome),
          _buildItem(context, Icons.menu_book_rounded, "MY COURSE", isHome),
          _buildItem(context, Icons.people_alt_rounded, "COMMUNITY", isHome),
          _buildItem(context, Icons.person_rounded, "PROFILE", isHome),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isHomeTheme,
  ) {
    final bool isSelected = currentRoute == title;

    final Color selectedBgColor = Colors.blueAccent;
    final Color selectedIconColor = Colors.white;
    final Color unselectedIconColor = isHomeTheme
        ? Colors.white60
        : Colors.grey;

    return GestureDetector(
      onTap: () {
        if (isSelected) return;

        if (title == "HOME") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WebHomePage()),
          );
        } else if (title == "SHOP") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExploreCoursesPage()),
          );
        } else if (title == "MY COURSE") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyCoursesPage()),
          );
        } else if (title == "COMMUNITY") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunityFeedPage()),
          );
        } else if (title == "PROFILE") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? selectedIconColor : unselectedIconColor,
          size: 24,
        ),
      ),
    );
  }
}
