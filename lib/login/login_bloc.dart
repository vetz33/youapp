import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'login_events.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();
      try {
        final token = await _authenticateUser(event.email, event.username, event.password);
        if (token != null) {
          yield LoginSuccess(token: token);
        } else {
          yield LoginFailure(error: 'Invalid token received');
        }
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }


  Future<String> _authenticateUser(String email, String username, String password) async {
    final apiUrl = 'https://techtest.youapp.ai/api/login';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'email': email,
      'username': username,
      'password': password,
    });

    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw 'Login failed';
    }
  }


}