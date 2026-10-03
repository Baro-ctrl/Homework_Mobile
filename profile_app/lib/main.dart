import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

void main() => runApp(
  DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
);

//main() là điểm bắt đầu
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const ProfileScreen(),
    );
  }
}

// MaterialApp là gốc của app Scaffold là khung của 1 trang
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _avatarBytes;
  final TransformationController _tc = TransformationController();
  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    _tc.value = Matrix4.identity();
    setState(() => _avatarBytes = bytes);
  }

  Widget _buildAvatar() {
    const double size = 120;
    if (_avatarBytes == null) {
      return GestureDetector(
        onTap: _pickImage,
        child: const CircleAvatar(
          radius: 60,
          backgroundColor: Color(0xFFCFE6F7),
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: InteractiveViewer(
          transformationController: _tc,
          minScale: 1,
          maxScale: 4,
          child: Image.memory(
            _avatarBytes!,
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: SafeArea(
        //SafeArea giữa nội dung không bị tai thỏ che
        child: Stack(
          //Stack sắp xếp widget chồng lên nhau: lớp dưới là hàng nút, lớp trên là khối avatar ở giữa
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                //Row xếp ngang
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //spaceBetween đẩy một icon sang trái, một icon sang phải
                children: [
                  SquareButton(
                    icon: Icons.arrow_back,
                    color: Colors.black87,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  SquareButton(
                    icon: Icons.edit_square,
                    color: const Color(0xFF1DB57A),
                    onTap: _pickImage,
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                //Column là widget sắp xếp các widget con theo chiều dọc
                // SizeBox tạo khoảng cách giữa các widget con
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatar(),
                  if (_avatarBytes != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Kéo để di chuyển, cuộn chuột để phóng to',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                  SizedBox(height: 16),
                  Text(
                    'Bùi Châu Gia Bảo',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('SV:054206001360', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SquareButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SquareButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE3E8EE)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
