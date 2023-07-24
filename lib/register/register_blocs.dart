import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:youapptest/register/register_events.dart';
import 'package:youapptest/register/register_states.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial());

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterButtonPressed) {
      yield RegisterLoading();
      try {
        final token = await _registerUser(
            event.username, event.email, event.password);
        yield RegisterSuccess(token: token);
      } catch (error) {
        yield RegisterFailure(error: error.toString());
      }
    }
  }

  Future<String> _registerUser(String username, String email, String password) async {
    final apiUrl = 'https://techtest.youapp.ai/api/register';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'username': username,
      'email': email,
      'password': password,
    });

    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('message') && responseData['message'] == 'User has been created successfully') {
        return 'Registration successful'; // or you can return responseData['token'] if available
      } else {
        throw 'Invalid response data: ${response.body}';
      }
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final errorMessage = errorData['message'] as String;
      if (errorMessage.toLowerCase().contains('user already exists')) {
        throw 'Registration failed: User with the provided email/username already exists';
      } else {
        throw 'Registration failed with status code: ${response.statusCode}';
      }
    } else {
      throw 'Registration failed with status code: ${response.statusCode}';
    }
  }

}