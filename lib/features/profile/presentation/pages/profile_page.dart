import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view profile")),
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

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("User not found")));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildCoverHeader(context, userData),
                _buildUserInfo(user, userData),
                _buildStatsCards(),
                _buildSectionHeader("Activity", "Sort"),
                _buildActivityFeed(userData['displayName'] ?? 'User'),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoverHeader(
    BuildContext context,
    Map<String, dynamic> userData,
  ) {
    final String? photoUrl = userData['photoURL'];

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // Cover Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/profile_cover.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // App Bar Actions
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.arrow_back_ios_new_rounded),
                Row(
                  children: [
                    _buildCircleButton(Icons.ios_share_rounded),
                    const SizedBox(width: 12),
                    _buildCircleButton(Icons.settings_outlined),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Text(
                          "Edit profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Profile Picture
          Positioned(
            bottom: 0,
            left: 20,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : const AssetImage("assets/images/avatar_ryan.png")
                              as ImageProvider,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
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

  Widget _buildCircleButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
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
              if (userData['role'] == 'admin') // Example badge logic
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
        children: [
          Expanded(child: _buildStatCard("0", "Courses owned")),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard("0", "Live sessions")),
        ],
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

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.sort_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActivityItem(
            userName,
            "Welcome to the community!",
            "You just joined Tiger Trade.",
            "assets/images/post_1.png",
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String name,
    String title,
    String subtitle,
    String image,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage("assets/images/avatar_ryan.png"),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Spacer(),
            const Icon(
              Icons.remove_red_eye_outlined,
              size: 14,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            const Text("0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 12),
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            const Text(
              "Just now",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade100, // Placeholder color
            // image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
