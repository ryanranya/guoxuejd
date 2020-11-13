
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../tabbar/initialize_item.dart';

class WBMainTabBarPage extends StatefulWidget {
  @override
  _WBMainTabBarPageState createState() => _WBMainTabBarPageState();
}

class _WBMainTabBarPageState extends State<WBMainTabBarPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        selectedFontSize: 15,
        unselectedFontSize: 15,
        selectedItemColor: Color.fromARGB(255, 18, 150, 219),
        unselectedItemColor: Color.fromARGB(255, 191, 191, 191),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
