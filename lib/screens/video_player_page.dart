import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  bool _isPlaying = true;
  bool _isFullScreen = false;
  bool _isHalfScreen = false;

  @override
  void initState() {
    super.initState();
    _currentVideoIndex = widget.currentIndex;
    _initializeVideo(_currentVideoIndex);
  }

  void _initializeVideo(int index) {
    final videoUrl = widget.videoList[index]["video"];
    
    // Dispose previous controller if exists
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }

    // AUTO DETECT VIDEO TYPE
    if (videoUrl.startsWith("http")) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    } else if (videoUrl.startsWith("assets")) {
      _controller = VideoPlayerController.asset(videoUrl);
    } else {
      _controller = VideoPlayerController.file(File(videoUrl));
    }

    _controller!.initialize().then((_) {
      setState(() {});
      _controller!.play(); // Auto play
      _isPlaying = true;
    });

    // Listen to video state changes
    _controller!.addListener(() {
      if (_controller!.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller!.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller != null) {
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
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _isHalfScreen = false; // Reset half screen when toggling full screen
    });
  }

  void _toggleHalfScreen() {
    setState(() {
      _isHalfScreen = !_isHalfScreen;
      _isFullScreen = false; // Reset full screen when toggling half screen
    });
  }

  void _resetScreenSize() {
    setState(() {
      _isFullScreen = false;
      _isHalfScreen = false;
    });
  }

  void _playVideo(int index) {
    if (index != _currentVideoIndex) {
      setState(() {
        _currentVideoIndex = index;
      });
      _initializeVideo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen ? null : AppBar( // Hide app bar in full screen
        backgroundColor: Colors.black,
        title: Text(
          widget.videoList[_currentVideoIndex]["title"],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Screen size controls
          if (!_isFullScreen)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'fullscreen') {
                  _toggleFullScreen();
                } else if (value == 'halfscreen') {
                  _toggleHalfScreen();
                } else if (value == 'normal') {
                  _resetScreenSize();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'fullscreen',
                  child: Row(
                    children: [
                      Icon(Icons.fullscreen, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Full Screen'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'halfscreen',
                  child: Row(
                    children: [
                      Icon(Icons.aspect_ratio, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Half Screen'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'normal',
                  child: Row(
                    children: [
                      Icon(Icons.crop_square, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Normal'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          // If width is less than 600, use mobile layout
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout(constraints);
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  // MOBILE LAYOUT (Vertical) with YouTube-like screen options
  Widget _buildMobileLayout(BoxConstraints constraints) {
    double videoHeight = _calculateVideoHeight(constraints);
    
    return Column(
      children: [
        // MAIN VIDEO PLAYER with responsive height
        Container(
          width: double.infinity,
          height: videoHeight,
          color: Colors.black,
          child: _controller != null && _controller!.value.isInitialized
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),
                    
                    // PLAY/PAUSE OVERLAY
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        color: Colors.transparent,
                        child: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 60,
                          color: Colors.white.withAlpha(170),
                        ),
                      ),
                    ),

                    // SCREEN SIZE CONTROLS (Top Right)
                    if (!_isFullScreen)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(153),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Full Screen Button
                              IconButton(
                                icon: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                                onPressed: _toggleFullScreen,
                                tooltip: 'Full Screen',
                              ),
                              // Half Screen Button
                              IconButton(
                                icon: const Icon(Icons.aspect_ratio, color: Colors.white, size: 20),
                                onPressed: _toggleHalfScreen,
                                tooltip: 'Half Screen',
                              ),
                              // Normal Screen Button
                              if (_isHalfScreen)
                                IconButton(
                                  icon: const Icon(Icons.crop_square, color: Colors.white, size: 20),
                                  onPressed: _resetScreenSize,
                                  tooltip: 'Normal',
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Exit Full Screen Button
                    if (_isFullScreen)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(153),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 20),
                            onPressed: _resetScreenSize,
                            tooltip: 'Exit Full Screen',
                          ),
                        ),
                      ),
                  ],
                )
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
        ),

        // VIDEO INFO BAR (Hide in full screen)
        if (!_isFullScreen)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoList[_currentVideoIndex]["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.videoList[_currentVideoIndex]["date"],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

        // PLAYLIST SECTION (Hide in full screen)
        if (!_isFullScreen)
          Expanded(
            child: Container(
              color: const Color(0xFF212121),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PLAYLIST HEADER
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Up Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // PLAYLIST VIDEOS
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.videoList.length,
                      itemBuilder: (context, index) {
                        final video = widget.videoList[index];
                        final isCurrentlyPlaying = index == _currentVideoIndex;

                        return GestureDetector(
                          onTap: () => _playVideo(index),
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 6,
                            ),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isCurrentlyPlaying
                                  ? const Color(0xFF323232)
                                  : const Color(0xFF212121),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                // THUMBNAIL
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        video["image"],
                                        width: 100,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 56,
                                            color: Colors.grey[600],
                                            child: const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                          );
                                        },
                                      ),
                                      
                                      // PLAYING INDICATOR
                                      if (isCurrentlyPlaying)
                                        Container(
                                          width: 100,
                                          height: 56,
                                          color: Colors.black.withAlpha(153),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // VIDEO INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video["title"],
                                        style: TextStyle(
                                          color: isCurrentlyPlaying
                                              ? const Color(0xFF3EA6FF)
                                              : Colors.white,
                                          fontSize: 12,
                                          fontWeight: isCurrentlyPlaying
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        video["date"],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Calculate video height based on screen size mode
  double _calculateVideoHeight(BoxConstraints constraints) {
    if (_isFullScreen) {
      return constraints.maxHeight; // Full screen height
    } else if (_isHalfScreen) {
      return constraints.maxHeight * 0.6; // 60% of screen height
    } else {
      // Normal mode - maintain aspect ratio but limit height
      if (_controller != null && _controller!.value.isInitialized) {
        final aspectRatio = _controller!.value.aspectRatio;
        final calculatedHeight = constraints.maxWidth / aspectRatio;
        // Limit to 40% of screen height in normal mode
        return math.min(calculatedHeight, constraints.maxHeight * 0.4);
      }
      return constraints.maxHeight * 0.3; // Default fallback
    }
  }

  // DESKTOP LAYOUT (Horizontal - YouTube Style)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // LEFT SIDE - VIDEO PLAYER
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // MAIN VIDEO PLAYER
              Container(
                color: Colors.black,
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller!),
                            
                            // PLAY/PAUSE OVERLAY
                            GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                color: Colors.transparent,
                                child: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  size: 60,
                                  color: Colors.white.withAlpha(170),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 400,
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
              ),

              // VIDEO INFO
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.videoList[_currentVideoIndex]["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.videoList[_currentVideoIndex]["date"],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // RIGHT SIDE - PLAYLIST
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFF212121),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PLAYLIST HEADER
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Up Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // PLAYLIST VIDEOS
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.videoList.length,
                    itemBuilder: (context, index) {
                      final video = widget.videoList[index];
                      final isCurrentlyPlaying = index == _currentVideoIndex;

                      return GestureDetector(
                        onTap: () => _playVideo(index),
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCurrentlyPlaying
                                ? const Color(0xFF323232)
                                : const Color(0xFF212121),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              // THUMBNAIL
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      video["image"],
                                      width: 120,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 120,
                                          height: 68,
                                          color: Colors.grey[600],
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    // PLAYING INDICATOR
                                    if (isCurrentlyPlaying)
                                      Container(
                                        width: 120,
                                        height: 68,
                                        color: Colors.black.withAlpha(153),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // VIDEO INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video["title"],
                                      style: TextStyle(
                                        color: isCurrentlyPlaying
                                            ? const Color(0xFF3EA6FF)
                                            : Colors.white,
                                        fontSize: 12,
                                        fontWeight: isCurrentlyPlaying
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      video["date"],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}