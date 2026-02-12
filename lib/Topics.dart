import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:topicreactorapp/utils/SessionManager.dart';

import 'Register.dart';
import 'TopicCreator.dart';
import 'SideNavbar.dart';

class Topics extends StatefulWidget {
  const Topics({super.key});

  @override
  State<Topics> createState() => _Topics();
}

class _Topics extends State<Topics> with WidgetsBindingObserver {
  List topics = [];
  bool isLoading = true;
  int userId = 0;
  final Map<int, TextEditingController> commentControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchTopics();
    loadUserId();
  }

  Future<void> loadUserId() async {
    int id = await SessionManager.getUserId();
    setState(() {
      userId = id;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchTopics();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var controller in commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchTopics() async {
    setState(() {
      isLoading = true;
    });

    final data = await getAllTopics();

    setState(() {
      topics = data;
      isLoading = false;

      commentControllers.clear();
      for (int i = 0; i < topics.length; i++) {
        commentControllers[i] = TextEditingController();
      }
    });
  }

  Future<void> addComment(int index) async {
    final topic = topics[index];
    final comment = commentControllers[index]!.text.trim();

    if (comment.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a comment",
        backgroundColor: Colors.red,
      );
      return;
    }

    const String apiUrl =
        "https://topicreactorbackendnextjs-rvt9.vercel.app/api/Comment?action=createcomment";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "topicid": topic["topicid"],
          "comment": comment,
          "commentedby": userId,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Comment added successfully",
          backgroundColor: Colors.green,
        );

        setState(() {
          topic["comments"] ??= [];
          topic["comments"].add(comment);
          commentControllers[index]!.clear();
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed to add comment",
          backgroundColor: Colors.red,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Error: $error",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Topics",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle,
                color: Colors.white, size: 30),
            onPressed: () async {
              Navigator.pushNamed(
                context,
                "/profile",
              );
            },
          ),
        ],
      ),
        drawer: SideNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        elevation: 30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        icon: Image.asset(
          'assets/images/topicreactor_only_logo.png',
          width: 50,
          height: 50,
        ),

        label: const Text(
          "",
          style: TextStyle(color: Colors.white),
        ),

        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SizedBox(
                  width: 400,
                  height: 300,
                  child: TopicCreator(),
                ),
              );
            },
          );

          if (result == true) {
            fetchTopics();
          }
        },
      ),


      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchTopics,
        child: topics.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 200),
            Center(child: Text("No topics available")),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            final comments = topic["comments"] ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        topic["topic"] ?? "No Title",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      subtitle: Text(
                        topic["reason"] ?? "No Reason",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: commentControllers[index],
                      decoration: const InputDecoration(
                        labelText: "Add a comment",
                        labelStyle: TextStyle(color: Colors.green,fontSize: 15,fontWeight: FontWeight.bold),
                        prefixIcon: Icon(Icons.comment_outlined,color:Colors.green),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.green),
                        ),
                        focusedBorder: OutlineInputBorder(

                          borderSide: BorderSide(width: 2,color: Colors.green)
                        )
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => addComment(index),
                      child: const Text(
                        "Add Comment",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    if (comments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "Comments:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 5),
                      for (var comment in comments)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              vertical: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.green, width: 2),
                            borderRadius:
                            BorderRadius.circular(8),
                            color: Colors.green[50],
                          ),
                          child: Text(
                            comment,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<List> getAllTopics() async {
  List data = [];
  const String apiUrl =
      "https://topicreactorbackendnextjs-rvt9.vercel.app/api/Topic?action=getalltopics";

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      data = decoded is Map ? decoded['topics'] ?? [] : decoded;
    }
  } catch (error) {
    Fluttertoast.showToast(
      msg: "Error: $error",
      backgroundColor: Colors.red,
    );
  }
  return data;
}
