import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "TasksDBWorker.dart";
import "TasksList.dart";
import "TasksEntry.dart";
import "TasksModel.dart" show TasksModel, tasksModel;


/// ********************************************************************************************************************
/// The Tasks screen.
/// ********************************************************************************************************************
class Tasks extends StatelessWidget {


  /// Constructor.
  Tasks({super.key}) {

    print("## Tasks.constructor");

    // Initial load of data.
    tasksModel.loadData("tasks", TasksDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## Tasks.build()");

    return ScopedModel<TasksModel>(
        model : tasksModel,
        child : ScopedModelDescendant<TasksModel>(
            builder : (inContext, inChild, TasksModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    const TasksList(),
                    TasksEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */