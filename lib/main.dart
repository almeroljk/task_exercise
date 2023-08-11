import 'package:flutter/material.dart';
import 'model/database_helper.dart';
import 'second_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    List<dynamic> usersData = [];

    final response = await DatabaseHelper.instance.getUser();

    if (response.isNotEmpty) {
      // Data was fetched from the local database
      usersData = response;
    } else {
      // Data was not found in the local database, fetch from the API
      final apiResponse = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

      if (apiResponse.statusCode == 200) {
        usersData = json.decode(apiResponse.body);

        for (dynamic userData in usersData) {
          final userToSave = User(
            id: userData['id'],
            name: userData['name'],
            email: userData['email'],
          );
          await DatabaseHelper.instance.insertUser(userToSave.toMap());
        }
      } else {
        print('Failed to fetch users from API');
      }
    }

    setState(() {
      users = usersData;
    });
  }

  void _navigateToUserTodos(BuildContext context, dynamic user) async {
    await fetchUsers();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserTodoPage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['name']),
            subtitle: Text(user['email']),
            onTap: () => _navigateToUserTodos(context, user),
          );
        },
      ),
    );
  }
}
