import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_blog/pages/post/post.dart';

class UsuarioService {
  Post p;


  UsuarioService(this.p);

  DocumentReference get _usuarios =>
      FirebaseFirestore.instance.collection("users").doc(p.user_id);

  Stream<DocumentSnapshot> get stream => _usuarios.snapshots();
}
