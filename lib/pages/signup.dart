import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../utils/global.dart' as global;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:js' as js;

class SignupForm extends StatefulWidget {
  @override
  _SignupForm createState() => _SignupForm();
}

class _SignupForm extends State<SignupForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var errors = global.Error();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode nomFocus = FocusNode();
  final FocusNode prenomFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode photoFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25.0, left: 200.0, right: 200.0),
      padding: const EdgeInsets.only(top: 25.0, left: 100.0, right: 100.0),
      height: 700.0,
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
                    FocusScope.of(context).requestFocus(usernameFocus);
                  },
                ),
                FormBuilderTextField(
                  attribute: 'username',
                  focusNode: usernameFocus,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.account_circle),
                    hintText: global.langue['username_enter'],
                    labelText: global.langue['username_label'],
                  ),
                  validators: [
                    FormBuilderValidators.required(errorText: errors.videError),
                    FormBuilderValidators.minLength(5,
                        errorText: errors.min(5)),
                    FormBuilderValidators.maxLength(20,
                        errorText: errors.max(20)),
                  ],
                  maxLines: 1,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(nomFocus);
                  },
                ),
                FormBuilderTextField(
                  attribute: 'nom',
                  focusNode: nomFocus,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.text_fields),
                    hintText: global.langue['fname_enter'],
                    labelText: global.langue['fname_label'],
                  ),
                  validators: [
                    FormBuilderValidators.required(errorText: errors.videError),
                    FormBuilderValidators.minLength(2,
                        errorText: errors.min(2)),
                    FormBuilderValidators.maxLength(20,
                        errorText: errors.max(20)),
                  ],
                  maxLines: 1,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(prenomFocus);
                  },
                ),
                FormBuilderTextField(
                  attribute: 'prenom',
                  focusNode: prenomFocus,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.perm_identity),
                    hintText: global.langue['lname_enter'],
                    labelText: global.langue['lname_label'],
                  ),
                  validators: [
                    FormBuilderValidators.required(errorText: errors.videError),
                    FormBuilderValidators.minLength(2,
                        errorText: errors.min(2)),
                    FormBuilderValidators.maxLength(20,
                        errorText: errors.max(20)),
                  ],
                  maxLines: 1,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(photoFocus);
                  },
                ),
                FormBuilderTextField(
                  attribute: 'photo',
                  focusNode: photoFocus,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.photo),
                    hintText: global.langue['pp_enter'],
                    labelText: global.langue['pp_label'],
                  ),
                  validators: [
                    FormBuilderValidators.required(errorText: errors.videError),
                    FormBuilderValidators.url(errorText: errors.urlError),
                    FormBuilderValidators.minLength(2,
                        errorText: errors.min(2)),
                  ],
                  maxLines: 1,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(passwordFocus);
                  },
                ),
                FormBuilderDropdown(
                  attribute: 'langue',
                  decoration: InputDecoration(
                    icon: const Icon(Icons.flag),
                    labelText: global.langue['langue_label'],
                  ),
                  initialValue: 'English',
                  validators: [FormBuilderValidators.required()],
                  items: ['English', 'Francais']
                      .map((country) => DropdownMenuItem(
                          value: country, child: Text("$country")))
                      .toList(),
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
            child: RaisedButton(
              child: Text(
                global.langue['signup_label'],
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (_fbKey.currentState.saveAndValidate()) {
                  var tab = _fbKey.currentState.value;
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(global.langue['signup_progress'])));
                  adduser(tab, 0).then((validation) {
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text(validation)));
                  });
                }
              },
              color: Theme.of(context).primaryColor,
            ),
            margin: new EdgeInsets.only(top: 40.0),
          ),
          Container(
            child: RaisedButton(
              child: Text(
                global.langue['signup_google_label'],
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(global.langue['signup_progress'])));
                loginwithgoogle().then((validation) {
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(validation)));
                });
              },
              color: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            child: RaisedButton(
              child: Text(
                global.langue['signup_42_label'],
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(global.langue['signup_progress'])));
                loginwith42();
              },
              color: Theme.of(context).primaryColor,
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
    var tab = {
      "mail": account.email,
      "username": account.displayName,
      "nom": account.displayName.split(' ')[1],
      "prenom": account.displayName.split(' ')[0],
      "photo": account.photoUrl,
      "langue": "English",
    };
    var result = adduser(tab, 1);
    return (result);
  } catch (error) {
    return (error);
  }
}

Future<String> adduser(tab, google) async {
  var newuser = global.bdd_fire.collection('users').doc(tab['mail']);
  var docSnapshot = await newuser.get();
  if (docSnapshot.exists) {
    return (global.langue['invalid_mail']);
  } else {
    newuser.set({
      "mail": tab['mail'],
      "username": tab['username'],
      "nom": tab['nom'],
      "prenom": tab['prenom'],
      "photo": tab['photo'],
      "google": google,
      "langue": tab['langue']
    });
  }
  if (google == 0) {
    global.auth_fire
        .createUserWithEmailAndPassword(tab['mail'], tab['password']);
  }
  return global.langue['signup_success'];
}
