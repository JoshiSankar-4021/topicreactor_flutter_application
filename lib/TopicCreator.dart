import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:topicreactorapp/utils/SessionManager.dart';

class TopicCreator extends StatefulWidget {
  const TopicCreator({super.key});

  @override
  State<TopicCreator> createState() => _TopicCreator();
}

class _TopicCreator extends State<TopicCreator> {

  final TextEditingController _topicNameController= TextEditingController();
  final TextEditingController _reasonController= TextEditingController();

  String topicName="";
  String reason="";
  int userId = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    int id = await SessionManager.getUserId();
    setState(() {
      userId = id;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CREATE TOPIC",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                "TOPIC CREATOR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller:_topicNameController,
                    decoration: InputDecoration(
                      labelText: 'Topic Name',
                      labelStyle: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      hintText: 'Enter Topic Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller:_reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      labelStyle: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      hintText: 'Enter Reason For Topic',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(child:ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    onPressed: () {
                      topicName=_topicNameController.text;
                      reason=_reasonController.text;
                      print("topic name:$topicName");
                      print("reason: $reason");
                      print("userid:$userId");
                      CreateTopic(topicName,reason,userId);
                    }, child: Text('Create Topic',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                  ),))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void>CreateTopic(String topicName,String reason,int userId)async {
    const String apiUrl="http://192.168.29.54:3000/api/Topic?action=createtopic";
    try{
      final response = await http.post(
          Uri.parse(apiUrl),
          headers:{
            "Content-Type":"application/json",
          },body:jsonEncode({
            "topic":topicName,
            "reason":reason,
            "createdby":userId
      }));
      if(response.statusCode==200){
        Fluttertoast.showToast(
          msg: "Topic Created Sucessfully",
          backgroundColor: Colors.green,
        );
      }else{
        Fluttertoast.showToast(
          msg: "Topic Not Created",
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
