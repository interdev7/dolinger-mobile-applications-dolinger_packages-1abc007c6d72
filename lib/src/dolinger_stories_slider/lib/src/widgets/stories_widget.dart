import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/stories_model.dart';
import '../tools.dart';

class StoriesWidget extends StatefulWidget {
  final StoriesModel story;

  final VoidCallback onTap;

  final Color borderColor;
  const StoriesWidget({
    super.key,
    required this.story,
    required this.onTap,
    this.borderColor = Colors.orange,
  });

  @override
  StoriesWidgetState createState() => StoriesWidgetState();
}

class StoriesWidgetState extends State<StoriesWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();

        // флаг isShown в true при открытии истории
        setState(() {
          widget.story.isShown = true;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: widget.story.isShown
              ? Border.all(color: Colors.transparent, width: 2)
              : Border.all(
                  color: widget.borderColor,
                  width: 2,
                ),
        ),
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            filterQuality: FilterQuality.high,
            imageUrl: Tools.formatImage(
              widget.story.image,
              kSize.large,
            ),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}
