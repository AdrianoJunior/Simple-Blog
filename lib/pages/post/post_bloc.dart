import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_blog/firebase/firebase_service.dart';
import 'package:simple_blog/pages/api_response.dart';
import 'package:simple_blog/utils/simple_bloc.dart';

class PostBloc extends SimpleBloc<bool> {
  Future<ApiResponse<bool>> savePost(Map<String, dynamic> postMap) async {
    add(true);

    ApiResponse response = await FirebaseService.savePost(postMap);

    add(false);

    return response;
  }

  Future<ApiResponse<String>> savePostImage(File file) async {
    add(true);

    ApiResponse response = await FirebaseService.uploadPostImage(file);
    add(false);

    return response;
  }
}
