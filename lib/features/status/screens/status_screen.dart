import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/models/status_model.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = '/status-screen';

  final Status status;

  const StatusScreen({
    super.key,
    required this.status,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final StoryController controller = StoryController();
  final List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  void initStoryPageItems() {
    if (widget.status.photoUrl.isEmpty) {
      storyItems.add(
        StoryItem.text(
          title: "No status available",
          backgroundColor: Colors.grey[900]!,
          textStyle: const TextStyle(fontSize: 20),
        ),
      );
      return;
    }

    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      final url = widget.status.photoUrl[i];

      storyItems.add(
        StoryItem.pageImage(
          url: url,
          controller: controller,
          imageFit: BoxFit.cover,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyItems.isEmpty
          ? const Loader()
          : StoryView(
              storyItems: storyItems,
              controller: controller,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              // Untuk versi 0.14.0 → hanya 1 parameter (StoryItem)
              onStoryShow: (storyItem) {
                // Kalau butuh index, bisa cari manual
                final index = storyItems.indexOf(storyItem);
                print("Showing story index: $index");
              },
              onComplete: () {
                Navigator.pop(context); // tutup otomatis setelah semua story selesai
              },
              repeat: false,
            ),
    );
  }
}