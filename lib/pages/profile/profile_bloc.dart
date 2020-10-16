import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_blog/firebase/firebase_service.dart';
import 'package:simple_blog/pages/api_response.dart';
import 'package:simple_blog/utils/simple_bloc.dart';

class ProfileBloc extends SimpleBloc<bool> {
  Future<ApiResponse<bool>> updateProfile(Map<String, dynamic> map, String uid) async {
    add(true);

    ApiResponse response = await FirebaseService.saveUserData(map, uid);

    add(false);

    return response;

  }
}
