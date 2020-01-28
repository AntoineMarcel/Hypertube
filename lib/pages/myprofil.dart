import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../utils/global.dart' as global;

class Myprofil extends StatefulWidget {
  Function(Widget) _changeBody;
  Myprofil(this._changeBody);

  @override
  _Myprofil createState() => _Myprofil();
}

class _Myprofil extends State<Myprofil> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _searchkey = GlobalKey<FormBuilderState>();
  var errors = global.Error();

  final FocusNode usernameFocus = FocusNode();
  final FocusNode nomFocus = FocusNode();
  final FocusNode prenomFocus = FocusNode();
  final FocusNode photoFocus = FocusNode();

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
          Center(child: Text(global.langue['infos'])),
          FormBuilder(
            key: _fbKey,
            initialValue: {},
            child: Column(
              children: [
                FormBuilderTextField(
                  attribute: 'mail',
                  initialValue: global.tab['mail'],
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
                  initialValue: global.tab['username'],
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
                  initialValue: global.tab['nom'],
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
                  initialValue: global.tab['prenom'],
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
                  initialValue: global.tab['photo'],
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
                ),
                FormBuilderDropdown(
                  attribute: 'langue',
                  decoration: InputDecoration(
                    icon: const Icon(Icons.flag),
                    labelText: global.langue['langue_label'],
                  ),
                  initialValue: global.tab['langue'],
                  validators: [FormBuilderValidators.required()],
                  items: ['English', 'Francais']
                      .map((country) => DropdownMenuItem(
                          value: country, child: Text("$country")))
                      .toList(),
                ),
              ],
            ),
          ),
          Container(
            child: RaisedButton(
              child: Text(
                global.langue['modif_label'],
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (_fbKey.currentState.saveAndValidate()) {
                  var tab = _fbKey.currentState.value;
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(global.langue['modif_progress'])));
                  modifuser(tab).then((validation) {
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text(validation)));
                    widget._changeBody(Myprofil(widget._changeBody));
                  });
                }
              },
              color: Theme.of(context).primaryColor,
            ),
            margin: new EdgeInsets.only(top: 40.0),
          ),
        ],
      ),
    );
  }
}

Future<String> modifuser(tab) async {
  var findinfo = global.bdd_fire.collection('users').doc(global.tab['mail']);
  var docSnapshot = await findinfo.get();

  if (docSnapshot.exists) {
    if ((global.tab['mail'] != tab['mail']) && global.tab['google'] != 1) {
      var newuser = global.bdd_fire.collection('users').doc(tab['mail']);
      var docSnapshot = await newuser.get();

      if (docSnapshot.exists) {
        return (global.langue['invalid_mail']);
      } else {
        newuser.set({
          "mail": tab['mail'],
          "username": global.tab['username'],
          "nom": global.tab['nom'],
          "prenom": global.tab['prenom'],
          "photo": global.tab['photo'],
          "google": global.tab['google'],
          "langue": global.tab['langue'],
        });
        findinfo.delete();
        var _user = global.auth_fire.currentUser;
        _user.updateEmail(tab['mail']);
      }
    }
    var updateuser = global.bdd_fire.collection('users').doc(tab['mail']);
    var docSnapshot = await updateuser.get();
    if (docSnapshot.exists) {
      updateuser.update(data: {
        "username": tab['username'],
        "nom": tab['nom'],
        "prenom": tab['prenom'],
        "photo": tab['photo'],
        "langue": tab['langue'],
      });
    }
    global.tab = tab;
    if (global.tab['langue'] == 'English') global.langue = global.English;
    if (global.tab['langue'] == 'Francais') global.langue = global.Francais;
    return global.langue['modif_success'];
  }
  return global.langue['modif_error'];
}
