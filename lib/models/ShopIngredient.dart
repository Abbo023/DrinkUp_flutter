class ShopIngredient {
   int? id;
   String name;
   int quantity;

  ShopIngredient({this.id, required this.name, required this.quantity});

  // Converte Ingrediente a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
    };
  }

  // Convert da Map a Ingrediente
  factory ShopIngredient.fromMap(Map<String, dynamic> map) {
    return ShopIngredient(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
    );
  }
}