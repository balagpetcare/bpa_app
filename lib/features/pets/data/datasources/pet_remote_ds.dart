import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_config.dart';

class PetRemoteDs {
  Future<String?> _token() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString("token");
  }

  Future<Map<String, String>> _authHeaders({bool json = true}) async {
    final t = await _token();
    return <String, String>{
      if (t != null) "Authorization": "Bearer $t",
      if (json) "Content-Type": "application/json",
      "Accept": "application/json",
    };
  }

  // -----------------------------
  // Common lookups
  // -----------------------------
  Future<List<Map<String, dynamic>>> getAnimalTypes() async {
    final res = await http.get(Uri.parse(ApiEndpoints.animalTypes()));
    if (res.statusCode != 200) throw Exception(res.body);
    final data = jsonDecode(res.body);
    final list = (data["types"] as List).cast<Map<String, dynamic>>();
    return list;
  }

  Future<List<Map<String, dynamic>>> getBreeds(int typeId) async {
    final res = await http.get(Uri.parse(ApiEndpoints.breedsByType(typeId)));
    if (res.statusCode != 200) throw Exception(res.body);
    final data = jsonDecode(res.body);
    final list = (data["breeds"] as List).cast<Map<String, dynamic>>();
    return list;
  }

  // -----------------------------
  // Pets list
  // Supports multiple shapes:
  // A) { success:true, data:[...] }
  // B) { pets:[...] }
  // C) { data:{ pets:[...] } }
  // -----------------------------
  Future<List<Map<String, dynamic>>> getAllPets() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.allPets()),
      headers: await _authHeaders(json: false),
    );
    if (res.statusCode != 200) throw Exception(res.body);

    final data = jsonDecode(res.body);

    final list = (data["data"] is List)
        ? data["data"]
        : (data["pets"] ?? data["data"]?["pets"] ?? []);

    return (list as List).cast<Map<String, dynamic>>();
  }

  // -----------------------------
  // ✅ NEW: Upload media to /api/v1/media/upload
  // Returns mediaId
  // Backend expects: upload.single("file")
  // -----------------------------
  Future<int> uploadMedia(File file) async {
    final t = await _token();
    if (t == null || t.isEmpty) {
      throw Exception("No token found. Please login again.");
    }

    final uri = Uri.parse("${ApiConfig.apiV1}/media/upload");
    final req = http.MultipartRequest("POST", uri);
    req.headers["Authorization"] = "Bearer $t";

    // IMPORTANT: field name must be "file"
    req.files.add(await http.MultipartFile.fromPath("file", file.path));

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      throw Exception("Upload failed (${streamed.statusCode}): $body");
    }

    final decoded = jsonDecode(body);
    final mediaId = decoded["data"]?["id"];
    if (mediaId == null) {
      throw Exception("Upload succeeded but mediaId missing: $body");
    }
    return (mediaId as num).toInt();
  }

  // -----------------------------
  // Register pet (JSON)
  // Supports response shapes:
  // A) { success:true, data:{ id:.. } }
  // B) { success:true, pet:{ id:.. } }
  // C) { success:true, data:{ pet:{ id:.. } } }
  // -----------------------------
  Future<int> registerPet(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse(ApiEndpoints.registerPet()),
      headers: await _authHeaders(json: true),
      body: jsonEncode(payload),
    );

    final body = res.body;
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Register failed (${res.statusCode}): $body");
    }

    dynamic data;
    try {
      data = jsonDecode(body);
    } catch (_) {
      throw Exception("Invalid JSON response: $body");
    }

    final id =
        data["data"]?["id"] ??
        data["pet"]?["id"] ??
        data["data"]?["pet"]?["id"];

    if (id == null) throw Exception("Pet id missing: $body");
    return (id as num).toInt();
  }

  // -----------------------------
  // ✅ KEY METHOD:
  // Create pet with optional photo:
  // 1) uploadMedia(file) -> mediaId
  // 2) registerPet(payload with profilePicId)
  // -----------------------------
  Future<int> registerPetWithOptionalPhoto({
    required Map<String, dynamic> payload,
    File? photoFile,
  }) async {
    final finalPayload = <String, dynamic>{...payload};

    if (photoFile != null) {
      debugPrint("Uploading media from: ${photoFile.path}");
      final mediaId = await uploadMedia(photoFile);
      debugPrint("Uploaded mediaId: $mediaId");
      finalPayload["profilePicId"] = mediaId;
    } else {
      debugPrint("No photo selected, registering without profilePicId");
    }

    debugPrint("FINAL REGISTER PAYLOAD: $finalPayload");
    return registerPet(finalPayload);
  }

  // -----------------------------
  // Update pet (PATCH)
  // -----------------------------
  Future<void> updatePet(int petId, Map<String, dynamic> payload) async {
    final res = await http.patch(
      Uri.parse(ApiEndpoints.updatePet(petId)),
      headers: await _authHeaders(json: true),
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) throw Exception(res.body);
  }

  // -----------------------------
  // ✅ Optional helper: update pet profilePic after upload
  // -----------------------------
  Future<void> updatePetProfilePic({
    required int petId,
    required int profilePicId,
  }) async {
    await updatePet(petId, {"profilePicId": profilePicId});
  }
}
