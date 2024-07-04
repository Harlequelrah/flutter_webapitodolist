import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key});

  Future<void> register(
      String username, String password, BuildContext context) async {
    final url = Uri.parse(
        'http://localhost:5208/api/Todo/register'); // Remplacez par votre endpoint d'inscription
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

      if (response.statusCode == 200) {
        // Succès : l'utilisateur est inscrit, récupérez le token si nécessaire
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['Token'];
        // Gérez le token comme requis
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie'),
          ),
        );
      } else {
        // Échec : affichez le message d'erreur ou gérez l'échec d'une autre manière
        throw Exception('Failed to register user');
      }
    } catch (e) {
      // Gestion des erreurs d'inscription
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'inscription: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String username = '';
    String password = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => username = value,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
              ),
            ),
            TextField(
              onChanged: (value) => password = value,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                register(username, password, context); // Passer context ici
              },
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
