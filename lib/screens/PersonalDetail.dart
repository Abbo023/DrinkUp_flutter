import 'dart:io';
import 'package:flutter/material.dart';


//MODELS
import '../models/Personal.dart';
import '../models/Ingredient.dart';

class PersonalDetail extends StatelessWidget {
  final Personal personal;

  PersonalDetail({required this.personal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(personal.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            personal.image.isNotEmpty
                ? Image.file(
              File(personal.image),
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
            )
                : Container(
              width: double.infinity,
              height: 400,
              color: Colors.grey,
              child: Icon(Icons.image, size: 100, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              personal.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Creato da: ${personal.autore}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Istruzioni:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              personal.instruction,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Ingredienti:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            buildIngredientsList(personal),
          ],
        ),
      ),
    );
  }

  Widget buildIngredientsList(Personal personal) {
    List<Widget> ingredients = [];
    List<Ingredient> ing = personal.getIngredients();

    for (int i = 0; i < ing.length; i++) {
      ingredients.add(
        Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(Icons.local_bar),
            title: Text(
              ing[i].name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              ing[i].measure,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }
    return Column(children: ingredients);
  }
}