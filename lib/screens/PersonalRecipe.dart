import 'dart:io';
import 'package:flutter/material.dart';


//MODELS
import '../models/Personal.dart';

//SCREENS
import 'CreateRecipe.dart';
import 'PersonalDetail.dart';

//SERVICES
import '../services/database_helper.dart';



class PersonalRecipe extends StatefulWidget {
  @override
  PersonalRecipeState createState() => PersonalRecipeState();
}

class PersonalRecipeState extends State<PersonalRecipe> {
  List<Personal> personals = [];


  @override
  void initState() {
    super.initState();
    loadPersonals();
  }

  Future<void> loadPersonals() async {
    List<Personal> loadedPersonals = await DatabaseHelper().getPersonals();
    setState(() {
      personals = loadedPersonals;
    });
  }

  void elimina(String id) async {
    await DatabaseHelper().deletePersonal(id);
    loadPersonals();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Crea la tua ricetta!',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,

      ),
      body: personals.isEmpty
          ? Center(child: Text('Non ci sono ricette ancora.'))
          : ListView.builder(
        itemCount: personals.length,
        itemBuilder: (context, index) {
          final personal = personals[index];
          return Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalDetail(personal: personal),
                    ),
                  );
                },
                child: ListTile(
                  leading: personal.image.isNotEmpty
                      ? Image.file(File(personal.image),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover)
                      : Icon(Icons.local_bar),
                  title: Text(personal.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: SizedBox(
                    child: Row(
                      children: [
                        Text('~By ',style: TextStyle(fontStyle: FontStyle.italic)),
                        Text(personal.autore, style: TextStyle(fontStyle: FontStyle.italic))
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: (){
                      elimina(personal.id);
                      },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.blue,
                    ),
                ),
              )
          )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPersonal = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateRecipe()),
          );

          if (newPersonal != null) {
            loadPersonals();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

