import 'api_config.dart';

class ApiEndpoints {
  // Auth
  static String login() => "${ApiConfig.baseUrl}/auth/login";
  static String register() => "${ApiConfig.baseUrl}/auth/register";

  // Profile
  static String myProfile() => "${ApiConfig.baseUrl}/profile/me";

  // Common
  static String animalTypes() => "${ApiConfig.baseUrl}/common/animal-types";
  static String breedsByType(int typeId) =>
      "${ApiConfig.baseUrl}/common/breeds/$typeId";
  static String updatePet(int petId) => "${ApiConfig.baseUrl}/pets/$petId";

  // Pets
  static String registerPet() => "${ApiConfig.baseUrl}/pets/register";
  static String allPets() => "${ApiConfig.baseUrl}/pets/all";
  static String uploadPetPhoto(int petId) =>
      "${ApiConfig.baseUrl}/pets/$petId/upload-photo";
}
