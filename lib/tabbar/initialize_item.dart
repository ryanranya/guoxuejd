

import 'package:flutter/material.dart';
import '../book/book_page.dart';
import '../home/home_page.dart';
import '../mine/mine_page.dart';
import '../tabbar/item.dart';

List<WBBottomBarItem> items = [
  WBBottomBarItem('stateful_n','stateful_s','stateful'),
  WBBottomBarItem('stateless_n','stateless_s','stateless'),
  WBBottomBarItem('proxy_n','proxy_s','proxy'),
];

List<Widget> pages = [
  HomePage(),
  BookPage(),
  MinePage(),
];