import 'package:flutter/material.dart';
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String avatar;
  final String domain;
  final bool available;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.avatar,
    required this.domain,
    required this.available,
  });
}