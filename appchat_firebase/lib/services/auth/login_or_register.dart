import 'package:appchat_firebase/pages/login_page.dart';
import 'package:appchat_firebase/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginState();
}

class _LoginState extends State<LoginOrRegister> {

  //  initially, show the login page
  bool showLoginPage = true;

  //  toggle between login and register pages
  void togglePages() {
    setState(() {
      showLoginPage =!showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(
        onTap: togglePages,
      );
    }else{
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}