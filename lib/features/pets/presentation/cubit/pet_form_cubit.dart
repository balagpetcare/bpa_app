import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pet_entity.dart';
import '../../domain/usecases/create_pet_usecase.dart';
import '../../domain/usecases/get_animal_types_usecase.dart';
import '../../domain/usecases/get_breeds_usecase.dart';
import '../../domain/usecases/get_pets_usecase.dart';
import '../../domain/usecases/update_pet_usecase.dart';
import '../../domain/usecases/upload_pet_photo_usecase.dart';
import 'pet_form_state.dart';

class PetFormCubit extends Cubit<PetFormState> {
  final GetAnimalTypesUsecase getAnimalTypes;
  final GetBreedsUsecase getBreeds;
  final GetPetsUsecase getPets;

  final CreatePetUsecase createPet;
  final UpdatePetUsecase updatePet; // expects (int id, PetEntity pet)
  final UpdatePetPhotoUsecase uploadPhoto; // expects (int id, File file)

  PetFormCubit({
    required this.getAnimalTypes,
    required this.getBreeds,
    required this.getPets,
    required this.createPet,
    required this.updatePet,
    required this.uploadPhoto,
    int? petId,
  }) : super(PetFormState.initial(petId: petId));

  Future<void> init() async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      final types = await getAnimalTypes();
      emit(state.copyWith(animalTypes: types, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadIfEdit() async {
    if (!state.editMode) return;

    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      final list = await getPets();
      final pet = list.firstWhere((p) => p.id == state.petId);

      final breeds = await getBreeds(pet.animalTypeId);

      int? ageYears;
      if (pet.dateOfBirth != null) {
        final now = DateTime.now();
        final dob = pet.dateOfBirth!;
        ageYears =
            now.year -
            dob.year -
            ((now.month < dob.month ||
                    (now.month == dob.month && now.day < dob.day))
                ? 1
                : 0);
        if (ageYears < 0) ageYears = 0;
      }

      emit(
        state.copyWith(
          loading: false,
          breeds: breeds,
          name: pet.name,
          animalTypeId: pet.animalTypeId,
          breedId: pet.breedId,
          dob: pet.dateOfBirth,
          ageYears: ageYears,
          sex: pet.sex,
          isRescue: pet.isRescue,
          isNeutered: pet.isNeutered,
          weightKg: pet.weightKg,
          microchipNumber: pet.microchipNumber ?? "",
          foodHabits: pet.foodHabits ?? "",
          healthDisorders: pet.healthDisorders ?? "",
          notes: pet.notes ?? "",
          photoChanged: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  // ---------- Step (4 pages)
  void next() {
    if (state.step == 0 && !state.basicValid) {
      emit(state.copyWith(error: "Basic info required"));
      return;
    }
    if (state.step < 3) emit(state.copyWith(step: state.step + 1, error: null));
  }

  void back() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1, error: null));
  }

  // ---------- Basic
  void setName(String v) => emit(state.copyWith(name: v, error: null));

  Future<void> setAnimalType(int? id) async {
    // ✅ IMPORTANT: reset breed + clear list to avoid dropdown mismatch
    emit(
      state.copyWith(
        animalTypeId: id,
        breedId: null,
        breeds: const [],
        error: null,
      ),
    );
    if (id == null) return;

    try {
      final list = await getBreeds(id);
      emit(state.copyWith(breeds: list));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void setBreed(int? id) => emit(state.copyWith(breedId: id, error: null));
  void setAgeYears(String v) =>
      emit(state.copyWith(ageYears: int.tryParse(v.trim()), error: null));
  void setDob(DateTime? d) => emit(state.copyWith(dob: d, error: null));

  // ---------- Photo
  void setPhoto(File? f) =>
      emit(state.copyWith(photoFile: f, photoChanged: true, error: null));
  void removePhoto() =>
      emit(state.copyWith(photoFile: null, photoChanged: true, error: null));

  // ---------- More 1
  void setSex(String v) => emit(state.copyWith(sex: v, error: null));
  void setRescue(bool v) => emit(state.copyWith(isRescue: v, error: null));
  void setNeutered(bool v) => emit(state.copyWith(isNeutered: v, error: null));
  void setWeight(String v) =>
      emit(state.copyWith(weightKg: double.tryParse(v.trim()), error: null));

  // ---------- More 2
  void setMicrochip(String v) =>
      emit(state.copyWith(microchipNumber: v, error: null));
  void setFood(String v) => emit(state.copyWith(foodHabits: v, error: null));
  void setHealth(String v) =>
      emit(state.copyWith(healthDisorders: v, error: null));
  void setNotes(String v) => emit(state.copyWith(notes: v, error: null));

  DateTime? _resolveDob() {
    if (state.dob != null) return state.dob;
    if (state.ageYears == null) return null;
    final now = DateTime.now();
    return DateTime(now.year - state.ageYears!, now.month, now.day);
  }

  Future<void> submit() async {
    if (!state.basicValid) {
      emit(state.copyWith(error: "Required fields missing"));
      return;
    }

    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      // ✅ Optional fields => null if empty
      final micro = state.microchipNumber.trim();
      final food = state.foodHabits.trim();
      final health = state.healthDisorders.trim();
      final notes = state.notes.trim();

      final pet = PetEntity(
        id: state.petId,
        name: state.name.trim(),
        animalTypeId: state.animalTypeId!,
        breedId: state.breedId, // keep optional-safe
        dateOfBirth: _resolveDob(),
        sex: state.sex,
        microchipNumber: micro.isEmpty ? null : micro, // ✅ KEY FIX
        isRescue: state.isRescue,
        isNeutered: state.isNeutered,
        weightKg: state.weightKg,
        foodHabits: food.isEmpty ? null : food,
        healthDisorders: health.isEmpty ? null : health,
        notes: notes.isEmpty ? null : notes,
      );

      int petId;

      if (state.editMode) {
        petId = state.petId!;
        await updatePet(petId, pet); // ✅ FIX: 2 args
      } else {
        petId = await createPet(pet);
        emit(state.copyWith(petId: petId));
      }

      if (state.photoChanged && state.photoFile != null) {
        await uploadPhoto(petId, state.photoFile!);
      }

      emit(state.copyWith(loading: false, success: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString(), success: false));
    }
  }
}
