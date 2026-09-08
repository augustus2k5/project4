import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/api_service.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {

  List<UserModel> users = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final data = await ApiService.getUsers();

      setState(() {
        users = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> deleteUser(String id) async {
    final success = await ApiService.deleteUser(id);

    if (success) {
      await loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa người dùng thành công'),
          ),
        );
      }
    }
  }

  Future<void> toggleBlock(UserModel user) async {

    bool success;

    if (user.status == 'BLOCKED') {
      success = await ApiService.unblockUser(user.id);
    } else {
      success = await ApiService.blockUser(user.id);
    }

    if (success) {
      await loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadUsers,

              child: ListView.builder(
                padding: const EdgeInsets.all(20),

                itemCount: users.length,

                itemBuilder: (context, index) {

                  final user = users[index];

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),

                    child: ListTile(

                      leading: CircleAvatar(
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                        ),
                      ),

                      title: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        '${user.email}\n${user.role} • ${user.status}',
                      ),

                      isThreeLine: true,

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            tooltip: user.status == 'BLOCKED'
                                ? 'Mở khóa'
                                : 'Khóa',

                            icon: Icon(
                              user.status == 'BLOCKED'
                                  ? Icons.lock_open
                                  : Icons.block,
                            ),

                            onPressed: () {
                              toggleBlock(user);
                            },
                          ),

                          IconButton(
                            tooltip: 'Xóa',

                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),

                            onPressed: () {
                              deleteUser(user.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}