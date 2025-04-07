library flutter_stories;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef MomentDurationGetter = Duration Function(int? index);

typedef ProgressSegmentBuilder = Widget Function(
    BuildContext context, int index, double progress, double gap);

class Story extends StatefulWidget {
  const Story({
    Key? key,
    required this.momentBuilder,
    required this.momentDurationGetter,
    required this.momentCount,
    this.onFlashForward,
    this.switchToSlide,
    this.onFlashBack,
    this.progressSegmentBuilder = Story.instagramProgressSegmentBuilder,
    this.progressSegmentGap = 2.0,
    this.progressOpacityDuration = const Duration(milliseconds: 300),
    this.momentSwitcherFraction = 0.33,
    this.startAt = 0,
    this.topOffset,
    this.fullscreen = true,
  })  : assert(momentCount > 0),
        assert(momentSwitcherFraction >= 0),
        assert(momentSwitcherFraction < double.infinity),
        assert(progressSegmentGap >= 0),
        assert(momentSwitcherFraction < double.infinity),
        assert(startAt >= 0),
        assert(startAt < momentCount),
        super(key: key);

  final Function(BuildContext context, int index, void Function() onLoadFinish)
      momentBuilder;
  final MomentDurationGetter momentDurationGetter;
  final ValueChanged<int>? switchToSlide;
  final int momentCount;
  final VoidCallback? onFlashForward;
  final VoidCallback? onFlashBack;
  final double momentSwitcherFraction;
  final ProgressSegmentBuilder progressSegmentBuilder;
  final double progressSegmentGap;
  final Duration progressOpacityDuration;
  final int startAt;
  final double? topOffset;
  final bool fullscreen;

  static Widget instagramProgressSegmentBuilder(
          BuildContext context, int index, double progress, double gap) =>
      Container(
        height: 2.0,
        margin: EdgeInsets.symmetric(horizontal: gap / 2),
        decoration: BoxDecoration(
          color: const Color(0x80ffffff),
          borderRadius: BorderRadius.circular(1.0),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            color: const Color(0xffffffff),
          ),
        ),
      );

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIdx;
  bool _isInFullscreenMode = false;

  void _switchToNextOrFinish() {
    _controller.stop();

    if (_currentIdx + 1 >= widget.momentCount &&
        widget.onFlashForward != null) {
      widget.onFlashForward!();
    } else if (_currentIdx + 1 < widget.momentCount) {
      _controller.reset();
      setState(() => _currentIdx += 1);
      _controller.duration = widget.momentDurationGetter(_currentIdx);
    } else if (_currentIdx == widget.momentCount - 1) {
      setState(() => _currentIdx = widget.momentCount);
    }

    widget.switchToSlide?.call(_currentIdx);
  }

  void _switchToPrevOrFinish() {
    _controller.stop();

    if (_currentIdx - 1 < 0 && widget.onFlashBack != null) {
      widget.onFlashBack!();
    } else {
      _controller.reset();
      if (_currentIdx - 1 >= 0) {
        setState(() => _currentIdx -= 1);
      }
      _controller.duration = widget.momentDurationGetter(_currentIdx);
    }

    widget.switchToSlide?.call(_currentIdx);
  }

  void _onTapDown(TapDownDetails details) => _controller.stop();

  void _onTapUp(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (details.localPosition.dx < width * widget.momentSwitcherFraction) {
      _switchToPrevOrFinish();
    } else {
      _switchToNextOrFinish();
    }
  }

  void _onLongPress() {
    _controller.stop();
    setState(() => _isInFullscreenMode = true);
  }

  void _onLongPressEnd() {
    setState(() => _isInFullscreenMode = false);
    _controller.forward();
  }

  Future<void> _hideStatusBar() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  Future<void> _showStatusBar() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);

  @override
  void initState() {
    if (widget.fullscreen) {
      _hideStatusBar();
    }

    _currentIdx = widget.startAt;

    _controller = AnimationController(
      vsync: this,
      duration: widget.momentDurationGetter(_currentIdx),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _switchToNextOrFinish();
        }
      });

    super.initState();
  }

  @override
  void didUpdateWidget(Story oldWidget) {
    if (widget.fullscreen != oldWidget.fullscreen) {
      if (widget.fullscreen) {
        _hideStatusBar();
      } else {
        _showStatusBar();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.fullscreen) {
      _showStatusBar();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.momentBuilder(
            context,
            _currentIdx < widget.momentCount
                ? _currentIdx
                : widget.momentCount - 1, () {
          if (_isInFullscreenMode) return;
          _controller.forward();
        }),
        Positioned(
          top: widget.topOffset ?? MediaQuery.of(context).padding.top + 10,
          left: 8.0 - widget.progressSegmentGap / 2,
          right: 8.0 - widget.progressSegmentGap / 2,
          child: AnimatedOpacity(
            opacity: _isInFullscreenMode ? 0.0 : 1.0,
            duration: widget.progressOpacityDuration,
            child: Row(
              children: <Widget>[
                ...List.generate(
                  widget.momentCount,
                  (idx) {
                    return Expanded(
                      child: idx == _currentIdx
                          ? AnimatedBuilder(
                              animation: _controller,
                              builder: (context, _) {
                                return widget.progressSegmentBuilder(
                                  context,
                                  idx,
                                  _controller.value,
                                  widget.progressSegmentGap,
                                );
                              },
                            )
                          : widget.progressSegmentBuilder(
                              context,
                              idx,
                              idx < _currentIdx ? 1.0 : 0.0,
                              widget.progressSegmentGap,
                            ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onLongPress: _onLongPress,
            onLongPressUp: _onLongPressEnd,
            onHorizontalDragEnd: (details) {
              // Свайп влево
              if (details.primaryVelocity! > 0) {
                widget.onFlashBack?.call();
              }
              // Свайп вправо
              if (details.primaryVelocity! < 0) {
                widget.onFlashForward?.call();
              }
            },
          ),
        ),
      ],
    );
  }
}
