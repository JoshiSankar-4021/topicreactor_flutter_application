import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topicreactorapp/utils/SessionManager.dart';

import 'Register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login Screen",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.green,
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  email = _emailController.text.trim();
                  password = _passwordController.text.trim();
                  submitLogin(email, password);
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Register",
                  style: TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔐 LOGIN API + SHARED PREFERENCES
  Future<void> submitLogin(String mail, String password) async {
    const String apiUrl =
        "http://192.168.29.54:3000/api/User?action=login";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": mail,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int userId = int.tryParse(data['userid'].toString()) ?? 0;

        if (userId > 0) {
          await SessionManager.saveUserId(userId);
          Fluttertoast.showToast(
            msg: "Login Successful",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.pushReplacementNamed(context, '/topics');
        }else {
          Fluttertoast.showToast(
            msg: "Invalid credentials",
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          backgroundColor: Colors.orange,
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }
}
