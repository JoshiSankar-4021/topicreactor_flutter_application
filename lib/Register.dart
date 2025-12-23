import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reTypePasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String firstName="";
  String lastName="";
  String email="";
  String password="";
  String reTypePassword="";
  String address="";
  String phone="";
  String educationvalue="0";
  String gender="";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Topic Reactor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.green
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Registration",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.green
                  ),
                ),
              ),
              TextFormField(
                controller: _firstnameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 20
                  ),
                  hintText: 'Enter Your First Name',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 2
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                      width:4
                    )
                  )
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name', labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 20
                ),
                  hintText: 'Enter Your Last Name',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width:4
                        )
                    )
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 20
                    ),
                  hintText: 'Enter Your E-mail',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width:4
                        )
                    )
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 20
                    ),
                  hintText: "Enter Your Password",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width:4
                        )
                    )
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _reTypePasswordController,
                decoration: const InputDecoration(
                  labelText: 'Re-Type Password',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 20
                    ),
                  hintText: "Enter Your Password",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width:4
                        )
                    )
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Address', labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 20
                ),
                  hintText: 'Enter Your Address',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width:4
                        )
                    )
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: educationvalue,
                decoration: const InputDecoration(
                  labelText: "Education",
                    labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 20
                ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width:4
                        )
                    )
                ),
                items: const [
                  DropdownMenuItem(value: "0", child: Text("Select")),
                  DropdownMenuItem(value: "1", child: Text("High School")),
                  DropdownMenuItem(value: "2", child: Text("Bachelors")),
                  DropdownMenuItem(value: "3", child: Text("Masters")),
                  DropdownMenuItem(value: "4", child: Text("PH.D")),
                ],
                onChanged: (value) {
                  setState(() => educationvalue = value!);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter Your Phone Number',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2
                        )
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width:4
                        )
                    )
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Gender",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green
                  ),
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "M",
                    groupValue: gender,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                  const Text("Male",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:Colors.black
                  ),),
                  Radio<String>(
                    value: "F",
                    groupValue: gender,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                  const Text("Female",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:Colors.black
                  ),),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    firstName=_firstnameController.text;
                    lastName=_lastnameController.text;
                    email=_emailController.text;
                    password=_passwordController.text;
                    address=_addressController.text;
                    phone=_phoneController.text;
                    submitRegister(firstName,lastName,email,password,address,educationvalue,phone,gender);
                  }, child: Text('Register',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:Colors.white,
                    fontSize: 20
                ),),),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> submitRegister(String firstName, String lastName,
      String email, String password, String address, String educationvalue, String phone, String gender) async {

    const String apiUrl="http://192.168.29.54:3000/api/User?action=registeruser";
    try{
      final response = await http.post(
          Uri.parse(apiUrl),
          headers:{
            "Content-Type":"application/json",
          },body:jsonEncode({
        "firstname": firstName,
        "lastname": lastName,
        "email": email,
        "password": password,
        "address": address,
        "education": educationvalue,
        "phone": phone,
        "gender": gender
      }));
      if(response.statusCode==200){
        Fluttertoast.showToast(
          msg: "User Created Sucessfully",
          backgroundColor: Colors.green,
        );
      }else{
        Fluttertoast.showToast(
          msg: "User Creation Failde",
          backgroundColor: Colors.red,
        );
      }
    }catch(error){
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }
}

