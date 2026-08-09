import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/responder_state.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ResponderState>(context);
    final earnings = state.completedMissionsCount * 500.0;
    
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                      ),
                    ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'PAYOUTS & WALLET',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.successGreen, letterSpacing: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Animated Double Glow Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.05), shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenLight,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.successGreen.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)],
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 48, color: AppColors.successGreen),
                ),
              ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              const Text('Total Balance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textGrey)).animate().fade().slideY(begin: 0.1),
              const SizedBox(height: 8),
              Text('₹ ${earnings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.successGreen, letterSpacing: -2.0)).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 36),
              
              // Massive White Data Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppColors.premiumCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RECENT TRANSACTIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
                    const SizedBox(height: 24),
                    
                    _buildTransaction('Mission #8842', 'Oct 12, 14:30', '+ ₹ 450.00', true),
                    _buildDivider(),
                    _buildTransaction('Mission #8841', 'Oct 12, 10:15', '+ ₹ 300.00', true),
                    _buildDivider(),
                    _buildTransaction('Bank Withdrawal', 'Oct 10, 09:00', '- ₹ 2,500.00', false),
                    
                    const SizedBox(height: 40),
                    
                    // Powerful Gradient Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [AppColors.successGreen, Color(0xFF16A34A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(color: AppColors.successGreen.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('WITHDRAW FUNDS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransaction(String title, String date, String amount, bool isCredit) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCredit ? AppColors.successGreenLight : AppColors.emergencyRedBg,
            shape: BoxShape.circle,
          ),
          child: Icon(isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
                     color: isCredit ? AppColors.successGreen : AppColors.emergencyRed, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
            ],
          ),
        ),
        Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isCredit ? AppColors.successGreen : AppColors.textDark)),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: AppColors.textGrey.withOpacity(0.1), thickness: 1.5),
    );
  }
}
