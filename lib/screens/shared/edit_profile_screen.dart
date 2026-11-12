import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String phone;
  final String role;
  final String accentColorHex;

  const EditProfileScreen({
    super.key,
    required this.username,
    required this.phone,
    required this.role,
    required this.accentColorHex,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController usernameController;
  late final TextEditingController phoneController;

  String? avatarBase64;
  bool isSaving = false;

  Color get accentColor {
    if (widget.accentColorHex == 'orange') {
      return const Color(0xffff9f43);
    }

    return const Color(0xff7048ff);
  }

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.username);
    phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      avatarBase64 = base64Encode(bytes);
    });
  }

  Future<void> saveProfile() async {
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();

    if (username.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Vui lòng nhập username')),
  );
  return;
}

if (phone.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
  );
  return;
}

final phoneRegex = RegExp(r'^[0-9]{9,11}$');

if (!phoneRegex.hasMatch(phone)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Số điện thoại phải gồm 9 đến 11 chữ số'),
    ),
  );
  return;
}

    setState(() {
      isSaving = true;
    });

    try {
      await UserService().updateCurrentUserProfile(
        username: username,
        phone: phone,
        avatar: avatarBase64,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.role == 'child'
          ? const Color(0xfffffdf8)
          : const Color(0xfffffaff),
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickAvatar,
              child: CircleAvatar(
  radius: 68,
  backgroundColor: accentColor.withValues(alpha: 0.18),
  child: avatarBase64 == null
      ? const Text('📷', style: TextStyle(fontSize: 42))
      : ClipOval(
  child: SizedBox(
    width: 150,
    height: 150,
    child: InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Image.memory(
        base64Decode(avatarBase64!),
        fit: BoxFit.cover,
      ),
    ),
  ),
),
),
            ),
            const SizedBox(height: 12),
            Text(
              'Chạm để chọn avatar',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : saveProfile,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: accentColor,
              ),
              child: Text(isSaving ? 'Đang lưu...' : 'Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
