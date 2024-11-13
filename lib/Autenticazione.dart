import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class LoginActivity extends StatefulWidget {
  @override
  LoginActivityState createState() => LoginActivityState();
}

class LoginActivityState extends State<LoginActivity> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Funzione per il login
  Future<void> loginUser(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      showToast('Per favore riempi tutti i campi');
      return;
    }
    if (!validateEmail(email)) {
      showToast('Per favore inserisci una email valida');
      return;
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      showToast('Autenticazione fallita: ${e.message}');
    }
  }


  bool validateEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  // Mostra messaggio toast
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accedi o Registrati'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      loginUser(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                    ),
                    child: Text('LOGIN'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Naviga alla schermata di registrazione
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationActivity(),
                  ),
                );
              },
              child: Text(
                "Se non sei ancora iscritto, registrati ora",
                style: TextStyle(
                  color: Colors.blue, // Colore del testo cliccabile
                  decoration: TextDecoration.underline, // Sottolinea il testo
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RegistrationActivity extends StatefulWidget {
  @override
  RegistrationState createState() => RegistrationState();
}

class RegistrationState extends State<RegistrationActivity> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  Future<void> registerUser(String username, String email, String password) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      showToast('Per favore riempi tutti i campi');
      return;
    }
    if (!validateEmail(email)) {
      showToast('Per favore inserisci una email valida');
      return;
    }

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateProfile(displayName: username);
        await saveUserToFirestore(userCredential.user!.uid, username, email);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      showToast('Registrazione fallita: ${e.message}');
    }
  }


  Future<void> saveUserToFirestore(String uid, String username, String email) async {
    final userMap = {
      "username": username,
      "email": email,
      "ricette preferite": []
    };
    try {
      await firestore.collection('users').doc(uid).set(userMap);
    } catch (e) {
      showToast('Errore durante il salvataggio dei dati utente: $e');
    }
  }


  bool validateEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  // Mostra messaggio toast
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accedi o Registrati'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Expanded(

              child: ElevatedButton(
                onPressed: () {
                  registerUser(
                    usernameController.text.trim(),
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
                child: Text('REGISTER'),
              ),
            ),
          ],
        ),
        ],
      ),
      ),
    );
  }
}