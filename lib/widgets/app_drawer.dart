import 'package:fitness_pj_3/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.username ?? '-'),
            accountEmail: Text(user?.email ?? '-'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('เพิ่มการออกกำลังกาย'),
            onTap: () => Navigator.pushNamed(context, '/workout-form'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('ประวัติ'),
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('วิเคราะห์ข้อมูล'),
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          if (user?.isAdmin ?? false)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Panel'),
              onTap: () => Navigator.pushNamed(context, '/admin'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ออกจากระบบ'),
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}

