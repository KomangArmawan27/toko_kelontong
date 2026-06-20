import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/api_client.dart';
import '../../services/api_data.dart';
import '../../widgets/app_drawer.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<AppUser> _users = [];
  bool _isLoading = true;
  String? _error;

  AppUser? get _currentUser => ApiClient.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<List<AppUser>> _load() async {
    return ApiClient.instance.listUsers();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _load();
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeRole(AppUser user, String role) async {
    if (user.id == null || user.id == _currentUser?.id) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change user role?'),
        content: Text(
          '${user.name} will be updated to ${_roleLabel(role)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await ApiClient.instance.updateUserRole(user.id!, role);
      final updated = dataMap(response)['user'];
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.name} updated to ${_roleLabel(role)}.',
          ),
        ),
      );
      if (updated is Map<String, dynamic>) {
        await _refresh();
      } else {
        await _refresh();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case AppUser.shopOwner:
        return 'Shop Owner';
      case AppUser.shopKeeper:
        return 'Shop Keeper';
      default:
        return 'Customer';
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final user = _users[index];
          final isMe = user.id != null && user.id == _currentUser?.id;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(_initials(user.name)),
              ),
              title: Text(
                isMe ? '${user.name} (You)' : user.name,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(user.label)),
                      if (isMe)
                        const Chip(
                          label: Text('Current account'),
                        ),
                    ],
                  ),
                ],
              ),
              trailing: isMe
                  ? const Text('Self')
                  : PopupMenuButton<String>(
                      tooltip: 'Change role',
                      onSelected: (role) => _changeRole(user, role),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: AppUser.shopKeeper,
                          child: Text('Promote to Shop Keeper'),
                        ),
                        const PopupMenuItem(
                          value: AppUser.shopOwner,
                          child: Text('Promote to Shop Owner'),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}



