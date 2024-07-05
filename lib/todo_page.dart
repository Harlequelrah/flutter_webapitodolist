import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Suivi d\'habitude',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red), // Replace with your desired color
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.amber,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.red,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ), // Replace with your desired color
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
          centerTitle: true,
        ),
        body: Container(height: 500, color: Colors.red));
  }
}
