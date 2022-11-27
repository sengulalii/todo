import 'package:flutter/material.dart';

mixin PageHelper {
  static List colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.deepPurple,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.indigo,
  ];

  static Widget paddingHelper() {
    return const Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: Divider(
          height: 1,
          thickness: 1,
        ),
      ),
    );
  }

  static textStyle() {
    return const TextStyle(fontFamily: 'DonegalOne');
  }
}
