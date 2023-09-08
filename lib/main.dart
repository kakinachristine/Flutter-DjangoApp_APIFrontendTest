import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ContactApp());
}

class ContactApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact App',
      home: ContactScreen(),
    );
  }
}

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  List<dynamic> contacts = [];

  @override
  void initState() {
    super.initState();
    fetchContacts(); // Fetch contacts when the screen is initialized
  }

  Future<void> fetchContacts() async {
    final response = await http.get(Uri.parse('http://localhost:8000/get_contacts/'));
    if (response.statusCode == 200) {
      setState(() {
        contacts = json.decode(response.body)['contacts'];
      });
    } else {
      // Handle the error appropriately
      print('Failed to load contacts: ${response.statusCode}');
    }
  }

  Future<void> saveContact() async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/save_contact/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'phone_number': phoneController.text,
      }),
    );
    if (response.statusCode == 200) {
      emailController.clear();
      phoneController.clear();
      fetchContacts(); // Fetch contacts after saving a new contact
    } else {
      // Handle the error appropriately
      print('Failed to save contact: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact App'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              saveContact();
            },
            child: Text('Save Contact'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final email = contacts[index]['email'];
                final phoneNumber = contacts[index]['phone_number'];
                return ListTile(
                  title: Text('Email: ${email ?? 'N/A'}'),
                  subtitle: Text('Phone: ${phoneNumber ?? 'N/A'}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
