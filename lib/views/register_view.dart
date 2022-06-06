
import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/utils/functions.dart';
import 'dart:developer' as devtools show log ;


class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
      ),
      body: Column(
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
                      decoration:
                          const InputDecoration(hintText: "Enter your Password"),
                    ),
                    TextButton(
                        child: const Text("Register"),
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          try {
                            final userCredential = AuthService.firebase().createUser(email: email, password: password);
                            await AuthService.firebase().sendEmailVerification();
                            devtools.log(userCredential.toString());
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              verifyRoute, (route) => false);
                          } on WeakPasswordAuthException{ 
                            devtools.log("Weak Password");
                            await showErrorDialog(context, 'Weak Password');
                          } on EmailAlreadyInUseAuthException{
                            devtools.log('Email already in use');
                            await showErrorDialog(context, 'Email already in use');
                          } on InvalidEmailAuthException{
                            devtools.log('Invalid Email');
                            await showErrorDialog(context, 'Invalid Email');
                          } on GenericAuthException{
                            await showErrorDialog(context, 'Authentication Error');
                          }        
                        }),
                        TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (route) => false);
                        },
                        child:
                            const Text("Already registered? Login here!")),
                  ],
                )     
          );
  }
}
