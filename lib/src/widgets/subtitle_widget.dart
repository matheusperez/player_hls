import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:player_hls/src/player_hls_controller.dart';

class SubtitleWidget extends StatelessWidget {
  final PlayerHlsController _controller;

  const SubtitleWidget(this._controller);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => (_controller.statusSubtitle == StatusSubtitle.on)
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black,
                margin: EdgeInsets.only(bottom: 50),
                padding: EdgeInsets.all(2),
                child: Observer(
                  builder: (_) => Text(
                    _controller.textSubtitle ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
