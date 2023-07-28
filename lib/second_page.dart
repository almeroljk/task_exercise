import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserTodoPage extends StatefulWidget {
  final dynamic user;

  UserTodoPage({required this.user});

  @override
  _UserTodoPageState createState() => _UserTodoPageState();
}

class _UserTodoPageState extends State<UserTodoPage> {
  List<dynamic> todos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserTodos();
  }

  Future<void> fetchUserTodos() async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/todos?userId=${widget.user['id']}'));
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        todos = json.decode(response.body);
      });
    } else {
      print('Failed to fetch user todos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos for ${widget.user['name']}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo['title']),
                  leading: Checkbox(
                    value: todo['completed'],
                    onChanged: (value) {},
                  ),
                );
              },
            ),
    );
  }
}
