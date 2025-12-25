import 'package:flutter/material.dart';
import 'pet_profile_wizard_screen.dart';

class CreatePetScreen extends StatelessWidget {
  const CreatePetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PetProfileWizardScreen(); // petId null => create mode
  }
}
