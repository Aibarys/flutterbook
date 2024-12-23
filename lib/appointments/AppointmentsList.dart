import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:scoped_model/scoped_model.dart";
import "package:intl/intl.dart";
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart";
import "package:flutter_calendar_carousel/classes/event.dart";
import "AppointmentsDBWorker.dart";
import "AppointmentsModel.dart" show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});


  @override
  Widget build(BuildContext inContext) {

    print("## AppointmentssList.build()");

    EventList<Event> markedDateMap = EventList(events: {});
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate!.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      markedDateMap.add(
          apptDate, Event(date : apptDate, icon : Container(decoration : const BoxDecoration(color : Colors.blue)))
      );
    }

    return ScopedModel<AppointmentsModel>(
        model : appointmentsModel,
        child : ScopedModelDescendant<AppointmentsModel>(
            builder : (inContext, inChild, inModel) {
              return Scaffold(
                // Add appointment.
                  floatingActionButton : FloatingActionButton(
                      child : const Icon(Icons.add, color : Colors.white),
                      onPressed : () async {
                        appointmentsModel.entityBeingEdited = Appointment();
                        DateTime now = DateTime.now();
                        appointmentsModel.entityBeingEdited.apptDate = "${now.year},${now.month},${now.day}";
                        appointmentsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(now.toLocal()));
                        appointmentsModel.setApptTime(null);
                        appointmentsModel.setStackIndex(1);
                      }
                  ),
                  body : Column(
                      children : [
                        Expanded(
                            child : Container(
                                margin : const EdgeInsets.symmetric(horizontal : 10),
                                child : CalendarCarousel<Event>(
                                    thisMonthDayBorderColor : Colors.grey,
                                    daysHaveCircularBorder : false,
                                    markedDatesMap : markedDateMap,
                                    onDayPressed : (DateTime inDate, List<Event> inEvents) {
                                      _showAppointments(inDate, inContext);
                                    }
                                ) /* End CalendarCarousel. */
                            ) /* End Container. */
                        ) /* End Expanded. */
                      ] /* End Column.children. */
                  ) /* End Column. */
              ); /* End Scaffold. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */

  void _showAppointments(DateTime inDate, BuildContext inContext) async {

    print(
        "## AppointmentsList._showAppointments(): inDate = $inDate (${inDate.year},${inDate.month},${inDate.day})"
    );

    print("## AppointmentsList._showAppointments(): appointmentsModel.entityList.length = "
        "${appointmentsModel.entityList.length}");
    print("## AppointmentsList._showAppointments(): appointmentsModel.entityList = "
        "${appointmentsModel.entityList}");

    showModalBottomSheet(
        context : inContext,
        builder : (BuildContext inContext) {
          return ScopedModel<AppointmentsModel>(
              model : appointmentsModel,
              child : ScopedModelDescendant<AppointmentsModel>(
                  builder : (inContext, inChild, AppointmentsModel inModel) {
                    return Scaffold(
                        body : Container(
                            child : Padding(
                                padding : const EdgeInsets.all(10),
                                child : GestureDetector(
                                    child : Column(
                                        children : [
                                          Text(
                                              DateFormat.yMMMMd("en_US").format(inDate.toLocal()),
                                              textAlign : TextAlign.center,
                                              style : TextStyle(color : Theme.of(inContext).colorScheme.secondary, fontSize : 24)
                                          ),
                                          const Divider(),
                                          Expanded(
                                              child : ListView.builder(
                                                  itemCount : appointmentsModel.entityList.length,
                                                  itemBuilder : (BuildContext inBuildContext, int inIndex) {
                                                    Appointment appointment = appointmentsModel.entityList[inIndex];
                                                    print("## AppointmentsList._showAppointments().ListView.builder(): "
                                                        "appointment = $appointment");
                                                    // Filter out any appointment that isn't for the specified date.
                                                    if (appointment.apptDate != "${inDate.year},${inDate.month},${inDate.day}") {
                                                      return Container(height : 0);
                                                    }
                                                    print("## AppointmentsList._showAppointments().ListView.builder(): "
                                                        "INCLUDING appointment = $appointment");
                                                    // If the appointment has a time, format it for display.
                                                    String apptTime = "";
                                                    if (appointment.apptTime != null) {
                                                      List timeParts = appointment.apptTime!.split(",");
                                                      TimeOfDay at = TimeOfDay(
                                                          hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
                                                      );
                                                      apptTime = " (${at.format(inContext)})";
                                                    }
                                                    // Return a widget for the appointment since it's for the correct date.
                                                    return Slidable(
                                                      startActionPane: ActionPane(
                                                        motion: const DrawerMotion(), // Или StretchMotion(), BehindMotion()
                                                        children: [
                                                          SlidableAction(
                                                            onPressed: (context) => _editAppointment(inContext, appointment),
                                                            backgroundColor: Colors.blue,
                                                            foregroundColor: Colors.white,
                                                            icon: Icons.edit,
                                                            label: 'Edit',
                                                          ),
                                                        ],
                                                      ),
                                                      endActionPane: ActionPane(
                                                        motion: const DrawerMotion(),
                                                        children: [
                                                          SlidableAction(
                                                            onPressed: (context) => _deleteAppointment(inBuildContext, appointment),
                                                            backgroundColor: Colors.red,
                                                            foregroundColor: Colors.white,
                                                            icon: Icons.delete,
                                                            label: 'Delete',
                                                          ),
                                                        ],
                                                      ),
                                                      child: Container(
                                                        margin: const EdgeInsets.only(bottom: 8),
                                                        color: Colors.grey.shade300,
                                                        child: ListTile(
                                                          title: Text("${appointment.title}$apptTime"),
                                                          subtitle: appointment.description == null
                                                              ? null
                                                              : Text(appointment.description),
                                                          onTap: () async {
                                                            _editAppointment(inContext, appointment);
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }
                                              )
                                          )
                                        ]
                                    )
                                )
                            )
                        )
                    );
                  }
              )
          );
        }
    );

  }


  /// Handle taps on an appointment to trigger editing.
  ///
  /// @param inContext     The BuildContext of the parent widget.
  /// @param inAppointment The Appointment being edited.
  void _editAppointment(BuildContext inContext, Appointment inAppointment) async {

    print("## AppointmentsList._editAppointment(): inAppointment = $inAppointment");

    // Get the data from the database and send to the edit view.
    appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(inAppointment.id ?? 0);
    // Parse out the apptDate and apptTime, if any, and set them in the model
    // for display.
    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate("");
    } else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(
          int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
      );
      appointmentsModel.setChosenDate(
          DateFormat.yMMMMd("en_US").format(apptDate.toLocal())
      );
    }
    if (appointmentsModel.entityBeingEdited.apptTime == null) {
      appointmentsModel.setApptTime(null);
    } else {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      TimeOfDay apptTime = TimeOfDay(
          hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
      );
      appointmentsModel.setApptTime(apptTime.format(inContext));
    }
    appointmentsModel.setStackIndex(1);
    Navigator.pop(inContext);

  } /* End _editAppointment. */


  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext     The parent build context.
  /// @param  inAppointment The appointment (potentially) being deleted.
  /// @return               Future.
  Future _deleteAppointment(BuildContext inContext, Appointment inAppointment) async {

    print("## AppointmentsList._deleteAppointment(): inAppointment = $inAppointment");

    return showDialog(
        context : inContext,
        barrierDismissible : false,
        builder : (BuildContext inAlertContext) {
          return AlertDialog(
              title : const Text("Delete Appointment"),
              content : Text("Are you sure you want to delete ${inAppointment.title}?"),
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
                      await AppointmentsDBWorker.db.delete(inAppointment.id ?? 0);
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Appointment deleted"),
                        ),
                      );

                      // Reload data from database to update list.
                      appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
                    }
                )
              ]
          );
        }
    );
  } /* End _deleteAppointment(). */
} /* End class. */