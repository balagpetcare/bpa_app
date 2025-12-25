import 'dart:io';
import 'package:flutter/material.dart';

import '../../services/pet_service.dart';
import '../../ui/components/app_text_field.dart';
import '../../ui/components/app_dropdown.dart';
import '../../ui/components/app_date_field.dart';

import 'widgets/pet_photo_picker.dart';
import 'widgets/pet_step_header.dart';

class PetProfileWizardScreen extends StatefulWidget {
  final int? petId; // null=create, not null=edit
  const PetProfileWizardScreen({super.key, this.petId});

  @override
  State<PetProfileWizardScreen> createState() => _PetProfileWizardScreenState();
}

class _PetProfileWizardScreenState extends State<PetProfileWizardScreen> {
  final _petService = PetService();

  final _pageCtrl = PageController();
  int _current = 0;
  bool _loading = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _microchipCtrl = TextEditingController();
  final _foodCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _weightCtrl = TextEditingController(); // optional kg

  // State
  DateTime? _dob; // mandatory
  String _sex = "UNKNOWN";
  bool _isRescue = false;
  bool _isNeutered = false;

  List<Map<String, dynamic>> _animalTypes = [];
  List<Map<String, dynamic>> _breeds = [];

  int? _selectedAnimalTypeId;
  int? _selectedBreedId; // mandatory

  File? _photoFile; // processed file
  bool _photoChanged = false;

  // Validation (image on 2nd page)
  bool get _step0BasicValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _selectedAnimalTypeId != null &&
      _selectedBreedId != null;

  bool get _step1ProfileValid =>
      (_photoFile != null || widget.petId != null) && _dob != null;

  bool get _step2HabitsValid => _foodCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _microchipCtrl.dispose();
    _foodCtrl.dispose();
    _healthCtrl.dispose();
    _notesCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLoad() async {
    setState(() => _loading = true);
    try {
      _animalTypes = await _petService.getAnimalTypes();

      if (widget.petId != null) {
        final pet = await _petService.getPetById(widget.petId!);

        _nameCtrl.text = (pet["name"] ?? "").toString();
        _sex = (pet["sex"] ?? "UNKNOWN").toString();
        _isRescue = (pet["isRescue"] ?? false) == true;
        _isNeutered = (pet["isNeutered"] ?? false) == true;

        final dobStr = pet["dateOfBirth"];
        if (dobStr != null) _dob = DateTime.tryParse(dobStr.toString());

        _microchipCtrl.text = (pet["microchipNumber"] ?? "").toString();
        _foodCtrl.text = (pet["foodHabits"] ?? "").toString();
        _healthCtrl.text = (pet["healthDisorders"] ?? "").toString();
        _notesCtrl.text = (pet["notes"] ?? "").toString();

        _selectedAnimalTypeId = pet["animalTypeId"];
        _selectedBreedId = pet["breedId"];

        if (_selectedAnimalTypeId != null) {
          _breeds = await _petService.getBreeds(_selectedAnimalTypeId!);
        }
      }
    } catch (e) {
      _snack("Load failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      if (mounted) setState(() => _breeds = list);
    } catch (e) {
      _snack("Breed load failed: $e");
    }
  }

  void _go(int i) {
    setState(() => _current = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    final ok = switch (_current) {
      0 => _step0BasicValid,
      1 => _step1ProfileValid,
      2 => _step2HabitsValid,
      _ => true,
    };

    if (!ok) {
      _snack("এই স্টেপে Required ফিল্ডগুলো পূরণ করুন।");
      return;
    }
    if (_current < 3) _go(_current + 1);
  }

  void _back() {
    if (_current > 0) _go(_current - 1);
  }

  Future<void> _submit() async {
    if (!_step0BasicValid || !_step1ProfileValid || !_step2HabitsValid) {
      _snack("Required ফিল্ডগুলো পূরণ করুন।");
      return;
    }

    setState(() => _loading = true);
    try {
      final payload = {
        "name": _nameCtrl.text.trim(),
        "animalTypeId": _selectedAnimalTypeId,
        "breedId": _selectedBreedId, // mandatory
        "sex": _sex,
        "dateOfBirth": _dob?.toIso8601String(), // mandatory
        "microchipNumber": _microchipCtrl.text.trim().isEmpty
            ? null
            : _microchipCtrl.text.trim(),
        "isRescue": _isRescue,
        "isNeutered": _isNeutered,
        "foodHabits": _foodCtrl.text.trim(), // required
        "healthDisorders": _healthCtrl.text.trim().isEmpty
            ? null
            : _healthCtrl.text.trim(),
        "notes": _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
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

      if (_photoChanged && _photoFile != null) {
        await _petService.uploadPetPhoto(petId, _photoFile!);
      }

      if (!mounted) return;
      _snack("Pet profile saved ✅");
      Navigator.pop(context, true);
    } catch (e) {
      _snack("Submit failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = const ["Basic", "Profile", "Habits", "Review"];
    final showBreedWarning =
        _current == 0 &&
        _selectedAnimalTypeId != null &&
        _selectedBreedId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petId == null ? "Register Pet" : "Update Pet"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                PetStepHeader(
                  current: _current,
                  titles: titles,
                  showBreedWarning: showBreedWarning,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _current = i),
                    children: [
                      _stepBasic(), // no photo
                      _stepProfile(), // photo + dob
                      _stepHabits(),
                      _stepReview(),
                    ],
                  ),
                ),
                _bottomBar(),
              ],
            ),
    );
  }

  Widget _bottomBar() {
    final isLast = _current == 3;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isLast ? _submit : _next,
                child: Text(isLast ? "Save" : "Next"),
              ),
            ),
            const SizedBox(width: 12),
            if (_current > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _back,
                  child: const Text("Back"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------- Step 0: Basic (Common style components)
  Widget _stepBasic() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _nameCtrl,
            label: "Pet Name *",
            prefixIcon: const Icon(Icons.pets),
            errorText: _nameCtrl.text.trim().isEmpty ? "Required" : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          AppDropdown<int>(
            label: "Animal Type *",
            value: _selectedAnimalTypeId,
            prefixIcon: const Icon(Icons.category),
            items: _animalTypes
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e["id"],
                    child: Text(e["name"]),
                  ),
                )
                .toList(),
            onChanged: _onAnimalTypeChanged,
            errorText: _selectedAnimalTypeId == null ? "Required" : null,
          ),
          const SizedBox(height: 12),

          AppDropdown<int>(
            label: "Breed *",
            value: _selectedBreedId,
            prefixIcon: const Icon(Icons.badge),
            items: _breeds
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e["id"],
                    child: Text(e["name"]),
                  ),
                )
                .toList(),
            onChanged: _selectedAnimalTypeId == null
                ? null
                : (v) => setState(() => _selectedBreedId = v),
            errorText: _selectedBreedId == null ? "Required" : null,
            hint: _selectedAnimalTypeId == null
                ? "Select Animal Type first"
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            "Breed mandatory (Animal Type অনুযায়ী breed লোড হবে).",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // -------------------- Step 1: Profile (Photo + DOB mandatory)
  Widget _stepProfile() {
    final dobText = _dob == null
        ? ""
        : "${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}";

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Center(
            child: PetPhotoPicker(
              file: _photoFile,
              onChanged: (f) => setState(() {
                _photoFile = f;
                _photoChanged = true;
              }),
              onRemove: () => setState(() {
                _photoFile = null;
                _photoChanged = true;
              }),
            ),
          ),
          const SizedBox(height: 18),

          AppDateField(
            label: "Date of Birth *",
            valueText: dobText,
            onTap: _selectDob,
            errorText: _dob == null ? "Required" : null,
          ),
          const SizedBox(height: 12),

          AppDropdown<String>(
            label: "Sex",
            value: _sex,
            prefixIcon: const Icon(Icons.wc),
            items: const [
              DropdownMenuItem(value: "MALE", child: Text("Male")),
              DropdownMenuItem(value: "FEMALE", child: Text("Female")),
              DropdownMenuItem(value: "UNKNOWN", child: Text("Unknown")),
            ],
            onChanged: (v) => setState(() => _sex = v ?? "UNKNOWN"),
          ),
          const SizedBox(height: 12),

          AppTextField(
            controller: _microchipCtrl,
            label: "Microchip Number (Optional)",
            prefixIcon: const Icon(Icons.qr_code),
          ),
          const SizedBox(height: 10),

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
      ),
    );
  }

  // -------------------- Step 2: Habits
  Widget _stepHabits() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          AppTextField(
            controller: _foodCtrl,
            label: "Food Habits *",
            hint: "e.g. Dry food + chicken, 2 times/day",
            maxLines: 2,
            errorText: _foodCtrl.text.trim().isEmpty ? "Required" : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          AppTextField(
            controller: _weightCtrl,
            label: "Weight in KG (Optional)",
            hint: "e.g. 4.5",
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.monitor_weight),
          ),
          const SizedBox(height: 12),

          AppTextField(
            controller: _healthCtrl,
            label: "Health Disorders (Optional)",
            maxLines: 2,
            prefixIcon: const Icon(Icons.health_and_safety),
          ),
          const SizedBox(height: 12),

          AppTextField(
            controller: _notesCtrl,
            label: "Short Description / Notes (Optional)",
            maxLines: 3,
            prefixIcon: const Icon(Icons.notes),
          ),
        ],
      ),
    );
  }

  // -------------------- Step 3: Review
  Widget _stepReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
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
              const SizedBox(height: 10),
              const Text("সব ঠিক থাকলে Save চাপুন ✅"),
            ],
          ),
        ),
      ),
    );
  }
}
