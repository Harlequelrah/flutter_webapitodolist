import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
export 'registration_service.dart';
import 'login_service.dart';

Future<void> register(
    String username, String password, BuildContext context) async {
  final url = Uri.parse(
      'http://10.0.2.2:5208/api/User/register');


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


      if (responseData.containsKey('token') &&
          responseData['token'] != null &&
          responseData['token'] is String) {
        final String token = responseData['token'];


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie')),

        );

        login(username,password,context);


      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Inscription réussie, mais token manquant ou invalide.')),
        );
      }
    } else {

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur d\'inscription: ${e.toString()}')),
    );
  }
}
