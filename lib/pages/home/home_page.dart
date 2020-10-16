import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_blog/firebase/firebase_service.dart';
import 'package:simple_blog/pages/login/login_page.dart';
import 'package:simple_blog/pages/post/post_form_page.dart';
import 'package:simple_blog/pages/post/posts_page.dart';
import 'package:simple_blog/pages/profile/profile_page.dart';
import 'package:simple_blog/utils/const.dart';
import 'package:simple_blog/utils/nav.dart';
import 'package:simple_blog/utils/prefs.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin<HomePage> {
  bool exists = false;

  int _currentIdx = 0;

  bool showFAB = false;

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

  String uid;

  _initBar() async {
    _currentIdx = await Prefs.getInt("idx");

    if (_currentIdx == null) {
      _currentIdx = 0;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initBar();
    uid = FirebaseAuth.instance.currentUser.uid;

    Future.wait([checkExist(uid)]).then((value) {
      bool ok = value[0];
      if (!ok) {
        push(context, ProfilePage(), replace: true);
      }
    });
  }

  Widget CallPage(int idx) {
    switch (idx) {
      case 0:
        showFAB = true;
        return PostsPage();
        break;
      case 1:
        showFAB = false;
        return Container(child: Center(child: Text("Notificações")));
        break;
      case 2:
        showFAB = false;
        return ProfilePage();
        break;

      default:
        showFAB = false;
        return Container(color: Colors.black);
        break;
    }
  }

  void handleClick(String value) {
    switch (value) {
      case 'Sair':
        FirebaseService().logout();
        push(context, LoginPage(), replace: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Blog"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Sair'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      floatingActionButton: _currentIdx == 0
          ? FloatingActionButton(
              onPressed: () {
                push(context, PostFormPage());
              },
              child: Icon(Icons.add_a_photo),
              elevation: 16)
          : Opacity(opacity: 0),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIdx,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _setIdx(index),
        items: [
          BottomNavigationBarItem(
            label: "Posts",
            icon: Icon(Icons.history),
            activeIcon: Icon(
              Icons.history,
              color: primaryColor,
            ),
          ),
          BottomNavigationBarItem(
            label: "Notificações",
            icon: Icon(Icons.favorite),
            activeIcon: Icon(
              Icons.favorite,
              color: primaryColor,
            ),
          ),
          BottomNavigationBarItem(
            label: "Conta",
            icon: Icon(Icons.person_pin_circle_outlined),
            activeIcon: Icon(
              Icons.person_pin_circle_outlined,
              color: primaryColor,
            ),
          ),
        ],
      ),
      body: CallPage(_currentIdx),
    );
  }

  _setIdx(int index) async {
    setState(() {
      _currentIdx = index;
    });

    await Prefs.setInt("idx", index);
  }
}
