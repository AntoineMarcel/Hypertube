import 'package:flutter/material.dart';
import '../utils/global.dart' as global;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'stream.dart';

class Library extends StatefulWidget {
  Function(Widget) _changeBody;
  Library(this._changeBody);

  @override
  _Library createState() => _Library();
}

class _Library extends State<Library> {
  var errors = global.Error();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List list = List();
  Map<String, dynamic> jsonofwebsite;
  var isLoading = false;
  var _filtres = false;
  @override
  Widget build(BuildContext context) {
    _fetchData(tab) async {
      setState(() {
        isLoading = true;
      });
      if (tab['search'] == null) tab['search'] = "";
      if (tab['sortby'] == null) tab['sortby'] = "title";
      list = List();
      int page = 1;
      while (true) {
        final getallpages = await http.get(
            "https://yts.lt/api/v2/list_movies.json?query_term=" +
                tab['search'] +
                "&sort_by=" +
                tab['sortby'] +
                "&limit=50&page=" +
                page.toString(),
           headers: {'Access-Control-Allow-Origin': '*'},
          );
        jsonofwebsite = jsonDecode(getallpages.body);
        if (jsonofwebsite['data']['movies'] != null &&
            getallpages.statusCode == 200) {
          list = list..addAll(jsonofwebsite['data']['movies']);
          page++;
        } else {
          if (tab['minrating'] != "" && tab['maxrating'] != "") {
            list = list
                .where((l) =>
                    l['rating'] >= int.parse(tab['minrating']) &&
                    l['rating'] <= int.parse(tab['maxrating']))
                .toList();
          }
          if (tab['minyear'] != "" && tab['maxyear'] != "") {
            list = list
                .where((l) =>
                    l['year'] >= int.parse(tab['minyear']) &&
                    l['year'] <= int.parse(tab['maxyear']))
                .toList();
          }
          break;
        }
      }
      setState(() {
        isLoading = false;
      });
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 25.0, left: 200.0, right: 200.0),
          child: FormBuilder(
              key: _fbKey,
              initialValue: {},
              child: Column(children: [
                FormBuilderTextField(
                  attribute: 'search',
                  decoration: InputDecoration(
                    icon: const Icon(Icons.local_movies),
                    hintText: global.langue['search_hint_movie'],
                    labelText: global.langue['search_label'],
                  ),
                  validators: [
                    FormBuilderValidators.required(errorText: errors.videError),
                  ],
                  maxLines: 1,
                ),
                FlatButton(
                  onPressed: () => {
                    setState(() {
                      _filtres = _filtres ? false : true;
                    })
                  },
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Filtres"), Icon(Icons.add)],
                  ),
                ),
                Opacity(
                  opacity: _filtres ? 1.0 : 0.0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: FormBuilderDropdown(
                            attribute: 'sortby',
                            decoration: InputDecoration(
                              icon: const Icon(Icons.sort),
                              labelText: global.langue['sort_label'],
                            ),
                            items: ['title', 'year', 'rating']
                                .map((country) => DropdownMenuItem(
                                    value: country, child: Text("$country")))
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white30,
                            margin: const EdgeInsets.only(right: 10.0),
                          ),
                        ),
                        Expanded(
                          child: FormBuilderTextField(
                            attribute: 'minyear',
                            decoration: InputDecoration(
                              icon: const Icon(Icons.vertical_align_bottom),
                              labelText: global.langue['filter_minyear_label'],
                              hintText: global.langue['filter_minyear_hint'],
                            ),
                            validators: [
                              FormBuilderValidators.numeric(),
                              (val) {
                                if (val != "") {
                                  if (_fbKey.currentState.fields['maxyear']
                                          .currentState.value ==
                                      "")
                                    return (global.langue['filter_max_empty']);
                                  if (int.parse(_fbKey
                                          .currentState
                                          .fields['maxyear']
                                          .currentState
                                          .value) <
                                      int.parse(val))
                                    return global.langue['filter_max_inf'];
                                }
                              },
                            ],
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          child: FormBuilderTextField(
                            attribute: 'maxyear',
                            decoration: InputDecoration(
                              icon: const Icon(Icons.vertical_align_top),
                              labelText: global.langue['filter_maxyear_label'],
                              hintText: global.langue['filter_maxyear_hint'],
                            ),
                            validators: [
                              FormBuilderValidators.numeric(),
                              (val) {
                                if (val != "") {
                                  if (_fbKey.currentState.fields['minyear']
                                          .currentState.value ==
                                      "")
                                    return (global.langue['filter_min_empty']);
                                  if (int.parse(_fbKey
                                          .currentState
                                          .fields['minyear']
                                          .currentState
                                          .value) >
                                      int.parse(val))
                                    return global.langue['filter_min_sup'];
                                }
                              },
                            ],
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white30,
                            margin:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                          ),
                        ),
                        Expanded(
                          child: FormBuilderTextField(
                            attribute: 'minrating',
                            decoration: InputDecoration(
                              icon: const Icon(Icons.vertical_align_bottom),
                              labelText:
                                  global.langue['filter_minrating_label'],
                              hintText: global.langue['filter_minrating_hint'],
                            ),
                            validators: [
                              FormBuilderValidators.numeric(),
                              (val) {
                                if (val != "") {
                                  if (_fbKey.currentState.fields['maxrating']
                                          .currentState.value ==
                                      "")
                                    return (global.langue['filter_max_empty']);
                                  if (int.parse(_fbKey
                                          .currentState
                                          .fields['maxrating']
                                          .currentState
                                          .value) <
                                      int.parse(val))
                                    return global.langue['filter_max_inf'];
                                }
                              },
                            ],
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          child: FormBuilderTextField(
                            attribute: 'maxrating',
                            decoration: InputDecoration(
                              icon: const Icon(Icons.vertical_align_top),
                              labelText:
                                  global.langue['filter_maxrating_label'],
                              hintText: global.langue['filter_maxrating_hint'],
                            ),
                            validators: [
                              FormBuilderValidators.numeric(),
                              (val) {
                                if (val != "") {
                                  if (_fbKey.currentState.fields['minrating']
                                          .currentState.value ==
                                      "")
                                    return (global.langue['filter_min_empty']);
                                  if (int.parse(_fbKey
                                          .currentState
                                          .fields['minrating']
                                          .currentState
                                          .value) >
                                      int.parse(val))
                                    return global.langue['filter_min_sup'];
                                }
                              },
                            ],
                            maxLines: 1,
                          ),
                        ),
                      ]),
                ),
              ])),
        ),
        RaisedButton(
          child: Text(
            global.langue['search_label'],
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            if (_fbKey.currentState.saveAndValidate()) {
              var tab = _fbKey.currentState.value;
              _fetchData(tab);
            }
          },
          color: Theme.of(context).primaryColor,
        ),
        !isLoading
            ? Expanded(
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      var seen = global.tab['watched']
                          .toString()
                          .contains(list[index]['slug'] + ',');
                      return Container(
                        padding: const EdgeInsets.all(10.0),
                        color: seen ? Colors.black12 : null,
                        child: Row(
                          children: [
                            Image.network(list[index]['large_cover_image'],
                                width: 300, height: 300, fit: BoxFit.contain),
                            Column(
                              children: <Widget>[
                                if (global.tab['watched']
                                    .toString()
                                    .contains(list[index]['slug']))
                                  Text("test"),
                                Text(list[index]['title']),
                                Text("Annee de production: " +
                                    list[index]['year'].toString()),
                                Text(list[index]['rating'].toString() +
                                    " etoiles"),
                                Text("Genres: " +
                                    list[index]['genres'].toString()),
                                RaisedButton(
                                  child: Text(
                                    "En savoir plus",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    widget._changeBody(Stream(
                                        widget._changeBody, list[index]));
                                  },
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }))
            : Center(
                child: CircularProgressIndicator(),
              ),
      ],
    );
  }
}
