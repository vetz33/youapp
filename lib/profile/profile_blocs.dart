import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:youapptest/profile/profile_events.dart';
import 'package:youapptest/profile/profile_states.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is FetchProfileData) {
      final accessToken = event.accessToken; // Get the accessToken from the event
      yield ProfileLoading();
      try {
        final profileData = await _fetchProfileData(accessToken);
        if (profileData != null) {
          yield ProfileLoaded(
            username: profileData['username'],
            email: profileData['email'],
            profileData: profileData,
          );
        } else {
          // If profileData is null, yield a ProfileFailure state with an appropriate error message
          yield ProfileFailure(error: 'Profile data is null');
        }
      } catch (error) {
        print('FetchProfileData Error: $error');
        yield ProfileFailure(error: error.toString());
      }
    } else if (event is CreateProfile) {
      yield ProfileLoading();
      try {
        await createProfile(event.accessToken, event.profileData);
        // Profile has been created successfully
        print('ProfileCreated');
        yield ProfileCreated();
      } catch (error) {
        print('CreateProfile Error: $error');
        yield ProfileFailure(error: error.toString());
      }
    } else if (event is UpdateProfile) {
      yield ProfileLoading();
      try {
        await updateProfile(event.accessToken, event.updatedProfileData);
        // Profile has been updated successfully
        print('ProfileUpdated');
        yield ProfileUpdated();
      } catch (error) {
        print('UpdateProfile Error: $error');
        yield ProfileFailure(error: error.toString());
      }
    }
  }

  Future<Map<String, dynamic>> _fetchProfileData(String accessToken) async {
    final apiUrl = 'https://techtest.youapp.ai/api/getProfile';
    final headers = {'x-access-token': accessToken};
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, dynamic> data = responseData['data'];

      final String username = data['username'] ?? ''; // Provide default value if null
      final String email = data['email'] ?? ''; // Provide default value if null

      return {'username': username, 'email': email};
    } else if (response.statusCode == 500) {
      throw 'Failed to get profile: Internal server error';
    } else {
      throw 'Failed to get profile: Unexpected error';
    }
  }



  Future<void> createProfile(String accessToken, Map<String, dynamic> profileData) async {
    if (accessToken == null || accessToken.isEmpty) {
      throw 'Access token is null or empty.';
    }

    if (profileData == null || profileData.isEmpty) {
      throw 'Profile data is null or empty.';
    }

    // Validate the profileData JSON object for required fields here
    if (!profileData.containsKey('name') ||
        !profileData.containsKey('birthday') ||
        !profileData.containsKey('height') ||
        !profileData.containsKey('weight') ) {
      throw 'Profile data is missing required fields.';
    }

    final apiUrl = 'https://techtest.youapp.ai/api/createProfile';
    final headers = {'x-access-token': accessToken, 'Content-Type': 'application/json'};

    // Convert interests to a list of strings if it exists
    final interests = profileData['interests'] as List<dynamic>?;

    // If the interests list exists and is not null, convert it to a list of strings
    if (interests != null) {
      profileData['interests'] = interests.map((interest) => interest.toString()).toList();
    } else {
      // If interests is null, set it to an empty list
      profileData['interests'] = [];
    }

    final body = json.encode(profileData);

    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);

    if (response.statusCode == 201) {
      // Profile has been created successfully
      print('Profile has been created successfully');
    } else {
      // Profile creation failed, throw an exception with the error message
      throw 'Failed to create profile. Bad request: ${response.body}';
    }
  }

  Future<void> updateProfile(String accessToken, Map<String, dynamic> updatedProfileData) async {
    final apiUrl = 'https://techtest.youapp.ai/api/updateProfile';
    final headers = {'x-access-token': accessToken, 'Content-Type': 'application/json'};
    final body = json.encode(updatedProfileData);

    final response = await http.put(Uri.parse(apiUrl), headers: headers, body: body);

    if (response.statusCode != 200) {
      throw 'Failed to update profile';
    }
  }
}
