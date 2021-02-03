import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:helpers/helpers.dart';

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
  int duration = 0, position = 0;
  VlcPlayerController controller;
  Duration seekToPosition;
  int animationMS = 500;
  bool isDragging = false;
  double height = 5;

  Size get size => MediaQuery.of(context).size;

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
        position = controller.value.position.inMilliseconds;

        if (duration == 0) {
          duration = controller.value.duration.inMilliseconds;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = size.width * .8;
    return _detectTap(
      width: width,
      child: Container(
        height: 30,
        width: width,
        child: controller.value.isInitialized
            ? Container(
                width: width,
                height: 50,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    _progressBar(width),
                    _progressBar((0 / duration) * width),
                    _progressBar((position / duration) * width),
                    _dotisDragging(width),
                    _dotIdentifier(width),
                  ],
                ),
              )
            : _progressBar(width),
      ),
    );
  }

  Widget _dotIdentifier(double maxWidth) => _dot(maxWidth);
  Widget _dotisDragging(double maxWidth) {
    // NOTE log
    // print('==== LOGX 5 $position');
    // print('==== LOGX 6 $duration');
    // print('==== LOGX 7 $maxWidth');

    double widthPos = (position / duration) * maxWidth;

    widthPos = (widthPos.isInfinite || widthPos.isNaN) ? 0 : widthPos;

    final double widthDot = height * 2;
    // NOTE log
    // print('==== LOGX 3 $widthPos');
    // print('==== LOGX 4 $widthDot');
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
      width: (width.isInfinite || width.isNaN) ? 0 : width,
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
    // NOTE log
    //print('==== LOGX 1 $width');
    return AnimatedContainer(
      width: (width.isInfinite || width.isNaN) ? 0 : width,
      height: height,
      duration: Duration(milliseconds: animationMS),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _detectTap({Widget child, double width}) {
    // NOTE log
    //print('==== LOGX 10 $width');
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
