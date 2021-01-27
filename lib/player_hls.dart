library video_viewer;

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'player_hls_core.dart';

class PlayerHls extends StatefulWidget {
  PlayerHls({
    Key key,
    @required this.source,
    this.looping = false,
    this.autoPlay = true,
    this.defaultAspectRatio = 16 / 9,
  });

  final VlcPlayerController source;
  final bool autoPlay;
  final bool looping;
  final double defaultAspectRatio;

  @override
  PlayerHlsState createState() => PlayerHlsState();
}

class PlayerHlsState extends State<PlayerHls> {
  VlcPlayerController _controller;

  @override
  void initState() {
    _controller = widget.source;
    super.initState();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void disposeController() async {
    await _controller?.pause();
    await _controller.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return PlayerHlsCore(
      looping: widget.looping,
      controller: _controller,
      defaultAspectRatio: widget.defaultAspectRatio,
    );
  }
}
