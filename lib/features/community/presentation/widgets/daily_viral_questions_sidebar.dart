import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';

class DailyViralQuestionsSidebar extends StatelessWidget {
  const DailyViralQuestionsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedFire,
                  color: Color(0xFFF43F5E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Trending Now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Top discussions from the community",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community')
                  .orderBy('createdAt', descending: true)
                  .limit(20) // Fetch batch to find viral/random
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Unable to load trends"));
                }
                if (!snapshot.hasData) {
                  return _buildLoadingSkeleton();
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No questions yet"));
                }

                // Strategy: Get recent 20, pick 5 random to simulate "Random Viral"
                // Or sort by engagement
                final List<QueryDocumentSnapshot> displayedDocs = List.from(
                  docs,
                );
                displayedDocs.shuffle(); // Randomize
                final finalDocs = displayedDocs.take(5).toList();

                return ListView.separated(
                  itemCount: finalDocs.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Colors.grey.shade100),
                  ),
                  itemBuilder: (context, index) {
                    final data =
                        finalDocs[index].data() as Map<String, dynamic>;
                    return _buildViralQuestionItem(data);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text("View All Trends"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            color: Colors.grey.shade100,
          ),
          const SizedBox(height: 8),
          Container(height: 12, width: 150, color: Colors.grey.shade100),
        ],
      ),
    );
  }

  Widget _buildViralQuestionItem(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Untitled Question';
    final solutions = data['solutionsCount'] ?? 0;
    final userImage = data['userImage'];

    return InkWell(
      onTap: () {
        // Navigate to details if needed
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF334155),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (userImage != null)
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(userImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedComment01,
                      size: 10,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$solutions Answers",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (solutions > 5) ...[
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAnalyticsUp,
                  size: 14,
                  color: Colors.green.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  "Trending",
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
