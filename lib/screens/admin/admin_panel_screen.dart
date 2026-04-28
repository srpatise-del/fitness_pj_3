import 'package:fitness_pj_3/providers/admin_provider.dart';
import 'package:fitness_pj_3/providers/auth_provider.dart';
import 'package:fitness_pj_3/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!(auth.user?.isAdmin ?? false)) {
        Navigator.pop(context);
        return;
      }
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showUserDialog({
    int? id,
    String? username,
    String? email,
    String role = 'user',
  }) async {
    final admin = context.read<AdminProvider>();
    final usernameCtrl = TextEditingController(text: username ?? '');
    final emailCtrl = TextEditingController(text: email ?? '');
    final passCtrl = TextEditingController();
    String currentRole = role;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(id == null ? 'เพิ่มผู้ใช้' : 'แก้ไขผู้ใช้'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้')),
              TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'อีเมล')),
              if (id == null)
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                  obscureText: true,
                ),
              DropdownButtonFormField<String>(
                value: currentRole,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('user')),
                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                ],
                onChanged: (v) {
                  setState(() => currentRole = v ?? 'user');
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก')),
            ElevatedButton(
              onPressed: () async {
                // Add error handling for user operations
                try {
                  if (id == null) {
                    await admin.addUser(
                      username: usernameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text.trim(),
                      role: currentRole,
                    );
                  } else {
                    await admin.updateUser(
                      id: id,
                      username: usernameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      role: currentRole,
                    );
                  }
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
    // Dispose controllers after the dialog is dismissed
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
  }

  Future<void> _showWorkoutTypeDialog({int? id, String? name}) async {
    final ctrl = TextEditingController(text: name ?? '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'เพิ่มประเภทการออกกำลังกาย' : 'แก้ไขประเภท'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'ชื่อประเภท'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () async {
              // Add error handling for workout type operations
              try {
                final admin = context.read<AdminProvider>();
                if (id == null) {
                  await admin.addWorkoutType(ctrl.text.trim());
                } else {
                  await admin.updateWorkoutType(id, ctrl.text.trim());
                }
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    ); // Dispose controller after the dialog is dismissed
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ผู้ใช้'),
            Tab(text: 'Monitoring'),
            Tab(text: 'Workout Types'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) _showUserDialog();
          if (_tabController.index == 2) _showWorkoutTypeDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: admin.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  itemCount: admin.users.length,
                  itemBuilder: (context, index) {
                    final user = admin.users[index];
                    return ListTile(
                      title: Text(user.username),
                      subtitle: Text('${user.email} (${user.role})'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showUserDialog(
                              id: user.id,
                              username: user.username,
                              email: user.email,
                              role: user.role,
                            ),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => admin.deleteUser(user.id),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListView(
                  children: [
                    ...admin.activity.entries.map(
                      (e) => ListTile(
                        title: Text(e.key),
                        trailing: Text('${e.value} ครั้ง'),
                      ),
                    ),
                    const Divider(),
                    ...admin.latestWorkouts.take(10).map(
                          (w) => ListTile(
                            title: Text(w.type),
                            subtitle: Text('user_id: ${w.userId}'),
                            trailing: Text(w.dateText),
                          ),
                        ),
                  ],
                ),
                ListView.builder(
                  itemCount: admin.workoutTypes.length,
                  itemBuilder: (context, index) {
                    final type = admin.workoutTypes[index];
                    return ListTile(
                      title: Text(type['name'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showWorkoutTypeDialog(
                              id: type['id'] as int,
                              name: type['name'].toString(),
                            ),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () =>
                                admin.deleteWorkoutType(type['id'] as int),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text('Total Users'),
                        trailing: Text('${admin.report.totalUsers}'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Active Users'),
                        trailing: Text('${admin.report.activeUsers}'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Total Workouts'),
                        trailing: Text('${admin.report.totalWorkouts}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
