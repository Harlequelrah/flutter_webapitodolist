import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'todo_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> login(
      String username, String password, BuildContext context) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5208/api/Todo/login');
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

        // Utilisez la clé 'token' en minuscules
        if (responseData.containsKey('token') &&
            responseData['token'] != null &&
            responseData['token'] is String) {
          final String token = responseData['token'];
          // Stockez le token de manière sécurisée et passez à la page suivante
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TodoPage()),
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
              content:
                  Text('Échec de la connexion. Vérifiez vos informations.')),
        );
      }
    } catch (e) {
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur de connexion. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                login(_usernameController.text, _passwordController.text,
                    context);
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
