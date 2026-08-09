import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class CheckpointManagementScreen extends StatelessWidget {
  const CheckpointManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Highway Blockades', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(top: 100, right: 0, child: _buildGlow(Colors.orangeAccent)),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
          
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildCheckpointCard('NH-44 Checkpoint Alpha', 'Active', Colors.greenAccent).animate().slideX(begin: -1).fade(),
                const SizedBox(height: 16),
                _buildCheckpointCard('State Highway 12 Blockade', 'Deploying', Colors.orangeAccent).animate().slideX(begin: -1).fade(delay: 100.ms),
                const SizedBox(height: 16),
                _buildCheckpointCard('City Exit Toll Plaza', 'Inactive', Colors.redAccent).animate().slideX(begin: -1).fade(delay: 200.ms),
                const SizedBox(height: 32),
                _buildButton(context, 'DEPLOY NEW CHECKPOINT').animate().scale(delay: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(20)),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 3.seconds, begin: const Offset(1,1), end: const Offset(1.2,1.2));
  }

  Widget _buildCheckpointCard(String title, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withAlpha(10), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withAlpha(20))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withAlpha(20), shape: BoxShape.circle),
            child: Icon(Icons.security, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Status: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withAlpha(100)),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return Container(
      height: 60,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: [Colors.blueAccent, Color(0xFF0033CC)]), boxShadow: [BoxShadow(color: Colors.blueAccent.withAlpha(100), blurRadius: 20, offset: const Offset(0, 8))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        onPressed: () { Navigator.pop(context); },
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)),
      ),
    );
  }
}
