import 'package:flutter/material.dart';

class LoginAppScreen extends StatefulWidget {
  const LoginAppScreen({Key? key}) : super(key: key);

  static const routeName = "/login_app";

  static const screenName = "Login in App";

  @override
  State<LoginAppScreen> createState() => _LoginAppScreenState();
}

_LoginAppScreenState? _loginScreenState;

updateLoginForm(String status, bool isChangeable) {
  _loginScreenState?.update(status, isChangeable);
}

class _LoginAppScreenState extends State<LoginAppScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String status = "ログイン準備中";
  bool isChangeable = true;

  update(String status, bool isChangeable) {
    setState(() {
      this.status = status;
      this.isChangeable = isChangeable;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loginScreenState = this;
    return Scaffold(
      appBar: AppBar(
        title: const Text(LoginAppScreen.screenName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Login",
                  textScaleFactor: 4.0,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter your pc account',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  style: TextStyle(
                    fontSize: 32.0,
                  ),
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  style: TextStyle(
                    fontSize: 32.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status,
                      textScaleFactor: 2.0,
                    ),
                    ElevatedButton(
                      onPressed: isChangeable
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                // loginState.entered = true;
                                // loginState.checkState();
                              }
                            }
                          : null,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Login",
                            textScaleFactor: 2.0,
                          )),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
