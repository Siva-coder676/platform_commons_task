
class UserResponse {
  final int? id;
  final String? email;
  final String firstName;
  final String? lastName;
  final String? avatar;
  final String? job;

  UserResponse({
    this.id,
    this.email,
    required this.firstName,
    this.lastName,
    this.avatar,
    this.job,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      avatar: json['avatar'],
      job: json['job'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'job': job,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'name': firstName,
      'job': job,
    };
  }
}