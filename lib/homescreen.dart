import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List content = [];
  bool loading = true;
  final Map<int, bool> expandedCaptions = {}; // Track expanded state
  final Map<int, bool> longCaptions = {}; // Track which captions need "See more"

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiUrl =
        "https://topicreactorbackendnextjs-rvt9.vercel.app/api/Upload?action=fetchimages";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data is Map && data.containsKey('images')) {
            content = data['images'] ?? [];
          } else if (data is List) {
            content = data;
          }
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<ImageInfo> getImageInfo(String url) async {
    final completer = Completer<ImageInfo>();
    final image = Image.network(url);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
            (info, _) => completer.complete(info),
        onError: (error, _) => completer.completeError(error),
      ),
    );
    return completer.future;
  }

  // Helper to check if caption exceeds 3 lines
  bool doesCaptionExceedLimit(String text, TextStyle style, double maxWidth) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(fontSize: 14);
    final maxWidth = MediaQuery.of(context).size.width - 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : content.isEmpty
          ? const Center(child: Text("No media available"))
          : ListView.builder(
        itemCount: content.length,
        itemBuilder: (context, index) {
          final media = content[index];
          final fileUrl = media['fileurl'] ?? '';
          final isVideo = fileUrl.endsWith('.mp4');
          final caption = media['caption']?.toString() ?? '';

          // Check if caption is long (only once)
          if (!longCaptions.containsKey(index) && caption.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final exceeds =
              doesCaptionExceedLimit(caption, textStyle, maxWidth);
              setState(() {
                longCaptions[index] = exceeds;
              });
            });
          }

          return Card(
            margin:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name & avatar
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    border: Border(
                      top: BorderSide(color: Colors.green, width: 1),
                    ),
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: media['profilePic'] != null &&
                              media['profilePic'].toString().isNotEmpty
                              ? NetworkImage(media['profilePic'])
                              : null,
                          child: media['profilePic'] == null ||
                              media['profilePic'].toString().isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${media['firstname'] ?? ''} ${media['lastname'] ?? ''}"
                              .trim()
                              .isNotEmpty
                              ? "${media['firstname'] ?? ''} ${media['lastname'] ?? ''}"
                              : "No name",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Caption with See more / See less
                if (caption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caption,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: expandedCaptions[index] == true ? null : 3,
                          overflow: expandedCaptions[index] == true
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        if (longCaptions[index] == true)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expandedCaptions[index] =
                                !(expandedCaptions[index] ?? false);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                expandedCaptions[index] == true
                                    ? "See less"
                                    : "See more",
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Image or Video
                if (fileUrl.isNotEmpty)
                  isVideo
                      ? VideoPlayerWidget(url: fileUrl)
                      : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImage(imageUrl: fileUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        fileUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Actions row
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    border: Border(
                      top: BorderSide(color: Colors.green, width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () =>
                              print("Liked ${media['postid']}"),
                        ),
                        Text(formatCount(media['likescount'])),
                        IconButton(
                          icon: const Icon(Icons.heart_broken_outlined),
                          onPressed: () =>
                              print("Disliked ${media['postid']}"),
                        ),
                        Text(formatCount(media['dislikescount'])),
                        IconButton(
                          icon: const Icon(Icons.comment_bank_outlined),
                          onPressed: () =>
                              print("Comment ${media['postid']}"),
                        ),
                        Text(formatCount(media['commentscount'])),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () =>
                              print("Share ${media['postid']}"),
                        ),
                        Text(formatCount(media['sharecount'])),
                        IconButton(
                          icon: const Icon(Icons.repeat),
                          onPressed: () =>
                              print("Repost ${media['postid']}"),
                        ),
                        Text(formatCount(media['repost'])),
                        IconButton(
                          icon: const Icon(Icons.bookmark_add_outlined),
                          onPressed: () =>
                              print("Saved ${media['postid']}"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.green,
      onPressed: (){
        pickMultipleFiles();
      },
          child: const Icon(Icons.post_add)
      ),
    );
  }

  String formatCount(dynamic count) {
    if (count == null) return '0';
    double numCount = 0;
    if (count is int) numCount = count.toDouble();
    if (count is String) numCount = double.tryParse(count) ?? 0;

    if (numCount >= 1000000000) {
      return "${(numCount / 1000000000).toStringAsFixed(1)}B";
    } else if (numCount >= 1000000) {
      return "${(numCount / 1000000).toStringAsFixed(1)}M";
    } else if (numCount >= 1000) {
      return "${(numCount / 1000).toStringAsFixed(1)}K";
    } else {
      return numCount.toStringAsFixed(0);
    }
  }

  Future<void> pickMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );

    if (result != null) {
      List<String?> files = result.paths;
      print("Picked files: $files");
    } else {
      print("User canceled file picking");
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => initialized = true);
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          icon: Icon(
            _controller.value.isPlaying
                ? Icons.pause_circle
                : Icons.play_circle,
            size: 50,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
        ),
      ],
    )
        : const SizedBox(
      height: 250,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
