import 'package:flutter/material.dart';
import 'package:mp3/random_quote_generator/data/model/quote_model.dart';
import 'package:share/share.dart';

import '../data/repo/repo_impl.dart';

class RandomQuoteScreen extends StatefulWidget {
  const RandomQuoteScreen({super.key});

  @override
  State<RandomQuoteScreen> createState() => _RandomQuoteScreenState();
}

class _RandomQuoteScreenState extends State<RandomQuoteScreen> {
  QuoteModel? _quote;

  String message = "Tap the button to get a random quote";
  QuoteRepoImpl repo = QuoteRepoImpl();

  Future<void> _getRandomQuote() async {
    try {
      _quote = (await repo.getQuote());
    } catch (e) {
      _quote = null;
      message = "Failed to load a quote";
    }
    setState(() {});
  }

  void _shareQuote() {
    if (_quote != null) {
      Share.share('${_quote!.content} - ${_quote!.author}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Quote'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _quote != null ? _quote!.content! : message,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _quote != null ? "- ${_quote!.author!}" : '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _getRandomQuote,
                  child: const Text('Get Random Quote'),
                ),
                if (_quote != null) ...[
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: _shareQuote,
                    child: const Text('Share'),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
