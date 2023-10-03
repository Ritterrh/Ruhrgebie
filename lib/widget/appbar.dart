import 'package:flutter/material.dart';

AppBar appbar() {
  return AppBar(
    backgroundColor: Colors.white10.withOpacity(0.2),
    elevation: 0,
    actions: const [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, Pathway",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text("India", style: TextStyle(fontSize: 10))
        ],
      ),
      Padding(
        padding: EdgeInsets.only(right: 8, left: 15),
        child: Icon(Icons.notifications_active_outlined, size: 30),
      )
    ],
  );
}
