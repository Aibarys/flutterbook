import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "NotesDBWorker.dart";
import "NotesModel.dart" show Note, NotesModel, notesModel;


/// ****************************************************************************
/// The Notes List sub-screen.
/// ****************************************************************************
class NotesList extends StatelessWidget {
  const NotesList({super.key});



  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {
    // Return widget.
    return ScopedModel<NotesModel>(
        model : notesModel,
        child : ScopedModelDescendant<NotesModel>(
            builder : (inContext, inChild, NotesModel inModel) {
              return Scaffold(
                // Add note.
                  floatingActionButton : FloatingActionButton(
                      child : const Icon(Icons.add, color : Colors.white),
                      onPressed : () async {
                        notesModel.entityBeingEdited = Note();
                        notesModel.setColor("");
                        notesModel.setStackIndex(1);
                      }
                  ),
                  body : ListView.builder(
                      itemCount : notesModel.entityList.length,
                      itemBuilder : (BuildContext inBuildContext, int inIndex) {
                        Note note = notesModel.entityList[inIndex];
                        // Determine note background color (default to white if none was selected).
                        Color color = Colors.white;
                        switch (note.color) {
                          case "red" : color = Colors.red; break;
                          case "green" : color = Colors.green; break;
                          case "blue" : color = Colors.blue; break;
                          case "yellow" : color = Colors.yellow; break;
                          case "grey" : color = Colors.grey; break;
                          case "purple" : color = Colors.purple; break;
                        }
                        return Container(
                            padding : const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child : Slidable(
                              key: ValueKey(note.id), // Уникальный ключ для каждого слайда
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(), // Современная анимация панели
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    label: "Delete",
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                    onPressed: (context) => _deleteNote(context, note),
                                  ),
                                ],
                              ),
                              child: Card(
                                elevation: 8,
                                color: color,
                                child: ListTile(
                                  title: Text(note.title),
                                  subtitle: Text(note.content),
                                  onTap: () async {
                                    notesModel.entityBeingEdited = await NotesDBWorker.db.get(note.id!);
                                    notesModel.setColor(notesModel.entityBeingEdited.color);
                                    notesModel.setStackIndex(1);
                                  },
                                ),
                              ),
                            ) /* End Slidable. */
                        ); /* End Container. */
                      } /* End itemBuilder. */
                  ) /* End End ListView.builder. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder. */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The BuildContext of the parent Widget.
  /// @param  inNote    The note (potentially) being deleted.
  /// @return           Future.
  Future _deleteNote(BuildContext inContext, Note inNote) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: Text("Are you sure you want to delete ${inNote.title}?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(inAlertContext).pop(); // Закрыть диалог
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                // Удаляем заметку
                await NotesDBWorker.db.delete(inNote.id!);
                Navigator.of(inAlertContext).pop(); // Закрываем диалог

                // Перезагружаем данные
                notesModel.loadData("notes", NotesDBWorker.db);

                // Убедитесь, что context всё еще активен перед использованием
                if (inContext.mounted) {
                  ScaffoldMessenger.of(inContext).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Note deleted"),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
} /* End class. */