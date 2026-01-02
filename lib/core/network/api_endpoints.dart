import 'api_config.dart';

class ApiEndpoints {
  // ---------- AUTH ----------
  static String login() => "${ApiConfig.apiV1}/auth/login";
  static String register() => "${ApiConfig.apiV1}/auth/register";

  // ---------- PROFILE ----------
  static String myProfile() => "${ApiConfig.userApi}/profile";
  static String updateMyProfile() => "${ApiConfig.userApi}/profile"; // PATCH

  // ---------- PETS ----------
  static String allPets() => "${ApiConfig.userApi}/pets/all";
  static String registerPet() => "${ApiConfig.userApi}/pets/register";
  static String updatePet(int petId) => "${ApiConfig.userApi}/pets/$petId";
  /// Deprecated: backend uses media/upload + updatePet(profilePicId)
  static String uploadPetPhoto(int petId) => ApiEndpoints.mediaUpload();

  // ---------- MEDIA ----------
  static String mediaUpload() => "${ApiConfig.apiV1}/media/upload";

  // ---------- COMMON ----------
  static String animalTypes() => "${ApiConfig.apiV1}/common/animal-types";
  static String breedsByType(int typeId) =>
      "${ApiConfig.apiV1}/common/breeds/$typeId";
}
