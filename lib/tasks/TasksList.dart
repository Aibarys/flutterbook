import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "TasksDBWorker.dart";
import "TasksModel.dart" show Task, TasksModel, tasksModel;


/// ********************************************************************************************************************
/// The Tasks List sub-screen.
/// ********************************************************************************************************************
class TasksList extends StatelessWidget {
  const TasksList({super.key});



  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## TasksList.build()");

    // Return widget.
    return ScopedModel<TasksModel>(
        model : tasksModel,
        child : ScopedModelDescendant<TasksModel>(
            builder : (inContext, inChild, TasksModel inModel) {
              return Scaffold(
                // Add task.
                  floatingActionButton : FloatingActionButton(
                      child : const Icon(Icons.add, color : Colors.white),
                      onPressed : () async {
                        tasksModel.entityBeingEdited = Task();
                        tasksModel.setChosenDate("");
                        tasksModel.setStackIndex(1);
                      }
                  ),
                  body : ListView.builder(
                    // Get the first Card out of the shadow.
                      padding : const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      itemCount : tasksModel.entityList.length,
                      itemBuilder : (BuildContext inBuildContext, int inIndex) {
                        Task task = tasksModel.entityList[inIndex];
                        // Get the date, if any, in a human-readable format.
                        String sDueDate;
                        List dateParts = task.dueDate!.split(",");
                        DateTime dueDate = DateTime(
                            int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
                        );
                        sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                                              // Create the Slidable.
                        return Slidable(
                          key: ValueKey(task.id), // Уникальный ключ для каждого слайда
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(), // Анимация слайдера
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                label: "Delete",
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (context) => _deleteTask(context, task),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: task.completed == "true",
                              onChanged: (inValue) async {
                                // Обновление статуса задачи
                                task.completed = inValue.toString();
                                await TasksDBWorker.db.update(task);
                                tasksModel.loadData("tasks", TasksDBWorker.db);
                              },
                            ),
                            title: Text(
                              task.description ?? "",
                              style: task.completed == "true"
                                  ? TextStyle(color: Theme.of(inContext).disabledColor, decoration: TextDecoration.lineThrough)
                                  : TextStyle(color: Theme.of(inContext).textTheme.titleLarge?.color),
                            ),
                            subtitle: task.dueDate == null ? null
                                : Text(sDueDate, style: task.completed == "true"
                                  ? TextStyle(color: Theme.of(inContext).disabledColor, decoration: TextDecoration.lineThrough)
                                  : TextStyle(color: Theme.of(inContext).textTheme.titleLarge?.color),
                            ),
                            onTap: () async {
                              // Невозможно редактировать завершённую задачу
                              if (task.completed == "true" || task.id == null) return;
                              tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id!);
                              tasksModel.setChosenDate(tasksModel.entityBeingEdited.dueDate ?? "");
                              tasksModel.setStackIndex(1);
                            },
                          ),
                        ); /* End Slidable. */
                      } /* End itemBuilder. */
                  ) /* End ListView.builder. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder. */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The parent build context.
  /// @param  inTask    The task (potentially) being deleted.
  /// @return           Future.
  Future _deleteTask(BuildContext inContext, Task inTask) async {

    print("## TasksList._deleteTask(): inTask = $inTask");

    return showDialog(
        context : inContext,
        barrierDismissible : false,
        builder : (BuildContext inAlertContext) {
          return AlertDialog(
              title : const Text("Delete Task"),
              content : Text("Are you sure you want to delete ${inTask.description}?"),
              actions : [
                TextButton(child : const Text("Cancel"),
                    onPressed: () {
                      // Just hide dialog.
                      Navigator.of(inAlertContext).pop();
                    }
                ),
                TextButton(child : const Text("Delete"),
                    onPressed : () async {
                      // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                      await TasksDBWorker.db.delete(inTask.id!);
                      Navigator.of(inAlertContext).pop();
                      tasksModel.loadData("tasks", TasksDBWorker.db);
                      if (inContext.mounted) {
                        ScaffoldMessenger.of(inContext).showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                                content: Text("Task deleted")
                            )
                        );
                      }
                      // Reload data from database to update list.
                    }
                )
              ]
          );
        }
    );

  } /* End _deleteTask(). */


} /* End class. */