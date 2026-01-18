import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/course_service.dart';

class CoursesPage extends StatelessWidget {
  final VoidCallback onCreateCourse;
  final Function(String, Map<String, dynamic>) onEditCourse;

  const CoursesPage({
    super.key,
    required this.onCreateCourse,
    required this.onEditCourse,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final courseService = CourseService();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Course Management",
                              style: TextStyle(
                                fontSize: 20, // Smaller font
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: onCreateCourse,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A89FF),
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Icon(Iconsax.add, size: 20),
                            ),
                          ],
                        ),
                        Text(
                          "Manage your educational content",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey,
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
                              "Course Management",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              "Manage your educational content",
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: onCreateCourse,
                          icon: const Icon(Iconsax.add, size: 18),
                          label: const Text("Create Course"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A89FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 32),
              // Stream Builder for Real Data
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: courseService.getCourses(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.box,
                              size: 64,
                              color: isDark ? Colors.white24 : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No courses found",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350, // Slightly wider cards
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.8, // Taller cards
                          ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final id = docs[index].id;
                        return _CourseCard(
                          data: data,
                          id: id,
                          onDelete: () => courseService.deleteCourse(id),
                          onEdit: onEditCourse,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String id;
  final VoidCallback onDelete;
  final Function(String, Map<String, dynamic>) onEdit;

  const _CourseCard({
    required this.data,
    required this.id,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final title = data['title'] ?? 'Untitled Course';
    final price = data['price'] ?? 0;
    final thumbnailUrl = data['thumbnailUrl'] ?? '';
    final isPublished = data['isPublished'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? Colors.black26 : Colors.grey[100],
                image: thumbnailUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(thumbnailUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: thumbnailUrl.isEmpty
                  ? Icon(
                      Iconsax.image,
                      color: isDark ? Colors.white10 : Colors.grey[300],
                      size: 40,
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPublished ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isPublished ? "Published" : "Draft",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space out elements
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                if (data['badges'] != null &&
                    (data['badges'] as List).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 20,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: (data['badges'] as List).length,
                      separatorBuilder: (c, i) => const SizedBox(width: 4),
                      itemBuilder: (context, index) {
                        final badge = (data['badges'] as List)[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A89FF,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(
                                0xFF4A89FF,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            badge.toString(),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF4A89FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹$price",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A89FF),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onEdit(id, data),
                          icon: Icon(
                            Iconsax.edit,
                            size: 18,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Course?"),
                                content: const Text(
                                  "This action cannot be undone.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      onDelete();
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Iconsax.trash,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
