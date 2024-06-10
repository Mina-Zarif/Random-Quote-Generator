import 'package:flutter/material.dart';
import 'package:mp3/random_quote_generator/view/home_view.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: const RandomQuoteScreen(),
    );
  }
}
