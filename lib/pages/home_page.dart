import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/pages/my_feed_page.dart';
import 'package:instaclone/pages/my_likes_page.dart';
import 'package:instaclone/pages/my_profile_page.dart';
import 'package:instaclone/pages/my_search_page.dart';
import 'package:instaclone/pages/my_upload_page.dart';

import '../services/utils_service.dart';

class HomePage extends StatefulWidget {
  static String id = "home_page";

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final FirebaseMessaging _firebaseMessaging=FirebaseMessaging.instance;

  late PageController _pageController;
  int _currentTab=0;

  _initNotification() {
    FirebaseMessaging.onMessage.listen((event) {
      // fetchRideInfo(getRideID(message), context);
          (Map<String, dynamic> message) async =>
          Utils.showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // fetchRideInfo(getRideID(message), context);
          (Map<String, dynamic> message) async => print("onLaunch: $message");
    });
    //
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     Utils.showLocalNotification(message);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     //print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     //print("onResume: $message");
    //   },
    // );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initNotification();
    _pageController=PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          MyFeedPage(pageController: _pageController),
          MySearchPage(),
          MyUploadPage(pageController: _pageController),
          MyLikesPage(),
          MyProfilePage(),
        ],
        onPageChanged: (int index){
          setState(() {
            _currentTab=index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (int index){
          setState(() {
            _currentTab=index;
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          });
        },
        currentIndex: _currentTab,
        activeColor: Color.fromRGBO(193, 53, 132, 1),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home,size: 32),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search,size: 32),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box,size: 32),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite,size: 32),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle,size: 32),
          ),

        ],

      ),
    );
  }
}
