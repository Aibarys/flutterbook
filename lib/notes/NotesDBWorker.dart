import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "NotesModel.dart";


/// ********************************************************************************************************************
/// Database provider class for notes.
/// ********************************************************************************************************************
class NotesDBWorker {


  /// Static instance and private constructor, since this is a singleton.
  NotesDBWorker._();
  static final NotesDBWorker db = NotesDBWorker._();


  /// The one and only database instance.
  Database? _db;


  /// Get singleton instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {

    _db ??= await init();
    return _db;

  }

  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {
    String path = join(utils.docsDir!.path, "notes.db");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
        onCreate : (Database inDB, int inVersion) async {
          await inDB.execute(
              "CREATE TABLE IF NOT EXISTS notes ("
                  "id INTEGER PRIMARY KEY,"
                  "title TEXT,"
                  "content TEXT,"
                  "color TEXT"
                  ")"
          );
        }
    );
    return db;

  } /* End init(). */


  /// Create a Note from a Map.
  Note noteFromMap(Map inMap) {
    Note note = Note();
    note.id = inMap["id"];
    note.title = inMap["title"];
    note.content = inMap["content"];
    note.color = inMap["color"];

    return note;

  }


  /// Create a Map from a Note.
  Map<String, dynamic> noteToMap(Note inNote) {
    Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = inNote.id;
    map["title"] = inNote.title;
    map["content"] = inNote.content;
    map["color"] = inNote.color;
    return map;

  }


  /// Create a note.
  ///
  /// @param  inNote The Note object to create.
  /// @return        Future.
  Future create(Note inNote) async {
    Database db = await database;
    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
    Object? id = val.first["id"];
    id ??= 1;

    // Insert into table.
    return await db.rawInsert(
        "INSERT INTO notes (id, title, content, color) VALUES (?, ?, ?, ?)",
        [
          id,
          inNote.title,
          inNote.content,
          inNote.color
        ]
    );

  }

  /// Get a specific note.
  ///
  /// @param  inID The ID of the note to get.
  /// @return      The corresponding Note object.
  Future<Note> get(int inID) async {
    Database db = await database;
    var rec = await db.query("notes", where : "id = ?", whereArgs : [ inID ]);
    return noteFromMap(rec.first);

  }

  /// Get all notes.
  ///
  /// @return A List of Note objects.
  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("notes");
    var list = recs.isNotEmpty ? recs.map((m) => noteFromMap(m)).toList() : [ ];
    return list;

  }


  /// Update a note.
  ///
  /// @param inNote The note to update.
  /// @return       Future.
  Future update(Note inNote) async {
    Database db = await database;
    return await db.update("notes", noteToMap(inNote), where : "id = ?", whereArgs : [ inNote.id ]);

  }

  /// Delete a note.
  ///
  /// @param inID The ID of the note to delete.
  /// @return     Future.
  Future delete(int inID) async {
    Database db = await database;
    return await db.delete("notes", where : "id = ?", whereArgs : [ inID ]);

  }


}