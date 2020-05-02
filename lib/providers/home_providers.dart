import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ebook_app/utils/const.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../model/book.dart';

class HomeProvider with ChangeNotifier {
  bool loading = true;

  Book _fetured_item;
  Book _last_read;
  List<Book> _reads_items;

  Book get featuredItems {
    return _fetured_item;
  }

  List<Book> get bookItems {
    return _reads_items;
  }


  Book get lastRead {
    return _last_read;
  }

  bool isLoading() {
    return loading;
  }

  setLoadingState(state) {
    loading = state;
    notifyListeners();
  }

  Future fetchBestReads() async {
    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var url = Constants.appAPIURL + 'best_read.json';

    final res = await dio.get(url);
    if (res.statusCode == 200) {
      final featureBook = Book.fromJson(res.data);
      _fetured_item = featureBook;
    } else {
      throw ("Error ${res.statusCode}");
    }

  }

  Future fetchReadsToday() async {
    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var url = Constants.appAPIURL + 'best_seller.json';

    final res = await dio.get(url);
    if (res.statusCode == 200) {
      final read = res.data as List;
      _reads_items = read.map<Book>((json) => Book.fromJson(json)).toList();
      setLoadingState(false);
    } else {
      throw ("Error ${res.statusCode}");
    }
  }

  Future updateLastRead({bookid, title, epath, imgUrl}) async {
    Directory appDocDir = await getExternalStorageDirectory();
    final path = appDocDir.path + "/reads.db";
    final db = ObjectDB(path);
    db.open();

    final book_exists = await db.find({});
    if (book_exists.isEmpty) {
      await db.insert({
        'bookid': bookid,
        'path': epath,
        'title': title,
        'imgUrl': imgUrl,
      });
      print('LastRead - FirstInsert');
    } else {
      await db.update({
        'bookid': book_exists[0]['bookid']
      }, {
        'bookid': bookid,
        'path': epath,
        'title': title,
        'imgUrl': imgUrl,
      });
      print('LastRead - Updated');
    }

    _last_read = Book(
      title: title,
      imgUrl: imgUrl,
      bookid: bookid,
      epubUrl:epath
    );

    db.close();
    notifyListeners();
  }

  Future fetchLastRead() async {
    Directory appDocDir = await getExternalStorageDirectory();
    final path = appDocDir.path + "/reads.db";
    final db = ObjectDB(path);
    db.open();
    final last_read = await db.find({});
    if (last_read.isNotEmpty) {
      _last_read = Book(
        title: last_read[0]['title'],
        imgUrl: last_read[0]['imageUrl'],
        bookid: last_read[0]['bookid'],
        epubUrl: last_read[0]['path'],
      );
    }
    db.close();
  }
}
