import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'utils/SessionManager.dart';
import 'SideNavbar.dart';

class TopicList extends StatefulWidget {
  const TopicList({super.key});

  @override
  State<TopicList> createState() => _TopicListState();
}

class _TopicListState extends State<TopicList> {
  bool showUpdateTopic = true;
  bool showUpdateComment = false;

  List<Topic> topics = [];
  List<Comment> comments = [];

  int userId = 0;

  TopicForm topicForm = TopicForm(topicid: 0, topic: '', reason: '');
  CommentForm commentForm = CommentForm(commentid: 0, comment: '');

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final id = await SessionManager.getUserId();
    if (id == null || id == 0) return;
    setState(() {
      userId = id;
    });
    if (showUpdateTopic) fetchTopics();
    if (showUpdateComment) fetchComments();
  }

  // ======================= TOPICS ==========================
  Future<void> fetchTopics() async {
    final url = Uri.parse(
        'https://topicreactorbackendnextjs-rvt9.vercel.app/api/Topic?action=gettopicbyuserid&createdby=$userId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final list = decoded['topics'] as List;
      setState(() {
        topics = list.map((e) => Topic.fromJson(e)).toList();
      });
    }
  }

  Future<void> deleteTopic(int topicId) async {
    final url = Uri.parse(
        'https://topicreactorbackendnextjs-rvt9.vercel.app/api/Topic?action=delete_topic&topicid=$topicId');
    final res = await http.delete(url);
    if (res.statusCode == 200) {
      setState(() {
        topics.removeWhere((t) => t.topicId == topicId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topic deleted successfully')));
    }
  }

  Future<void> updateTopic() async {
    final url = Uri.parse(
        'https://topicreactorbackendnextjs-rvt9.vercel.app/api/Topic?action=updatetopic&topicid=${topicForm.topicid}');
    final res = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "topic": topicForm.topic,
        "reason": topicForm.reason,
      }),
    );
    if (res.statusCode == 200) {
      setState(() {
        final index =
        topics.indexWhere((t) => t.topicId == topicForm.topicid);
        if (index != -1) {
          topics[index] =
              Topic(topicId: topicForm.topicid, topic: topicForm.topic, reason: topicForm.reason);
        }
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Topic updated successfully')));
    }
  }

  void getTopic(int topicId) {
    final selected = topics.firstWhere((t) => t.topicId == topicId);
    setState(() {
      topicForm = TopicForm(
        topicid: selected.topicId,
        topic: selected.topic,
        reason: selected.reason,
      );
    });
  }

  // ======================= COMMENTS ==========================
  Future<void> fetchComments() async {
    final url = Uri.parse(
        'https://topicreactorbackendnextjs-rvt9.vercel.app/api/Comment?action=comments_by_commentedby&commentedby=$userId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final list = decoded['comments'] as List;
      setState(() {
        comments = list.map((e) => Comment.fromJson(e)).toList();
      });
    }
  }

  Future<void> deleteComment(int commentId) async {
    final url = Uri.parse(
        'https://topicreactorbackendnextjs-rvt9.vercel.app/api/Comment?action=deleteby_comment_id&commentid=$commentId');
    final res = await http.delete(url);
    if (res.statusCode == 200) {
      setState(() {
        comments.removeWhere((c) => c.commentid == commentId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Comment deleted successfully')));
    }
  }

  Future<void> updateComment() async {
    final url = Uri.parse(
        'https://topicreactorbackendnextjs-rvt9.vercel.app/api/Comment?action=updatecomment&commentid=${commentForm.commentid}');
    final res = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"comment": commentForm.comment}),
    );
    if (res.statusCode == 200) {
      setState(() {
        final index =
        comments.indexWhere((c) => c.commentid == commentForm.commentid);
        if (index != -1) {
          comments[index] =
              Comment(commentid: commentForm.commentid, comment: commentForm.comment, topic: comments[index].topic);
        }
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Comment updated successfully')));
    }
  }

  void getComment(int commentId) {
    final selected = comments.firstWhere((c) => c.commentid == commentId);
    setState(() {
      commentForm = CommentForm(commentid: selected.commentid, comment: selected.comment);
    });
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Colors.green;
    const lightGreen = Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: const Text("My Content"),
        backgroundColor: greenColor,
      ),
      drawer: SideNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Toggle buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          showUpdateTopic = true;
                          showUpdateComment = false;
                          fetchTopics();
                        });
                      },
                      child: const Text("MY TOPICS")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          showUpdateComment = true;
                          showUpdateTopic = false;
                          fetchComments();
                        });
                      },
                      child: const Text("MY COMMENTS")),
                ],
              ),
            ),

            // ======================= TOPICS ==========================
            if (showUpdateTopic)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text("Update Topic Details",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Topic",
                        labelStyle: const TextStyle(color: greenColor),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: greenColor),
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: greenColor),
                            borderRadius: BorderRadius.circular(8)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      controller: TextEditingController(text: topicForm.topic),
                      onChanged: (val) => topicForm.topic = val,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Reason",
                        labelStyle: const TextStyle(color: greenColor),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: greenColor),
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: greenColor),
                            borderRadius: BorderRadius.circular(8)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      controller: TextEditingController(text: topicForm.reason),
                      onChanged: (val) => topicForm.reason = val,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            foregroundColor: Colors.white),
                        onPressed: updateTopic,
                        child: const Text("Update Topic")),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final t = topics[index];
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: greenColor)),
                          child: ListTile(
                            title: Text(
                              t.topic,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: greenColor),
                            ),
                            subtitle: Text(t.reason),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    color: greenColor,
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => getTopic(t.topicId)),
                                IconButton(
                                    color: Colors.red,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => deleteTopic(t.topicId)),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),

            // ======================= COMMENTS ==========================
            if (showUpdateComment)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text("Update Comment Details",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Comment",
                        labelStyle: const TextStyle(color: greenColor),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: greenColor),
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: greenColor),
                            borderRadius: BorderRadius.circular(8)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      controller: TextEditingController(text: commentForm.comment),
                      onChanged: (val) => commentForm.comment = val,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            foregroundColor: Colors.white),
                        onPressed: updateComment,
                        child: const Text("Update Comment")),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: greenColor)),
                          child: ListTile(
                            title: Text(
                              c.topic,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: greenColor),
                            ),
                            subtitle: Text(c.comment),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    color: greenColor,
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => getComment(c.commentid)),
                                IconButton(
                                    color: Colors.red,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => deleteComment(c.commentid)),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

// ======================= MODELS ==========================
class Topic {
  final int topicId;
  final String topic;
  final String reason;

  Topic({required this.topicId, required this.topic, required this.reason});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
        topicId: int.parse(json['topicid'].toString()),
        topic: json['topic'].toString(),
        reason: json['reason'].toString());
  }
}

class Comment {
  final int commentid;
  final String comment;
  final String topic;

  Comment({required this.commentid, required this.comment, this.topic = ''});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentid: int.parse(json['commentid'].toString()),
      comment: json['comment'].toString(),
      topic: json['topic']?.toString() ?? '',
    );
  }
}

// ======================= FORMS ==========================
class TopicForm {
  int topicid;
  String topic;
  String reason;

  TopicForm({required this.topicid, required this.topic, required this.reason});
}

class CommentForm {
  int commentid;
  String comment;

  CommentForm({required this.commentid, required this.comment});
}
