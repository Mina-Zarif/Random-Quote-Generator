import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../utils/db_helper.dart';
import 'deck_editor.dart';
import 'flashcard_list.dart';


class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  late Future<List<Deck>> _decks;
  List<Deck> localDecks = [];

  Future<List<Deck>> loadDecks() async {
    final deckData = await DBHelper().query('deck');
    final flashCards = await DBHelper().query('flashcard');
    return deckData
        .map((e) => Deck(
              id: e['id'] as int,
              title: e['title'] as String,
              flashcards:
                  (flashCards.where((fc) => fc['deckId'] == e['id']).toList())
                      .map((fc) => Flashcard(
                            id: fc['id'] as int,
                            deckId: fc['deckId'] as int,
                            question: fc['question'] as String,
                            answer: fc['answer'] as String,
                          ))
                      .toList(),
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _decks = loadDecks();
    _decks.then((value) => {
          if (value.isEmpty) {loadDecksJson()}
        });
  }

  Future<void> loadDecksJson() async {
    final String jsonContent = await DefaultAssetBundle.of(context)
        .loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(jsonContent);

    for (final dynamic item in jsonData) {
      final String title = item['title'];
      final int deckId = DateTime.now().millisecondsSinceEpoch;
      final List<Flashcard> flashcards =
          (item['flashcards'] as List<dynamic>).asMap().entries.map((entry) {
        int index = entry.key;
        var fc = entry.value;
        final int deckId = DateTime.now().millisecondsSinceEpoch;
        return Flashcard(
            id: index,
            deckId: deckId,
            question: fc['question'],
            answer: fc['answer']);
      }).toList();

      await DBHelper().insert('deck', {'id': deckId, 'title': title});
      for (var flashcard in flashcards) {
        await DBHelper().insert('flashcard', {
          'question': flashcard.question,
          'answer': flashcard.answer,
          'deckId': deckId,
        });
      }
      localDecks.add(Deck(id: deckId, title: title, flashcards: flashcards));
    }
    setState(() {
      localDecks = localDecks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _decks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.data != null) {
            localDecks = snapshot.data as List<Deck>;
          } else {
            localDecks.clear();
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Center(
                child: Text(
                  'Flashcard Decks',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => loadDecksJson(),
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (localDecks.isEmpty) {
                  return Center(
                      child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      loadDecksJson();
                    },
                  ));
                }
                int crossAxisCount =
                    max(1, (constraints.maxWidth / 300).floor());
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  padding: const EdgeInsets.all(4),
                  children: List.generate(
                    localDecks.length,
                    (index) => Card(
                      color: Colors.blue[100],
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardList(
                                deckId: localDecks[index].id ?? 0,
                                deckTitle: localDecks[index].title,
                                decks: localDecks,
                              ),
                            ),
                          ).then((value) => {
                                if (value == true)
                                  {
                                    setState(() {
                                      _decks = loadDecks();
                                    })
                                  }
                              });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Center(child: Text(localDecks[index].title)),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '(${localDecks[index].flashcards.length.toString()} cards)',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          final newDeck = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DeckEditor(
                                                deckIndex:
                                                    localDecks[index].id ?? 0,
                                                deckTitle:
                                                    localDecks[index].title,
                                                decks: localDecks,
                                                isBeingCreated: false,
                                              ),
                                            ),
                                          );
                                          if (newDeck != null) {
                                            setState(() {
                                              localDecks = newDeck;
                                              _decks = loadDecks();
                                            });
                                          }
                                        },
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final List<Deck> newDeck = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckEditor(
                      deckIndex: 0,
                      deckTitle: '',
                      decks: localDecks,
                      isBeingCreated: true,
                    ),
                  ),
                );
                if (newDeck.isNotEmpty) {
                  setState(() {
                    localDecks = newDeck;
                  });
                }
              },
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
