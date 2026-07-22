class RegisterResponse {
  final bool done;
  final String email;

  RegisterResponse({
    required this.done,
    required this.email,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      done: json['done'] as bool? ?? false,
      email: json['user']?['email'] as String? ?? '',
    );
  }
}
