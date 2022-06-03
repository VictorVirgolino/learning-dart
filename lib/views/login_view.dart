import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/utils/functions.dart';
import 'dart:developer' as devtools show log ;
import '../firebase_options.dart';

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
      body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
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
                            final userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);
                            devtools.log(userCredential.toString());
                            final user = FirebaseAuth.instance.currentUser;
                            if(user?.emailVerified  ?? false){
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                notesRoute, (route) => false);
                            }else{
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                verifyRoute, (route) => false);
                            }
                            
                          } on FirebaseAuthException catch (e) {
                            if (e.code == "user-not-found") {
                              devtools.log("User not found");
                              await showErrorDialog(context, 'User not found');
                            } else if (e.code == 'wrong-password') {
                              devtools.log("Wrong Password");
                              await showErrorDialog(context, "Login or Password Invalid");
                            }else{
                              devtools.log(e.code);
                              await showErrorDialog(context, 'Error: ${e.code}');
                            }
                          } catch (error) {
                            devtools.log(error.toString());
                            await showErrorDialog(context, error.toString());

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
                );
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
    );
  }
}
