class Drink {
  final String? idDrink;
  final String? strDrink;
  final String? strCategory;
  final String? strAlcoholic;
  final String? strGlass;
  final String? strInstructions;
  final String? strDrinkThumb;
  final List<Ingredient>? ingredients;

  Drink({
    required this.idDrink,
    required this.strDrink,
     this.strCategory,
     this.strAlcoholic,
     this.strGlass,
     this.strInstructions,
    required this.strDrinkThumb,
      this.ingredients,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];

    for (int i = 1; i <= 15; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient,
          measure: measure,
        ));
      }
    }

    return Drink(
      idDrink: json['idDrink'] ?? '',
      strDrink: json['strDrink'] ?? 'Unknown Drink',
      strCategory: json['strCategory'] ?? 'Unknown Category',
      strAlcoholic: json['strAlcoholic'] ?? 'Unknown',
      strGlass: json['strGlass'] ?? 'Unknown Glass',
      strInstructions: json['strInstructions'] ?? 'No instructions available',
      strDrinkThumb: json['strDrinkThumb'] ?? '',
      ingredients: ingredients,
    );
  }

  getIngredients(){
    return ingredients;
  }
}

class Ingredient {
  final String? name;
  final String? measure;

  Ingredient({
    this.name,
    this.measure,
  });
}
