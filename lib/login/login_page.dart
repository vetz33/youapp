import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../profile/profile_page.dart';
import 'login_bloc.dart';
import 'login_events.dart';
import 'login_state.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ Color(0xff00423a), Color(0xff00211d)], // Add the gradient colors here
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: BlocProvider(
          create: (context) => LoginBloc(),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _obscurePassword = true;

  String? _accessToken; // Add this variable to store the access token

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          _accessToken = state.token; // Store the access token
          Navigator.pushReplacementNamed(context, '/profile', arguments: _accessToken);
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      builder: (context, state) {
        if (state is LoginLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login', // Add the Login text above the email TextField
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, // Make both the TextField and ElevatedButton expand to full width
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.white), // Set text color to white
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: InputBorder.none, // Remove the default border
                            contentPadding: EdgeInsets.all(16), // Adjust the content padding
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        )
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.tealAccent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              final email = _emailController.text;
                              final password = _passwordController.text;
                              final username = _usernameController.text;
                              BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed(email: email, username: username, password: password));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.transparent, // Set the button color to transparent
                              onPrimary: Colors.white, // Set the text color to white
                              elevation: 0, // Remove elevation to have a flat button
                              padding: EdgeInsets.symmetric(vertical: 16), // Adjust the button padding
                              textStyle: TextStyle(fontSize: 18), // Adjust the button text style
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                              shadowColor: Colors.transparent, // Hide the button shadow
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Add circular border
                            ),
                            child: Text('Login'),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
        'No account?',
        style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        ShaderMask(
        shaderCallback: (bounds) {
        return LinearGradient(
        colors: [Color(0xFFDAA520), Colors.white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        ).createShader(bounds);
        },
        child: TextButton(
        onPressed: () {
        // Navigate to the Register page
        Navigator.pushNamed(context, '/register');
        },
        child: Text(
        'Register here',
        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
        ),
        ),
        ),
        ],
        ),
                ]))]));
      }
      },
    );
  }
}