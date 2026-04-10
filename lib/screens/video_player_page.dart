import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

class VideoPlayerPage extends StatefulWidget {
  final List<Map<String, dynamic>> videoList;
  final int currentIndex;

  const VideoPlayerPage({
    super.key,
    required this.videoList,
    required this.currentIndex,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  late int _currentVideoIndex;

  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isDescriptionExpanded = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _currentVideoIndex = widget.currentIndex;
    _initializeVideo(_currentVideoIndex);
  }

  void _initializeVideo(int index) {
    final url = widget.videoList[index]["video"];

    _controller?.dispose();

    if (url.startsWith("http")) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    } else if (url.startsWith("assets")) {
      _controller = VideoPlayerController.asset(url);
    } else {
      _controller = VideoPlayerController.file(File(url));
    }

    _controller!.initialize().then((_) {
      setState(() => _isInitialized = true);
    });
  }

  void _togglePlay() {
    if (!_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
  }

  void _playVideo(int index) {
    setState(() {
      _currentVideoIndex = index;
      _isInitialized = false;
      _isPlaying = false;
    });
    _initializeVideo(index);
  }

  void _shareVideo() {
    final v = widget.videoList[_currentVideoIndex];
    Share.share("${v["title"]}\n${v["date"]}");
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.videoList[_currentVideoIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
      body: Column(
        children: [
          /// 🎬 VIDEO PLAYER
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                /// VIDEO / THUMBNAIL
                Positioned.fill(
                  child: !_isPlaying
                      ? Image.network(video["image"], fit: BoxFit.cover)
                      : (_isInitialized
                          ? VideoPlayer(_controller!)
                          : const Center(
                              child: CircularProgressIndicator())),
                ),

                /// TAP TO PLAY
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: Container(color: Colors.transparent),
                  ),
                ),

                /// CONTROLS BAR
                if (_isInitialized)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          /// PLAY BUTTON
                          IconButton(
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlay,
                          ),

                          /// CURRENT TIME
                          Text(
                            _formatDuration(
                                _controller!.value.position),
                            style:
                                const TextStyle(color: Colors.white),
                          ),

                          const SizedBox(width: 8),

                          /// PROGRESS BAR
                          Expanded(
                            child: VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Colors.blue,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          /// TOTAL TIME
                          Text(
                            _formatDuration(
                                _controller!.value.duration),
                            style:
                                const TextStyle(color: Colors.white),
                          ),

                          /// FULLSCREEN
                          IconButton(
                            icon: const Icon(Icons.fullscreen,
                                color: Colors.white),
                            onPressed: _toggleFullScreen,
                          ),
                        ],
                      ),
                    ),
                  ),

                /// EXIT FULLSCREEN
                if (_isFullScreen)
                  Positioned(
                    top: 30,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: _toggleFullScreen,
                    ),
                  ),
              ],
            ),
          ),

          /// HIDE BELOW IN FULLSCREEN
          if (!_isFullScreen)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// TITLE
                  Text(
                    video["title"],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  /// DATE
                  Text(
                    video["date"],
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const Divider(color: Colors.grey),

                  /// DESCRIPTION TITLE
                  const Text(
                    "Description",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  /// DESCRIPTION
                  Text(
                    video["description"] ?? 
                    "Join us for an inspiring community event focused on development and growth. This special gathering brings together people from all walks of life to share experiences and build meaningful connections. Don't miss this opportunity to be part of something meaningful and make a positive impact in our community.",
                    style: const TextStyle(color: Colors.white70),
                    maxLines: _isDescriptionExpanded ? null : 3,
                    overflow: _isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  /// READ MORE - Always show
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Text(
                      _isDescriptionExpanded
                          ? "Read less"
                          : "Read more",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// SHARE BUTTON ONLY
                  OutlinedButton.icon(
                    onPressed: _shareVideo,
                    icon:
                        const Icon(Icons.share, color: Colors.white),
                    label: const Text("Share",
                        style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(color: Colors.grey),

                  const SizedBox(height: 10),

                  /// OTHER VIDEOS
                  const Text(
                    "Other Videos",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...widget.videoList.asMap().entries.map((entry) {
                    int index = entry.key;
                    var v = entry.value;

                    if (index == _currentVideoIndex) {
                      return const SizedBox();
                    }

                    return GestureDetector(
                      onTap: () => _playVideo(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  v["image"],
                                  width: 120,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                const Icon(Icons.play_arrow,
                                    color: Colors.white),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(v["title"],
                                      style: const TextStyle(
                                          color: Colors.white)),
                                  Text(v["date"],
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            )
        ],
      ),
    );
  }
}