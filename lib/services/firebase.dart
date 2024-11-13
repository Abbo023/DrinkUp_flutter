import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//MODELS
import '../models/Drink.dart';
import '../models/RicetteFav.dart';


import 'api_service.dart';


final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;


Future<bool> isFavoriteDrink(String drinkId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        List<dynamic> ricettePreferite = userData['ricette preferite'] ?? [];

        List<RicetteFav> ricetteFavList = ricettePreferite.map((item) {
          return RicetteFav(
            origin: item['origin'] as String,
            drinkId: item['drinkId'] as String,
          );
        }).toList();

        for (var ricetta in ricetteFavList) {
          if (ricetta.origin == 'pred' && ricetta.drinkId == drinkId) {
            return true;
          }
        }
        return false;
      }
    } catch (e) {
      print("Errore durante la ricerca di drink preferiti: $e");
    }
  }
  return false;
}


Future<void> toggleLike(Drink drink) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? user = auth.currentUser;

  if (user != null) {
    final userRef = firestore.collection("users").doc(user.uid);

    try {
      final userData = await userRef.get();

      if (userData.exists) {
        final List<dynamic> ricettePreferite = userData.get("ricette preferite") ?? [];

        List<RicetteFav> ricetteFavList = ricettePreferite.map((item) {
          return RicetteFav(
            origin: item["origin"] ?? "unknown",
            drinkId: item["drinkId"] ?? "",
          );
        }).toList();

        final nuovaRicettaFav = RicetteFav(origin: "pred", drinkId: drink.idDrink!);

        if (ricetteFavList.contains(nuovaRicettaFav)) {
          ricetteFavList.remove(nuovaRicettaFav);
        } else {
          ricetteFavList.add(nuovaRicettaFav);
        }

        await userRef.update({
          "ricette preferite": ricetteFavList.map((ricetta) {
            return {
              "origin": ricetta.origin,
              "drinkId": ricetta.drinkId,
            };
          }).toList(),
        });
      }
    } catch (e) {
      print("Errore durante l'aggiornamento delle ricette preferite: $e");
    }
  }
}

Future<List<Drink>> fetchFavsDrinks() async {

  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
  final userData = await userRef.get();

  if (userData.exists) {
    final List<dynamic> favoriteIds = userData.get("ricette preferite") ?? [];

    List<Drink> favoriteDrinks = [];

    for (var dr in favoriteIds) {
      if (dr["origin"] == "pred") {
        final drink = await fetchDrinkDetailsById(dr["drinkId"]);

        Drink partialDrink = Drink(
          idDrink: drink.idDrink,
          strDrink: drink.strDrink,
          strDrinkThumb: drink.strDrinkThumb,
        );

        favoriteDrinks.add(partialDrink);
      }
    }
    return favoriteDrinks;
  }
  return [];
}