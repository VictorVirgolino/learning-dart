
import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/views/login_view.dart';
import 'package:learningdart/views/notes/new_note_view.dart';
import 'package:learningdart/views/notes/notes_view.dart';
import 'package:learningdart/views/register_view.dart';
import 'package:learningdart/views/verifyEmail_view.dart';
import 'dart:developer' as devtools show log ;



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.pink,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      verifyRoute: (context) => const VerifyEmailView(),
      notesRoute:(context) => const NotesView(),
      newNoteRoute:((context) => const NewNoteView())
    },
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if(user != null){
                if (user.isEmailVerified) {
                  devtools.log('User Verified');
                  return const NotesView();
                } else {
                  devtools.log('Please verify your email');
                  return const VerifyEmailView();
                }
              }else{
                return const LoginView();
              }
              
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }
}
