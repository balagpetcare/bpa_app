import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../services/pet_service.dart';

class PetProfileWizardScreen extends StatefulWidget {
  final int? petId; // null => create, not null => edit
  const PetProfileWizardScreen({super.key, this.petId});

  @override
  State<PetProfileWizardScreen> createState() => _PetProfileWizardScreenState();
}

class _PetProfileWizardScreenState extends State<PetProfileWizardScreen> {
  final _petService = PetService();

  int _currentStep = 0;
  bool _loading = false;

  // Controllers / State
  final _nameCtrl = TextEditingController();
  final _microchipCtrl = TextEditingController();
  final _foodCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(); // optional (kg)

  DateTime? _dob;
  String _sex = "UNKNOWN";
  bool _isRescue = false;
  bool _isNeutered = false;

  List<Map<String, dynamic>> _animalTypes = [];
  List<Map<String, dynamic>> _breeds = [];

  int? _selectedAnimalTypeId;
  int? _selectedBreedId;

  File? _pickedCroppedFile; // local processed image
  bool _photoChanged = false;

  // Validation flags
  bool _step1Valid() =>
      (_pickedCroppedFile != null ||
          widget.petId != null) && // edit mode allows existing photo
      _nameCtrl.text.trim().isNotEmpty &&
      _selectedAnimalTypeId != null &&
      _selectedBreedId != null; // mandatory

  bool _step2Valid() => _dob != null; // mandatory DOB

  bool _step3Valid() {
    // food habits recommended required (আপনি চাইলে optional করতে পারেন)
    return _foodCtrl.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() => _loading = true);

    try {
      _animalTypes = await _petService.getAnimalTypes();

      if (widget.petId != null) {
        final pet = await _petService.getPetById(widget.petId!);

        _nameCtrl.text = pet["name"] ?? "";
        _sex = (pet["sex"] ?? "UNKNOWN").toString();
        _isRescue = (pet["isRescue"] ?? false) == true;
        _isNeutered = (pet["isNeutered"] ?? false) == true;

        final dobStr = pet["dateOfBirth"];
        if (dobStr != null) _dob = DateTime.tryParse(dobStr);

        _microchipCtrl.text = pet["microchipNumber"] ?? "";
        _foodCtrl.text = pet["foodHabits"] ?? "";
        _healthCtrl.text = pet["healthDisorders"] ?? "";
        _notesCtrl.text = pet["notes"] ?? "";

        _selectedAnimalTypeId = pet["animalTypeId"];
        _selectedBreedId = pet["breedId"];

        if (_selectedAnimalTypeId != null) {
          _breeds = await _petService.getBreeds(_selectedAnimalTypeId!);
        }
      }
    } catch (e) {
      _showSnack("Load failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickCropCompressImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: x.path,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Profile Photo",
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square, // ✅ 1:1
          ],
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: "Crop Profile Photo",
          aspectRatioLockEnabled: true,
          cropStyle: CropStyle.circle, // ✅ iOS ONLY supports circle
        ),
      ],
    );

    if (cropped == null) return;

    // Compress + resize
    final outPath = "${cropped.path}_500.jpg";
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      cropped.path,
      minWidth: 500,
      minHeight: 500,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    if (compressedBytes == null) {
      _showSnack("Image processing failed");
      return;
    }

    final f = File(outPath);
    await f.writeAsBytes(compressedBytes);

    setState(() {
      _pickedCroppedFile = f;
      _photoChanged = true;
    });
  }

  Future<void> _selectDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 1, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990, 1, 1),
      lastDate: now,
    );

    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _onAnimalTypeChanged(int? v) async {
    setState(() {
      _selectedAnimalTypeId = v;
      _selectedBreedId = null;
      _breeds = [];
    });
    if (v == null) return;

    try {
      final list = await _petService.getBreeds(v);
      setState(() => _breeds = list);
    } catch (e) {
      _showSnack("Breed load failed: $e");
    }
  }

  void _next() {
    final canGo = switch (_currentStep) {
      0 => _step1Valid(),
      1 => _step2Valid(),
      2 => _step3Valid(),
      _ => true,
    };

    if (!canGo) {
      _showSnack("Please complete required fields in this step.");
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final payload = {
        "name": _nameCtrl.text.trim(),
        "animalTypeId": _selectedAnimalTypeId,
        "breedId": _selectedBreedId,
        "sex": _sex,
        "dateOfBirth": _dob?.toIso8601String(),
        "microchipNumber": _microchipCtrl.text.trim().isEmpty
            ? null
            : _microchipCtrl.text.trim(),
        "isRescue": _isRescue,
        "isNeutered": _isNeutered,
        "foodHabits": _foodCtrl.text.trim(),
        "healthDisorders": _healthCtrl.text.trim().isEmpty
            ? null
            : _healthCtrl.text.trim(),
        "notes": _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        // Weight optional: backend যদি আলাদা table এ নেয়, তাহলে create pet এর পরে separate endpoint call করবেন
        "weightKg": _weightCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(_weightCtrl.text.trim()),
      };

      int petId;
      if (widget.petId == null) {
        petId = await _petService.createPet(payload);
      } else {
        petId = widget.petId!;
        await _petService.updatePet(petId, payload);
      }

      // Photo upload if changed
      if (_photoChanged && _pickedCroppedFile != null) {
        await _petService.uploadPetPhoto(petId, _pickedCroppedFile!);
      }

      if (!mounted) return;
      _showSnack("Pet profile saved ✅");
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack("Submit failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petId == null ? "Register Pet" : "Update Pet"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: _currentStep == 3 ? _submit : _next,
              onStepCancel: _back,
              controlsBuilder: (context, details) {
                final isLast = _currentStep == 3;
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLast ? "Save" : "Next"),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text("Back"),
                      ),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text("Basic"),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: _buildStep1(),
                ),
                Step(
                  title: const Text("DOB"),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content: _buildStep2(),
                ),
                Step(
                  title: const Text("Habits"),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                  content: _buildStep3(),
                ),
                Step(
                  title: const Text("Review"),
                  isActive: _currentStep >= 3,
                  state: StepState.indexed,
                  content: _buildStep4(),
                ),
              ],
            ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: InkWell(
            onTap: _pickCropCompressImage,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _pickedCroppedFile != null
                  ? FileImage(_pickedCroppedFile!)
                  : null,
              child: _pickedCroppedFile == null
                  ? const Icon(Icons.camera_alt, size: 26)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: "Pet Name *",
            prefixIcon: Icon(Icons.pets),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<int>(
          value: _selectedAnimalTypeId,
          items: _animalTypes
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e["id"],
                  child: Text(e["name"]),
                ),
              )
              .toList(),
          onChanged: _onAnimalTypeChanged,
          decoration: const InputDecoration(
            labelText: "Animal Type *",
            prefixIcon: Icon(Icons.category),
          ),
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<int>(
          value: _selectedBreedId,
          items: _breeds
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e["id"],
                  child: Text(e["name"]),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedBreedId = v),
          decoration: const InputDecoration(
            labelText: "Breed *",
            prefixIcon: Icon(Icons.badge),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Breed is mandatory, and loads based on Animal Type."),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cake),
          title: Text(
            _dob == null
                ? "Select Date of Birth *"
                : "DOB: ${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}",
          ),
          trailing: const Icon(Icons.calendar_month),
          onTap: _selectDob,
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: _sex,
          items: const [
            DropdownMenuItem(value: "MALE", child: Text("Male")),
            DropdownMenuItem(value: "FEMALE", child: Text("Female")),
            DropdownMenuItem(value: "UNKNOWN", child: Text("Unknown")),
          ],
          onChanged: (v) => setState(() => _sex = v ?? "UNKNOWN"),
          decoration: const InputDecoration(labelText: "Sex"),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _microchipCtrl,
          decoration: const InputDecoration(
            labelText: "Microchip Number (Optional)",
            prefixIcon: Icon(Icons.qr_code),
          ),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isRescue,
          onChanged: (v) => setState(() => _isRescue = v),
          title: const Text("Is Rescue?"),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isNeutered,
          onChanged: (v) => setState(() => _isNeutered = v),
          title: const Text("Is Neutered?"),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        TextField(
          controller: _foodCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: "Food Habits *",
            hintText: "e.g. Dry food + chicken, 2 times/day",
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _weightCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Weight in KG (Optional)",
            hintText: "e.g. 4.5",
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _healthCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: "Health Disorders (Optional)",
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Short Description / Notes (Optional)",
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${_nameCtrl.text.trim()}"),
            Text("AnimalTypeId: ${_selectedAnimalTypeId ?? '-'}"),
            Text("BreedId: ${_selectedBreedId ?? '-'}"),
            Text("DOB: ${_dob == null ? '-' : _dob!.toIso8601String()}"),
            Text("Sex: $_sex"),
            Text("Rescue: $_isRescue"),
            Text("Neutered: $_isNeutered"),
            Text("Food: ${_foodCtrl.text.trim()}"),
            Text(
              "Weight: ${_weightCtrl.text.trim().isEmpty ? '-' : _weightCtrl.text.trim()}",
            ),
            const SizedBox(height: 8),
            const Text("Press Save to submit."),
          ],
        ),
      ),
    );
  }
}
