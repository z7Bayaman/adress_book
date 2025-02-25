import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AddressBookApp());
}

class AddressBookApp extends StatelessWidget {
  const AddressBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ContactListScreen(),
    );
  }
}

class Contact {
  String firstName;
  String? lastName;
  String? phone;
  String? email;
  DateTime? birthDate;

  Contact({
    required this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.birthDate,
  });
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> contacts = [
    Contact(
        firstName: "Иван",
        lastName: "Иванов",
        birthDate: DateTime(1990, 5, 10)),
    Contact(
        firstName: "Анна",
        lastName: "Петрова",
        birthDate: DateTime.now()), // Сегодня ДР
    Contact(
        firstName: "Сергей",
        lastName: "Сидоров",
        birthDate: DateTime(1985, 12, 25)),
  ];

  void _addContact(Contact contact) {
    setState(() {
      contacts.add(contact);
    });
  }

  void _showContactDetails(Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${contact.firstName} ${contact.lastName ?? ''}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              if (contact.phone != null) Text("Телефон: ${contact.phone}"),
              if (contact.email != null) Text("Email: ${contact.email}"),
              if (contact.birthDate != null)
                Text(
                    "ДР: ${DateFormat('dd.MM.yyyy').format(contact.birthDate!)}"),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Закрыть"))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text("Адресная книга")),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final isBirthday = contact.birthDate != null &&
              contact.birthDate!.day == today.day &&
              contact.birthDate!.month == today.month;

          return ListTile(
            title: Text("${contact.firstName} ${contact.lastName ?? ''}"),
            trailing:
                isBirthday ? const Icon(Icons.cake, color: Colors.red) : null,
            onTap: () => _showContactDetails(contact),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newContact = await showDialog<Contact>(
            context: context,
            builder: (context) => const AddContactDialog(),
          );
          if (newContact != null) _addContact(newContact);
        },
      ),
    );
  }
}

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Добавить контакт"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "Имя *"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Обязательное поле" : null,
              ),
              TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: "Фамилия")),
              TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Телефон")),
              TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedDate == null
                      ? "Выберите дату рождения"
                      : DateFormat('dd.MM.yyyy').format(_selectedDate!)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newContact = Contact(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text.isNotEmpty
                    ? _lastNameController.text
                    : null,
                phone: _phoneController.text.isNotEmpty
                    ? _phoneController.text
                    : null,
                email: _emailController.text.isNotEmpty
                    ? _emailController.text
                    : null,
                birthDate: _selectedDate,
              );
              Navigator.pop(context, newContact);
            }
          },
          child: const Text("Добавить"),
        ),
      ],
    );
  }
}
