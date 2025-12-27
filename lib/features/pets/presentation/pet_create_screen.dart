import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/pet_remote_ds.dart';
import '../data/repositories/pet_repository_impl.dart';
import '../domain/usecases/create_pet_usecase.dart';
import '../domain/usecases/get_animal_types_usecase.dart';
import '../domain/usecases/get_breeds_usecase.dart';
import '../domain/usecases/get_pets_usecase.dart';
import '../domain/usecases/update_pet_usecase.dart';
import '../domain/usecases/upload_pet_photo_usecase.dart';
import 'cubit/pet_form_cubit.dart';
import 'pet_profile_wizard_screen.dart';

class PetCreateScreen extends StatelessWidget {
  final int? petId; // null=create, not null=edit
  const PetCreateScreen({super.key, this.petId});

  @override
  Widget build(BuildContext context) {
    final repo = PetRepositoryImpl(PetRemoteDs());

    return BlocProvider(
      create: (_) =>
          PetFormCubit(
              getAnimalTypes: GetAnimalTypesUsecase(repo),
              getBreeds: GetBreedsUsecase(repo),
              getPets: GetPetsUsecase(repo),
              createPet: CreatePetUsecase(repo),
              updatePet: UpdatePetUsecase(repo),
              uploadPhoto: UpdatePetPhotoUsecase(repo),
              petId: petId,
            )
            ..init()
            ..loadIfEdit(),
      child: const PetProfileWizardScreen(),
    );
  }
}
