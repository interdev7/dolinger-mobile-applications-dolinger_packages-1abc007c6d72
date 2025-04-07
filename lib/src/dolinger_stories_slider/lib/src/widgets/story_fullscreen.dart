import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/stories_model.dart';
import 'story.dart';

class StoryFullscreen extends StatefulWidget {
  final List<StoriesModel> stories;
  final VoidCallback? openNextBanner;
  final VoidCallback? openPrevBanner;

  final VoidCallback? onButtonTap;

  final BoxFit contentFit;

  const StoryFullscreen({
    super.key,
    required this.stories,
    this.openNextBanner,
    this.openPrevBanner,
    this.onButtonTap,
    required this.contentFit,
  });

  @override
  State<StoryFullscreen> createState() => _StoryFullscreenState();
}

class _StoryFullscreenState extends State<StoryFullscreen> {
  List<StoriesModel> get stories => widget.stories;
  VideoPlayerController? controller;

  int currentStoriesIndex = 0;

  @override
  void initState() {
    super.initState();
    _setVideo();
  }

  void _setVideo() {
    final video = stories[currentStoriesIndex].video;

    if (video != null) {
      controller = VideoPlayerController.network(
        video,
      );

      Future.delayed(Duration.zero).then((value) async {
        await controller!.initialize();
        controller!.play();

        setState(() {});
      });
    }
  }

  void _disposeVideoController() {
    if (controller != null) {
      controller?.pause();
      controller?.dispose();
      controller = null;
    }
  }

  void switchToSlide(int slide) {
    currentStoriesIndex = slide;
    _disposeVideoController();
    _setVideo();

    setState(() {});
  }

  @override
  dispose() {
    _disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final openNextBanner = widget.openNextBanner;
    final openPrevBanner = widget.openPrevBanner;

    final mediaQueryPadd = MediaQuery.of(context).padding;

    final buttonText = stories[currentStoriesIndex].buttonText;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Stack(
        children: [
          Story(
            switchToSlide: switchToSlide,
            onFlashForward: () {
              if (openNextBanner != null) {
                openNextBanner();
              } else {
                Navigator.of(context).pop();
              }
            },
            onFlashBack: () {
              if (openPrevBanner != null) {
                openPrevBanner();
              } else {
                Navigator.of(context).pop();
              }
            },
            momentCount: stories.length,
            momentDurationGetter: (idx) {
              const defaultDuration = Duration(seconds: 5);
              if (idx == null) {
                return defaultDuration;
              }

              final screenTime = stories[idx].screenTime;
              if (screenTime == null) {
                return defaultDuration;
              }

              return Duration(
                milliseconds: screenTime,
              );
            },
            progressSegmentGap: 6,
            fullscreen: false,
            momentBuilder: (context, idx, onLoadFinish) {
              if (controller != null) {
                final isInitialized = controller!.value.isInitialized;

                if (!isInitialized) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                onLoadFinish();

                return Center(
                  child: AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: VideoPlayer(controller!),
                  ),
                );
              }

              return CachedNetworkImage(
                imageUrl: stories[idx].image,
                fit: widget.contentFit,
                fadeInDuration: const Duration(milliseconds: 500),
                fadeOutDuration: const Duration(milliseconds: 300),
                imageBuilder: (context, imageProvider) {
                  onLoadFinish();

                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: widget.contentFit,
                      ),
                    ),
                  );
                },
                placeholder: (context, str) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: mediaQueryPadd.top + 15, right: 20),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                  size: 30,
                  shadows: [
                    Shadow(
                        color: Colors.black.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
              ),
            ),
          ),
          if (buttonText != null && buttonText.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onButtonTap?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
