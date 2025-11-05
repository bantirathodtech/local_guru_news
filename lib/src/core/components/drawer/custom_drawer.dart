import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/features/location/view/screens/location_screen_v2.dart';
import 'package:local_guru_all/src/src.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import 'footer/copyright_footer.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  String _maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '*****';
    if (phone.length <= 4) return '*****';
    return phone.substring(0, 4) + '*' * (phone.length - 4);
  }

  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }

  Future<void> _logout(BuildContext context) async {
    // Use the provider's logout method
    await context.read<AuthProvider>().logout();

    // Clear navigation stack and go to login
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreenV2()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _switchTab(BuildContext context, WidgetRef ref, int tabIndex) {
    // Switch tab using currentIndexProvider
    ref.read(currentIndexProvider.notifier).state = tabIndex;

    // Close drawer
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    // Get user data
    final userName = currentUser?.name ?? 'Guest';
    final userPhone = _maskPhone(currentUser?.contact);
    final userProfileImage = currentUser?.profile;

    // Truncate long names to prevent overflow
    final displayName = _truncateName(userName, 15);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ============ Header with Profile Preview ============
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const ProfileScreenV2()),
              );
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.primaryDark],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Photo
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        userProfileImage != null && userProfileImage.isNotEmpty
                            ? NetworkImage(userProfileImage) as ImageProvider
                            : null,
                    child: userProfileImage == null || userProfileImage.isEmpty
                        ? const Icon(
                            Icons.account_circle_outlined,
                            size: 50,
                            color: AppColors.accent,
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  // User Name
                  Text(
                    'Hello, $displayName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Masked Phone
                  Text(
                    userPhone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // ============ Tab Navigation Menu Items ============
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text('News'),
            onTap: () => _switchTab(context, ref, 0),
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Jobs'),
            onTap: () => _switchTab(context, ref, 1),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Listings'),
            onTap: () => _switchTab(context, ref, 2),
          ),
          ListTile(
            leading: const Icon(Icons.celebration),
            title: const Text('Greetings'),
            onTap: () => _switchTab(context, ref, 3),
          ),

          const Divider(),

          // ============ Other Menu Items ============
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const ProfileScreenV2()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Location'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const LocationScreenV2()),
              );
            },
          ),

          const SizedBox(height: 20),

          // ============ Logout Button ============
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ============ Footer ============
          const SizedBox(height: 20),
          const CopyrightFooter(),
        ],
      ),
    );
  }
}
