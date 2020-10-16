import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/firebase/firebase_service.dart';
import 'package:simple_blog/pages/api_response.dart';
import 'package:simple_blog/pages/post/post.dart';
import 'package:simple_blog/pages/post/post_bloc.dart';
import 'package:simple_blog/utils/alert.dart';
import 'package:simple_blog/utils/const.dart';
import 'package:simple_blog/utils/nav.dart';
import 'package:simple_blog/widgets/app_button.dart';

class PostFormPage extends StatefulWidget {
  double width;

  @override
  _PostFormPageState createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = PostBloc();

  double get width => widget.width;

  File _file;

  final _tDesc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo Post"),
      ),
      body: _body(),
    );
  }

  _body() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: onClickFoto,
              child: _file != null
                  ? Image.file(_file, width: MediaQuery
                  .of(context)
                  .size
                  .width)
                  : Image.asset('assets/images/post_placeholder.png',
                  width: MediaQuery
                      .of(context)
                      .size
                      .width),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                maxLines: 5,
                textAlignVertical: TextAlignVertical.top,
                textAlign: TextAlign.start,
                controller: _tDesc,
                textInputAction: TextInputAction.newline,
                validator: _validateDesc,
                decoration: InputDecoration(
                  labelText: "Descição",
                  hintText: "Digite a descrição do post",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor)),
                ),
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<bool>(
              stream: _bloc.stream,
              initialData: false,
              builder: (context, snapshot) {
                return Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: AppButton(
                    "Salvar",
                    onPressed: _onClickPostar,
                    showprogress: snapshot.data,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _onClickPostar() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    String desc = _tDesc.text.replaceAll("\n", "\n");
    Post post = new Post();
    String uid = FirebaseAuth.instance.currentUser.uid;

    if (_file != null) {
      try {
        ApiResponse<String> uploadResponse =
        await _bloc.savePostImage(_file);
        if (uploadResponse.ok) {
          post.image_url = uploadResponse.result;
          post.desc = desc;
          post.user_id = uid;
          post.dataPost = Timestamp.fromDate(DateTime.now().toLocal().toUtc());

          ApiResponse postResponse = await _bloc.savePost(post.toMap());

          if (postResponse.ok) {
            alert(context, "Post salvo com sucesso!", callback: (){
              Navigator.pop(context);
            });
          } else {
            alert(context, "Não foi possível salvar o post, tente novamente.");
          }
        } else {
          alert(context,
              "Não foi possível fazer o upload da imagem, tente novamente.");
        }
      } catch (e) {
        alert(context, "Não foi possível publicar o post, tente novamentet.");
        print(e);
      }
    }
  }

  String _validateDesc(String text) {
    if (text.isEmpty) {
      return "Digite a descrição do Post";
    }
    return null;
  }

  void onClickFoto() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
    await imagePicker.getImage(source: ImageSource.gallery);

    File file = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: "",
        ));

    if (file != null) {
      setState(() {
        this._file = file;
      });
    }
  }
}
