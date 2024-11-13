import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Autenticazione.dart';

//SCREEN
import 'screens/DrinkList.dart';
import 'screens/Favorites.dart';
import 'screens/PersonalRecipe.dart';
import 'screens/ShopList.dart';
import 'screens/UserSettings.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Preparation(),
    );
  }
}


class Preparation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginActivity();
          } else {
            return MyHomePage();
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}




class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;


  static List<Widget> widgetOptions = <Widget>[
    DrinkList(),
    Favorites(),
    PersonalRecipe(),
    ShopList(),
    UserSettings(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            label: 'Ricette',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'preferiti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Crea',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'spesa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'utente',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: onItemTapped,
      ),
    );
  }
}


