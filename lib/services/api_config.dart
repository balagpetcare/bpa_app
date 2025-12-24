class ApiConfig {
  // ✅ শুধু এখানে বদলালেই পুরো প্রজেক্টে URL পরিবর্তন হবে
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.10.111:3000/api/v1',
  );
}
