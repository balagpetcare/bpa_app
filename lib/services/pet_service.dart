import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class PetService {
  Future<String?> _token() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString("token");
  }

  Future<List<Map<String, dynamic>>> getAnimalTypes() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/common/animal-types"),
    );
    if (res.statusCode != 200) throw Exception(res.body);
    final data = jsonDecode(res.body);
    final list = (data["types"] as List).cast<Map<String, dynamic>>();
    return list;
  }

  Future<List<Map<String, dynamic>>> getBreeds(int typeId) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/common/breeds/$typeId"),
    );
    if (res.statusCode != 200) throw Exception(res.body);
    final data = jsonDecode(res.body);
    final list = (data["breeds"] as List).cast<Map<String, dynamic>>();
    return list;
  }

  Future<Map<String, dynamic>> getPetById(int petId) async {
    // আপনার backend এ endpoint না থাকলে add করবেন, বা all pets থেকে filter করবেন
    final t = await _token();
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/user/pets/$petId"),
      headers: {"Authorization": "Bearer $t"},
    );
    if (res.statusCode != 200) throw Exception(res.body);
    return jsonDecode(res.body)["pet"];
  }

  Future<int> createPet(Map<String, dynamic> payload) async {
    final t = await _token();
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/user/pets/add"),
      headers: {
        "Authorization": "Bearer $t",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    if (res.statusCode != 201 && res.statusCode != 200)
      throw Exception(res.body);
    final data = jsonDecode(res.body);
    return data["pet"]["id"];
  }

  Future<void> updatePet(int petId, Map<String, dynamic> payload) async {
    final t = await _token();
    final res = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/user/pets/$petId"),
      headers: {
        "Authorization": "Bearer $t",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) throw Exception(res.body);
  }

  Future<void> uploadPetPhoto(int petId, File file) async {
    final t = await _token();
    final req = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiConfig.baseUrl}/user/pets/$petId/upload-photo"),
    );
    req.headers["Authorization"] = "Bearer $t";
    req.files.add(await http.MultipartFile.fromPath("file", file.path));
    final res = await req.send();
    if (res.statusCode != 200 && res.statusCode != 201) {
      final body = await res.stream.bytesToString();
      throw Exception(body);
    }
  }
}
