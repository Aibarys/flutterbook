import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart' as utils;
import 'AppointmentsDBWorker.dart';
import 'AppointmentsModel.dart' show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  AppointmentsEntry({super.key}) {
    print("## AppointmentsEntry.constructor");

    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  @override
  Widget build(BuildContext inContext) {
    if (appointmentsModel.entityBeingEdited != null) {
      _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
      _descriptionEditingController.text = appointmentsModel.entityBeingEdited.description;
    }

    return ScopedModel(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
            builder: (inContext, inChild, AppointmentsModel inModel) {
              return Scaffold(
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            FocusScope.of(inContext).requestFocus(FocusNode());
                            inModel.setStackIndex(0);
                          },
                          child: const Text("Cancel")
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            _save(inContext, appointmentsModel);
                          },
                          child: const Text("Save")
                      )
                    ],
                  ),
                ),
                body: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.subject),
                          title: TextFormField(
                            decoration: const InputDecoration(hintText: "Title"),
                            controller: _titleEditingController,
                            validator: (String? inValue) {
                              if (inValue!.isEmpty) {
                                return "Please enter a title";
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration: const InputDecoration(hintText: "Description"),
                            controller: _descriptionEditingController,
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.today),
                          title: const Text("Date"),
                          subtitle: Text(appointmentsModel.chosenDate?.isEmpty ?? true ? "No Date Chosen" : appointmentsModel.chosenDate!),
                          trailing: IconButton(
                              color: Colors.blue,
                              onPressed: () async {
                                String chosenDate = await utils.selectedDate(
                                    inContext, appointmentsModel, appointmentsModel.entityBeingEdited.apptDate
                                );
                                appointmentsModel.entityBeingEdited.apptDate =
                                    chosenDate;
                                },
                              icon: const Icon(Icons.edit),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.alarm),
                          title: const Text("Time"),
                          subtitle: Text(appointmentsModel.apptTime?.isEmpty ?? true ? "No Time" : appointmentsModel.apptTime!),
                          trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _selectTime(inContext),
                              color: Colors.blue,
                          ),
                        )
                      ],
                    )
                ),
              );
            }
        )
    );
  }

  Future _selectTime(BuildContext inContext) async {

    // Default to right now, assuming we're adding an appointment.
    TimeOfDay initialTime = TimeOfDay.now();

    // If editing an appointment, set the initialTime to the current apptTime, if any.
    if (appointmentsModel.entityBeingEdited.apptTime != null) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      // Create a DateTime using the hours, minutes and a/p from the apptTime.
      initialTime = TimeOfDay(hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1]));
    }

    // Now request the time.
    TimeOfDay? picked = await showTimePicker(context : inContext, initialTime : initialTime);

    // If they didn't cancel, update it on the appointment being edited as well as the apptTime field in the model so
    // it shows on the screen.
    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(inContext));
    }

  } /* End _selectTime(). */


  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The AppointmentsModel.
  void _save(BuildContext inContext, AppointmentsModel inModel) async {

    print("## AppointmentsEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) { return; }

    // Creating a new appointment.
    if (inModel.entityBeingEdited.id == null) {

      print("## AppointmentsEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);

      // Updating an existing appointment.
    } else {

      print("## AppointmentsEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);

    }

    // Reload data from database to update list.
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(
        const SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : Text("Appointment saved")
        )
    );

  } /* End _save(). */

}