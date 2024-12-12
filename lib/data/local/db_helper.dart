import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  //privatisation of a constructor so that it object cannot be created anywhere
  DbHelper._();

  static final getInstatnce = DbHelper._();

  Database? myDb;
  String TABLE_NOTE = "notes";
  String Col_Sno = "sno";
  String Col_title = "title";
  String Col_desc = "desc";

  //db Open(if path exist then open else create)

  Future<Database> getDb() async {
    if (myDb != null) {
      return myDb!;
    } else {
      myDb = await openDb();
      return myDb!;
    }
  }

  Future<Database> openDb() async {
    //First we will get the directory
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "notes.db");
    return openDatabase(dbPath, onCreate: (db, version) {
      //create tables query comes here
      db.execute(
          "CREATE TABLE $TABLE_NOTE ($Col_Sno INTEGER PRIMARY KEY AUTOINCREMENT, $Col_title TEXT, $Col_desc TEXT)");
    }, version: 1);
  }

  //all queries

  //insertion
  Future<bool> addNote(
      {required String title, required String description}) async {
    var db = await getDb();
    int rowsAffected = await db.insert(TABLE_NOTE, {
      Col_title: title,
      Col_desc: description,
    });

    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await getDb();
    //select * from notes;
    List<Map<String, dynamic>> notesFetched = await db.query(TABLE_NOTE);
    return notesFetched;
  }

  void deleteRecord(int index) async {
    var db = await getDb();
    await db.delete(
      TABLE_NOTE,
      where: '$Col_Sno = $index', // Proper where clause with a placeholder
      // Pass the index as a list
    );
  }

  Future<bool> updateRecord(
      {required String title,
      required String description,
      required int sno}) async {
    var db = await getDb();
    int rowsAffected = await db.update(
        TABLE_NOTE,
        {
          Col_title: title,
          Col_desc: description,
        },
        where: "$Col_Sno==$sno");
    return rowsAffected > 1;
  }
}
