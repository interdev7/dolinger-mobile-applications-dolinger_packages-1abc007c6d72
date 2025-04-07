import 'package:flutter/material.dart';

import '../models/stories_model.dart';
import 'stories_list.dart';
import 'story_fullscreen.dart';

class SliderFullScreen extends StatefulWidget {
  final List<StoriesModel> stories;

  final int currentIndex;

  final OpenBannerCallback? onButtonTap;

  final ValueChanged<int>? onStoryOpen;

  final BoxFit storyContentFit;

  const SliderFullScreen({
    super.key,
    required this.currentIndex,
    required this.stories,
    this.onStoryOpen,
    this.onButtonTap,
    required this.storyContentFit,
  });

  @override
  State<SliderFullScreen> createState() => _SliderFullScreenState();
}

class _SliderFullScreenState extends State<SliderFullScreen> {
  late final PageController controller = PageController(
    initialPage: widget.currentIndex,
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onStoryOpen?.call(widget.currentIndex);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.stories;

    return PageView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: stories.length,
      onPageChanged: (value) {
        widget.onStoryOpen?.call(value);
      },
      itemBuilder: (context, index) {
        final story = widget.stories[index];

        return StoryFullscreen(
          stories: story.innerBanners ?? [],
          contentFit: widget.storyContentFit,
          onButtonTap: () {
            widget.onButtonTap?.call(story);
          },
          openNextBanner: () {
            if (index == stories.length - 1) {
              Navigator.of(context).pop();
              return;
            }

            controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          openPrevBanner: () {
            if (index == 0) {
              Navigator.of(context).pop();
              return;
            }

            controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      },
    );
  }
}
