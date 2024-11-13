import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

//MODELS
import '../models/Personal.dart';
import '../models/Ingredient.dart';

//SERVICES
import '../services/database_helper.dart';

class CreateRecipe extends StatefulWidget {
  @override
  CreateRecipeState createState() => CreateRecipeState();
}

class CreateRecipeState extends State<CreateRecipe> {
  final formKey = GlobalKey<FormState>();
  String? name;
  String? autore;
  String? instruction;
  String? image;
  List<Ingredient> ingredients = [];
  List<TextEditingController> ingredientNameControllers = [];
  List<TextEditingController> ingredientMeasureControllers = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    setAutore();
  }

  Future<void> setAutore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      autore = user?.displayName ?? 'Anonimo';
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image = pickedFile.path;
      }
    });
  }

  void addIngredient() {
    setState(() {
      ingredients.add(Ingredient('', ''));
      ingredientNameControllers.add(TextEditingController());
      ingredientMeasureControllers.add(TextEditingController());
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
      ingredientNameControllers[index].dispose();
      ingredientMeasureControllers[index].dispose();
      ingredientNameControllers.removeAt(index);
      ingredientMeasureControllers.removeAt(index);
    });
  }

  void saveRecipe() async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      for (int i = 0; i < ingredients.length; i++) {
        ingredients[i].name = ingredientNameControllers[i].text;
        ingredients[i].measure = ingredientMeasureControllers[i].text;
      }

      Personal newPersonal = Personal(
        id: DateTime.now().toString(),
        name: name!,
        autore: autore!,
        instruction: instruction!,
        image: image ?? '',
        ingredients: ingredients,
      );

      await DatabaseHelper().insertPersonal(newPersonal);

      Navigator.pop(context, newPersonal);
    } else {
      print("Errore: Il form non è valido.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Crea la tua ricetta!',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Titolo Ricetta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'titolo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il nome';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    name = value;
                  },
                ),
                SizedBox(height: 32),
                image == null
                    ? Image.asset(
                  'lib/images/galleria.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Image.file(File(image!)),
                ElevatedButton(
                  onPressed: pickImage,
                  child: Text('Seleziona immagine'),
                ),
                SizedBox(height: 16),
                Text(
                  'Istruzioni Ricetta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'istruzioni'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci le istruzioni';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    instruction = value;
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                SizedBox(height: 32),
                Text(
                  'Ingredienti Ricetta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: ingredientNameControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Ingrediente',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: ingredientMeasureControllers[index],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}$')),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Quantità',
                                  suffixText: 'mL',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                removeIngredient(index);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: addIngredient,
                  child: Text('Aggiungi Ingrediente'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saveRecipe,
                  child: Text('Salva Ricetta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}