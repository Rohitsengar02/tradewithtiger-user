import 'package:flutter/material.dart';

import 'package:tradewithtiger/features/home/presentation/widgets/web_mobile_bottom_bar.dart';
import 'package:tradewithtiger/features/home/presentation/widgets/web_sidebar.dart';
import 'package:tradewithtiger/features/community/presentation/widgets/daily_viral_questions_sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tradewithtiger/features/community/presentation/pages/create_post_page.dart';
import 'package:tradewithtiger/features/community/presentation/widgets/community_post_card.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: const WebMobileBottomBar(currentRoute: "COMMUNITY"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('community')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final posts = snapshot.data?.docs ?? [];

          // If user is logged in, listen to their saved posts
          if (user != null) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('saved_posts')
                  .snapshots(),
              builder: (context, savedSnapshot) {
                final savedIds =
                    savedSnapshot.data?.docs.map((d) => d.id).toSet() ?? {};

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return _buildDesktopLayout(context, posts, savedIds);
                    }
                    return _buildMobileLayout(context, posts, savedIds);
                  },
                );
              },
            );
          }

          // Guest user: no saved posts
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildDesktopLayout(context, posts, {});
              }
              return _buildMobileLayout(context, posts, {});
            },
          );
        },
      ),
    );
  }

  void _handleSave(String postId, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_posts')
        .doc(postId);

    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'postId': postId,
        'savedAt': FieldValue.serverTimestamp(),
        'title': data['title'],
        'description': data['description'],
        'imageUrl': data['imageUrl'],
        'userImage': data['userImage'],
        'userName': data['userName'],
        'userRole': data['userRole'],
        'createdAt': data['createdAt'],
      });
    }
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    List<QueryDocumentSnapshot> posts,
    Set<String> savedIds,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 250, child: WebSidebar(activePage: "Community")),
        Expanded(
          child: Container(
            color: const Color(0xFFF9FAFB),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                if (posts.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          "No questions yet. Be the first to ask!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: CommunityPostCard(
                              data: posts[index].data() as Map<String, dynamic>,
                              postId: posts[index].id,
                              isSaved: savedIds.contains(posts[index].id),
                              onSaveToggle: () => _handleSave(
                                posts[index].id,
                                posts[index].data() as Map<String, dynamic>,
                              ),
                            ),
                          ),
                        ),
                        childCount: posts.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 300, child: DailyViralQuestionsSidebar()),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<QueryDocumentSnapshot> posts,
    Set<String> savedIds,
  ) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          if (posts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    "No questions yet. Be the first to ask!",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => CommunityPostCard(
                    data: posts[index].data() as Map<String, dynamic>,
                    postId: posts[index].id,
                    isSaved: savedIds.contains(posts[index].id),
                    onSaveToggle: () => _handleSave(
                      posts[index].id,
                      posts[index].data() as Map<String, dynamic>,
                    ),
                  ),
                  childCount: posts.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
}
