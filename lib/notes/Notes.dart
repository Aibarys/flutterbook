import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "NotesDBWorker.dart";
import "NotesList.dart";
import "NotesEntry.dart";
import "NotesModel.dart" show NotesModel, notesModel;


/// ********************************************************************************************************************
/// The Notes screen.
/// ********************************************************************************************************************
class Notes extends StatelessWidget {


  /// Constructor.
  Notes({super.key}) {
    // Initial load of data.
    notesModel.loadData("notes", NotesDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (inContext, inChild, NotesModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    const NotesList(),
                    NotesEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */