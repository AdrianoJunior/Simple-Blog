import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_blog/pages/login/usuario.dart';
import 'package:simple_blog/pages/login/usuario_service.dart';
import 'package:simple_blog/pages/post/post.dart';

class PostsListView extends StatelessWidget {
  List<Post> posts;

  int likes = 0;

  int comments = 0;

  PostsListView({this.posts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: posts != null ? posts.length : 0,
        itemBuilder: (context, index) {
          Post p = posts[index];

          return Container(
            child: InkWell(
              onTap: _onCickPost(context, p),
              onLongPress: _onLongCickPost(context, p),
              child: Card(
                color: Colors.white,
                elevation: 10,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                          stream: UsuarioService(p).stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Opacity(opacity: 0);
                            if (snapshot.hasError) return Opacity(opacity: 0);
                            Usuario usuario =
                                Usuario.fromMap(snapshot.data.data());

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: usuario != null
                                      ? CachedNetworkImage(
                                          imageUrl: usuario.urlFoto,
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                        )
                                      : Image.asset(
                                          'assets/images/default_image.png',
                                          height: 40,
                                          width: 40,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(usuario.nome ?? "Usuário",
                                        style: titleStyle()),
                                    Text(
                                      DateFormat("dd/MM/yyyy").format(
                                          p.dataPost.toDate().toLocal()),
                                      style: TextStyle(
                                          color: Color(0xff95989A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                      SizedBox(height: 30),
                      CachedNetworkImage(
                        imageUrl: p.image_url ??
                            'https://firebasestorage.googleapis.com/v0/b/simple-blog-468e5.appspot.com/o/placeholder%2Fpost_placeholder.png?alt=media&token=a3eb1806-b9da-4494-8dfb-d589845abfae',
                        height: 190,
                        width: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(height: 20),
                      Text(
                        p.desc ?? "Legenda do post",
                        style: titleStyle(),
                      ),
                      SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: Color(0xff95989A),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      likes.toString(),
                                      style: TextStyle(
                                          color: Color(0xff95989A),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                                onTap: _onClickFavorito(context, p),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                child:
                                    Icon(Icons.share, color: Color(0xff95989A)),
                                onTap: _onClickShare(context, p),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: _onClickComment(context, p),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.mode_comment,
                                    color: Color(0xff95989A)),
                                SizedBox(width: 4),
                                Text(
                                  comments.toString(),
                                  style: TextStyle(
                                      color: Color(0xff95989A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TextStyle titleStyle() {
    return TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: 18,
    );
  }

  _onCickPost(BuildContext context, Post p) {}

  _onLongCickPost(BuildContext context, Post p) {}

  _onClickFavorito(BuildContext context, Post p) {}

  _onClickShare(BuildContext context, Post p) {}

  _onClickComment(BuildContext context, Post p) {}
}
