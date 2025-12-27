import '../../data/repositories/auth_repository_impl.dart';

class RegisterUseCase {
  final AuthRepositoryImpl repo;
  RegisterUseCase(this.repo);

  Future<void> execute({
    required String name,
    required String identifier, // email or phone
    required String password,
  }) {
    return repo.register(
      name: name,
      identifier: identifier,
      password: password,
    );
  }
}
