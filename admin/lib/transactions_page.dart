import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Transactions",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Track all financial activity",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
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
                padding: const EdgeInsets.all(24),
                itemCount: 10,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? Colors.white10 : Colors.grey[100],
                  height: 32,
                ),
                itemBuilder: (context, index) {
                  return _buildTransactionItem(context, index, isDark);
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTransactionItem(BuildContext context, int index, bool isDark) {
    // Dummy Data Generation
    final isCredit = index % 3 != 0;
    final amount = (index + 1) * 1500;
    final status = index % 4 == 0 ? "Pending" : "Success";
    final statusColor = status == "Success"
        ? [const Color(0xFF00B087), const Color(0xFF00695C)]
        : [const Color(0xFFFFB74D), const Color(0xFFF57C00)];

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCredit
                  ? [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)]
                  : [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isCredit ? Iconsax.arrow_down : Iconsax.arrow_up,
            color: isCredit ? const Color(0xFF1976D2) : const Color(0xFFD32F2F),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCredit
                    ? "Course Purchase: Advance Forex"
                    : "Refund Processed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${DateFormat('MMM d, yyyy').format(DateTime.now().subtract(Duration(days: index)))} • ID: #TRX883$index",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${isCredit ? '+' : '-'} ₹$amount",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCredit
                    ? const Color(0xFF00B087)
                    : const Color(0xFFFF6D6D),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: statusColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
