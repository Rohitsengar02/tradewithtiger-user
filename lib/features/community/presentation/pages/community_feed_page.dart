import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:tradewithtiger/features/community/presentation/pages/create_post_page.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPostCard(context, index),
                  childCount: 3,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/mentor_1.png"),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Trader's Q&A",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add_comment_rounded, size: 14),
              label: const Text(
                "Ask",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D1FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, int index) {
    final posts = [
      {
        "user": "Ethan Clarke",
        "tag": "Expert Trader",
        "userImage": "assets/images/mentor_1.png",
        "question":
            "How to identify a fakeout in a high-volatility market like Forex?",
        "content":
            "I've been noticing that often the price breaks the resistance but immediately reverses. What indicators do you use to confirm a true breakout?",
        "image": "assets/images/course_bg_analysis.png",
        "likes": "164",
        "solutions": "18",
        "isSaved": false,
      },
      {
        "user": "Sophia Mitchell",
        "tag": "Price Action Pro",
        "userImage": "assets/images/mentor_2.png",
        "question": "Best timeframes for scalping Nifty 50 options?",
        "content":
            "I'm currently using 1-minute charts but finding too much noise. Would switching to 3-minute or 5-minute be better for consistent entries?",
        "image": null,
        "likes": "245",
        "solutions": "32",
        "isSaved": true,
      },
      {
        "user": "Lili Evans",
        "tag": "Technical Analyst",
        "userImage": "assets/images/mentor_3.png",
        "question":
            "Is RSI enough for spotting divergences, or should I combine it with MACD?",
        "content":
            "Looking for some advice on creating a robust divergence strategy. Here's a recent chart I was analyzing. Any thoughts?",
        "image": "assets/images/course_bg_priceaction.png",
        "likes": "512",
        "solutions": "64",
        "isSaved": false,
      },
    ];

    final post = posts[index % posts.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
                  backgroundImage: AssetImage(post['userImage'] as String),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['user'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        post['tag'] as String,
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
                  onPressed: () {},
                  icon: Icon(
                    (post['isSaved'] as bool)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: (post['isSaved'] as bool)
                        ? Colors.blue
                        : Colors.grey,
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
                  post['question'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['content'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (post['image'] != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: AssetImage(post['image'] as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                _buildCardAction(
                  context,
                  HugeIcons.strokeRoundedFavourite,
                  post['likes'] as String,
                ),
                const SizedBox(width: 8),
                _buildCardAction(
                  context,
                  HugeIcons.strokeRoundedComment01,
                  "${post['solutions']} Sols.",
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 200).ms).slideY(begin: 0.1);
  }

  Widget _buildCardAction(
    BuildContext context,
    List<List<dynamic>> icon,
    String count,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: Colors.black87, size: 20),
          const SizedBox(width: 6),
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CommentSheet(),
    );
  }
}

class CommentSheet extends StatelessWidget {
  const CommentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Solutions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 5,
              itemBuilder: (context, index) {
                final commentAuthors = [
                  {
                    "name": "Sophia Mitchell",
                    "image": "assets/images/avatar_sophia.png",
                  },
                  {
                    "name": "Ethan Clarke",
                    "image": "assets/images/avatar_ethan.png",
                  },
                  {
                    "name": "Lili Evans",
                    "image": "assets/images/avatar_lili.png",
                  },
                  {
                    "name": "Ryan Sterling",
                    "image": "assets/images/avatar_ryan.png",
                  },
                  {"name": "Mark Owen", "image": "assets/images/avatar.png"},
                ];
                final author = commentAuthors[index % commentAuthors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(author['image']!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              "Real style is all about wearing pink with confidence. Stunning! ✨",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Reply",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Hide",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.pink,
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "164",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D1FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
