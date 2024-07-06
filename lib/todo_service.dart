import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl =
    'http://10.0.2.2:5208/api'; // Remplacez par votre URL de l'API

class TodoService {
  static Future<List<TodoItem>> fetchTodoItems(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Todo'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((item) => TodoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load todo items');
    }
  }

  static Future<TodoItem> createTodoItem(
      String accessToken, TodoItemAdd todoItem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Todo'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todoItem.toJson()),
    );

    if (response.statusCode == 201) {
      return TodoItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create todo item');
    }
  }

  static Future<void> updateTodoItem(
      String accessToken, TodoItem todoItem) async {
    final response = await http.put(
      Uri.parse('$baseUrl/Todo/${todoItem.id}'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todoItem.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update todo item');
    }
  }

  static Future<void> deleteTodoItem(String accessToken, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Todo/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo item');
    }
  }

  static Future<TodoItem> fetchTodoItem(String accessToken, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Todo/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return TodoItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load todo item');
    }
  }
}

class TodoItem {
  final int id;
  final String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

class TodoItemAdd {
  final String title;
  final bool isCompleted;

  TodoItemAdd({
    required this.title,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
