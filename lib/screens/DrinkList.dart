import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

//MODELS
import '../models/Drink.dart';

//SCREEN
import 'DrinkDetail.dart';

//SERVICES
import '../services/api_service.dart';
import '../services/firebase.dart';

class DrinkList extends StatefulWidget {
  @override
  DrinkListState createState() => DrinkListState();
}

class DrinkListState extends State<DrinkList> {
  late Future<List<Drink>> futureDrinks;

  @override
  void initState() {
    super.initState();
    loadDrinks();
  }

  void loadDrinks() {
    setState(() {
      futureDrinks = fetchDrinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ricette predefinite',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column( // Modifica qui
        children: [
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Drink>>(
              future: futureDrinks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      child: Lottie.network(
                          'https://lottie.host/416f3738-9f44-4e73-b7f2-63147102aab5/8yyXWzRU22.json'),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Errore: ${snapshot.error}'));
                } else {
                  final drinks = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: drinks.length,
                    itemBuilder: (context, index) {
                      final drink = drinks[index];
                      return DrinkListItem(
                          drink: drink);
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

  const DrinkListItem({Key? key, required this.drink}) : super(key: key);

  @override
  DrinkListItemState createState() => DrinkListItemState();
}

class DrinkListItemState extends State<DrinkListItem> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    bool favorite = await isFavoriteDrink(widget.drink.idDrink!);
    setState(() {
      isFavorite = favorite;
    });
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    toggleLike(widget.drink);
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