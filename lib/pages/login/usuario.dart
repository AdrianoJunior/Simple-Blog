import 'dart:convert' as convert;

import 'package:simple_blog/utils/prefs.dart';


class Usuario {
  String login;
  String nome;
  String email;
  String urlFoto;
  String token;

  Usuario(
      {this.login,
        this.nome,
        this.email,
        this.urlFoto,
        this.token});

  Usuario.fromMap(Map<String, dynamic> json) {
    nome = json['nome'];
    email = json['email'];
    urlFoto = json['urlFoto'];
    token = json['token'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['email'] = this.email;
    data['urlFoto'] = this.urlFoto;
    data['token'] = this.token;
    return data;
  }


  @override
  String toJson() {
    String json = convert.json.encode(toMap());
    return json;
  }

  static void clear() {

    Prefs.setString("user.prefs", "");
  }

  void save() {

    Map map = toMap();
    String json =convert.json.encode(map);
    Prefs.setString("user.prefs", json);
  }

  static Future<Usuario> get() async {
    String json = await Prefs.getString("user.prefs");

    if(json.isEmpty) {
      return null;
    }
    Map map = convert.json.decode(json);

    Usuario  user  = Usuario.fromMap(map);

    return user;
  }


}
