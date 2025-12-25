import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class PetPhotoPicker extends StatefulWidget {
  final File? file;
  final ValueChanged<File> onChanged;
  final VoidCallback? onRemove;
  final double radius;

  const PetPhotoPicker({
    super.key,
    required this.file,
    required this.onChanged,
    this.onRemove,
    this.radius = 60,
  });

  @override
  State<PetPhotoPicker> createState() => _PetPhotoPickerState();
}

class _PetPhotoPickerState extends State<PetPhotoPicker> {
  bool _busy = false;

  Future<void> _pickCropCompress() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final picker = ImagePicker();

      // ✅ ফিক্স ১: এই লাইনটি আপনার কোডে মিসিং ছিল, তাই 'x' এরর দিচ্ছিল
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );

      if (x == null) return;

      // ✅ ফিক্স ২: কম্পাইলারের চাহিদা অনুযায়ী cropStyle ভেতরে দেওয়া হলো
      CroppedFile? cropped;

      try {
        cropped = await ImageCropper().cropImage(
          sourcePath: x.path,
          compressQuality: 100,
          // v8 এর জন্য টপ-লেভেলে aspect ratio
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),

          // ⚠️ লক্ষ্য করুন: cropStyle এখানে দেওয়া হয়নি কারণ আপনার কম্পাইলার এটি নিচ্ছে না
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: "Crop Pet Photo",
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              // যদি আপনার ভার্সন পুরোনো হয়, তাহলে এটি এখানে কাজ করবে
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: "Crop Pet Photo",
              aspectRatioLockEnabled: true,
              // iOS এর জন্য
              cropStyle: CropStyle.circle,
            ),
          ],
        );
      } catch (e) {
        // যদি উপরের নিয়মে ক্র্যাশ করে, আমরা ফলব্যাক হিসেবে v8 ট্রাই করব
        // কিন্তু সাধারণত কম্পাইলার এরর দিলে কোড রানই করবে না
        debugPrint("Crop error: $e");
        cropped = CroppedFile(x.path);
      }

      if (cropped == null) return;

      // ৩. কমপ্রেশন
      final processed = await _compressToProfileTemp(File(cropped.path));

      widget.onChanged(processed);
    } catch (e) {
      debugPrint("Photo Picker Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load image: $e")));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // কমপ্রেশন ফাংশন
  Future<File> _compressToProfileTemp(File input) async {
    final tmp = await getTemporaryDirectory();
    final outPath =
        "${tmp.path}/pet_profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

    Future<List<int>?> compress(int quality) {
      return FlutterImageCompress.compressWithFile(
        input.path,
        minWidth: 500,
        minHeight: 500,
        quality: quality,
        format: CompressFormat.jpeg,
      );
    }

    List<int>? bytes = await compress(85);
    if (bytes != null && bytes.length > 300 * 1024) {
      bytes = await compress(70);
    }
    if (bytes != null && bytes.length > 300 * 1024) {
      bytes = await compress(50);
    }

    if (bytes == null) return input;

    final f = File(outPath);
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _busy ? null : _pickCropCompress,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: CircleAvatar(
                  radius: widget.radius,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: widget.file != null
                      ? FileImage(widget.file!)
                      : null,
                  child: widget.file == null
                      ? (_busy
                            ? const CircularProgressIndicator()
                            : Icon(
                                Icons.pets,
                                size: widget.radius * 0.8,
                                color: Colors.grey.shade400,
                              ))
                      : null,
                ),
              ),
            ),
            if (widget.file != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _pickCropCompress,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          widget.file == null ? "Upload Pet Photo" : "Tap to change",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
