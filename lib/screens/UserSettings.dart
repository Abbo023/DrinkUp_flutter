import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:DrinkUp_flutter/Autenticazione.dart';

class UserSettings extends StatefulWidget {
  @override
  UserSettingsState createState() => UserSettingsState();
}

class UserSettingsState extends State<UserSettings> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
  }

  void resetPassword() {
    if (user != null && user!.email != null) {
      auth.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email di reimpostazione password inviata a ${user!.email}'),
      ));
    }
  }


  void logoutUser() async {
    await auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginActivity()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilo Utente'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: user != null ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('lib/images/avatar.png'),
                ),

              ),
              SizedBox(height: 20),


              TextFormField(
                initialValue: user!.displayName ?? 'N/A',
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Email
              TextFormField(
                initialValue: user!.email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              SizedBox(height: 20),


              TextFormField(
                initialValue: '********',
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  resetPassword();
                },
                child: Text('Reimposta Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),

              SizedBox(height: 60),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    logoutUser();
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ) : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

