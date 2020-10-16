import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/firebase/firebase_service.dart';
import 'package:simple_blog/pages/api_response.dart';
import 'package:simple_blog/pages/home/home_page.dart';
import 'package:simple_blog/pages/login/usuario.dart';
import 'package:simple_blog/pages/profile/profile_bloc.dart';
import 'package:simple_blog/utils/alert.dart';
import 'package:simple_blog/utils/const.dart';
import 'package:simple_blog/utils/nav.dart';
import 'package:simple_blog/utils/prefs.dart';
import 'package:simple_blog/widgets/app_button.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool exists = false;

  Future<bool> checkExist(String docID) async {
    try {
      await FirebaseFirestore.instance.doc("users/$docID").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      print(exists);
      return exists;
    } catch (e) {
      return false;
    }
  }

  String urlFoto;
  FirebaseFirestore _firestore;

  final _tNome = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String uid;

  File _file;

  final _firebaseStorage = FirebaseStorage.instance;

  Usuario _usuario;

  var userData;

  final _bloc = ProfileBloc();

  @override
  void initState() {
    super.initState();

    _firestore = FirebaseFirestore.instance;

    uid = FirebaseAuth.instance.currentUser.uid;

    Future.wait([checkExist(uid)]).then((value) {
      if (value[0]) {
        _firestore.collection('users').doc(uid).get().then((value) {
          userData = value.data();

          _usuario = Usuario.fromMap(value.data());

          if (userData != null && userData.isNotEmpty) {
            urlFoto = userData['urlFoto'] ?? null;
            _tNome.text = userData['nome'] ?? "";

            setState(() {});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Center(
                child: InkWell(
                  onTap: _onClickFoto,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _file != null
                          ? Image.file(
                              _file,
                              height: 125,
                              width: 125,
                              fit: BoxFit.cover,
                            )
                          : urlFoto != null
                              ? CachedNetworkImage(
                                  width: 125,
                                  height: 125,
                                  imageUrl: urlFoto,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      valueColor: new AlwaysStoppedAnimation(
                                          Colors.grey),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Image.asset(
                                  'assets/images/default_image.png',
                                  height: 125,
                                  width: 125,
                                  fit: BoxFit.cover,
                                )),
                ),
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _tNome,
                  validator: _validateNome,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Nome",
                    hintText: "Digite seu nome",
                    focusColor: accentColor,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: accentColor,
                        width: 2.5,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: accentColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              StreamBuilder<bool>(
                stream: _bloc.stream,
                initialData: false,
                builder: (context, snapshot) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      child: AppButton(
                        "Salvar",
                        onPressed: _onClickSalvar,
                        showprogress: snapshot.data,
                      ));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _onClickSalvar() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    Usuario usuario = Usuario();

    if (urlFoto == null) {
      if (_file != null) {
        _upLoadUserData(usuario, _file, uid);
      } else {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Nenhuma foto selecionada")));
      }
    } else {
      if (_file != null) {
        Prefs.setInt("idx", 0);
        _upLoadUserData(usuario, _file, uid);

      }
    }
  }

  String _validateNome(String text) {
    if (text.isEmpty) {
      return "Digite seu nome";
    }
    return null;
  }

  void _upLoadUserData(
      Usuario usuario, File fileUpload, String uidUpload) async {
    try {
      ApiResponse uploadResponse =
          await FirebaseService.uploadFirebaseStorage(_file, uidUpload);

      if (uploadResponse.ok) {
        usuario.urlFoto = uploadResponse.result;
        usuario.nome = _tNome.text;
        usuario.token = uidUpload;
        usuario.email = FirebaseAuth.instance.currentUser.email;

        var mapUser = usuario.toMap();
        ApiResponse saveResponse =
            await _bloc.updateProfile(mapUser, uidUpload);
        if (saveResponse.ok) {
          usuario.save();
          alert(context, "Dados salvos com sucesso", callback: () {
            push(context, HomePage(), replace: true);
          });

          Future.delayed(Duration(seconds: 3)).then((value) {
            Prefs.setInt("idx", 0);
            push(context, HomePage(), replace: true);
          });
        } else {
          alert(context, "Nãoo foi possível salvar os dados, tente novamente");
        }
      }
    } catch (e) {
      print("FIRESTORE SAVE ERROR >>>>>>> $e");
    }
  }

  Future<void> _onClickFoto() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);

    File file = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: "",
        ));

    if (file != null) {
      setState(() {
        this._file = file;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
