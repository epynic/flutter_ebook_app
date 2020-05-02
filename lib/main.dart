import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/screens/epub_reader.dart';
import 'package:provider/provider.dart';

import './utils/const.dart';
import './widgets/rounded_button.dart';

import './screens/home_screen.dart';
import './providers/home_providers.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HomeProvider()),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(
              displayColor: Constants.kBlackColor,
            ),
      ),
      home: WelcomeScreen(),
      routes: {
        WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        EpubReader.routeName: (ctx) => EpubReader()
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) {
    Provider.of<HomeProvider>(context, listen: false).fetchBestReads();
    Provider.of<HomeProvider>(context, listen: false).fetchReadsToday();
    Provider.of<HomeProvider>(context, listen: false).fetchLastRead();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bitmap.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.display3,
                children: [
                  TextSpan(
                    text: "flamin",
                  ),
                  TextSpan(
                    text: "go.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Consumer<HomeProvider>(
              builder: (BuildContext context, HomeProvider homeProvider, _) {
                return homeProvider.isLoading()
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * .6,
                        child: RoundedButton(
                          text: "start reading",
                          fontSize: 20,
                          press: () => Navigator.pushReplacementNamed(
                              context, HomeScreen.routeName),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
