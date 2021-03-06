import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'dart:developer' as devtools show log ;
import 'crud_exceptions.dart';

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'Person, ID = $id, email = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String title;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote(
      {required this.id,
      required this.userId,
      required this.title,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return 'Note, ID => $id, userId => $userId, title => $title, isSyncedWithCloud => $isSyncedWithCloud, \n text = $text';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

//Exceptions


class NotesService {
  Database? _db;
  

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  List<DatabaseNote> _notes = [];

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
  final user = await getUser(email: email);
  return user;
} on CouldNotFindUserException {
  final createdUser = await createUser(email: email);
  return createdUser;
} catch(e){
  rethrow;
}
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    await _ensureDblsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0
    });

    if(updateCount == 0){
      throw CouldNotUpdateNoteException();
    }else{
      final updatedNote =  await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async{
    await _ensureDblsOpen();
    final db =  _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));

    
  }

  Future<DatabaseNote> getNote({required int id}) async{
    await _ensureDblsOpen();
    final db =  _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id]
    );

    if(notes.isEmpty){
      throw CouldNotFindNoteException();
    } else{
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async{
    await _ensureDblsOpen();
    final db = _getDatabaseOrThrow();
    _notes = [];
    _notesStreamController.add(_notes);
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDblsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount =  await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id]
    );
    if(deletedCount == 0){
      throw CouldNotDeleteNoteException();
    }else{
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDblsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = '';
    const title = '';

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      textColumn: text,
      isSyncedWithCloudColumn: 1
    });

    final note = DatabaseNote(
        id: noteId,
        userId: owner.id,
        title: title,
        text: text,
        isSyncedWithCloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;

  }

  Future<DatabaseUser> getUser({required String email}) async {
    devtools.log('getuser');
    final db = _getDatabaseOrThrow();


    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    devtools.log('get');
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDblsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExistException();
    }
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDblsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db != null) {
      return db;
    } else {
      throw DatabaseisNotOpenException();
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    } else {
      try {
        final docsPath = await getApplicationDocumentsDirectory();
        final dbPath = join(docsPath.path, dbName);
        final db = await openDatabase(dbPath);
        _db = db;
        await db.execute(createUserTable);
        await db.execute(createNotestable);
        await _cacheNotes();
      } on MissingPlatformDirectoryException {
        throw UnableToGetDocumentsDirectoryException();
      }
    }
  }

  Future<void> _ensureDblsOpen() async{
    try {
      await open().then((value) async{
        final db = _getDatabaseOrThrow();
        final user = await getUser(email: 'victorvirgolino@gmail.com');
        devtools.log(user.toString());
      });
    } on DatabaseAlreadyOpenException {
      
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseisNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }
}

const noteTable = 'note';
const userTable = 'users';
const dbName = 'notes.db';
const idColumn = '00';
const emailColumn = 'email';
const userIdColumn = '01';
const titleColumn = 'title';
const textColumn = 'text';
const isSyncedWithCloudColumn = '1';
const createUserTable = ''' 
        CREATE TABLE IF NOT EXISTS "users"  (
          "id"	INTEGER NOT NULL,
          "email"	TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
        );''';
const createNotestable = '''
        CREATE TABLE IF NOT EXISTS "note" (
          "id"	INTEGER NOT NULL,
          "user_id"	INTEGER NOT NULL,
          "text"	TEXT NOT NULL,
          "title"	TEXT NOT NULL,
          "is_sync_with_cloud"	INTEGER NOT NULL,
          FOREIGN KEY("user_id") REFERENCES "users"("id"),
          PRIMARY KEY("id" AUTOINCREMENT)
        );''';
