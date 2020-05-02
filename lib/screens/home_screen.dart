import 'package:flutter_ebook_app/screens/epub_reader.dart';

import '../utils/const.dart';
import '../widgets/book_rating.dart';
import '../widgets/reading_card_list.dart';
import '../widgets/two_side_rounded_button.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_providers.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    var lastRead = Provider.of<HomeProvider>(context).lastRead;

    var size = MediaQuery.of(context).size;
    List<Widget> bookList = homeProvider.bookItems
        .map(
          (wiz) => ReadingListCard(
            title: wiz.title,
            bookid: wiz.bookid,
            rating: wiz.rating,
            epubUrl: wiz.epubUrl,
            imgUrl: wiz.imgUrl,
            pressDetails: () {},
          ),
        )
        .toList();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/main_page_bg.png"),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: size.height * .1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.display1,
                        children: [
                          TextSpan(text: "What are you \nreading "),
                          TextSpan(
                              text: "today?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: bookList),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.display1,
                            children: [
                              TextSpan(text: "Best of the "),
                              TextSpan(
                                text: "day",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        bestOfTheDayCard(
                            size, context, homeProvider.featuredItems),
                        (lastRead != null)
                            ? lastReading(context, size, lastRead)
                            : SizedBox(
                                height: 10,
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container bestOfTheDayCard(Size size, BuildContext context, item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      height: 210,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                top: 24,
                right: size.width * .35,
              ),
              height: 195,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFEAEAEA).withOpacity(.45),
                borderRadius: BorderRadius.circular(29),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "New York Time Best For 11th March 2020",
                    style: TextStyle(
                      fontSize: 9,
                      color: Constants.kLightBlackColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.title,
                  ),
                  Text(
                    "Gary Venchuk",
                    style: TextStyle(color: Constants.kLightBlackColor),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      BookRating(score: item.rating.toString()),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "When the earth was flat and everyone wanted to win the game of the best and people….",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Constants.kLightBlackColor,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Image.network(
              Constants.appAPIURL + item.imgUrl,
              width: size.width * .27,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              width: size.width * .3,
              child: TwoSideRoundedButton(
                  text: "Read",
                  radious: 24,
                  bookid: item.bookid,
                  epubURL: item.epubUrl,
                  title: item.title,
                  imgUrl: item.imgUrl),
            ),
          ),
        ],
      ),
    );
  }

  Container lastReading(BuildContext context, size, lastRead) {
    return Container(
      child: Column(
        children: <Widget>[
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.display1,
              children: [
                TextSpan(text: "Continue "),
                TextSpan(
                  text: "reading...",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, EpubReader.routeName, arguments: {
              'path': lastRead.epubUrl,
              'bookid': lastRead.bookid,
              'title': lastRead.title,
              'imgUrl': lastRead.imgUrl,
            }),
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(38.5),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 33,
                    color: Color(0xFFD3D3D3).withOpacity(.84),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 30, right: 20),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    lastRead.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Gary Venchuk",
                                    style: TextStyle(
                                      color: Constants.kLightBlackColor,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                            Image.network(
                              Constants.appAPIURL + lastRead.imgUrl,
                              width: 55,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 7,
                      width: size.width * .50,
                      decoration: BoxDecoration(
                        color: Constants.kProgressIndicator,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
