import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfileData extends ProfileEvent {
  final String accessToken;

  FetchProfileData({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
}

class CreateProfile extends ProfileEvent {
  final String accessToken;
  final Map<String, dynamic> profileData;

  CreateProfile({required this.accessToken, required this.profileData});

  @override
  List<Object> get props => [accessToken, profileData];
}

class UpdateProfile extends ProfileEvent {
  final String accessToken;
  final Map<String, dynamic> updatedProfileData;

  UpdateProfile({required this.accessToken, required this.updatedProfileData});

  @override
  List<Object> get props => [accessToken, updatedProfileData];
}
