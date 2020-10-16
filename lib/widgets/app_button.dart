import 'package:flutter/material.dart';
import 'package:simple_blog/utils/const.dart';

class AppButton extends StatelessWidget {
  String text;

  Function onPressed;
  bool showprogress;
  Color color;
  Color txtColor;

  AppButton(this.text, {this.onPressed, this.showprogress = false, this.color = accentColor, this.txtColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),
        onPressed: onPressed,
        child: showprogress
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    Colors.white,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 22,
                ),
              ),
        color: color,
      ),
    );
  }
}
