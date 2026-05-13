class UserModel {
  String uid;
  String email;
  String name;
  String role; // 'student' or 'supervisor'
  String? supervisorId; // for students
  List<String>? studentIds; // for supervisors

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.supervisorId,
    this.studentIds,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'name': name,
    'role': role,
    'supervisorId': supervisorId,
    'studentIds': studentIds,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'],
    email: json['email'],
    name: json['name'],
    role: json['role'],
    supervisorId: json['supervisorId'],
    studentIds: List<String>.from(json['studentIds'] ?? []),
  );
}