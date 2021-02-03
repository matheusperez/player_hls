import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:helpers/helpers.dart';

import 'closed_caption_file.dart';
import 'player_hls_controller.dart';
import 'widgets/bar_progress_widget.dart';
import 'widgets/subtitle_widget.dart';

class PlayerHlsCore extends StatefulWidget {
  PlayerHlsCore({
    Key key,
    @required this.playKey,
    @required this.controller,
  });
  final GlobalKey playKey;

  final PlayerHlsController controller;

  @override
  PlayerHlsCoreState createState() => PlayerHlsCoreState();
}

class PlayerHlsCoreState extends State<PlayerHlsCore> {
  PlayerHlsController _controller;
  bool _showAMomentPlayAndPause = false;
  Timer _hidePlayAndPause;

  List<bool> _showAMomentRewindIcons = [false, false];
  int _transitions = 0;

  Size get size => MediaQuery.of(context).size;

  double _progressBarWidth = 0, _progressScale = 0, _iconPlayWidth = 0;
  bool _switchRemaingText = false;
  double _progressBarMargin = 0;

  @override
  void initState() {
    _controller = widget.controller;
    _transitions = 400;
    super.initState();
  }

  @override
  void dispose() async {
    _hidePlayAndPause?.cancel();
    super.dispose();
  }

  //--------------//
  //MISC FUNCTIONS//
  //--------------//
  void _onTapPlayAndPause() {
    final value = _controller.vlcPlayerController.value;
    setState(() {
      if (_controller.isPlaying)
        _controller.pause();
      else {
        if (value.position >= value.duration)
          _controller.vlcPlayerController.seekTo(Duration.zero);
        _controller.lastPosition = _controller.lastPosition - 1;
        _controller.play();
      }
      if (!_controller.showButtons) {
        _showAMomentPlayAndPause = true;
        _hidePlayAndPause?.cancel();
        _hidePlayAndPause = Misc.timer(600, () {
          setState(() => _showAMomentPlayAndPause = false);
        });
      } else if (_controller.isPlaying) _controller.changeShowButtons(false);
    });
  }

  void _showAndHideOverlay([bool show]) {
    var _showButtons = show ?? !_controller.showButtons;
    _controller.changeShowButtons(_showButtons);
    setState(() {
      if (_showButtons) _controller.isGoingToCloseBufferingWidget = false;
    });
  }

  //------------------//
  //FORWARD AND REWIND//
  //------------------//
  void _rewind() => _showRewindAndForward(0, -10);
  void _forward() => _showRewindAndForward(1, 10);

  void _vlcControllerSeekTo(int amount) async {
    int seconds = _controller.vlcPlayerController.value.position.inSeconds;
    await _controller.vlcPlayerController
        .seekTo(Duration(seconds: seconds + amount));
    await _controller.play();
  }

  void _showRewindAndForward(int index, int amount) async {
    _vlcControllerSeekTo(amount);
    setState(() {
      _showAMomentRewindIcons[index] = true;
    });
    Misc.delayed(600, () {
      setState(() {
        _showAMomentRewindIcons[index] = false;
      });
    });
  }

  //-----//
  //BUILD//
  //-----//
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      Orientation landscape = Orientation.landscape;
      double padding = 12;

      _progressBarMargin = orientation == landscape ? padding * 2 : padding;

      return _player(orientation);
    });
  }

  Widget _player(Orientation orientation) {
    return Observer(
      builder: (_) => Stack(
        children: [
          _fadeTransition(
            visible: true,
            child: VlcPlayer(
              controller: _controller.vlcPlayerController,
              aspectRatio: 16 / 9,
              placeholder: Center(child: CircularProgressIndicator()),
            ),
          ),
          // NOTE quando for iniciado
          if (_controller.isInitialized) ...{
            // NOTE legenda
            SubtitleWidget(_controller),

            // NOTE pega todo o evento da tela
            GestureDetector(
              onTap: _showAndHideOverlay,
              onScaleStart: null,
              onScaleUpdate: null,
              child: Container(color: Colors.transparent),
            ),
            _fadeTransition(
              visible: false,
              child: GestureDetector(onTap: () {
                Misc.delayed(
                  800,
                  () => setState(
                    () => _iconPlayWidth = GetKey(widget.playKey)?.width ?? 500,
                  ),
                );
                _controller.play();
              }

                  // setState(() {

                  //   _changeIconPlayWidth();
                  // }),
                  ),
            ),
            _rewindAndForward(),
            _fadeTransition(
              visible: true,
              child: _overlayButtons(),
            ),
            Center(
              child: _playAndPause(
                Container(
                  width: size?.width == null ? 500 : size.width * 0.2,
                  height: size?.height == null ? 40 : size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Observer(
              builder: (_) => _fadeTransition(
                visible: _controller.isBuffering,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            _rewindAndForwardIconsIndicator(),
          },
          // NOTE ?
        ],
      ),
    );
  }

  Widget _playAndPause(Widget child) {
    return GestureDetector(child: child, onTap: _onTapPlayAndPause);
  }

  //------------------//
  //TRANSITION WIDGETS//
  //------------------//
  Widget _fadeTransition({bool visible, Widget child}) {
    return OpacityTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: _transitions),
      visible: visible,
      child: child,
    );
  }

  Widget _swipeTransition(
      {bool visible, Widget child, SwipeDirection direction}) {
    return SwipeTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: _transitions),
      direction: direction,
      visible: visible,
      child: child,
    );
  }

  //------//
  //REWIND//
  //------//
  Widget _rewindAndForward() {
    return _rewindAndForwardLayout(
      rewind: GestureDetector(onDoubleTap: _rewind),
      forward: GestureDetector(onDoubleTap: _forward),
    );
  }

  Widget _rewindAndForwardLayout({Widget rewind, Widget forward}) {
    return Row(children: [
      Expanded(child: rewind),
      SizedBox(width: GetMedia(context).width / 2),
      Expanded(child: forward),
    ]);
  }

  Widget _rewindAndForwardIconsIndicator() {
    return _rewindAndForwardLayout(
      rewind: _fadeTransition(
        visible: _showAMomentRewindIcons[0],
        child: Center(child: Icon(Icons.fast_rewind, color: Colors.white)),
      ),
      forward: _fadeTransition(
        visible: _showAMomentRewindIcons[1],
        child: Center(child: Icon(Icons.fast_forward, color: Colors.white)),
      ),
    );
  }

  String _secondsFormatter(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final int hours = duration.inHours;
    final String formatter = [
      if (hours != 0) hours,
      duration.inMinutes,
      seconds
    ]
        .map((seg) => seg.abs().remainder(60).toString().padLeft(2, '0'))
        .join(':');
    return seconds < 0 ? "-$formatter" : formatter;
  }

  Widget _overlayButtons() {
    return Observer(
      builder: (_) => Stack(
        children: [
          _swipeTransition(
            direction: SwipeDirection.fromBottom,
            visible: _controller.showButtons,
            child: _bottomProgressBar(),
          ),
          _fadeTransition(
            visible: _controller.showButtons,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Platform.isAndroid
                          ? Icons.arrow_back
                          : Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientBackground({Widget child, bool onBottom = true}) {
    List<Color> colors = [
      Colors.transparent,
      Colors.white.withOpacity(0.2),
    ];
    return Container(
      //width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: onBottom ? colors : colors.reversed.toList(),
        ),
      ),
      child: child,
    );
  }

  //-------------------//
  //BOTTOM PROGRESS BAR//
  //-------------------//
  Widget _containerPadding({Widget child}) {
    return Container(
      color: Colors.transparent,
      padding: Margin.vertical(_progressBarMargin),
      child: child,
    );
  }

  Widget _textPositionProgress(String position) {
    double width = 60;
    double margin =
        (_progressScale * _progressBarWidth) + _iconPlayWidth - (width / 2);
    return Observer(
      builder: (_) => OpacityTransition(
        visible: _controller.isDraggingProgress,
        child: Container(
          width: width ?? 500,
          child: Text(
            position,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          margin: Margin.left(margin < 0 ? 0 : margin),
          padding: Margin.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _bottomProgressBar() {
    String position = "00:00", remaing = "-00:00";
    double padding = 12;

    if (_controller.vlcPlayerController.value.isInitialized) {
      final value = _controller.vlcPlayerController.value;
      final seconds = value.position.inSeconds;
      position = _secondsFormatter(seconds);
      remaing = _secondsFormatter(seconds - value.duration.inSeconds);
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //   Expanded(child: SizedBox()),
          Container(
            height: size.height * .805,
          ),
          _textPositionProgress(position),
          _gradientBackground(
            child: Row(
              children: [
                _playAndPause(
                  Container(
                    key: widget.playKey,
                    padding: Margin.symmetric(
                      horizontal: padding,
                      vertical: _progressBarMargin,
                    ),
                    child: Observer(
                      builder: (_) => !_controller.isPlaying
                          ? Icon(Icons.play_arrow, color: Colors.white)
                          : Icon(Icons.pause, color: Colors.white),
                    ),
                  ),
                ),
                Observer(
                  builder: (_) => BarProgressWidget(
                    _controller.vlcPlayerController,
                    padding: Margin.vertical(_progressBarMargin),
                    isBuffering: _controller.isBuffering,
                    changePosition: (double scale, double width) {
                      if (mounted) {
                        if (scale != null) {
                          _controller.changeIsDraggingProgress(true);
                          setState(() {
                            _progressScale = scale;
                            _progressBarWidth = width ?? 500;
                          });
                          _controller.cancelCloseOverlayButtons();
                        } else {
                          _controller.changeIsDraggingProgress(false);
                          _controller.startCloseOverlayButtons();
                        }
                      }
                    },
                  ),
                ),
                SizedBox(width: padding),
                Observer(
                  builder: (_) => CupertinoButton(
                    padding: EdgeInsets.all(5),
                    minSize: 25,
                    child: Text(
                      "CC",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(
                          _controller.statusSubtitle == StatusSubtitle.on
                              ? 1
                              : 0.4,
                        ),
                      ),
                    ),
                    onPressed: () => _controller.changeStatusSubtitle(
                      (_controller.statusSubtitle == StatusSubtitle.on)
                          ? StatusSubtitle.off
                          : StatusSubtitle.on,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _switchRemaingText = !_switchRemaingText);
                      _controller.cancelCloseOverlayButtons();
                    },
                    child: _containerPadding(
                      child: Text(
                        _switchRemaingText ? position : remaing,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: padding),
              ],
            ),
          ),
          //===
        ],
      ),
    );
  }
}
