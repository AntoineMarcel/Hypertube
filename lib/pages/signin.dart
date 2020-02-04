import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../utils/global.dart' as global;
import './library.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase/firebase.dart';
import 'dart:js' as js;
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SigninForm extends StatefulWidget {
  Function(Widget) _changeBody;
  SigninForm(this._changeBody);

  @override
  _SigninForm createState() => _SigninForm();
}

class _SigninForm extends State<SigninForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var errors = global.Error();
  final FocusNode passwordFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25.0, left: 200.0, right: 200.0),
      padding: const EdgeInsets.only(top: 25.0, left: 100.0, right: 100.0),
      height: 600.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: ListView(
        children: [
          FormBuilder(
            key: _fbKey,
            initialValue: {},
            child: Column(
              children: [
                FormBuilderTextField(
                  attribute: 'mail',
                  autofocus: true,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email),
                    hintText: global.langue['mail_enter'],
                    labelText: global.langue['mail_label'],
                  ),
                  validators: [
                    FormBuilderValidators.required(errorText: errors.videError),
                    FormBuilderValidators.email(errorText: errors.mailError),
                  ],
                  maxLines: 1,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(passwordFocus);
                  },
                ),
                FormBuilderCustomField(
                  attribute: "password",
                  formField: FormField(
                    enabled: true,
                    builder: (FormFieldState<dynamic> field) {
                      return TextFormField(
                        obscureText: true,
                        focusNode: passwordFocus,
                        validator: (value) {
                          if (value.isEmpty) return errors.videError;
                          if (value.length < 5) return errors.min(5);
                          return null;
                        },
                        decoration: InputDecoration(
                          icon: const Icon(Icons.vpn_key),
                          hintText: global.langue['pass_enter'],
                          labelText: global.langue['pass_label'],
                        ),
                        onChanged: (value) {
                          field.didChange(value);
                        },
                      );
                    },
                  ),
                  valueTransformer: (val) {
                    return val;
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 40.0),
            child: RaisedButton(
              child: Text(
                global.langue['signin_label'],
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (_fbKey.currentState.saveAndValidate()) {
                  var tab = _fbKey.currentState.value;
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(global.langue['signin_progress'])));
                  login(tab).then((validation) {
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text(validation)));
                    if (global.isLoggedIn == true)
                      widget._changeBody(Library(widget._changeBody));
                  });
                }
              },
              color: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 700.0, right: 700.0),
            child: SignInButton(
              Buttons.GoogleDark,
              text: global.langue['signin_google_label'],
              onPressed: () {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(global.langue['signin_progress'])));
                  loginwithgoogle().then((validation) {
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text(validation)));
                    if (global.isLoggedIn == true)
                      widget._changeBody(Library(widget._changeBody));
                  });
                },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 700.0, right: 700.0),
            child: SignInButtonBuilder(
              text: global.langue['signin_42_label'],
              image: Image.network("https://www.42.us.org/wp-content/uploads/2017/07/logo.png", 
                                  height: 30),
              onPressed: () {
                  loginwith42();
                },
              backgroundColor: Colors.blueGrey[700],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> loginwith42() async {
 js.context.callMethod("open", ['https://api.intra.42.fr/oauth/authorize?client_id=628061f039b7ecd339a752c9039ce8963b96bcb45f70f3e1c5cf816595deda76&redirect_uri=http%3A%2F%2Flocalhost%3A5000%2F&response_type=code', "_self"]);
}

Future<String> loginwithgoogle() async {
  GoogleSignIn _googleSignIn = GoogleSignIn();

  try {
    var account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication auth = await account.authentication;
    if (auth.idToken.toString() == null || auth.accessToken.toString() == null)
      return "Sign in error";

    final _cred = GoogleAuthProvider.credential(auth.idToken, auth.accessToken);

    var findinfo = global.bdd_fire.collection('users').doc(account.email);
    var docSnapshot = await findinfo.get();

    if (docSnapshot.exists) {
      global.auth_fire.signInWithCredential(_cred);
      global.isLoggedIn = true;
      global.tab = docSnapshot.data();
      if (global.tab['langue'] == 'English') global.langue = global.English;
      if (global.tab['langue'] == 'Francais') global.langue = global.Francais;
      return global.langue['signin_success'];
    }
    return global.langue['signin_error'];
  } catch (error) {
    return error;
  }
}

Future<String> login(tab) async {
  var erreur;
  var findinfo = global.bdd_fire.collection('users').doc(tab['mail']);
  var docSnapshot = await findinfo.get();
  if (docSnapshot.exists) {
    await global.auth_fire
        .signInWithEmailAndPassword(tab['mail'], tab['password'])
        .catchError((error) {
      erreur = error.message;
    });
    if (erreur != null) return (erreur);
    global.isLoggedIn = true;
    global.tab = docSnapshot.data();
    if (global.tab['langue'] == 'English') global.langue = global.English;
    if (global.tab['langue'] == 'Francais') global.langue = global.Francais;
    return global.langue['signin_success'];
  }
  return global.langue['signin_error'];
}
