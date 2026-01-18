import 'package:flutter/material.dart';

class ReturnRefundPage extends StatelessWidget {
  const ReturnRefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Return & Refund",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Refund Policy",
              "We offer a 7-day money-back guarantee on all our courses if you are not satisfied with the content, provided you have not completed more than 30% of the course.",
            ),
            _buildSection(
              "How to Request",
              "To request a refund, please contact our support team within 7 days of purchase via the Help & Support page.",
            ),
            _buildSection(
              "Processing Time",
              "Refunds are processed within 5-10 business days and will be credited back to your original payment method.",
            ),
            _buildSection(
              "Non-Refundable Items",
              "Live coaching sessions and mentorship programs are non-refundable once scheduled.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
