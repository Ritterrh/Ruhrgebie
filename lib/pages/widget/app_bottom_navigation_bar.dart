import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.podcasts),
          label: 'Audio Guide',
        ),
        /*  BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoriten',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Einstellungen',
        ),
        */
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    );
  }
}
