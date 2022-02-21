import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/model/user_model.dart';
import 'package:instaclone/pages/signin_page.dart';
import 'package:instaclone/services/data_service.dart';

import '../services/auth_service.dart';
import '../services/prefs_service.dart';
import '../services/utils_service.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static String id = "signup_page";

  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var fullNameController=TextEditingController();
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  var cpasswordController=TextEditingController();
  bool isLoading=false;

  _doSignUp() {
    String fullName = fullNameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String cpassword= cpasswordController.text.toString().trim();
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) return;
    if(cpassword!=password) {
      Utils.fireToast("Password and confirm password does not match");
      return;
    }
    setState(() {
      isLoading=true;
    });
    User1 user1=User1(fullname: fullName, email: email, password: password);
    AuthService.signUpUser(context, fullName, email, password).then((user) => {
      _getFirebaseUser(user1, user),
    });

  }
  _getFirebaseUser( User1? user1, Map<String,User?> map) async {

    setState(() {
      isLoading=false;
    });
    User? user;
    if (!map.containsKey("SUCCESS")) {
      if (map.containsKey("ERROR_EMAIL_ALREADY_IN_USE"))
        Utils.fireToast("Email already in use");
      if (map.containsKey("ERROR"))
        Utils.fireToast("Try again later");
      return;
    }
    user = map["SUCCESS"];
    if (user == null) return;
    if (user != null) {
      await Prefs.saveUserId(user.uid);
      DataService.storeUser(user1!).then((value) => {
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage())),
      });
  }
  }

  _callSignInPage(){
    Navigator.pushReplacementNamed(context, SignInPage.id);
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
                              controller: fullNameController,
                              decoration: InputDecoration(
                                hintText: "FullName",
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
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
                                hintText: "Email",
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
                                hintText: "Password",
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
                              controller: cpasswordController,
                              decoration: const InputDecoration(
                                hintText: "Confirm Password",
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 17.0, color: Colors.white54),
                              ),
                            ),
                          ),

                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              _doSignUp();

                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(right: 10, left: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white54.withOpacity(0.2), width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign Up", style: TextStyle(color: Colors.white, fontSize: 17),
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
                        Text("Already have an account?", style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(width: 10,),
                        GestureDetector(
                          onTap: _callSignInPage,
                          child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),),
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
      ),
    );
  }
}
