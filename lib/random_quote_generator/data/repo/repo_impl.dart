import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mp3/random_quote_generator/data/model/quote_model.dart';

abstract class QuoteRepo {
  Future<QuoteModel?> getQuote();
}

class QuoteRepoImpl implements QuoteRepo {
  @override
  Future<QuoteModel?> getQuote() async {
    final response =
        await http.get(Uri.parse('https://api.quotable.io/random'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return QuoteModel.fromJson(data);
    } else {
      return null;
    }
  }
}
