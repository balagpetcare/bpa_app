import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  Future<UserEntity> login({
    required String identifier,
    required String password,
  }) async {
    final data = await remote.login(identifier: identifier, password: password);

    // ✅ Assumption: { success:true, token:"", user:{...} }
    final token = data['token']?.toString() ?? '';
    final userJson = data['user'];

    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw Exception(data['message']?.toString() ?? 'Invalid login response');
    }

    final user = UserModel.fromJson(userJson);

    await LocalStorage.saveAuth(
      token: token,
      userName: user.name,
      userEmail: user.email,
    );

    return user;
  }

  Future<void> register({
    required String name,
    required String identifier,
    required String password,
  }) async {
    await remote.register(
      name: name,
      identifier: identifier,
      password: password,
    );
  }
}
