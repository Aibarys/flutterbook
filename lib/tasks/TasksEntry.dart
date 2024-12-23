import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "../utils.dart" as utils;
import "TasksDBWorker.dart";
import "TasksModel.dart" show TasksModel, tasksModel;


/// ********************************************************************************************************************
/// The Tasks Entry sub-screen.
/// ********************************************************************************************************************
class TasksEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _descriptionEditingController = TextEditingController();


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// Constructor.
  TasksEntry({super.key}) {

    print("## TasksList.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionEditingController.text;
    });

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## TasksEntry.build()");

    // Set value of controllers.
    if (tasksModel.entityBeingEdited?.description == null) {
      _descriptionEditingController.text = "";  // Пустая строка по умолчанию
    } else {
      _descriptionEditingController.text = tasksModel.entityBeingEdited.description!;
    }


    // Return widget.
    return ScopedModel(
        model : tasksModel,
        child : ScopedModelDescendant<TasksModel>(
            builder : (inContext, inChild, TasksModel inModel) {
              return Scaffold(
                  bottomNavigationBar : Padding(
                      padding : const EdgeInsets.symmetric(vertical : 0, horizontal : 10),
                      child : Row(
                          children : [
                            TextButton(child : const Text("Cancel"),
                                onPressed : () {
                                  // Hide soft keyboard.
                                  FocusScope.of(inContext).requestFocus(FocusNode());
                                  // Go back to the list view.
                                  inModel.setStackIndex(0);
                                }
                            ),
                            const Spacer(),
                            TextButton(child : const Text("Save"),
                                onPressed : () { _save(inContext, tasksModel); }
                            )
                          ]
                      )
                  ),
                  body : Form(
                      key : _formKey,
                      child : ListView(
                          children : [
                            // Description.
                            ListTile(
                                leading : const Icon(Icons.description),
                                title : TextFormField(
                                    keyboardType : TextInputType.multiline,
                                    maxLines : 4,
                                    decoration : const InputDecoration(hintText : "Description"),
                                    controller : _descriptionEditingController,
                                    validator : (String? inValue) {
                                      if (inValue!.isEmpty) { return "Please enter a description"; }
                                      return null;
                                    }
                                )
                            ),
                            // Due date.
                            ListTile(
                                leading : const Icon(Icons.today),
                                title : const Text("Due Date"),
                                subtitle : Text(tasksModel.chosenDate?.isEmpty ?? true ? "" : tasksModel.chosenDate!),
                                trailing : IconButton(
                                    icon : const Icon(Icons.edit), color : Colors.blue,
                                    onPressed : () async {
                                      // Request a date from the user.  If one is returned, store it.
                                      String chosenDate = await utils.selectedDate(
                                          inContext, tasksModel, tasksModel.entityBeingEdited.dueDate
                                      );
                                      tasksModel.entityBeingEdited.dueDate = chosenDate;
                                    }
                                )
                            )
                          ] /* End Column children. */
                      ) /* End ListView. */
                  ) /* End Form. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The TasksModel.
  void _save(BuildContext inContext, TasksModel inModel) async {

    print("## TasksEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) { return; }

    // Creating a new task.
    if (inModel.entityBeingEdited.id == null) {
      print("## TasksEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await TasksDBWorker.db.create(inModel.entityBeingEdited);
    } else {
      print("## TasksEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await TasksDBWorker.db.update(inModel.entityBeingEdited);
    }


    // Reload data from database to update list.
    tasksModel.loadData("tasks", TasksDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : Text("Task saved")
        )
    );


  } /* End _save(). */


} /* End class. */