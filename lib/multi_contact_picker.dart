library multi_contact_picker;

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/email.dart';
import 'package:flutter_contacts/properties/name.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MultiContactPicker extends StatefulWidget {
  /// App bar of the scaffold
  final PreferredSizeWidget? appBar;

  /// The background color taken up by the leading CircleAvatar
  final Color? leadingAvatarColor;

  /// Displayed when the number of contacts to display is zero
  final Widget? emptyState;

  /// Customise the way the contacts are displayed
  final Widget Function(BuildContext context, Contact contact, bool selected)?
      contactBuilder;

  /// Customise the way the contacts are displayed
  final Widget? floatingActionButton;

  /// Customise the loader shown when the contacts are being pulled from the device
  final Widget? loader;

  /// Customise the error widget displayed when contacts the contacts cannot be retrieved from the device
  final Widget Function(PermissionStatus permissionStatus)? error;
  const MultiContactPicker(
      {Key? key,
      this.error,
      this.leadingAvatarColor,
      this.loader,
      this.floatingActionButton,
      this.contactBuilder,
      this.emptyState,
      this.appBar})
      : super(key: key);

  @override
  State<MultiContactPicker> createState() => _MultiContactPickerState();
}

class _MultiContactPickerState extends State<MultiContactPicker> {
  List<Contact> _contacts = [];
  List<Contact> selectedContacts = [];
  bool _isLoading = false;
  bool error = false;
  PermissionStatus? permissionStatusError = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    getContactsPermission();
  }

  List<Contact> contactsExchange(contactInfos) {
     return contactInfos.map((info) => Contact(
            id: info.identifier ?? '',
            // thumbnail: info.,
            photo: info.avatar,
            // isStarred: info.,
            name: info.displayName != null ? Name(
              first: info.givenName ?? '',
              last: info.familyName ?? '',
              middle: info.middleName ?? '',
              prefix: info.prefix  ?? '',
              suffix: info.suffix ?? '',
            ) : null,
            displayName: info.displayName ??'',
            emails: info.emails?.map((e) => Email(e.value ?? '')).toList(),
            
            phones: info.phones?.map((p) => Phone(p.value ?? '', normalizedNumber: p.value ?? '')).toList(),
          ));
         
  }

  void getContactsPermission() async {
    await Permission.contacts.request().then((PermissionStatus value) async {
      try {
        debugPrint("Contact Permission Status $value");
        if (value != PermissionStatus.granted) {
          permissionStatusError = value;
          error = true;
        }
        setState(() {});
        if (value == PermissionStatus.granted) {
          setState(() {
            _isLoading = true;
          });
          var contactInfos = await FlutterContactsService.getContacts();
          debugPrint("Contacts found: ${contactInfos.length}");
          _populateContacts((contactsExchange(contactInfos)));
        }
      } catch (error) {
        debugPrint("Error: $error");
      }
    });
  }

  void _populateContacts(Iterable<Contact> contacts) {
    try {
      _contacts = contacts.where((item) => item.displayName != null).toList();
      _contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  String getInitials(String string) => string.isNotEmpty
      ? string.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';

  ListTile _buildListTile(Contact contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: widget.leadingAvatarColor,
        child: Text(getInitials(contact.displayName)),
      ),
      title: Text(contact.displayName),
      subtitle: contact.phones.isNotEmpty
          ? Text(contact.phones[0].toString())
          : null,
      trailing: Checkbox(
          activeColor: Colors.green,
          value: selectedContacts.contains(contact),
          onChanged: (bool? value) {
            debugPrint(contact.displayName);
            if (value != null) {
              if (value) {
                selectedContacts.add(contact);
              } else {
                selectedContacts.remove(contact);
              }
              setState(() {});
            }
          }),
    );
  }

  Widget centeredLoader({required Widget child}) {
    if (error) {
      if (widget.error == null) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Error occurred when trying to retrieve contacts. Please grant contact permissions from phone settings",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(permissionStatusError.toString()),
            ],
          )),
        );
      }
      return widget.error!(permissionStatusError!);
    }
    if (_isLoading) {
      if (widget.loader == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return widget.loader!;
    }
    return child;
  }

  Widget? buildFloatingActionButton() {
    if (selectedContacts.isNotEmpty) {
      return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {
            Navigator.pop(context, selectedContacts);
          },
          child: widget.floatingActionButton ??
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ));
    }

    return null;
  }

  Widget buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "No contacts available to display",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      )),
    );
  }

  Widget buildBodySection() {
    if (_contacts.isEmpty) {
      if (widget.emptyState != null) {
        return widget.emptyState!;
      }
      return buildEmptyState();
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 50),
      separatorBuilder: (context, index) {
        return Divider(
          color: Colors.grey.shade200,
          height: 0,
        );
      },
      itemCount: _contacts.length,
      itemBuilder: (BuildContext context, int index) {
        Contact contact = _contacts[index];
        return widget.contactBuilder != null
            ? widget.contactBuilder!(
                context, contact, selectedContacts.contains(contact))
            : _buildListTile(contact);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      appBar: widget.appBar ??
          AppBar(
            automaticallyImplyLeading: false,
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
      body: centeredLoader(child: buildBodySection()),
      floatingActionButton: buildFloatingActionButton(),
    ));
  }
}
