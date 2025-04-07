import 'dart:math';

import 'package:flutter/material.dart';

import '../models/stories_model.dart';
import 'slider_fullscreen.dart';
import 'stories_widget.dart';

typedef OpenBannerCallback = void Function(StoriesModel story);

class StoriesList extends StatefulWidget {
  final List<StoriesModel> stories;

  final EdgeInsets outerPadding;
  final double gapBetweenItems;
  final int maxElementsVisible;

  final Color borderColor;

  final OpenBannerCallback? onButtonTap;

  final ValueChanged<int>? onStoryOpen;

  final BoxFit storyContentFit;
  const StoriesList({
    super.key,
    required this.stories,
    this.outerPadding = defaultOuterPadding,
    this.gapBetweenItems = 6.0,
    this.maxElementsVisible = 3,
    this.onStoryOpen,
    this.borderColor = Colors.orange,
    this.onButtonTap,
    this.storyContentFit = BoxFit.cover,
  });

  static const EdgeInsets defaultOuterPadding =
      EdgeInsets.symmetric(horizontal: 20);

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final visibleItemsCount =
        min(widget.stories.length, widget.maxElementsVisible);

    final width = size.width;

    final widthWithoutPadding = width - widget.outerPadding.horizontal;

    final widthWithoutPaddingAndGaps = widthWithoutPadding -
        (widget.gapBetweenItems * (visibleItemsCount - 1));

    final listHeight = widthWithoutPaddingAndGaps / widget.maxElementsVisible;

    if (widget.stories.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: widget.outerPadding,
        scrollDirection: Axis.horizontal,
        itemCount: widget.stories.length,
        itemBuilder: (context, index) {
          final child = StoriesWidget(
            story: widget.stories[index],
            borderColor: widget.borderColor,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => SliderFullScreen(
                    currentIndex: index,
                    stories: widget.stories,
                    onButtonTap: widget.onButtonTap,
                    storyContentFit: widget.storyContentFit,
                    onStoryOpen: (value) {
                      try {
                        widget.stories[value].isShown = true;
                        setState(() {});
                        widget.onStoryOpen?.call(value);
                      } catch (e) {
                        print('$e');
                      }
                    },
                  ),
                ),
              );
            },
          );

          if (widget.stories.length < 3) {
            return SizedBox(
              width: widthWithoutPaddingAndGaps / visibleItemsCount,
              child: child,
            );
          }

          return AspectRatio(
            aspectRatio: 1 / 1,
            child: child,
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            width: widget.gapBetweenItems,
          );
        },
      ),
    );
  }
}
