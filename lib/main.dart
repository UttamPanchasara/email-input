import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'email_input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose Email'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10.0),
          width: double.infinity,
          color: Colors.grey,
          child: EmailInput(),
        ),
      ),
    );
  }
}
