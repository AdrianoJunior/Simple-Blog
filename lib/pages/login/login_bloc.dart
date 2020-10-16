import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_blog/firebase/firebase_service.dart';
import 'package:simple_blog/pages/api_response.dart';
import 'package:simple_blog/utils/simple_bloc.dart';

class LoginBloc extends SimpleBloc<bool> {
  Future<ApiResponse<User>> login(String login, String senha) async {
    add(true);

    ApiResponse response = await FirebaseService().login(login, senha);

    add(false);

    return response;
  }

  Future<ApiResponse<User>> create(String login, String senha) async {
    add(true);

    ApiResponse response = await FirebaseService().create(login, senha);

    add(false);

    return response;
  }
}
