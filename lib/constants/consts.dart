import 'package:flutter/material.dart';

const String usersCollection = "usersCollection";
const String taskCollection = "tasks";
const String myTaskCollection = "myTasks";
const double kDateTimePickerHeight = 100;
Color color1 = Colors.white;
Color color2 = Colors.white;

int dayNum = DateTime.now().day;
int month = DateTime.now().month;
int year = DateTime.now().year;

DateTime fullDateTime = DateTime.now();

int select = 0;
bool dateVisible = true;
bool timeVisible = false;
int index = 0;
int hour = DateTime.now().hour;
int minute = DateTime.now().minute;
