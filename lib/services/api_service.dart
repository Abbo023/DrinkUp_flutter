import 'dart:convert';
import 'package:http/http.dart' as http;

//MODELS
import '../models/Drink.dart';

Future<List<Drink>> fetchDrinks() async {
  final response = await http.get(Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic'));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  if (response.statusCode == 200) {
    // Decodifica la risposta JSON
    final Map<String, dynamic> json = jsonDecode(response.body);

    // Estrai la lista di drink
    final List<dynamic> drinksJson = json['drinks'];

    // Mappa ogni oggetto JSON in un oggetto Drink
    return drinksJson.map((drink) => Drink.fromJson(drink)).toList();
  } else {
    throw Exception('Failed to load drinks');
  }
}

Future<Drink> fetchDrinkDetailsById(String drinkId) async {
  final url = 'https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=$drinkId';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final drinkData = data['drinks'][0];
    return Drink.fromJson(drinkData);
  } else {
    throw Exception('Failed to load drink details');
  }
}

Future<List<String>> fetchIngredients() async {
  final response = await http.get(Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<dynamic> ingredientsData = data['drinks'];

    // Mappiamo i dati degli ingredienti in una lista di stringhe
    return ingredientsData.map((item) => item['strIngredient1'] as String).toList();
  } else {
    throw Exception('Failed to load ingredients');
  }
}