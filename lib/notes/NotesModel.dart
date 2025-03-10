import "../BaseModel.dart";


/// A class representing this PIM entity type.
class Note {

  /// The fields this entity type contains.
  int? id;
  String title = '';
  String content = '';
  String color = '';

  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return "{ id=$id, title=$title, content=$content, color=$color }";
  }
}


/// ****************************************************************************
/// The model backing this entity type's views.
/// ****************************************************************************
class NotesModel extends BaseModel {
  /// The color.  Needed to be able to display what the user picks in the Text widget on the entry screen.
  String? color;

  /// For display of the color chosen by the user.
  ///
  /// @param inColor The color.
  void setColor(String inColor) {
    color = inColor;
    notifyListeners();
  }


}


// The one and only instance of this model.
NotesModel notesModel = NotesModel();