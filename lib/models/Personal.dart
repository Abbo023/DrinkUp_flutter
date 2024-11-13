import 'dart:convert';
import 'Ingredient.dart';

class Personal {
  String id;
  String name;
  String autore;
  String instruction;
  String image;
  List<Ingredient> ingredients;

  Personal({
    required this.id,
    required this.name,
    required this.autore,
    required this.instruction,
    required this.image,
    required this.ingredients,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'autore': autore,
      'instruction': instruction,
      'image': image,
      'ingredients': jsonEncode(ingredients.map((e) => e.toMap()).toList()),
    };
  }

  factory Personal.fromMap(Map<String, dynamic> map) {
    return Personal(
      id: map['id'],
      name: map['name'],
      autore: map['autore'],
      instruction: map['instruction'],
      image: map['image'],
      ingredients: (jsonDecode(map['ingredients']) as List)
          .map((item) => Ingredient.fromMap(item))
          .toList(),
    );
  }


  List<Ingredient> getIngredients(){
    return ingredients;
  }


}
