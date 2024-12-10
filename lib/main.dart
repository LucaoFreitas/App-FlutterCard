import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart'; // Certifique-se de ter essa dependência
import 'package:provider/provider.dart'; // Para gerenciar o estado

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Teste',
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // Gerenciamento de favoritos
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0; // Gerenciar o índice da NavigationRail

  @override
  Widget build(BuildContext context) {
    // Alternar entre as páginas com base no selectedIndex
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Página principal
        break;
      case 1:
        page = FavoritesPage(); // Página de favoritos
        break;
      default:
        throw UnimplementedError('Sem widget para o índice $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favoritos'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value; // Atualiza o índice selecionado
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page, // Usa a página definida no switch
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Gerador de Palavras Aleatórias',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Escolha sua palavra :',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Define a cor branca para o texto
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          BigCard(pair: pair),
          SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(
                  icon,
                  color: appState.favorites.contains(pair) ? Colors.red : null,
                ),
                label: Text('Favoritar'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Próxima'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Página de favoritos
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(
          'Nenhum favorito ainda.',
          style: TextStyle(fontSize: 24),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Seus Favoritos:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: appState.favorites.length,
            itemBuilder: (context, index) {
              var pair = appState.favorites[index];
              return ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text(
                  pair.asLowerCase,
                  style: TextStyle(fontSize: 18),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    appState.favorites
                        .remove(pair); // Remove diretamente da lista
                    appState.notifyListeners(); // Atualiza o estado
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${pair.asPascalCase} removido dos favoritos.',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair pair; // Parâmetro obrigatório para o widget

  BigCard({required this.pair, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headline5!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 15,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(30), // Adiciona espaço dentro do Card
        child: Text(
          pair.asLowerCase, // Converte para letras minúsculas
          style: style, // Aplica o estilo do texto
        ),
      ),
    );
  }
}
