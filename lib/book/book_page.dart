
import 'package:flutter/material.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('国学经典'),),
      body: Center(
        child: Text('国学经典',style: TextStyle(fontFamily: 'FZFSJT',fontSize: 30),),
      ),
    );
  }
}
