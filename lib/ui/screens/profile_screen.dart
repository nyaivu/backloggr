import 'package:backloggr/core/constants.dart';
import 'package:backloggr/data/services/supabase_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = SupabaseService();
  void _handleLogout() {
    supabase.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.getUser();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BACKLOG",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.scaffoldBackground,
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(user!.email!),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.steamBlue.withAlpha(20),
                  foregroundColor: AppColors.steamBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: Text(
                  'Log out of account',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
