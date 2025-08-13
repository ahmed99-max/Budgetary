import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../core/utils/app_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TextEditingController _nameController;
  late TextEditingController _incomeController;
  File? _pickedImage;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _nameController = TextEditingController();
    _incomeController = TextEditingController();
    _animationController.forward();
    _loadUserData();
  }

  void _loadUserData() {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProv.userProfile?.firstName ?? '';
    _incomeController.text = userProv.monthlyIncome.toString(); // Use getter
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final userProv = Provider.of<UserProvider>(context, listen: false);
    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _uploadImage(_pickedImage!);
    }
    final newName = _nameController.text;
    final newIncome = double.tryParse(_incomeController.text) ?? 0.0;

    final success = await userProv.updateUserProfile(
      firstName: newName,
      totalIncome: newIncome, // Changed to totalIncome
      profileImageUrl: imageUrl ??
          userProv.userProfile?.profileImageUrl, // Changed to profileImageUrl
    );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
        _pickedImage = null;
      });
      AppUtils.showSnackBar(context, 'Profile updated successfully!');
    } else if (mounted) {
      AppUtils.showSnackBar(context, 'Failed to update profile');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) return null;
      final ref = firebase_storage.FirebaseStorage.instance
          .ref('users/$userId/profile.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, 'Failed to upload image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, child) {
        final profile = userProv.userProfile;
        final profilePic =
            profile?.profileImageUrl ?? 'https://via.placeholder.com/150';

        return RefreshIndicator(
          onRefresh: () async => await userProv.loadUserProfile(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largeSpacing),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeumorphicContainer(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: Hero(
                            tag: 'profilePic',
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _pickedImage != null
                                        ? FileImage(_pickedImage!)
                                        : NetworkImage(profilePic)
                                            as ImageProvider,
                                  ),
                                ),
                                if (_isEditing)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primary,
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.mediumSpacing),
                        Text(
                          profile?.firstName ?? 'User Name',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          profile?.email ?? 'email@example.com',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.largeSpacing),
                  NeumorphicContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(_isEditing ? Icons.close : Icons.edit),
                              onPressed: () {
                                setState(() => _isEditing = !_isEditing);
                                if (!_isEditing)
                                  _loadUserData(); // Reset fields on cancel
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.mediumSpacing),
                        if (!_isEditing) ...[
                          _infoRow('Name', profile?.firstName ?? 'N/A'),
                          _infoRow('Email', profile?.email ?? 'N/A'),
                          _infoRow('Country', profile?.country ?? 'N/A'),
                          _infoRow(
                              'Monthly Income',
                              AppUtils.formatCurrency(
                                  profile?.totalIncome ?? 0)),
                          _infoRow('Currency', profile?.currency ?? 'N/A'),
                        ] else ...[
                          CustomTextField(
                            controller: _nameController,
                            label: 'Name',
                            prefixIcon: Icons.person,
                          ),
                          const SizedBox(height: AppConstants.smallSpacing),
                          CustomTextField(
                            controller: _incomeController,
                            label: 'Monthly Income',
                            prefixIcon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: AppConstants.mediumSpacing),
                          CustomButton(
                            text: 'Save Changes',
                            onPressed: _updateProfile,
                            isLoading: _isLoading,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
