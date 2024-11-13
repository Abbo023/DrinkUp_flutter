class Ingredient {
    String name;
    String measure;

  Ingredient(this.name, this.measure);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'measure': measure,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      map['name'],
      map['measure'],
    );
  }
}