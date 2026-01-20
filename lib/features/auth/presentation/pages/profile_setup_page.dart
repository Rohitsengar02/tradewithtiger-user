import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradewithtiger/features/home/presentation/pages/home_page.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tradewithtiger/core/services/cloudinary_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:tradewithtiger/features/home/presentation/pages/web_home_page.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  bool _isLoading = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _existingPhotoUrl;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _existingPhotoUrl = user.photoURL;
      });
    }
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? photoURL;
        if (_imageFile != null) {
          debugPrint("Starting image upload...");
          photoURL = await CloudinaryService().uploadImage(_imageFile!);
          debugPrint("Upload result: $photoURL");
        }

        final Map<String, dynamic> data = {
          'displayName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'occupation': _occupationController.text.trim(),
          'isProfileComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (photoURL != null) {
          data['photoURL'] = photoURL;
          await user.updatePhotoURL(photoURL); // Update Auth profile too
        } else if (_imageFile != null) {
          debugPrint("Upload failed, photoURL is null");
          // Optional: Show error to user?
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please try again.'),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(data);

        if (mounted) {
          if (kIsWeb && MediaQuery.of(context).size.width > 900) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WebHomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout();
          }
          return _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F4F6), Color(0xFFE0E7FF)],
        ),
      ),
      child: Center(
        child: Container(
          width: 500,
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: SingleChildScrollView(child: _buildFormContent()),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Complete Your Profile",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1E2D),
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          const Text(
            "Tell us a bit more about yourself to get started.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 48),

          const SizedBox(height: 20),
          // Image Picker UI
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    color: Colors.grey.shade100,
                    image: _imageFile != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(_imageFile!.path)
                                : FileImage(File(_imageFile!.path))
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : (_existingPhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_existingPhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  ),
                  child: _imageFile == null && _existingPhotoUrl == null
                      ? const Icon(Iconsax.user, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B1B2F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.camera,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Name Field
          _buildLabel("Full Name"),
          _buildInputField(
            controller: _nameController,
            hint: "John Doe",
            icon: Iconsax.user,
            validator: (v) => v?.isEmpty ?? true ? "Name is required" : null,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          const SizedBox(height: 24),

          // Phone Field
          _buildLabel("Phone Number"),
          _buildInputField(
            controller: _phoneController,
            hint: "+1 234 567 8900",
            icon: Iconsax.call,
            keyboardType: TextInputType.phone,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 24),

          // Occupation Field
          _buildLabel("Occupation / Trading Style"),
          _buildInputField(
            controller: _occupationController,
            hint: "Day Trader, Investor, etc.",
            icon: Iconsax.briefcase,
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
          const SizedBox(height: 48),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B1B2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E1E2D),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
