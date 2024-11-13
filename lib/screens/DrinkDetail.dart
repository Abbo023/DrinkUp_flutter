import 'package:flutter/material.dart';

//MODELS
import '../models/Drink.dart';

//SERVICES
import '../services/api_service.dart';
import '../services/firebase.dart';

class DrinkDetail extends StatefulWidget {
  final Drink drink;
  final Function(bool) onFavoriteChanged;

  DrinkDetail({required this.drink, required this.onFavoriteChanged});

  @override
  DrinkDetailState createState() => DrinkDetailState();
}

class DrinkDetailState extends State<DrinkDetail> {
  late Drink drinkDetails;
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    drinkDetails = widget.drink;
    loadDrinkDetails();
    checkIfFavorite();
  }

  Future<void> loadDrinkDetails() async {
    Drink detailedDrink = await fetchDrinkDetailsById(widget.drink.idDrink!);
    setState(() {
      drinkDetails = detailedDrink;
      isLoading = false;
    });
  }

  Future<void> checkIfFavorite() async {
    bool favorite = await isFavoriteDrink(widget.drink.idDrink!);
    setState(() {
      isFavorite = favorite;
    });
  }

  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });
    await toggleLike(drinkDetails);
    widget.onFavoriteChanged(isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? 'Loading...' : drinkDetails.strDrink!),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, isFavorite);
          },
        ),
      ),
      body: isLoading
          ? Center(child: Container())
          : SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: drinkDetails.strDrinkThumb != null
                            ? Image.network(
                          drinkDetails.strDrinkThumb!,
                          height: 250,
                        )
                            : SizedBox(),
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(12),
                          child: IconButton(
                            onPressed: toggleFavorite,
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            iconSize: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    drinkDetails.strDrink ?? 'Nome sconosciuto',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Instructions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    drinkDetails.strInstructions ?? 'Nessuna istruzione disponibile',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Ingredients:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  buildIngredientsList(drinkDetails),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIngredientsList(Drink drink) {
    List<Widget> ingredients = [];
    List<Ingredient> ing = drink.getIngredients();

    for (int i = 0; i < ing.length; i++) {
      ingredients.add(
        Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(Icons.local_bar),
            title: Text(ing[i].name ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(ing[i].measure ?? '', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }
    return Column(children: ingredients);
  }
}

