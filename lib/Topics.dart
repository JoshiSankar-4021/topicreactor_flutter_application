import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:topicreactorapp/utils/SessionManager.dart';

class Topics extends StatefulWidget {
  const Topics({super.key});

  @override
  State<Topics> createState() => _Topics();
}

class _Topics extends State<Topics> {
  List topics = [];
  bool isLoading = true;

  int userId = 0;

  // Each topic has its own controller
  final Map<int, TextEditingController> commentControllers = {};

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    for (var controller in commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ---------------- FETCH TOPICS ----------------
  Future<void> fetchTopics() async {
    final data = await getAllTopics();
    setState(() {
      topics = data;
      isLoading = false;

      for (int i = 0; i < topics.length; i++) {
        commentControllers[i] = TextEditingController();
      }
    });
  }

  // ---------------- ADD COMMENT ----------------
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
        "http://192.168.29.54:3000/api/Comment?action=createcomment";

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

        // 🔥 UPDATE UI IMMEDIATELY
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

  // ---------------- UI ----------------
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : topics.isEmpty
          ? const Center(child: Text("No topics available"))
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

                  // -------- COMMENT INPUT --------
                  TextFormField(
                    controller: commentControllers[index],
                    decoration: const InputDecoration(
                      labelText: "Add a comment",
                      labelStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(10)),
                        borderSide:
                        BorderSide(color: Colors.green),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => addComment(index),
                      child: const Text(
                        "Add Comment",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // -------- SHOW COMMENTS --------
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
                        margin:
                        const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.green[50],
                        ),
                        child: Text(
                          comment,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- FETCH TOPICS API ----------------
Future<List> getAllTopics() async {
  List data = [];
  const String apiUrl =
      "http://192.168.29.54:3000/api/Topic?action=getalltopics";

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded['topics'] != null) {
        data = decoded['topics'];
      }
    } else {
      Fluttertoast.showToast(
        msg: "Failed to fetch topics",
        backgroundColor: Colors.red,
      );
    }
  } catch (error) {
    Fluttertoast.showToast(
      msg: "Error: $error",
      backgroundColor: Colors.red,
    );
  }
  return data;
}
