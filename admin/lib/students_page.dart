import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            children: [
              // Header & Search
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Student Directory",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          "View and manage all enrolled students",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search students...",
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Iconsax.search_normal,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF2C2C3E)
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Student Directory",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              "View and manage all enrolled students",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search students...",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                              prefixIcon: Icon(
                                Iconsax.search_normal,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C3E)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 32),
              // Students List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: 15, // Dummy data
                    separatorBuilder: (context, index) => Divider(
                      color: isDark ? Colors.white10 : Colors.grey[100],
                    ),
                    itemBuilder: (context, index) {
                      return _buildStudentItem(context, index, isDark);
                    },
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn();
      },
    );
  }

  Widget _buildStudentItem(BuildContext context, int index, bool isDark) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 8,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color((index * 0xFF42A5F5) % 0xFFFFFFFF).withValues(alpha: 1.0),
              Color((index * 0xFFAB47BC) % 0xFFFFFFFF).withValues(alpha: 0.8),
            ].map((c) => c.withValues(alpha: 0.8)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "S${index + 1}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12, // slightly smaller text
            ),
          ),
        ),
      ),
      title: Text(
        "Student Name ${index + 1}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 14 : 16,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "student${index + 1}@example.com",
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey,
              fontSize: 12,
            ),
          ),
          if (isMobile) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildBadge("3 Courses", isDark, Colors.blue, false),
                _buildBadge("Active", isDark, Colors.green, true),
              ],
            ),
          ],
        ],
      ),
      trailing: isMobile
          ? IconButton(
              onPressed: () {},
              icon: Icon(
                Iconsax.more,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBadge("3 Courses", isDark, Colors.blue, false),
                const SizedBox(width: 16),
                _buildBadge("Active", isDark, Colors.green, true),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Iconsax.more,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBadge(
    String text,
    bool isDark,
    MaterialColor color,
    bool isStatus,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isStatus
            ? const Color(0xFFE8F5E9)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : color.shade50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isStatus
              ? const Color(0xFF2E7D32)
              : (isDark ? Colors.white70 : color),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
