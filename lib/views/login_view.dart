
import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/utils/functions.dart';
import 'dart:developer' as devtools show log ;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body:  Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(hintText: "Enter your Email"),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          hintText: "Enter your Password"),
                    ),
                    TextButton(
                        child: const Text("Login"),
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try {
                            final userCredential = await AuthService.firebase().logIn(email: email, password: password);
                            final user = AuthService.firebase().currentUser;
                            if(user?.isEmailVerified ?? false){
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                notesRoute, (route) => false);
                            }else{
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                verifyRoute, (route) => false);
                            }
                            
                          } on UserNotFoundAuthException {
                            devtools.log("User not found");
                            await showErrorDialog(context, 'User not found');
                          } on WrongPasswordAuthException {
                            devtools.log("Wrong Password");
                            await showErrorDialog(context, "Login or Password Invalid");
                          } on GenericAuthException {
                            await showErrorDialog(context, 'Authentication Error');
                          }
                        }),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              registerRoute, (route) => false);
                        },
                        child:
                            const Text("Not registered yet? Register here!")),
                  ],
                )
          );
  }
}
