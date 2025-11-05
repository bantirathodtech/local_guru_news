import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/auth_provider.dart';
import '../signin/sign_in_v2.dart';

class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({Key? key}) : super(key: key);

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isEditing = false;
  File? _imageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _contactController.text = user.contact ?? '';
      _aadharController.text = user.aadharNumber ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user?.id == null || user?.role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    // Validate required fields
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _contactController.text.trim().isEmpty ||
        _aadharController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await auth.updateProfile(
        id: user!.id!,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: user.role!,
        aadharNumber: _aadharController.text.trim(),
        address: _addressController.text.trim(),
        contact: _contactController.text.trim(),
        image: _imageFile,
      );
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _imageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  Future<void> _onLogout() async {
    final auth = context.read<AuthProvider>();

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await auth.logout();
      if (!mounted) return;

      // Navigate to sign in and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreenV2()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        iconColor: Colors.black,
        backgroundColor: Colors.white,
        titleColor: Colors.black,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: auth.isLoading
                  ? null
                  : () {
                      _initializeControllers();
                      setState(() {
                        _isEditing = false;
                        _imageFile = null;
                      });
                    },
              child: const Text('Cancel'),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _initializeControllers();
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user data'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : (user.profile != null &&
                                        user.profile!.isNotEmpty)
                                    ? NetworkImage(user.profile!)
                                        as ImageProvider
                                    : null,
                            child: _imageFile == null &&
                                    (user.profile == null ||
                                        user.profile!.isEmpty)
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // User Info Card
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              icon: Icons.person_outline,
                              label: 'Name',
                              value: user.name ?? '-',
                              isEditing: _isEditing,
                              controller: _nameController,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email ?? '-',
                              isEditing: _isEditing,
                              controller: _emailController,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Contact',
                              value: user.contact ?? '-',
                              isEditing: _isEditing,
                              controller: _contactController,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.badge_outlined,
                              label: 'Aadhar Number',
                              value: user.aadharNumber ?? '-',
                              isEditing: _isEditing,
                              controller: _aadharController,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: user.address ?? '-',
                              isEditing: _isEditing,
                              controller: _addressController,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.badge_outlined,
                              label: 'Role',
                              value: user.role?.toUpperCase() ?? '-',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              icon: Icons.fingerprint_outlined,
                              label: 'User ID',
                              value: user.id ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button (if editing)
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: auth.isLoading ? null : _save,
                          icon: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: auth.isLoading ? null : _onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),

                    if (auth.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isEditing = false,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing && controller != null
                    ? TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
