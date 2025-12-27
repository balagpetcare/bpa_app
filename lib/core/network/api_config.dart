class ApiConfig {
  static const String host = 'http://192.168.10.111:3000';

  // Common base
  static const String apiV1 = '$host/api/v1';

  // ✅ User scoped base (এটাই আপনার PREFIX এর মতো)
  static const String userApi = '$apiV1/user';
}
