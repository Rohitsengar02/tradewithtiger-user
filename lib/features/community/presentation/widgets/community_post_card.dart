import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tradewithtiger/features/community/presentation/widgets/comment_sheet.dart';

class CommunityPostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String postId;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final bool showActions;

  const CommunityPostCard({
    super.key,
    required this.data,
    required this.postId,
    required this.isSaved,
    required this.onSaveToggle,
    this.showActions = true,
  });

  void _showCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userImage = data['userImage'] as String?;
    final imageUrl = data['imageUrl'] as String?;
    final likes = data['likes'] as List<dynamic>? ?? [];
    final timestamp = data['createdAt'] as Timestamp?;

    // Format timestamp
    String timeAgo = "";
    if (timestamp != null) {
      timeAgo = DateFormat.yMMMd().format(timestamp.toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: showActions
            ? Colors.white
            : Colors.grey.shade50, // Slightly simpler bg for saved
        borderRadius: BorderRadius.circular(32),
        border: showActions ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: userImage != null && userImage.isNotEmpty
                      ? NetworkImage(userImage)
                      : const AssetImage("assets/images/avatar_ryan.png")
                            as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['userName'] ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${data['userRole'] ?? 'Trader'} • $timeAgo",
                        style: TextStyle(
                          color: Colors.blue.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSaveToggle,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? const Color(0xFF00D1FF) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['description'] ?? "",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey.shade100,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
            ),

          if (showActions) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  // Likes
                  InkWell(
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final ref = FirebaseFirestore.instance
                            .collection('community')
                            .doc(postId);
                        if (likes.contains(user.uid)) {
                          ref.update({
                            'likes': FieldValue.arrayRemove([user.uid]),
                          });
                        } else {
                          ref.update({
                            'likes': FieldValue.arrayUnion([user.uid]),
                          });
                        }
                      }
                    },
                    child: _buildCardAction(
                      context,
                      likes.contains(FirebaseAuth.instance.currentUser?.uid)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      "${likes.length}",
                      color:
                          likes.contains(FirebaseAuth.instance.currentUser?.uid)
                          ? Colors.pink
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCardAction(
                    context,
                    Icons.mode_comment_outlined,
                    "${data['solutionsCount'] ?? 0} Sols.",
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _showCommentsSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D1FF).withOpacity(0.1),
                      foregroundColor: const Color(0xFF00D1FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      "Solve",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 20),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildCardAction(
    BuildContext context,
    IconData icon,
    String count, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.black87, size: 20),
          const SizedBox(width: 6),
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
