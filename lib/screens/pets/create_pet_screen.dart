import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePetScreen extends StatefulWidget {
  const CreatePetScreen({super.key});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  // ✅ আপনার সার্ভার IP/Domain বসান
  static const String baseUrl = "http://192.168.10.111:3000/api/v1";

  // dropdown apis
  static const String animalTypesUrl = "$baseUrl/common/animal-types";
  static String breedsByTypeUrl(int typeId) => "$baseUrl/common/breeds/$typeId";

  // pet apis
  static const String registerPetUrl = "$baseUrl/pets/register";
  static String uploadPetPhotoUrl(int petId) =>
      "$baseUrl/pets/$petId/upload-photo";

  int _step = 0;
  bool _loading = false;

  // Step-1
  final _nameCtrl = TextEditingController();
  String _sex = "UNKNOWN";

  List<_AnimalType> _types = [];
  List<_Breed> _breeds = [];
  _AnimalType? _selectedType;
  _Breed? _selectedBreed;

  int? _petId;

  // Step-2
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _loadAnimalTypes();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ✅ Load animal types
  Future<void> _loadAnimalTypes() async {
    try {
      setState(() => _loading = true);

      final res = await http.get(Uri.parse(animalTypesUrl));
      if (res.statusCode != 200) {
        throw Exception(
          "Animal types load failed (${res.statusCode}): ${res.body}",
        );
      }

      final decoded = jsonDecode(res.body);
      final list = (decoded["types"] as List? ?? []);

      setState(() {
        _types = list.map((e) => _AnimalType.fromJson(e)).toList();
      });
    } catch (e) {
      _toast(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ✅ Load breeds by selected type
  Future<void> _loadBreedsByType(int typeId) async {
    try {
      setState(() {
        _loading = true;
        _breeds = [];
        _selectedBreed = null;
      });

      final res = await http.get(Uri.parse(breedsByTypeUrl(typeId)));
      if (res.statusCode != 200) {
        throw Exception("Breeds load failed (${res.statusCode}): ${res.body}");
      }

      final decoded = jsonDecode(res.body);
      final list = (decoded["breeds"] as List? ?? []);

      setState(() {
        _breeds = list.map((e) => _Breed.fromJson(e)).toList();
      });
    } catch (e) {
      _toast(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (x == null) return;
    setState(() => _pickedImage = File(x.path));
  }

  // ✅ Step-1 Register (Type + Breed REQUIRED)
  Future<void> _registerPet() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _toast("পেটের নাম দিন");
      return;
    }
    if (_selectedType == null) {
      _toast("Animal Type নির্বাচন করুন");
      return;
    }
    // ✅ REQUIRED
    if (_selectedBreed == null) {
      _toast("Breed নির্বাচন করুন");
      return;
    }

    try {
      setState(() => _loading = true);

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token পাওয়া যায়নি। আবার Login করুন।");
      }

      final body = {
        "name": _nameCtrl.text.trim(),
        "sex": _sex,
        "animalTypeId": _selectedType!.id,
        "breedId": _selectedBreed!.id, // ✅ REQUIRED
      };

      final res = await http.post(
        Uri.parse(registerPetUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception("Pet register failed (${res.statusCode}): ${res.body}");
      }

      final decoded = jsonDecode(res.body);
      final id = decoded["data"]?["pet"]?["id"];
      if (id == null) throw Exception("Response এ petId নেই");

      setState(() {
        _petId = (id as num).toInt();
        _step = 1;
      });

      _toast("✅ Step-1 Done! Pet ID: $_petId");
    } catch (e) {
      _toast(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ✅ Step-2 Upload photo (optional skip)
  Future<void> _uploadPhoto() async {
    if (_petId == null) {
      _toast("আগে Step-1 সম্পন্ন করুন");
      return;
    }
    if (_pickedImage == null) {
      _toast("একটি ছবি সিলেক্ট করুন");
      return;
    }

    try {
      setState(() => _loading = true);

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token পাওয়া যায়নি। আবার Login করুন।");
      }

      final request = http.MultipartRequest(
        "POST",
        Uri.parse(uploadPetPhotoUrl(_petId!)),
      );
      request.headers["Authorization"] = "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath("profile_pic", _pickedImage!.path),
      );

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 200 && streamed.statusCode != 201) {
        throw Exception("Upload failed (${streamed.statusCode}): $body");
      }

      setState(() => _step = 2);
      _toast("✅ Photo uploaded!");
    } catch (e) {
      _toast(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pet Registration")),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _loading
            ? null
            : () {
                if (_step == 0)
                  _registerPet();
                else if (_step == 1)
                  _uploadPhoto();
                else
                  Navigator.pop(context, true); // finish
              },
        onStepCancel: _loading
            ? null
            : () {
                if (_step == 0) {
                  Navigator.pop(context);
                  return;
                }
                setState(() => _step = (_step - 1).clamp(0, 2));
              },
        controlsBuilder: (context, details) {
          final text = _step == 0
              ? "Continue"
              : _step == 1
              ? "Upload & Continue"
              : "Finish";

          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(text),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text("Back"),
              ),
              if (_step == 1)
                TextButton(
                  onPressed: _loading ? null : () => setState(() => _step = 2),
                  child: const Text("Skip"),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text("Basic Info"),
            isActive: _step >= 0,
            content: _step1(),
          ),
          Step(
            title: const Text("Profile Photo"),
            isActive: _step >= 1,
            content: _step2(),
          ),
          Step(
            title: const Text("Done"),
            isActive: _step >= 2,
            content: const Text("✅ Registration Completed!"),
          ),
        ],
      ),
    );
  }

  Widget _step1() {
    return Column(
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: "Pet Name *"),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _sex,
          items: const [
            DropdownMenuItem(value: "MALE", child: Text("Male")),
            DropdownMenuItem(value: "FEMALE", child: Text("Female")),
            DropdownMenuItem(value: "UNKNOWN", child: Text("Unknown")),
          ],
          onChanged: _loading
              ? null
              : (v) => setState(() => _sex = v ?? "UNKNOWN"),
          decoration: const InputDecoration(labelText: "Gender *"),
        ),
        const SizedBox(height: 12),

        // ✅ Animal Type required
        DropdownButtonFormField<_AnimalType>(
          value: _selectedType,
          items: _types
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
              .toList(),
          onChanged: _loading
              ? null
              : (v) {
                  setState(() => _selectedType = v);
                  if (v != null) _loadBreedsByType(v.id);
                },
          decoration: const InputDecoration(labelText: "Animal Type *"),
        ),
        const SizedBox(height: 12),

        // ✅ Breed required + disabled until type selected
        DropdownButtonFormField<_Breed>(
          value: _selectedBreed,
          items: _breeds
              .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
              .toList(),
          onChanged: (_selectedType == null || _loading)
              ? null
              : (v) => setState(() => _selectedBreed = v),
          decoration: InputDecoration(
            labelText: "Breed *",
            helperText: _selectedType == null
                ? "প্রথমে Animal Type নির্বাচন করুন"
                : null,
          ),
        ),

        if (_loading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: _pickedImage != null
                  ? FileImage(_pickedImage!)
                  : null,
              child: _pickedImage == null ? const Icon(Icons.pets) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _pickedImage == null ? "No image selected" : "Image selected ✓",
              ),
            ),
            TextButton.icon(
              onPressed: _loading ? null : _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick"),
            ),
          ],
        ),
        if (_loading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

class _AnimalType {
  final int id;
  final String name;
  _AnimalType({required this.id, required this.name});

  factory _AnimalType.fromJson(Map<String, dynamic> json) {
    return _AnimalType(
      id: (json["id"] as num).toInt(),
      name: (json["name"] ?? "").toString(),
    );
  }
}

class _Breed {
  final int id;
  final String name;
  _Breed({required this.id, required this.name});

  factory _Breed.fromJson(Map<String, dynamic> json) {
    return _Breed(
      id: (json["id"] as num).toInt(),
      name: (json["name"] ?? "").toString(),
    );
  }
}
