import 'package:appchat_firebase/services/auth/auth_service.dart';
import 'package:appchat_firebase/components/my_button.dart';
import 'package:appchat_firebase/components/my_textfield.dart';
import 'package:appchat_firebase/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dar

class LoginPage extends StatelessWidget {
  LoginPage({super.key, this.onTap});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // onTap method
  final void Function()? onTap;

  // login method
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();
    try {
      await authService.signInWithEmailPassword(
          _emailController.text, _pwController.text);
   
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(),));
      
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // logo
          Icon(
            Icons.message,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),

          // welcome message
          Text(
            "Welcome back, you've been missed!",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 25),

          // email field
          MyTextField(
            hintText: "Email",
            obcureText: false,
            controller: _emailController,
          ),

          // password field
          MyTextField(
            hintText: "Password",
            obcureText: true,
            controller: _pwController,
          ),

          SizedBox(
            height: 25,
          ),
          // login button
          MyButton(
            text: "Login",
            onTap: () => login(context),
          ),

          SizedBox(
            height: 25,
          ),

          // register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Not a member?",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "Register now",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
