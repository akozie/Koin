import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.fullName, required this.email, required this.phone});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
  );

  final String id;
  final String fullName;
  final String email;
  final String phone;

  String get firstName => fullName.split(' ').first;

  String get initials => fullName
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  Map<String, dynamic> toJson() => {'id': id, 'fullName': fullName, 'email': email, 'phone': phone};

  @override
  List<Object?> get props => [id, fullName, email, phone];
}
