import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_blog/pages/home/home_page.dart';
import 'package:simple_blog/pages/login/login_page.dart';
import 'package:simple_blog/utils/const.dart';
import 'package:simple_blog/utils/nav.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future futureDelay = Future.delayed(Duration(seconds: 4));

    // Future<Usuario> futureUser = Usuario.get();

    Future.wait([
      futureDelay /*, futureUser*/
    ]).then((values) {
      User user = FirebaseAuth.instance.currentUser;
      // Usuario user = values[1];
      if (user != null) {
        push(context, HomePage(), replace: true);
      } else {
        push(context, LoginPage(), replace: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColorDark,
      body: _body(),
    );
  }

  _body() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/app_name.png',
                width: MediaQuery.of(context).size.width * 0.75,
              ),
            ),
            CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
