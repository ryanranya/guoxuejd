import 'package:flutter/material.dart';

class WBBottomBarItem extends BottomNavigationBarItem {
  WBBottomBarItem(@required String unSelectImageName,
      @required String selectImageName, @required String titleName) : super(
    label: titleName,
    icon: Image.asset("assets/images/tabbar/${unSelectImageName}.png",width: 30,gaplessPlayback: true,),
    activeIcon: Image.asset("assets/images/tabbar/${selectImageName}.png",width: 30,gaplessPlayback: true,),
  );
}