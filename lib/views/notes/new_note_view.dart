import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  Future<DatabaseNote> createNewNote() async{
    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Note'),),
      body: const Text('New note...'),
    );
  }
}