import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/pages/signup_page.dart';

import '../services/auth_service.dart';
import '../services/prefs_service.dart';
import '../services/utils_service.dart';
import 'home_page.dart';

class SignInPage extends StatefulWidget {
  static String id = "signin_page";

  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  bool isLoading=false;

  _doSignin() {
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    if (email.isEmpty || password.isEmpty) return;
    setState(() {
      isLoading=true;
    });

    AuthService.signInUser(context, email, password).then((user) => {
      _getFirebaseUser(user),
    });
  }
  _getFirebaseUser(Map<String,User?> map) async {
    setState(() {
      isLoading=false;
    });
    User? user;
    if (!map.containsKey("SUCCESS")) {
      if (map.containsKey("ERROR"))
        Utils.fireToast("Check email or password");
      return;
    }
    user = map["SUCCESS"];
    if (user == null) return;
      await Prefs.saveUserId(user.uid);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()));
  }

  _callSignUpPage(){
    Navigator.pushReplacementNamed(context, SignUpPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery
              .of(context)
              .size
              .height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(193, 53, 132, 1),
                    Color.fromRGBO(131, 58, 180, 1),
                  ]
              )
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Instagram", style: TextStyle(color: Colors.white,fontSize: 45, fontFamily: "Billabong"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 50,
                            padding: EdgeInsets.only(right: 10,left: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "email",
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(right: 10,left: 10),
                            decoration: BoxDecoration(
                              color: Colors.white54.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              controller: passwordController,
                              decoration: const InputDecoration(
                                hintText: "password",
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              _doSignin();
                            },
                            child:                     Container(
                              height: 50,
                              padding: const EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white54.withOpacity(0.2), width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign In", style: TextStyle(color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),

                          ),

                        ],
                      )
                  ),

                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(width: 10,),
                        GestureDetector(
                          onTap: _callSignUpPage,
                          child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              isLoading?
              const Center(
                child: CircularProgressIndicator(),
              ):SizedBox.shrink(),
            ],
          ),
        ),
      )
    );
  }
}