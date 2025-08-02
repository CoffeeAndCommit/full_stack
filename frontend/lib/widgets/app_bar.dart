import 'package:flutter/material.dart';

AppBar customAppBar({
  String title = 'Todo',
  Color appbarColor = const Color(0xff001133),
}) {
  return AppBar(
    title: Text(title, style: const TextStyle(color: Colors.white)),
    elevation: 10.0,
    backgroundColor: appbarColor,

  );
}
