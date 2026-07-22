enum UserRole {
  student,
  propertyProvider;

  static String toJson(UserRole role) => role.toMap();

  factory UserRole.fromJson(String name) => switch (name) {
    "student" => student,
    "property-provider" => propertyProvider,
    _ => student,
  };
  String toMap() => switch (this) {
    UserRole.student => "student",
    UserRole.propertyProvider => "property-provider",
  };
}

enum UserStatus {
  active,
  blocked;

  factory UserStatus.fromJson(String name) => switch (name) {
    "active" => active,
    "blocked" => blocked,
    _ => active,
  };
  String toMap() => switch (this) {
    UserStatus.active => "active",
    UserStatus.blocked => "blocked",
  };
}
