
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/services/auth/auth_user.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("We've sent you an email verification. Please open it to verify your account"),
            const Text("In case you haven't receive a verification email yet, press the button below"),
            TextButton(
                onPressed: () async {
                  AuthService.firebase().sendEmailVerification(); 
                },
                child: const Text('Send Confirmation Email')),
             TextButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (route) => false);
                },
                child: const Text('Restart'))
          ],
        ),
      ),
    );
  }
}
