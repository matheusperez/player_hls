import 'dart:developer';

import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

class BarProgressWidget extends StatefulWidget {
  BarProgressWidget(
    this.controller, {
    Key key,
    this.padding,
    this.isBuffering = false,
    this.changePosition,
  });

  final bool isBuffering;
  final EdgeInsetsGeometry padding;
  final VlcPlayerController controller;
  final void Function(double, double) changePosition;

  @override
  _BarProgressWidgetState createState() => _BarProgressWidgetState();
}

class _BarProgressWidgetState extends State<BarProgressWidget> {
  int maxBuffering = 0, duration = 0, position = 0;
  VlcPlayerController controller;
  Duration seekToPosition;
  int animationMS = 500;
  bool isDragging = false;
  double height = 5;

  @override
  void initState() {
    controller = widget.controller;

    controller.addListener(progressListener);

    if (controller.value.isInitialized) {
      duration = controller.value.duration.inMilliseconds;
    }

    //progressListener();
    Misc.onLayoutRendered(() {
      if (controller.value.isPlaying && !widget.isBuffering)
        setState(() {
          position = controller.value.position.inMilliseconds + 500;
        });
    });
    super.initState();
  }

  // @override
  // void didUpdateWidget(BarProgressWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.controller.hashCode != controller.hashCode) {
  //     setState(() {
  //       controller = widget.controller;
  //       if (controller.value.isInitialized)
  //         duration = controller.value.duration.inMilliseconds;
  //     });
  //     controller.addListener(progressListener);
  //     progressListener();
  //   }
  // }

  @override
  void dispose() {
    controller.removeListener(progressListener);
    super.dispose();
  }

  void play() {
    if (!controller.value.isPlaying) controller.play();
  }

  void pause() {
    if (controller.value.isPlaying) controller.pause();
  }

  void changePosition(double scale, double width) {
    if (widget.changePosition != null) widget.changePosition(scale, width);
  }

  void startDragging() {
    setState(() {
      isDragging = true;
      animationMS = 0;
    });
  }

  void progressListener() {
    if (mounted && controller.value.isInitialized) {
      setState(() {
        if (controller.value.isPlaying && animationMS != 500) {
          animationMS = 500;
        }
        if (isDragging) {
          animationMS = 0;
        }
        maxBuffering = 0;
        position = controller.value.position.inMilliseconds;

        // TODO ???
        // for (DurationRange range in controller.value.buffered) {
        //   final int end = range.end.inMilliseconds;
        //   if (end > maxBuffering) maxBuffering = end;
        // }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      double width = constraints.maxWidth;

      return _detectTap(
        width: width,
        child: Container(
          width: width,
          color: Colors.transparent,
          padding: widget.padding,
          alignment: Alignment.centerLeft,
          child: controller.value.isInitialized
              ? Stack(alignment: AlignmentDirectional.centerStart, children: [
                  _progressBar(width),
                  _progressBar((maxBuffering / duration) * width),
                  _progressBar((position / duration) * width),
                  _dotisDragging(width),
                  _dotIdentifier(width),
                ])
              : _progressBar(width),
        ),
      );
    });
  }

  Widget _dotIdentifier(double maxWidth) => _dot(maxWidth);
  Widget _dotisDragging(double maxWidth) {
    final double widthPos = (position / duration) * maxWidth;
    final double widthDot = height * 2;
    return BooleanTween(
      animate: isDragging &&
          (widthPos > widthDot) &&
          (widthPos < maxWidth - widthDot),
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (value) => _dot(maxWidth, value, 2),
    );
  }

  Widget _dot(double maxWidth, [double opacity = 1, int multiplicator = 1]) {
    final double widthPos = (position / duration) * maxWidth;
    final double widthDot = height * 2;
    final double width =
        widthPos < height ? widthDot : widthPos + height * multiplicator;

    return AnimatedContainer(
      width: width,
      duration: Duration(milliseconds: animationMS),
      alignment: Alignment.centerRight,
      child: Container(
        height: height * 2 * multiplicator,
        width: height * 2 * multiplicator,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _progressBar(double width) {
    return AnimatedContainer(
      width: width,
      height: height,
      duration: Duration(milliseconds: animationMS),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _detectTap({Widget child, double width}) {
    void seekToRelativePosition(Offset local, [bool showText = false]) async {
      final double localPos = local.dx / width;
      final Duration position = controller.value.duration * localPos;
      await controller.seekTo(position);
      if (showText && local.dx > 0 && local.dx < width)
        changePosition(localPos, width);
    }

    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        startDragging();
        pause();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.localPosition, true);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        changePosition(null, width);
        setState(() => isDragging = false);
        Misc.delayed(50, () => play());
      },
      onTapDown: (TapDownDetails details) {
        startDragging();
        changePosition(null, width);
        seekToRelativePosition(details.localPosition);
        pause();
      },
      onTapUp: (TapUpDetails details) {
        changePosition(null, width);
        setState(() => isDragging = false);
        seekToRelativePosition(details.localPosition);
        Misc.delayed(50, () => play());
      },
    );
  }
}
