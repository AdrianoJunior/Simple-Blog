import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  CollectionReference get _posts =>
      FirebaseFirestore.instance.collection("posts");

  Stream<QuerySnapshot> get stream => _posts.orderBy("dataPost").snapshots();
}
