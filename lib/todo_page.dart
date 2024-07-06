import 'package:flutter/material.dart';
import 'package:flutter_webapitodolist/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_service.dart';
import 'login_page.dart';
import 'todoupdate_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  TodoPageState createState() => TodoPageState();
}

class TodoPageState extends State<TodoPage> {
  late String accessToken;
  late List<TodoItem> todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    final String? token = await _getToken();
    if (token != null) {
      setState(() {
        accessToken = token;
      });
      await _fetchData();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchData() async {
    try {
      final List<TodoItem> fetchedItems =
          await TodoService.fetchTodoItems(accessToken);
      setState(() {
        todoItems = fetchedItems;
      });
    } catch (e) {
      print('Failed to fetch todo items: $e');
      // Gérer les erreurs de récupération des données
    }
  }

  Future<void> _addItem(String title) async {
    try {
      final TodoItem newItem = await TodoService.createTodoItem(
          accessToken, TodoItemAdd(title: title, isCompleted: false));
      setState(() {
        todoItems.add(newItem);
      });
    } catch (e) {
      print('Failed to add todo item: $e');
      // Gérer les erreurs d'ajout
    }
  }

  Future<void> _updateItem(TodoItem updatedItem) async {
    try {
      await TodoService.updateTodoItem(accessToken, updatedItem);
      final TodoItem newItem =
          await TodoService.fetchTodoItem(accessToken, updatedItem.id);
      setState(() {
        final index =
            todoItems.indexWhere((element) => element.id == updatedItem.id);
        if (index != -1) {
          todoItems[index] = newItem;
        }
      });
    } catch (e) {
      print('Failed to update todo item: $e');
      // Gérer les erreurs de mise à jour
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await TodoService.deleteTodoItem(accessToken, id);
      setState(() {
        todoItems.removeWhere((item) => item.id == id);
      });
    } catch (e) {
      print('Failed to delete todo item: $e');
      // Gérer les erreurs de suppression
    }
  }

  Future<void> _showDeleteConfirmationDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Êtes-vous sûr de vouloir supprimer cet élément ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditPage(TodoItem item) async {
    final updatedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditTodoPage(todoItem: item, accessToken: accessToken),
      ),
    );
    if (updatedItem != null) {
      // Mettre à jour l'élément dans la liste après la modification
      setState(() {
        final index =
            todoItems.indexWhere((element) => element.id == updatedItem.id);
        if (index != -1) {
          todoItems[index] = updatedItem;
        }
      });
    }
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: todoItems.length,
        itemBuilder: (context, index) {
          final item = todoItems[index];
          return CheckboxListTile(
            title: Text(item.title),
            value: item.isCompleted,
            onChanged: (newValue) async {
              setState(() {
                item.isCompleted = newValue ?? false;
              });
              // Mettre à jour l'élément sur le serveur
              await _updateItem(item);
            },
            secondary: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEditPage(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(item.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? newItemTitle = await _showAddItemDialog(context);
          if (newItemTitle != null && newItemTitle.isNotEmpty) {
            await _addItem(newItemTitle);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showAddItemDialog(BuildContext context) async {
    TextEditingController textFieldController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un élément'),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: 'Entrez le titre'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () {
                String newItemTitle = textFieldController.text.trim();
                Navigator.of(context).pop(newItemTitle);
              },
            ),
          ],
        );
      },
    );
  }
}
