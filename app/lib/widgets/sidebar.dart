import 'package:flutter/material.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
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
      child: Container(
        color: AppColors.sageGreenLight.withOpacity(0.3),
        child: user == null
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.mainSageGreen,
                ),
              )
            : Column(
                children: [
                  // Use UserAccountsDrawerHeader with bottom border removed
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        bottom: BorderSide.none, // Removes bottom line
                      ),
                    ),
                    margin: EdgeInsets.zero,
                    accountName: Padding(
                      padding: const EdgeInsets.only(top: 12.0), // adds space from top + pic
                      child: Text(
                        user.name.isNotEmpty ? user.name : 'No Name',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.mainSageGreen,
                        ),
                      ),
                    ),
                    accountEmail: Text(
                      user.email.isNotEmpty ? user.email : 'No Email',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.mainSageGreen,
                      ),
                    ),
                    currentAccountPicture: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // adds spacing below pic
                      child: CircleAvatar(
                        backgroundImage: (user.profilePhoto.isNotEmpty)
                            ? NetworkImage(user.profilePhoto)
                            : null,
                        child: (user.profilePhoto.isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.mainSageGreen,
                              )
                            : null,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),

                  // Use Expanded ListView for the drawer items except logout
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                    //     _createDrawerItem(
                    //       icon: Icons.home,
                    //       text: 'Home',
                    //       onTap: () => _navigateTo(context, '/home'),
                    //       iconColor: AppColors.mainSageGreen,
                    //       textColor: AppColors.mainSageGreen,
                    //     ),

                        // Uncomment and add more items as needed

                        // _createDrawerItem(
                        //   icon: Icons.calendar_today,
                        //   text: 'My Agenda',
                        //   onTap: () => _navigateTo(context, '/agenda'),
                        //   iconColor: AppColors.mainSageGreen,
                        //   textColor: AppColors.mainSageGreen,
                        // ),

                        // Add dividers or other items here
                      ],
                    ),
                  ),

                  // Logout at bottom with some padding
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _createDrawerItem(
                      icon: Icons.logout,
                      text: 'Log Out',
                      onTap: () {
                        authProvider.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      iconColor: AppColors.mainSageGreen,
                      textColor: AppColors.mainSageGreen,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushNamed(context, route);
  }
}
