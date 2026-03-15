import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';
import 'package:snake_bite_resq/widgets/glass_card.dart';
import 'package:snake_bite_resq/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final unitInitial = (authService.unitId?.isNotEmpty ?? false)
        ? authService.unitId![0].toUpperCase()
        : "S";

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blueGrey.shade900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Station Profile",
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- AVATAR & INFO ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          unitInitial,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authService.hospitalName ?? "Unknown Hospital",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authService.unitId ?? "Unknown Unit",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        "● Active Unit",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- STATION INFO SECTION ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Station Info",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.local_hospital_outlined,
                      title: "Hospital",
                      value: authService.hospitalName ?? "—",
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildInfoTile(
                      icon: Icons.badge_outlined,
                      title: "Unit ID",
                      value: authService.unitId ?? "—",
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: "Region",
                      value: "Kedah, Malaysia",
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildInfoTile(
                      icon: Icons.medical_services_outlined,
                      title: "System",
                      value: "SnakeBiteResQ v1.0.0",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- QUICK ACTIONS ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.sync_rounded,
                      title: "Sync Offline Records",
                      subtitle: "Upload pending cases to server",
                      iconColor: Colors.blue.shade700,
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Syncing offline records..."),
                            backgroundColor: Colors.teal,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSettingsTile(
                      icon: Icons.phone_outlined,
                      title: "Poison Centre",
                      subtitle: "Hospital KL — 03-2615 5555",
                      iconColor: Colors.green.shade600,
                      onTap: () async {
                        final uri = Uri.parse("tel:0326155555");
                        try {
                          await launchUrl(uri);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Could not launch dialer"),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      subtitle: "Contact system admin",
                      iconColor: Colors.blue.shade600,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              "System Contact",
                              style: TextStyle(color: Colors.blueGrey.shade900),
                            ),
                            content: Text(
                              "For technical issues, contact:\n\nSystem Admin\nsnakebiteresq@moh.gov.my\n+60 4-740 6233 ext. 100",
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                height: 1.6,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- LOGOUT ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          "End Shift?",
                          style: TextStyle(color: Colors.blueGrey.shade900),
                        ),
                        content: Text(
                          "This will lock the station. Continue?",
                          style: TextStyle(color: Colors.blueGrey.shade700),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              "End Shift",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await authService.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.lock_clock),
                  label: const Text(
                    "END SHIFT / LOCK",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "SnakeBiteResQ v1.0.0",
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(
        title,
        style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Colors.blueGrey.shade900,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? Colors.blue.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.blueGrey.shade900,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.blueGrey.shade300,
        size: 16,
      ),
    );
  }
}
