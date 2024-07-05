import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
export 'login_service.dart';
import 'todo_page.dart';

Future<void> login(
    String username, String password, BuildContext context) async {
  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez remplir tous les champs.')),
    );
    return;
  }

  final url = Uri.parse('http://10.0.2.2:5208/api/User/login');
  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    print('Statut de la réponse: ${response.statusCode}');
    print('Réponse du serveur: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);


      if (responseData.containsKey('token') &&
          responseData['token'] != null &&
          responseData['token'] is String) {
        final String token = responseData['token'];

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TodoPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Échec de la connexion. Token invalide.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Échec de la connexion. Vérifiez vos informations.')),
      );
    }
  } catch (e) {
    print('Erreur: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur de connexion. Veuillez réessayer.')),
    );
  }
}
