import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  // 1. Tambahkan 'Plus' di tipe datanya
  late CachedVideoPlayerPlusController videoPlayerController;
  bool isPlay = false;

  @override
  void initState() {
    super.initState();
    // 2. Gunakan CachedVideoPlayerPlusController.networkUrl (API terbaru pakai networkUrl)
    // Kalau versi 3.x, dia lebih suka Uri.parse
    videoPlayerController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((value) {
        videoPlayerController.setVolume(1);
        setState(() {});
      });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          // 3. Nama widgetnya juga pakai 'Plus'
          CachedVideoPlayerPlus(videoPlayerController),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () {
                if (isPlay) {
                  videoPlayerController.pause();
                } else {
                  videoPlayerController.play();
                }

                setState(() {
                  isPlay = !isPlay;
                });
              },
              icon: Icon(
                isPlay ? Icons.pause_circle : Icons.play_circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}