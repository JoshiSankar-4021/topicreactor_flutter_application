import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:topicreactorapp/utils/SessionManager.dart';

class Register extends StatefulWidget {
  final bool isUpdate;
  const Register({super.key, this.isUpdate = false});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String educationValue = "0";
  String gender = "";
  int userId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      loadProfile();
    }
  }

  // ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    userId = await SessionManager.getUserId();

    final url =
        "https://topicreactorbackendnextjs-rvt9.vercel.app/api/User?action=getprofile&userid=$userId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];

        setState(() {
          _firstnameController.text = data['firstname'] ?? '';
          _lastnameController.text = data['lastname'] ?? '';
          _emailController.text = data['email'] ?? '';
          _addressController.text = data['address'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          educationValue = data['education'].toString();
          gender = data['gender'] ?? '';
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load profile",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading profile",
        backgroundColor: Colors.red,
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isUpdate ? "Profile" : "Register",
          style: const TextStyle(color: Colors.white, fontSize: 26),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _field("First Name", Icons.person, _firstnameController),
            _field("Last Name", Icons.person, _lastnameController),
            _field(
              "Email",
              Icons.email,
              _emailController,
            ),

            if (!widget.isUpdate)
              _password("Password", _passwordController),

            if (!widget.isUpdate)
              _password("Re-Type Password", _rePasswordController),

            _address(),
            _education(),
            _field("Phone", Icons.phone, _phoneController,
                keyboardType: TextInputType.phone),

            _gender(),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed:
                widget.isUpdate ? updateProfile : registerUser,
                child: Text(
                  widget.isUpdate ? "Update" : "Register",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            if (!widget.isUpdate) _loginLink(),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _field(String label, IconData icon, TextEditingController c,
      {bool enabled = true,
        TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: _decoration(label, icon),
      ),
    );
  }

  Widget _password(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: c,
        obscureText: true,
        decoration: _decoration(label, Icons.lock),
      ),
    );
  }

  Widget _address() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _addressController,
        maxLines: 4,
        decoration: _decoration("Address", Icons.location_on),
      ),
    );
  }

  Widget _education() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: educationValue,
        decoration: _decoration("Education", Icons.school),
        items: const [
          DropdownMenuItem(value: "0", child: Text("Select")),
          DropdownMenuItem(value: "1", child: Text("High School")),
          DropdownMenuItem(value: "2", child: Text("Bachelors")),
          DropdownMenuItem(value: "3", child: Text("Masters")),
          DropdownMenuItem(value: "4", child: Text("Ph.D")),
        ],
        onChanged: (v) => setState(() => educationValue = v!),
      ),
    );
  }

  Widget _gender() {
    return Row(
      children: [
        Radio(
          value: "M",
          groupValue: gender,
          activeColor: Colors.green,
          onChanged: (v) => setState(() => gender = v!),
        ),
        const Text("Male"),
        Radio(
          value: "F",
          groupValue: gender,
          activeColor: Colors.green,
          onChanged: (v) => setState(() => gender = v!),
        ),
        const Text("Female"),
      ],
    );
  }

  Widget _loginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/"),
          child: const Text(
            "Login",
            style: TextStyle(
                color: CupertinoColors.destructiveRed,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 4),
      ),
    );
  }

  // ================= API =================
  Future<void> registerUser() async {
    const api =
        "https://topicreactorbackendnextjs-rvt9.vercel.app/api/User?action=registeruser";

    final response = await http.post(
      Uri.parse(api),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstname": _firstnameController.text,
        "lastname": _lastnameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "address": _addressController.text,
        "education": educationValue,
        "phone": _phoneController.text,
        "gender": gender,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Registered Successfully", backgroundColor: Colors.green);
      Navigator.pushNamed(context, "/");
    } else {
      Fluttertoast.showToast(
          msg: "Registration Failed", backgroundColor: Colors.red);
    }
  }

  Future<void> updateProfile() async {
    userId = await SessionManager.getUserId();

    final String api =
        "https://topicreactorbackendnextjs-rvt9.vercel.app/api/User?action=update_profile&userid=$userId";

    try {
      final response = await http.put(
        Uri.parse(api),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstname": _firstnameController.text.trim(),
          "lastname": _lastnameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "address": _addressController.text.trim(),
          "education": educationValue,
          "phone": _phoneController.text.trim(),
          "gender": gender, // must be "M" or "F"
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Profile Updated Successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(
          msg: "Update Failed",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      debugPrint("Update profile error: $e");
    }
  }
}
