import 'package:appchat_firebase/pages/home_page.dart';
import 'package:appchat_firebase/services/auth/auth_service.dart';
import 'package:appchat_firebase/components/my_button.dart';
import 'package:appchat_firebase/components/my_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  // onTap method
  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  void register(BuildContext context) {
    final _auth = AuthService();

    if (_pwController.text == _confirmpwController.text) {
        try {
             _auth.signUpWithEmailPassword(
                _emailController.text, _pwController.text);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(),
                ));
        } catch (e) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text("Error: ${e.toString()}"), // Hiển thị lỗi rõ ràng
                ),
            );
        }
    } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text("Passwords do not match"),
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
            "Create an account for you",
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

          // confirm password
          MyTextField(
            hintText: "Confirm Password",
            obcureText: true,
            controller: _confirmpwController,
          ),

          SizedBox(
            height: 25,
          ),

          // login button
          MyButton(
            text: "Register",
            onTap: () => register(context),
          ),

          SizedBox(
            height: 25,
          ),

          // register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "Login now",
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
