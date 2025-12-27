import 'package:bpa_app/features/pets/data/models/pet_model.dart';

class UserProfileModel {
  final int id;
  final String name;
  final List<String> galleryUrls;

  final String? email;
  final String? phone;
  final String? username;

  final int points;
  final double balance;
  final String? tier;

  final int followers;
  final int? rank;

  final String? photoUrl;
  final String? coverUrl;

  final List<PetModel> pets;

  const UserProfileModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.username,
    required this.points,
    required this.balance,
    this.tier,
    required this.followers,
    this.rank,
    this.photoUrl,
    this.coverUrl,
    required this.pets,
    required this.galleryUrls,
  });

  factory UserProfileModel.fromApi(Map<String, dynamic> root) {
    final data = (root["data"] is Map)
        ? (root["data"] as Map<String, dynamic>)
        : root;

    final auth = (data["auth"] is Map)
        ? (data["auth"] as Map<String, dynamic>)
        : const <String, dynamic>{};

    final profile = (data["profile"] is Map)
        ? (data["profile"] as Map<String, dynamic>)
        : const <String, dynamic>{};

    final wallet = (data["wallet"] is Map)
        ? (data["wallet"] as Map<String, dynamic>)
        : const <String, dynamic>{};

    final displayName =
        (profile["displayName"] ?? profile["name"] ?? data["name"] ?? "")
            .toString()
            .trim();

    final petsRaw = (data["pets"] as List?) ?? const [];

    // ✅ PetModel unchanged, just use it:
    final pets = petsRaw
        .whereType<Map>()
        .map((e) => PetModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final points = _toInt(wallet["points"]);
    final computedRank = _rankFromPoints(points);

    final galleryRaw = (data["galleryItems"] as List?) ?? const [];

    final galleryUrls = galleryRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map((item) {
          final media = item["media"];
          if (media is Map) {
            return media["url"]?.toString();
          }
          return null;
        })
        .whereType<String>()
        .where((u) => u.trim().isNotEmpty)
        .toList();

    return UserProfileModel(
      id: _toInt(data["id"]),
      name: displayName.isEmpty ? "BPA Member" : displayName,
      email: auth["email"]?.toString() ?? data["email"]?.toString(),
      phone: auth["phone"]?.toString() ?? data["phone"]?.toString(),
      username: profile["username"]?.toString(),
      points: points,
      balance: _toDouble(wallet["balance"]),
      tier: wallet["tier"]?.toString(),
      followers: _toInt(data["followers"] ?? 0),
      rank: computedRank,
      photoUrl: profile["photoUrl"]?.toString() ?? data["photoUrl"]?.toString(),
      coverUrl: profile["coverUrl"]?.toString(),
      pets: pets,
      galleryUrls: galleryUrls,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? "") ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? "") ?? 0.0;
  }

  static int? _rankFromPoints(int points) {
    if (points <= 0) return null;
    if (points >= 5000) return 5;
    if (points >= 2000) return 25;
    if (points >= 1000) return 80;
    return 200;
  }
}
