import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:youapptest/login/login_bloc.dart';
import 'package:youapptest/profile/profile_blocs.dart';
import 'package:youapptest/profile/profile_page.dart';
import 'package:youapptest/register/register_blocs.dart';
import 'package:youapptest/register/register_page.dart';

import 'login/login_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      BlocProvider<LoginBloc>(create: (_) => LoginBloc()),
      BlocProvider<RegisterBloc>(create: (_) => RegisterBloc()),
      BlocProvider<ProfileBloc>(create: (_) => ProfileBloc()), // Add this line to provide the ProfileBloc
      // Add other providers here if needed
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // Your MaterialApp configurations
      home: LoginPage(), // Or any other starting page
      routes: {
        '/register': (context) => RegisterPage(),
        '/profile': (context) => ProfilePage(),
      },
    ),
  );
}
}
