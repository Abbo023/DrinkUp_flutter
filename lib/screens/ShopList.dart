import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//MODELS
import '../models/ShopIngredient.dart';

//SERVICE
import '../services/database_helper.dart';
import '../services/api_service.dart';


class ShopList extends StatefulWidget {
  @override
  ShopListState createState() => ShopListState();
}

class ShopListState extends State<ShopList> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  List<ShopIngredient> ingredients = [];
  List<String> dropdownIngredients = [];

  String selectedIngredient = '';


  @override
  void initState() {
    super.initState();
    loadIngredients();
  }

  Future<void> loadIngredients() async {
    try {
      List<String> dropIngredients = await fetchIngredients();
      List<ShopIngredient> loadedIngredients = await dbHelper.getIngredients();
      setState(() {
        dropdownIngredients = dropIngredients;
        ingredients = loadedIngredients;
      });
    } catch (error) {
      // Gestisci l'errore come preferisci
      print('Errore durante il caricamento degli ingredienti: $error');
    }
  }


  void addIngredient(String name, int quantity) async {
    int index = ingredients.indexWhere((ingredient) => ingredient.name == name);
    if (index != -1) {
      updateQuantity(index, quantity);
    } else {
      ShopIngredient ingredient = ShopIngredient(
          name: name, quantity: quantity);
      await dbHelper.insertIngredient(ingredient);
    }
    loadIngredients();
  }


  void updateQuantity(int index, int quantity) async {
    ShopIngredient ingredient = ingredients[index];
    ingredient.quantity += quantity;
    await dbHelper.updateIngredient(ingredient);
    loadIngredients();
  }

  void deleteIngredient(int index) async {
    ShopIngredient ingredient = ingredients[index];
    await dbHelper.deleteIngredient(ingredient.id!);
    loadIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista della spesa',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  TextEditingController quantityController = TextEditingController(
                    text: '${ingredients[index].quantity}',
                  );

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ingredients[index].name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}$')),
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                    suffixText: 'mL',
                                  ),
                                  onSubmitted: (value) async {
                                    int? newQuantity = int.tryParse(value);
                                    if (newQuantity != null && newQuantity > 0) {
                                      ingredients[index].quantity = newQuantity;
                                      await dbHelper.updateIngredient(ingredients[index]);
                                      setState(() {
                                        loadIngredients(); // Ricarica la lista
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 4),
                              IconButton(
                                onPressed: () {
                                  deleteIngredient(index);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            if (dropdownIngredients.isNotEmpty)
              DropdownButton<String>(
                hint: Text('Seleziona un ingrediente'),
                value: selectedIngredient.isEmpty ? null : selectedIngredient,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedIngredient = newValue ?? '';
                  });
                  addIngredient(selectedIngredient, 100);
                  selectedIngredient = '';
                },
                items: dropdownIngredients.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

            SizedBox(height: 16),


            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Ingrediente',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: '',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Quantità',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}$')),
                        ],
                        decoration: InputDecoration(
                          hintText: '',
                          suffixText: 'mL',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                  int? quantity = int.tryParse(quantityController.text);
                  if (quantity != null && quantity > 0) {
                    addIngredient(textController.text, quantity);
                    textController.clear();
                    quantityController.clear();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text('AGGIUNGI'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
