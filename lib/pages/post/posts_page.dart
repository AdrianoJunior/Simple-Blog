import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_blog/pages/login/usuario.dart';
import 'package:simple_blog/pages/post/post.dart';
import 'package:simple_blog/pages/post/post_listview.dart';
import 'package:simple_blog/pages/post/post_service.dart';
import 'package:simple_blog/utils/const.dart';
import 'package:simple_blog/widgets/text_error.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<Post> posts;

  Usuario usuario;

  @override
  void initState() {
    super.initState();

    Usuario.get().then((usuarioResult) {
      usuario = usuarioResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(


      stream: PostService().stream,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return TextError("Não foi possível buscar os posts");
        } else if(!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation(accentColor),),);
        }

        posts = snapshot.data.docs.map((doc) {
          return Post.fromMap(doc.data());
        }).toList();


        return PostsListView(posts: posts);
      },

    );
  }
}