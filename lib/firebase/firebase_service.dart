import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:simple_blog/pages/api_response.dart';
import 'package:simple_blog/pages/login/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ApiResponse<User>> login(String email, String senha) async {
    try {
      // Usuario do Firebase
      final authResult =
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      final User fUser = authResult.user;
      print("signed in ${authResult.user.displayName}");

      // Cria um usuario do app
      final user = Usuario(
          nome: fUser.displayName,
          email: fUser.email,
          login: fUser.email,
          urlFoto: fUser.photoURL,
          token: fUser.uid);
      user.save();

      // Resposta genérica

      if (user != null) {
        return ApiResponse.ok();
      } else {
        return ApiResponse.error(
            msg: "Não foi possível fazer o login, tente novamente!");
      }
    } on FirebaseAuthException catch (e) {
      print(" >>> CODE : ${e.code}\n>>> ERRO : $e");
      return ApiResponse.error(
          msg: "Não foi possível fazer o login, tente novamente!");
    }
  }

  Future<ApiResponse<User>> create(String email, String senha) async {
    try {
      // Usuario do Firebase
      final authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: senha);
      final User fUser = authResult.user;
      print("created user ${authResult.user.displayName}");

      // Cria um usuario do app
      final user = Usuario(
          nome: fUser.displayName,
          email: fUser.email,
          login: fUser.email,
          urlFoto: fUser.photoURL,
          token: fUser.uid);
      user.save();

      // Resposta genérica

      if (user != null) {
        return ApiResponse.ok();
      } else {
        return ApiResponse.error(
            msg: "Não foi possível criar sua conta, tente novamente!");
      }
    } on FirebaseAuthException catch (e) {
      print(" >>> CODE : ${e.code}\n>>> ERRO : $e");
      return ApiResponse.error(
          msg: "Não foi possível criar sua conta, tente novamente!");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Usuario.clear();
  }


  static Future<ApiResponse<String>> uploadFirebaseStorage(File file,
      String uid) async {
    try {
      String fileName = path.basename(file.path);
      final storageRef = FirebaseStorage.instance.ref().child('users').child(
          uid).child(fileName);

      final StorageTaskSnapshot task = await storageRef
          .putFile(file)
          .onComplete;
      final String urlFoto = await task.ref.getDownloadURL();

      return ApiResponse.ok(result: urlFoto);
    } catch (e) {
      print("UPLOAD ERROR >>>>>> $e");
      return ApiResponse.error();
    }
  }


  static Future<ApiResponse<String>> uploadPostImage(File file) async {
    try {
      String fileName = path.basename(file.path);
      final storageRef = FirebaseStorage.instance.ref().child('posts').child(fileName);

      final StorageTaskSnapshot task = await storageRef
          .putFile(file)
          .onComplete;
      final String urlFoto = await task.ref.getDownloadURL();

      return ApiResponse.ok(result: urlFoto);
    } catch (e) {
      print("UPLOAD ERROR >>>>>> $e");
      return ApiResponse.error();
    }
  }

  static Future<ApiResponse<bool>> savePost(Map <String, dynamic> mapPost) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      await _firestore.collection('posts').doc().set(mapPost);
      return ApiResponse.ok();
  } catch (e) {
      print("ERRO >>>>> $e");
      return ApiResponse.error();
  }
  }

  static Future<ApiResponse<bool>> saveUserData(
      Map<String, dynamic> mapUser, String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(uid).set(mapUser);
      return ApiResponse.ok();
    } catch (e) {
      print("ERRO FIRESTORE SAVE >>>>> $e");

      return ApiResponse.error();
    }
  }
}
