import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:tradewithtiger/features/home/presentation/widgets/web_sidebar.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/login_page.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/signup_page.dart';
import 'package:intl/intl.dart';
import 'package:tradewithtiger/features/community/presentation/widgets/community_post_card.dart';

import 'package:tradewithtiger/features/profile/presentation/pages/legal/about_us_page.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/legal/help_support_page.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/legal/privacy_policy_page.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/legal/return_refund_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return _buildDesktopNotLoggedInView(context);
            }
            return _buildMobileNotLoggedInView(context);
          },
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = (snapshot.hasData && snapshot.data!.exists)
            ? snapshot.data!.data() as Map<String, dynamic>
            : {
                'displayName': user.displayName ?? 'Tiger User',
                'email': user.email,
              };

        return Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildDesktopLayout(user, userData);
              }
              return _buildMobileLayout(context, user, userData);
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(User user, Map<String, dynamic> userData) {
    return Row(
      children: [
        const SizedBox(width: 250, child: WebSidebar(activePage: "Profile")),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 350,
                  child: _buildCoverHeader(null, userData, isDesktop: true),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _buildUserInfo(user, userData),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsCards(),
                                const SizedBox(height: 32),
                                const Text(
                                  "Saved Posts",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSavedPosts(user.uid),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(flex: 1, child: _buildSupportLinks(context)),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    User user,
    Map<String, dynamic> userData,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildCoverHeader(context, userData),
          _buildUserInfo(user, userData),
          _buildStatsCards(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: _buildSupportLinks(context),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Posts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSavedPosts(user.uid),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSavedPosts(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_posts')
          .orderBy('savedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "No saved posts yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final postId = data['postId'] ?? docs[index].id;

            return CommunityPostCard(
              data: data,
              postId: postId,
              isSaved: true,
              showActions: false,
              onSaveToggle: () async {
                // Unsave
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('saved_posts')
                    .doc(postId)
                    .delete();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSupportLinks(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Support & Legal",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          _buildLinkItem(Icons.info_outline_rounded, "About Us", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
          }),
          _buildLinkItem(Icons.help_outline_rounded, "Help & Support", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupportPage()),
            );
          }),
          _buildLinkItem(Icons.privacy_tip_outlined, "Privacy Policy", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyPage(),
              ),
            );
          }),
          _buildLinkItem(Icons.refresh_rounded, "Return & Refund", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReturnRefundPage()),
            );
          }),
          const Divider(height: 30),
          _buildLinkItem(Icons.logout_rounded, "Log Out", () async {
            await FirebaseAuth.instance.signOut();
            // Force state refresh or navigation if needed,
            // typically the StreamBuilder at the root of the page handles the UI update
            // or navigate to home/login
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.red : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverHeader(
    BuildContext? context,
    Map<String, dynamic> userData, {
    bool isDesktop = false,
  }) {
    final String? photoUrl = userData['photoURL'];

    return SizedBox(
      height: isDesktop ? 350 : 280,
      child: Stack(
        children: [
          // Cover Image
          Container(
            height: isDesktop ? 250 : 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/profile_cover.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // App Bar Actions (Only if context provided - typically mobile)
          if (context != null && !isDesktop)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      _buildCircleButton(Icons.ios_share_rounded),
                      const SizedBox(width: 12),
                      _buildCircleButton(Icons.settings_outlined),
                      const SizedBox(width: 12),
                      _buildEditProfileButton(context),
                    ],
                  ),
                ],
              ),
            ),
          // Desktop Edit Button
          if (isDesktop)
            Positioned(
              top: 20,
              right: 40,
              child: _buildEditProfileButton(context ?? userData['context']),
            ),

          // Profile Picture
          Positioned(
            bottom: 0,
            left: isDesktop ? 40 : 20,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: isDesktop ? 140 : 100,
                    height: isDesktop ? 140 : 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      image: photoUrl != null && photoUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                "assets/images/avatar_ryan.png",
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: photoUrl == null || photoUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey, size: 40)
                        : null,
                  ),
                ),
                Container(
                  width: isDesktop ? 30 : 20,
                  height: isDesktop ? 30 : 20,
                  margin: const EdgeInsets.only(bottom: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext? context) {
    if (context == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: const Text(
          "Edit profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildUserInfo(User user, Map<String, dynamic> userData) {
    final String name = userData['displayName'] ?? 'User';
    final String email = userData['email'] ?? user.email ?? '';
    final String occupation = userData['occupation'] ?? 'New Member';
    final String location = userData['location'] ?? 'Global';

    // Format join date
    String joinedDate = "Joined recently";
    if (userData['createdAt'] != null) {
      final Timestamp ts = userData['createdAt'];
      joinedDate = "Joined ${DateFormat.yMMM().format(ts.toDate())}";
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (userData['role'] == 'admin')
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          Text(
            occupation,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(Icons.location_on_outlined, location),
              const SizedBox(width: 16),
              _buildInfoItem(Icons.calendar_month_outlined, joinedDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [Expanded(child: _buildStatCard("0", "Courses owned"))],
      ),
    );
  }

  Widget _buildStatCard(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDesktopNotLoggedInView(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 250, child: WebSidebar(activePage: "Profile")),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3F4F6), Color(0xFFE0E7FF)],
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _buildAuthPromptContent(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNotLoggedInView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: _buildAuthPromptContent(context),
      ),
    );
  }

  Widget _buildAuthPromptContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Not Logged In",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E1E2D),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Log in to view your profile, track your progress, and access your courses.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  foregroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
