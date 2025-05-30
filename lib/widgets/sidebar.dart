import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harf_ba_harf/providers/user_provider.dart';
import 'package:harf_ba_harf/providers/auth_provider.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<CustomAuthProvider>(
      context,
      listen: false,
    );
    final user = userProvider.user;

    return Drawer(
      child:
          user == null
              ? Builder(
                builder: (context) {
                  return const Center(child: CircularProgressIndicator());
                },
              )
              : Builder(
                builder: (context) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(
                          user.name.isNotEmpty ? user.name : 'No Name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        accountEmail: Text(
                          user.email.isNotEmpty ? user.email : 'No Email',
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage:
                              (user.profilePhoto.isNotEmpty)
                                  ? NetworkImage(user.profilePhoto)
                                  : null,
                          child:
                              (user.profilePhoto.isEmpty)
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                        ),
                        decoration: BoxDecoration(color: Colors.blue.shade700),
                      ),
                      _createDrawerItem(
                        icon: Icons.home,
                        text: 'Home',
                        onTap: () => _navigateTo(context, '/home'),
                      ),
                      _createDrawerItem(
                        icon: Icons.calendar_today,
                        text: 'My Agenda',
                        onTap: () => _navigateTo(context, '/agenda'),
                      ),
                      _createDrawerItem(
                        icon: Icons.link,
                        text: 'My Linked Accounts',
                        onTap: () => _navigateTo(context, '/linked-accounts'),
                      ),
                      _createDrawerItem(
                        icon: Icons.folder,
                        text: 'Folders',
                        onTap: () => _navigateTo(context, '/folders'),
                      ),
                      _createDrawerItem(
                        icon: Icons.people,
                        text: 'Speakers',
                        onTap: () => _navigateTo(context, '/speakers'),
                      ),
                      _createDrawerItem(
                        icon: Icons.work,
                        text: 'Projects',
                        onTap: () => _navigateTo(context, '/projects'),
                      ),
                      const Divider(),
                      _createDrawerItem(
                        icon: Icons.logout,
                        text: 'Log Out',
                        onTap: () {
                          authProvider.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  );
                },
              ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, route);
  }
}
