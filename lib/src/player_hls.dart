import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:player_hls/src/closed_caption_file.dart';
import 'package:player_hls/src/player_hls_controller.dart';

import 'player_hls_core.dart';

class PlayerHls extends StatefulWidget {
  PlayerHls({
    Key key,
    @required this.source,
    @required this.playKey,
    this.captions,
  });
  final GlobalKey playKey;
  final VlcPlayerController source;
  final List<Caption> captions;

  @override
  PlayerHlsState createState() => PlayerHlsState();
}

class PlayerHlsState extends State<PlayerHls> {
  PlayerHlsController _controller;
  @override
  void initState() {
    _controller = PlayerHlsController(
      widget.source,
      subtitles: widget.captions,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerHlsCore(
      controller: _controller,
      playKey: widget.playKey,
    );
  }
}
