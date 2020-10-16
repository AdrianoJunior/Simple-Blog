import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert' as convert;

class Post {


  String user_id;
  String image_url;
  String desc;
  Timestamp dataPost;

  Post({this.user_id, this.image_url, this.desc, this.dataPost});

  Post.fromMap(Map<String, dynamic> post)
      : user_id = post['user_id'],
        image_url = post['image_url'],
        desc = post['desc'],
        dataPost = post['dataPost'];

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.user_id;
    data['image_url'] = this.image_url;
    data['desc'] = this.desc;
    data['dataPost'] = this.dataPost;
    return data;
  }

  String toJson() {
    String json = convert.json.encode(toMap());
    return json;
  }
}