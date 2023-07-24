import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String username;
  final String email;
  final Map<String, dynamic> profileData; // Add this field to hold profile information

  ProfileLoaded({
    required this.username,
    required this.email,
    required this.profileData,
  });

  @override
  List<Object> get props => [username, email];
}

class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// New state for successful profile update
class ProfileUpdated extends ProfileState {
  // You can add any additional data you need to indicate success, if necessary
  @override
  List<Object> get props => [];
}

// New state for successful profile creation
class ProfileCreated extends ProfileState {
  // You can add any additional data you need to indicate success, if necessary
  @override
  List<Object> get props => [];
}
