import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_ebook_app/providers/home_providers.dart';
import 'package:provider/provider.dart';

class EpubReader extends StatefulWidget {
  static const routeName = '/reader';

  @override
  _EpubReaderState createState() => _EpubReaderState();
}

class _EpubReaderState extends State<EpubReader> {
  String local_path;

  Future<Uint8List> _loadFromStorage() async {
    return await File(local_path).readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as Map;
    local_path = args['path'];

    return WillPopScope(
      onWillPop: () {
        Provider.of<HomeProvider>(context, listen: false).updateLastRead(
          title: args['title'],
          bookid: args['bookid'],
          imgUrl: args['imgUrl'],
          epath: args['path'],
        );

        Navigator.pop(context);
        return Future.value();
      },
      child: Scaffold(
        body: FutureBuilder<Uint8List>(
          future: _loadFromStorage(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return EpubReaderView.fromBytes(
                bookData: snapshot.data,
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
