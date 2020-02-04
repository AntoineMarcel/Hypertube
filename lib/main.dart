import 'dart:io';

import 'package:flutter/material.dart';
import './pages/signup.dart';
import './pages/signin.dart';
import './pages/myprofil.dart';
import './pages/userprofil.dart';
import './pages/library.dart';
import './utils/global.dart' as global;
import './pages/jquery.dart';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  jQuery('.loader-wrapper').remove();
  updatemovie();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  var appTitle = 'Hypertube';
  var text = global.langue;

  Widget bodyContent;
  bool connexion = false;
  void _changeBody(Widget toChange) {
    setState(() {
      if (text != global.langue) text = global.langue;
      if (global.isLoggedIn && connexion == false) connexion = true;
      if (!global.isLoggedIn && connexion == true) connexion = false;
      if (toChange != bodyContent) bodyContent = toChange;
    });
  }

  List<Widget> _appBarNotConnected() {
    return [
      FlatButton(
        textColor: Colors.white,
        child: Text("Sign in"),
        onPressed: () {
          _changeBody(SigninForm(_changeBody));
        },
      ),
      FlatButton(
        textColor: Colors.white,
        child: Text("Sign up"),
        onPressed: () {
          _changeBody(SignupForm());
        },
      ),
    ];
  }

  List<Widget> _appBarConnected() {
    return [
      FlatButton(
        textColor: Colors.white,
        child: Text(text['home']),
        onPressed: () {
          _changeBody(Library(_changeBody));
        },
      ),
      FlatButton(
        textColor: Colors.white,
        child: Text(text['infos']),
        onPressed: () {
          _changeBody(Myprofil(_changeBody));
        },
      ),
      FlatButton(
        textColor: Colors.white,
        child: Text(text['search_user']),
        onPressed: () {
          _changeBody(SearchProfil(_changeBody));
        },
      ),
      FlatButton(
        textColor: Colors.white,
        child: Text(text['disconnect']),
        onPressed: () {
          global.isLoggedIn = false;
          global.tab = null;
          global.auth_fire.signOut();
          global.langue = global.English;
          _changeBody(SigninForm(_changeBody));
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var index = window.location.href.indexOf("?code=");
    if (index != -1 && global.isLoggedIn == false)
      check42(_changeBody);
    if (bodyContent == null) bodyContent = SigninForm(_changeBody);

    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.white30,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              global.isLoggedIn && connexion == true
                  ? _changeBody(Library(_changeBody))
                  : _changeBody(SigninForm(_changeBody));
            },
          ),
          title: Text(appTitle),
          actions: connexion ? _appBarConnected() : _appBarNotConnected(),
        ),
        body: bodyContent,
      ),
    );
  }
}

Future<void> updatemovie() async {
  var movie = await global.bdd_fire.collection('movies').get();
  movie.forEach((callback) {
    var date = callback.data()['date'];
    Duration dur = DateTime.now().difference(date);
    if (dur.inDays > 30) {
      global.bdd_fire.collection('movies').doc(callback.id).delete();
    }
  });
}

Future<void> check42(Function(Widget) _changeBody) async {
 var url = window.location.href;
 var index = url.indexOf("?code=");
 var response;
 var token;
 if (index != -1)
 {
    url = url.substring(index + 6);
    url = url.replaceAll("#/", "");
    await http.post("https://api.intra.42.fr/oauth/token",
          body: {'grant_type': 'authorization_code', 
          'client_id': '628061f039b7ecd339a752c9039ce8963b96bcb45f70f3e1c5cf816595deda76', 
          'client_secret': 'af344d1a996378df714734653a1b711ebcf61e33f54c1f96327cd4defc54529e',  
          'code': url,
          'redirect_uri' : 'http://localhost:5000/'}).then((code){
            response = code.statusCode;
            token = code.body;
          });
    
    if (response == 200)
    {
      // print(url);
      var jsontoken = jsonDecode(token);

      final info = await http.read("https://api.intra.42.fr/v2/me", 
      headers: {"Authorization" : "Bearer " + jsontoken['access_token']});
      var jsoninfo = jsonDecode(info);
      // print(jsoninfo);

      var tab = {
        "mail": jsoninfo['email'],
        "password": jsoninfo['email'],
        "username": jsoninfo['login'],
        "nom": jsoninfo['last_name'],
        "prenom": jsoninfo['first_name'],
        "photo": jsoninfo['image_url'],
        "langue": "English",
      };
      var findinfo = global.bdd_fire.collection('users').doc(tab['mail']);
      var docSnapshot = await findinfo.get();
      if (!docSnapshot.exists) {
        await global.auth_fire
            .createUserWithEmailAndPassword(tab['mail'], jsoninfo['email']);
        await adduser(tab, 1);
      }
      await login(tab);
      if (global.isLoggedIn == true)
        _changeBody(Library(_changeBody));
    }
 }
}