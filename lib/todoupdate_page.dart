import 'package:flutter/material.dart';
import 'todo_service.dart';

class EditTodoPage extends StatefulWidget {
  final TodoItem todoItem;
  final String accessToken;

  const EditTodoPage(
      {super.key, required this.todoItem, required this.accessToken});

  @override
  _EditTodoPageState createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController _titleController;
  late bool _isCompleted;
  late String accessToken;

  @override
  void initState() {
    super.initState();
    accessToken = widget.accessToken; // Initialisation de accessToken
    _titleController = TextEditingController(text: widget.todoItem.title);
    _isCompleted = widget.todoItem.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    try {
      await TodoService.updateTodoItem(
        accessToken, // Assurez-vous d'avoir l'accessToken disponible ici
        TodoItem(
          id: widget.todoItem.id,
          title: _titleController.text.trim(),
          isCompleted: _isCompleted,
        ),
      );

      // Après la mise à jour réussie, retourner à l'écran précédent
      final updatedItem =
          await TodoService.fetchTodoItem(accessToken, widget.todoItem.id);
      Navigator.of(context).pop(updatedItem);
    } catch (e) {
      print('Failed to update todo item: $e');
      // Gérer les erreurs de mise à jour
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            CheckboxListTile(
              title: const Text('Terminé'),
              value: _isCompleted,
              onChanged: (newValue) {
                setState(() {
                  _isCompleted = newValue!;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateItem,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
