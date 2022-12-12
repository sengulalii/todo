import 'package:flutter/material.dart';

class PageHelper {
  static int dayNum = DateTime.now().day;
  static int month = DateTime.now().month;
  static int year = DateTime.now().year;

  static DateTime taskDateTime = DateTime.now();
  static int select = 0;
  static bool dateVisible = true;
  static bool timeVisible = false;
  static int index = 0;

  static int years = DateTime.now().year;
  static int months = DateTime.now().month;
  static int days = DateTime.now().day;

  static int hour = DateTime.now().hour;
  static int minute = DateTime.now().minute;
  static Color color1 = Colors.white;
  static Color color2 = Colors.white;
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
