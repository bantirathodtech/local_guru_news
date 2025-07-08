import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// class VideoItems extends StatefulWidget {
//   final VideoPlayerController? videoPlayerController;
//   final bool? looping;
//   final bool? autoplay;
//   final bool? showControlles;
//
//   VideoItems({
//     @required this.videoPlayerController,
//     this.looping,
//     this.autoplay,
//     Key? key,
//     this.showControlles,
//   }) : super(key: key);
//
//   @override
//   _VideoItemsState createState() => _VideoItemsState();
// }
//
// class _VideoItemsState extends State<VideoItems> {
//   ChewieController? _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     _chewieController = ChewieController(
//       videoPlayerController: widget.videoPlayerController!,
//       aspectRatio: 16 / 9,
//       autoInitialize: true,
//       autoPlay: widget.autoplay!,
//       looping: widget.looping!,
//       allowFullScreen: false,
//       showOptions: false,
//       showControls: widget.showControlles!,
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(
//             errorMessage,
//             style: TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     widget.videoPlayerController!.dispose();
//     _chewieController!.pause();
//     _chewieController!.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Chewie(
//         controller: _chewieController!,
//       ),
//     );
//   }
// }


class VideoItems extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final bool autoplay;
  final bool showControlles;

  const VideoItems({
    Key? key,
    required this.videoPlayerController,
    required this.looping,
    required this.autoplay,
    required this.showControlles,
  }) : super(key: key);

  @override
  _VideoItemsState createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.videoPlayerController;

    _initVideoPlayer();
  }

  void _initVideoPlayer() async {
    try {
      await _controller.initialize();
      if (widget.autoplay) {
        await _controller.play();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // developer.log('Video player initialization error: $e');
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        color: Colors.black,
        child: Center(
          child: Text(
            "Error loading video",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return _isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          if (widget.showControlles)
          _ControlsOverlay(controller: _controller),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
        ],
      ),
    )
        : Container(
      width: MediaQuery.of(context).size.width,
      height: 250,
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
