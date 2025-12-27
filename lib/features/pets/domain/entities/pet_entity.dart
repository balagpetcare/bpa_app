class PetEntity {
  final int? id; // ✅ create flow এ null হতে পারে
  final String name;

  final int animalTypeId;
  final int? breedId; // ✅ Prisma অনুযায়ী optional
  final int? profilePicId;

  // ✅ UI display fields (optional)
  final String? animalTypeName;
  final String? breedName;

  final DateTime? dateOfBirth;
  final String? sex;
  final String? microchipNumber;
  final bool? isRescue;
  final bool? isNeutered;
  final String? foodHabits;
  final String? healthDisorders;
  final String? notes;
  final double? weightKg;
  final String? photoUrl;

  const PetEntity({
    this.id,
    required this.name,
    required this.animalTypeId,
    this.breedId,
    this.animalTypeName,
    this.breedName,
    this.dateOfBirth,
    this.sex,
    this.microchipNumber,
    this.isRescue,
    this.isNeutered,
    this.foodHabits,
    this.healthDisorders,
    this.notes,
    this.weightKg,
    this.photoUrl,
    this.profilePicId,
  });

  // ✅ UI friendly getters (আপনার PetHorizontalList এগুলোই ব্যবহার করবে)
  String get animalType => animalTypeName ?? "";
  String get breed => breedName ?? "";
}
