import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ui/components/inputs/app_text_field.dart';
import '../../../ui/components/inputs/app_dropdown.dart';
import '../../../ui/components/app_date_field.dart';
import '../../../ui/components/buttons/app_primary_button.dart';
import '../../../ui/components/feedback/app_snackbar.dart';

import 'cubit/pet_form_cubit.dart';
import 'cubit/pet_form_state.dart';
import 'widgets/pet_photo_picker.dart';
import 'widgets/pet_step_header.dart';

class PetProfileWizardScreen extends StatefulWidget {
  const PetProfileWizardScreen({super.key});

  @override
  State<PetProfileWizardScreen> createState() => _PetProfileWizardScreenState();
}

class _PetProfileWizardScreenState extends State<PetProfileWizardScreen> {
  final _pageCtrl = PageController();

  final _nameCtrl = TextEditingController();
  final _microchipCtrl = TextEditingController();
  final _foodCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

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

  void _syncControllers(PetFormState s) {
    if (_nameCtrl.text != s.name) _nameCtrl.text = s.name;

    if (_microchipCtrl.text != s.microchipNumber) {
      _microchipCtrl.text = s.microchipNumber;
    }

    if (_foodCtrl.text != s.foodHabits) _foodCtrl.text = s.foodHabits;
    if (_healthCtrl.text != s.healthDisorders) {
      _healthCtrl.text = s.healthDisorders;
    }
    if (_notesCtrl.text != s.notes) _notesCtrl.text = s.notes;

    final wText = s.weightKg?.toString() ?? "";
    if (_weightCtrl.text != wText) _weightCtrl.text = wText;
  }

  String _formatDob(DateTime? dob) {
    if (dob == null) return "Select date";
    final dd = dob.day.toString().padLeft(2, '0');
    final mm = dob.month.toString().padLeft(2, '0');
    final yyyy = dob.year.toString();
    return "$dd/$mm/$yyyy";
  }

  String _animalTypeName(PetFormState s) {
    final id = s.animalTypeId;
    if (id == null) return "-";
    final found = s.animalTypes.where((e) => e["id"] == id).toList();
    if (found.isEmpty) return "-";
    return found.first["name"]?.toString() ?? "-";
  }

  String _breedName(PetFormState s) {
    final id = s.breedId;
    if (id == null) return "-";
    final found = s.breeds.where((e) => e["id"] == id).toList();
    if (found.isEmpty) return "-";
    return found.first["name"]?.toString() ?? "-";
  }

  // Professional textarea style: bigger + blue focus border
  InputDecoration _textareaDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF1E60AA), width: 2),
      ),
    );
  }

  Widget _textareaField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
    required ValueChanged<String> onChanged,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: _textareaDecoration(label: label, hint: hint),
    );
  }

  Widget _genderSelector(PetFormState state, PetFormCubit cubit) {
    final sex = state.sex;
    return Row(
      children: [
        _genderCard(
          selected: sex == "MALE",
          label: "Male",
          icon: Icons.male,
          onTap: () => cubit.setSex("MALE"),
        ),
        const SizedBox(width: 12),
        _genderCard(
          selected: sex == "FEMALE",
          label: "Female",
          icon: Icons.female,
          onTap: () => cubit.setSex("FEMALE"),
        ),
      ],
    );
  }

  Widget _genderCard({
    required bool selected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF1E60AA) : Colors.grey.shade300,
              width: 2,
            ),
            color: selected
                ? const Color(0xFF1E60AA).withOpacity(0.08)
                : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? const Color(0xFF1E60AA) : Colors.grey,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF1E60AA) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _jumpTo(int i) {
    if (!mounted) return;

    if (!_pageCtrl.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_pageCtrl.hasClients) {
          _pageCtrl.animateToPage(
            i,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
          );
        }
      });
      return;
    }

    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickDob(BuildContext context) async {
    final cubit = context.read<PetFormCubit>();
    final s = cubit.state;

    final now = DateTime.now();
    final initial = s.dob ?? DateTime(now.year - 1, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
    );

    if (picked != null) {
      cubit.setDob(picked);

      final years =
          now.year -
          picked.year -
          ((now.month < picked.month ||
                  (now.month == picked.month && now.day < picked.day))
              ? 1
              : 0);

      // if (years >= 0) cubit.setAgeYears(years.toString());
    }
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  void _handleNextPressed(
    BuildContext context,
    PetFormState state,
    PetFormCubit cubit,
  ) {
    // Step 0 validations (keep messages simple)
    if (state.step == 0) {
      if (state.name.trim().isEmpty) {
        AppSnackBar.show(context, "Please enter your pet's name");
        return;
      }
      if (state.sex != "MALE" && state.sex != "FEMALE") {
        AppSnackBar.show(context, "Please select your pet’s gender");
        return;
      }
      if (state.animalTypeId == null) {
        AppSnackBar.show(context, "Please choose an animal type");
        return;
      }
      if (state.breedId == null) {
        AppSnackBar.show(context, "Please select a breed");
        return;
      }
    }

    cubit.next();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PetFormCubit, PetFormState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          // Keep errors simple & readable
          AppSnackBar.show(context, state.error!);
        }

        if (state.success) {
          AppSnackBar.show(context, "Pet profile saved successfully ✅");
          Navigator.pop(context, true);
          return;
        }

        if (!state.loading) {
          _jumpTo(state.step);
        }
      },
      builder: (context, state) {
        _syncControllers(state);
        final cubit = context.read<PetFormCubit>();

        final titles = const ["Basic", "Photo", "Details", "Preview"];
        final isLast = state.step == 3;

        return Scaffold(
          appBar: AppBar(
            title: Text(state.editMode ? "Update Pet" : "Register Pet"),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  PetStepHeader(current: state.step, titles: titles),
                  Expanded(
                    child: PageView(
                      controller: _pageCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _stepBasic(context, state),
                        _stepPhotoOnly(context, state),
                        _stepDetails(context, state),
                        _stepPreview(context, state),
                      ],
                    ),
                  ),
                  _bottomBar(context, state, cubit, isLast),
                ],
              ),
              if (state.loading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66FFFFFF),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Step 1: Basic
  Widget _stepBasic(BuildContext context, PetFormState state) {
    final cubit = context.read<PetFormCubit>();

    // ✅ SAFE VALUE FIX (Dropdown crash avoid)
    final typeIds = state.animalTypes.map((e) => e["id"] as int).toSet();
    final safeTypeId =
        (state.animalTypeId != null && typeIds.contains(state.animalTypeId))
        ? state.animalTypeId
        : null;

    final breedIds = state.breeds.map((e) => e["id"] as int).toSet();
    final safeBreedId =
        (state.breedId != null && breedIds.contains(state.breedId))
        ? state.breedId
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          _sectionCard(
            title: "Basic Info",
            children: [
              AppTextField(
                controller: _nameCtrl,
                label: "Pet Name *",
                onChanged: cubit.setName,
              ),
              const SizedBox(height: 12),
              const Text(
                "Gender *",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _genderSelector(state, cubit),
              const SizedBox(height: 12),
              AppDropdown<int>(
                label: "Animal Type *",
                value: safeTypeId,
                items: state.animalTypes
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e["id"] as int,
                        child: Text(e["name"].toString()),
                      ),
                    )
                    .toList(),
                onChanged: cubit.setAnimalType,
              ),
              const SizedBox(height: 12),
              AppDropdown<int>(
                label: "Breed *",
                value: safeBreedId,
                items: state.breeds
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e["id"] as int,
                        child: Text(e["name"].toString()),
                      ),
                    )
                    .toList(),
                onChanged: safeTypeId == null ? null : cubit.setBreed,
              ),
              const SizedBox(height: 12),
              AppDateField(
                label: "Date of Birth",
                valueText: _formatDob(state.dob),
                onTap: () => _pickDob(context),
              ),
              const SizedBox(height: 8),
              const Text(
                "DOB না জানলে খালি রাখতে পারেন।",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Step 2: Photo ONLY
  Widget _stepPhotoOnly(BuildContext context, PetFormState state) {
    final cubit = context.read<PetFormCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _sectionCard(
            title: "Profile Photo",
            children: [
              PetPhotoPicker(
                file: state.photoFile, // File?
                onChanged: cubit.setPhoto, // void Function(File?)
                onRemove: cubit.removePhoto,
              ),
              const SizedBox(height: 10),
              const Text(
                "এখানে শুধু ছবি আপলোড করুন। Crop/Adjust করে নিন।",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Step 3: Details
  Widget _stepDetails(BuildContext context, PetFormState state) {
    final cubit = context.read<PetFormCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          _sectionCard(
            title: "Identity",
            children: [
              AppTextField(
                controller: _microchipCtrl,
                label: "Microchip Number (Optional)",
                onChanged: cubit.setMicrochip,
              ),
              const SizedBox(height: 6),
              const Text(
                "Microchip না থাকলে ফাঁকা রাখুন — কোনো সমস্যা হবে না।",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          _sectionCard(
            title: "Status",
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: state.isRescue,
                onChanged: cubit.setRescue,
                title: const Text("Is Rescue?"),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: state.isNeutered,
                onChanged: cubit.setNeutered,
                title: const Text("Is Neutered?"),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _weightCtrl,
                label: "Weight (KG) (Optional)",
                keyboardType: TextInputType.number,
                onChanged: cubit.setWeight,
              ),
            ],
          ),
          _sectionCard(
            title: "Lifestyle & Health",
            children: [
              _textareaField(
                controller: _foodCtrl,
                label: "Food Habits (Optional)",
                hint: "Example: Rice, chicken, dry food...",
                maxLines: 4,
                onChanged: cubit.setFood,
              ),
              const SizedBox(height: 12),
              _textareaField(
                controller: _healthCtrl,
                label: "Health Disorders (Optional)",
                hint: "Example: Allergy, skin issue...",
                maxLines: 4,
                onChanged: cubit.setHealth,
              ),
              const SizedBox(height: 12),
              _textareaField(
                controller: _notesCtrl,
                label: "Notes (Optional)",
                hint: "Anything important about your pet...",
                maxLines: 5,
                onChanged: cubit.setNotes,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Step 4: Preview
  Widget _stepPreview(BuildContext context, PetFormState state) {
    final photo = state.photoFile;
    final typeName = _animalTypeName(state);
    final breedName = _breedName(state);

    Widget photoBox() {
      return Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x11000000)),
          color: const Color(0xFFF6F8FC),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: photo == null
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets, size: 34, color: Colors.black38),
                      SizedBox(height: 8),
                      Text(
                        "No photo selected",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                )
              : Image.file(File(photo.path), fit: BoxFit.cover),
        ),
      );
    }

    Widget rowItem(String k, String v) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(k, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(
              child: Text(
                v.isEmpty ? "-" : v,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          _sectionCard(
            title: "Preview",
            children: [
              photoBox(),
              const SizedBox(height: 14),
              rowItem("Name", state.name),
              rowItem("Animal Type", typeName),
              rowItem("Breed", breedName),
              rowItem("Date of Birth", _formatDob(state.dob)),
              const Divider(height: 24),
              rowItem("Sex", state.sex),
              rowItem(
                "Microchip",
                state.microchipNumber.isEmpty ? "-" : state.microchipNumber,
              ),
              rowItem("Rescue", state.isRescue ? "Yes" : "No"),
              rowItem("Neutered", state.isNeutered ? "Yes" : "No"),
              rowItem("Weight (KG)", state.weightKg?.toString() ?? "-"),
              const Divider(height: 24),
              rowItem("Food Habits", state.foodHabits),
              rowItem("Health Disorders", state.healthDisorders),
              rowItem("Notes", state.notes),
              const SizedBox(height: 6),
              const Text(
                "সবকিছু ঠিক থাকলে Save করুন ✅",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Bottom bar
  Widget _bottomBar(
    BuildContext context,
    PetFormState state,
    PetFormCubit cubit,
    bool isLast,
  ) {
    final canBack = state.step > 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 520;

            final backBtn = AppPrimaryButton(
              text: "Back",
              onPressed: (!canBack || state.loading) ? null : cubit.back,
            );

            final nextBtn = AppPrimaryButton(
              text: isLast ? "Save" : "Next",
              onPressed: state.loading
                  ? null
                  : (isLast
                        ? cubit.submit
                        : () => _handleNextPressed(context, state, cubit)),
            );

            if (wide) {
              return Row(
                children: [
                  Expanded(child: backBtn),
                  const SizedBox(width: 12),
                  Expanded(child: nextBtn),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: double.infinity, child: nextBtn),
                const SizedBox(height: 10),
                if (canBack) SizedBox(width: double.infinity, child: backBtn),
              ],
            );
          },
        ),
      ),
    );
  }
}
