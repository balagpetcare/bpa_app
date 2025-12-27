import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class PetPhotoPicker extends StatelessWidget {
  final File? file;
  final ValueChanged<File?> onChanged;
  final VoidCallback? onRemove;

  const PetPhotoPicker({
    super.key,
    required this.file,
    required this.onChanged,
    this.onRemove,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    final cropped = await _cropImage(context, picked.path);
    if (cropped == null) return;

    onChanged(File(cropped.path));
  }

  Future<CroppedFile?> _cropImage(BuildContext context, String path) {
    return ImageCropper().cropImage(
      sourcePath: path,
      compressQuality: 90,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Photo",
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(title: "Crop Photo", aspectRatioLockEnabled: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x11000000)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: file == null
                  ? _emptyState()
                  : Image.file(file!, fit: BoxFit.cover),
            ),
          ),
        ),
        if (file != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.edit),
                label: const Text("Change"),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: onRemove ?? () => onChanged(null),
                icon: const Icon(Icons.delete_outline),
                label: const Text("Remove"),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _emptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 42, color: Colors.black38),
        SizedBox(height: 10),
        Text("Upload Pet Photo", style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 4),
        Text("Tap to select & crop", style: TextStyle(color: Colors.black54)),
      ],
    );
  }
}
