import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../utils/global.dart' as global;

class SearchProfil extends StatefulWidget {
  Function(Widget) _changeBody;
  SearchProfil(this._changeBody);

  @override
  _SearchProfil createState() => _SearchProfil();
}

class Userprofil extends StatefulWidget {
  Function(Widget) _changeBody;
  Map _infos;
  Userprofil(this._changeBody, this._infos);

  @override
  _Userprofil createState() => _Userprofil();
}

Container _infos(String label, IconData icon) {
  return Container(
    padding: EdgeInsets.only(bottom: 3.0),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 2.0, color: Colors.black),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        Text(label),
      ],
    ),
  );
}

class _Userprofil extends State<Userprofil> {
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
          Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Center(child: Text(global.langue['username_label']))),
          _infos(widget._infos['username'], Icons.account_circle),
          Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Center(child: Text(global.langue['fname_label']))),
          _infos(widget._infos['nom'], Icons.text_fields),
          Container(
              margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Center(child: Text(global.langue['lname_label']))),
          _infos(widget._infos['prenom'], Icons.perm_identity),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Image.network(widget._infos['photo'],
                width: 300, height: 300, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _SearchProfil extends State<SearchProfil> {
  final GlobalKey<FormBuilderState> _searchkey = GlobalKey<FormBuilderState>();
  var errors = global.Error();

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
          Center(child: Text(global.langue['search_hint_text'])),
          Container(
            child: FormBuilder(
              key: _searchkey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      attribute: 'searched',
                      decoration: InputDecoration(
                        icon: const Icon(Icons.person),
                        hintText: global.langue['username_search_enter'],
                        labelText: global.langue['username_label'],
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: global.langue['null_field']),
                      ],
                      maxLines: 1,
                    ),
                  ),
                  RaisedButton(
                    child: Text(
                      global.langue['search_label'],
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_searchkey.currentState.saveAndValidate()) {
                        global.bdd_fire
                            .collection("users")
                            .where("username", "==",
                                _searchkey.currentState.value['searched'])
                            .get()
                            .then((onValue) {
                          if (!onValue.empty)
                            widget._changeBody(Userprofil(
                                widget._changeBody, onValue.docs[0].data()));
                          else
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(global.langue['user_not_found'])));
                        });
                      }
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
