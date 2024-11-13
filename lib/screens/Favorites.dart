import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

//MODELS
import '../models/Drink.dart';

//SCREEN
import 'DrinkDetail.dart';

//SERVICE
import '../services/firebase.dart';


class Favorites extends StatefulWidget {
  @override
  FavoritesState createState() => FavoritesState();
}

class FavoritesState extends State<Favorites> {
  late Future<List<Drink>> futureFavoriteDrinks;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() {
    setState(() {
      futureFavoriteDrinks = fetchFavsDrinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferiti', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
    children: [
    SizedBox(height: 16),
    Expanded(
    child: FutureBuilder<List<Drink>>(
        future: futureFavoriteDrinks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                child: Lottie.network('https://lottie.host/416f3738-9f44-4e73-b7f2-63147102aab5/8yyXWzRU22.json'),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else {
            final favoriteDrinks = snapshot.data ?? [];
            if (favoriteDrinks.isEmpty) {
              return Center(child: Text("Nessun drink nei preferiti."));
            }
            return ListView.builder(
              itemCount: favoriteDrinks.length,
              itemBuilder: (context, index) {
                final drink = favoriteDrinks[index];
                return DrinkListItem(
                  drink: drink,
                  onFavoriteToggle: loadFavorites,
                );
              },
            );
          }
        },
      ),
    ),
      ],
      ),
    );
  }
}

class DrinkListItem extends StatefulWidget {
  final Drink drink;
  final VoidCallback onFavoriteToggle;

  const DrinkListItem({Key? key, required this.drink, required this.onFavoriteToggle}) : super(key: key);

  @override
  DrinkListItemState createState() => DrinkListItemState();
}

class DrinkListItemState extends State<DrinkListItem> {
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    bool favorite = await isFavoriteDrink(widget.drink.idDrink!);
    setState(() {
      isFavorite = favorite;
      isLoading = false;
    });
  }

  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });
    await toggleLike(widget.drink);
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        leading: widget.drink.strDrinkThumb != null
            ? Image.network(widget.drink.strDrinkThumb!)
            : null,
        title: Text(widget.drink.strDrink ?? 'Unknown Drink'),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DrinkDetail(
                drink: widget.drink,
                onFavoriteChanged: (isFavorite) {
                  setState(() {
                    this.isFavorite = isFavorite;
                  });
                },
              ),
            ),
          );


            widget.onFavoriteToggle();

        },
        trailing: IconButton(
          onPressed: toggleFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}