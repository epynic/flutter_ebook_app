import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../utils/const.dart';
import '../screens/epub_reader.dart';
import '../providers/home_providers.dart';

class TwoSideRoundedButton extends StatefulWidget {
  final String text;
  final double radious;
  final String bookid;
  final String epubURL;
  final String imgUrl;
  final String title;
  const TwoSideRoundedButton({
    Key key,
    this.text,
    this.radious = 29,
    this.bookid,
    this.epubURL,
    this.imgUrl,
    this.title,
  }) : super(key: key);

  @override
  _TwoSideRoundedButtonState createState() => _TwoSideRoundedButtonState();
}

class _TwoSideRoundedButtonState extends State<TwoSideRoundedButton> {
  //check book in objectDB
  //Yes - Open EPUBReader
  //No - Dio download
  //   - Add in Object DB - Open EpubReader.
  // TODO: Just a basic implementation
  // TODO: Need to use a custom AlertDialog.
  // TODO: File check should be if epub existing in Location.
  // TODO: permission fail checks

  Dio dio = new Dio();
  int received = 0;
  double progress = 0.0;
  int total = 0;

  _startReading(context) async {
    setState(() {
      progress = 0;
    });

    if (!await Permission.storage.request().isGranted) {
      print(' TODO: Storage permission denied');
    }

    Directory appDocDir = await getExternalStorageDirectory();
    final path = appDocDir.path + "/books.db";
    final db = ObjectDB(path);
    db.open();

    final book_exists = await db.find({'bookid': widget.bookid});
    db.close();

    if (book_exists.isEmpty) {
      _downloader(widget.bookid, widget.epubURL);
    } else {
      Navigator.pushNamed(context, EpubReader.routeName, arguments: {
        'path': book_exists[0]['path'],
        'bookid': widget.bookid,
        'title': widget.title,
        'imgUrl': widget.imgUrl,
      });
    }
  }

  _addToLibrary(local_path) async {
    Directory appDocDir = await getExternalStorageDirectory();
    final path = appDocDir.path + "/books.db";
    final db = ObjectDB(path);
    db.open();
    await db.insert({
      'bookid': widget.bookid,
      'path': local_path,
      'title': widget.title,
      'imgUrl': widget.imgUrl
    });
    db.close();
  }

  _downloader(String bookid, String epubURL) async {
    Directory appDocDir = await getExternalStorageDirectory();
    var local_path = appDocDir.path + "/books/" + bookid + ".epub";

    final downloadDir = Directory(appDocDir.path + "/books/");
    await downloadDir.exists().then((isThere) async {
      isThere
          ? print('Download directory exists')
          : await Directory(appDocDir.path + "/books")
              .create(recursive: true)
              .then(
              (Directory directory) {
                print(directory.path);
              },
            );
    });

    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Starting to downloading book.')));

    File file = File(local_path);
    if (!await file.exists()) {
      await file.create();
    } else {
      await file.delete();
      await file.create();
    }

    BuildContext dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          title: Text('Hold tight!'),
          content: Text('We are binding the book '),
        );
      },
    );

    await dio.download(
      Constants.appAPIURL + epubURL,
      local_path,
      deleteOnError: true,
      onReceiveProgress: (receivedBytes, totalBytes) {
        setState(() {
          received = receivedBytes;
          total = totalBytes;
          progress = (received / total);
        });
        print(progress);
        if (receivedBytes == totalBytes) {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Book Downloaded'),
            ),
          );
          print('File Downloaded! ' + local_path);
          _addToLibrary(local_path);
          Navigator.pop(dialogContext);
          Scaffold.of(context).hideCurrentSnackBar();

          Navigator.pushNamed(context, EpubReader.routeName, arguments: {
            'path': local_path,
            'bookid': widget.bookid,
            'title': widget.title,
            'imgUrl': widget.imgUrl,
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _startReading(context),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Constants.kBlackColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.radious),
            bottomRight: Radius.circular(widget.radious),
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
