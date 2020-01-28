import 'package:flutter/material.dart';
import '../utils/global.dart' as global;
import 'package:http/http.dart' as http;
import 'dart:convert';
import './jquery.dart';
import 'dart:js' as js;
import 'package:flutter_form_builder/flutter_form_builder.dart';

class Stream extends StatefulWidget {
  Function(Widget) _changeBody;
  var _thismovie;
  Stream(this._changeBody, this._thismovie);

  @override
  _Stream createState() => _Stream();
}

class _Stream extends State<Stream> {
  var errors = global.Error();
  var comments_show = false;
  List comments = List();
  final GlobalKey<FormBuilderState> _comment = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    var list = widget._thismovie;

    var magnet = "magnet:?xt=urn:btih:" +
        list['torrents'][0]['hash'].toString() +
        "&dn=" +
        list['slug'].toString() +
        "&tr=udp://open.demonii.com:1337/announce&tr=udp://tracker.openbittorrent.com:80&tr=udp://tracker.coppersurfer.tk:6969&tr=udp://glotorrents.pw:6969/announce";

    _fetchComment() async {
      var commentaires = await global.bdd_fire
          .collection('movies')
          .doc(list['slug'])
          .collection("comments")
          .orderBy('date', "desc")
          .get();
      comments = List();
      commentaires.docs.forEach((f) {
        comments.add(f.data());
      });
      setState(() {
        comments_show = true;
      });
    }

    _fetchComment();
    return Container(
        margin: const EdgeInsets.only(top: 25.0, left: 200.0, right: 200.0),
        child: ListView(
          children: <Widget>[
            Row(
              children: [
                Image.network(list['large_cover_image'],
                    width: 300, height: 300, fit: BoxFit.contain),
                Expanded(
                    child: Column(
                  children: <Widget>[
                    Text(
                      list['title_long'],
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                    Text(
                      "Annee de production: " + list['year'].toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                    Text(
                      list['rating'].toString() + " etoiles",
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                    Text(
                      "Genres: " + list['genres'].toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ],
                )),
              ],
            ),
            Container(
                margin: const EdgeInsets.only(top: 25.0),
                child: Text(list['summary'])),
            RaisedButton(
              child: Text(
                global.langue['read_movie'],
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                updatemovie(list);
                js.context.callMethod("open", [
                  'http://localhost:8080/?torrent="' +
                      magnet +
                      '"&title=' +
                      list['slug']
                ]);
              },
              color: Theme.of(context).primaryColor,
            ),
            Container(
              margin: const EdgeInsets.only(top: 25.0, bottom: 25.0),
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: comments.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Text(comments[index]['username'] +
                            " : " +
                            comments[index]['comment']);
                      })
                  : Text("Pas de commentaires"),
            ),
            FormBuilder(
              key: _comment,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      attribute: 'comment',
                      decoration: InputDecoration(
                        icon: const Icon(Icons.person),
                        hintText: "Envoyer un commentaire",
                        labelText: "Commentaire",
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
                      "Envoyer",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_comment.currentState.saveAndValidate()) {
                        var tab = _comment.currentState.value;
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(global.langue['signin_progress'])));
                        sendcomment(tab['comment'], list['slug'])
                            .then((validation) {
                          Scaffold.of(context).hideCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text(validation)));
                        });
                        _comment.currentState.reset();
                      }
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

Future<String> sendcomment(commentaire, slug) async {
  var movie = global.bdd_fire.collection('movies').doc(slug);
  var docSnapshot = await movie.get();
  if (docSnapshot.exists) {
    global.bdd_fire.collection('movies').doc(slug).collection("comments").add({
      "username": global.tab['username'],
      "comment": commentaire.toString(),
      "date": DateTime.now(),
    });
    return ("Commentaire envoyer");
  } else {
    movie.set({
      "title": slug,
      "date": DateTime.now(),
    });
    global.bdd_fire.collection('movies').doc(slug).collection("comments").add({
      "username": global.tab['username'],
      "comment": commentaire.toString(),
      "date": DateTime.now(),
    });
    return ("Commentaire envoyer");
  }
}

Future<String> updatemovie(list) async {
  var movie = global.bdd_fire.collection('movies').doc(list['slug']);

  var docSnapshot = await movie.get();
  if (docSnapshot.exists) {
    movie.update(data: {
      "date": DateTime.now(),
    });
  } else {
    movie.set({
      "title": list['slug'],
      "date": DateTime.now(),
    });
  }

  var updateuser = global.bdd_fire.collection('users').doc(global.tab['mail']);
  var doc = await updateuser.get();
  if (doc.exists) {
    var data = doc.data();
    String watched = data['watched'];
    if (!watched.contains(list['slug'] + ',')) {
      watched = watched + list['slug'] + ',';
      updateuser.update(data: {"watched": watched});
    }
  } else
    print("TAMERE");
  doc = await updateuser.get();
  global.tab = doc.data();
  return ("UPDATED");
}
