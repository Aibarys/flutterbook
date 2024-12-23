import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "ContactsDBWorker.dart";
import "ContactsList.dart";
import "ContactsEntry.dart";
import "ContactsModel.dart" show ContactsModel, contactsModel;


/// ********************************************************************************************************************
/// The Contacts screen.
/// ********************************************************************************************************************
class Contacts extends StatelessWidget {


  /// Constructor.
  Contacts({super.key}) {

    print("## Contacts.constructor");

    // Initial load of data.
    contactsModel.loadData("contacts", ContactsDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {

    print("## Contacts.build()");

    return ScopedModel<ContactsModel>(
        model : contactsModel,
        child : ScopedModelDescendant<ContactsModel>(
            builder : (inContext, inChild, ContactsModel inModel) {
              return IndexedStack(
                  index : inModel.stackIndex,
                  children : [
                    const ContactsList(),
                    ContactsEntry()
                  ] /* End IndexedStack children. */
              ); /* End IndexedStack. */
            } /* End ScopedModelDescendant builder(). */
        ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */