import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  Future<void> register(
      String username, String password, BuildContext context) async {
    final url = Uri.parse(
        'http://10.0.2.2:5208/api/Todo/register'); // Remplacez par votre endpoint d'inscription

    // Vérifiez si les champs sont vides avant d'envoyer la requête
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

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

        // Vérifiez la présence et le type de la clé 'token' en minuscules
        if (responseData.containsKey('token') &&
            responseData['token'] != null &&
            responseData['token'] is String) {
          final String token = responseData['token'];
          // Gérez le token comme requis, par exemple, en le stockant de manière sécurisée

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscription réussie')),
          );

          // Naviguez vers une autre page ou effectuez une autre action
          // Exemple :
          // Navigator.push(context, MaterialPageRoute(builder: (context) => SomePage()));
        } else {
          // Si le token est absent ou invalide
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Inscription réussie, mais token manquant ou invalide.')),
          );
        }
      } else {
        // Affichez le message d'erreur du serveur ou gérez l'échec d'une autre manière
        String errorMessage =
            'Échec de l\'inscription. Code: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Gestion des erreurs d'inscription
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'inscription: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

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
                register(_usernameController.text, _passwordController.text,
                    context);
              },
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
