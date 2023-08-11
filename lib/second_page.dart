import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'model/database_helper.dart';

class UserTodoPage extends StatefulWidget {
  final dynamic user;

  UserTodoPage({required this.user});

  @override
  _UserTodoPageState createState() => _UserTodoPageState();
}

class _UserTodoPageState extends State<UserTodoPage> {
  List<dynamic> todos = [];
  bool isLoading = true;
  String searchValue = '';

  @override
  void initState() {
    super.initState();
    fetchUserTodos();
  }

  Future<void> fetchUserTodos() async {
    final dbHelper = DatabaseHelper.instance;

    final List<Map<String, dynamic>> todosData =
        await dbHelper.fetchTodos(widget.user['id']);

    if (todosData.isNotEmpty) {
      final List<Todo> todosList =
          todosData.map((todoData) => Todo.fromMap(todoData)).toList();

      setState(() {
        isLoading = false;
        todos = todosList;
      });
    } else {
      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/todos?userId=${widget.user['id']}'));
      if (response.statusCode == 200) {
        final List<dynamic> todosData = json.decode(response.body);

        for (dynamic todoData in todosData) {
          final todoToSave = Todo(
            id: todoData['id'],
            userId: todoData['userId'],
            title: todoData['title'],
            completed: todoData['completed'],
          );
          await dbHelper.insertTodo(todoToSave.toMap());
        }

        setState(() {
          isLoading = false;
          todos = todosData;
        });
      } else {
        print('Failed to fetch user todos');
      }
    }
  }

  List<dynamic> get filteredTodos {
    if (searchValue.isEmpty) {
      return todos;
    }
    return todos
        .where((todo) => todo['title']
            .toString()
            .toLowerCase()
            .contains(searchValue.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
        title: Text('Todos for ${widget.user['name']}',
            style: TextStyle(color: Colors.white)),
        onSearch: (value) => setState(() => searchValue = value),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (value) {},
                  ),
                );
              },
            ),
    );
  }
}
