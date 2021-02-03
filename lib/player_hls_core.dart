import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:helpers/helpers.dart';

import 'widgets/bar_progress_widget.dart';

class PlayerHlsCore extends StatefulWidget {
  PlayerHlsCore({
    Key key,
    @required this.controller,
    this.looping = true,
    this.defaultAspectRatio,
    this.onFullscreenFixLandscape,
    @required this.playKey,
  });
  final GlobalKey playKey;
  final bool looping;
  final double defaultAspectRatio;
  final bool onFullscreenFixLandscape;
  final VlcPlayerController controller;

  @override
  PlayerHlsCoreState createState() => PlayerHlsCoreState();
}

class PlayerHlsCoreState extends State<PlayerHlsCore> {
  VlcPlayerController _controller;
  bool _isInitialized = false,
      _isPlaying = false,
      _isBuffering = false,
      _showButtons = false,
      _showAMomentPlayAndPause = false,
      _isGoingToCloseBufferingWidget = false;
  Timer _closeOverlayButtons, _timerPosition, _hidePlayAndPause;

  List<bool> _showAMomentRewindIcons = [false, false];
  int _lastPosition = 0, _transitions = 0;

  Size get size => MediaQuery.of(context).size;

  //TEXT POSITION ON DRAGGING
  // NOTE Key
  //final GlobalKey _playKey = GlobalKey();
  double _progressBarWidth = 0, _progressScale = 0, _iconPlayWidth = 0;
  bool _isDraggingProgress = false, _switchRemaingText = false;
  double _progressBarMargin = 0;

  @override
  void initState() {
    _controller = widget.controller;
    _transitions = 400;

    _controller.addListener(_videoListener);
    //_controller.setLooping(widget.looping);

    super.initState();
  }

  @override
  void dispose() {
    _timerPosition?.cancel();
    _hidePlayAndPause?.cancel();
    _closeOverlayButtons?.cancel();
    _controller?.removeListener(_videoListener);
    super.dispose();
  }

  //----------------//
  //VIDEO CONTROLLER//
  //----------------//
  void _videoListener() {
    if (_controller.value.isInitialized && !_isInitialized) {
      _isInitialized = true;
    }
    if (mounted && _controller.value.isInitialized) {
      final value = _controller.value;
      final playing = value.isPlaying;

      if (playing != _isPlaying) _isPlaying = playing;
      if (_isPlaying && _isDraggingProgress) _isDraggingProgress = false;
      if (_showButtons) {
        if (_isPlaying) {
          if (value.position >= value.duration && !widget.looping) {
            _controller.seekTo(Duration.zero);
          } else {
            if (_timerPosition == null) _createBufferTimer();
            if (_closeOverlayButtons == null && !_isDraggingProgress)
              _startCloseOverlayButtons();
          }
        } else if (_isGoingToCloseBufferingWidget) _cancelCloseOverlayButtons();
      }
      setState(() {});
    }
  }

  //-----//
  //TIMER//
  //-----//
  void _startCloseOverlayButtons() {
    if (!_isGoingToCloseBufferingWidget && mounted) {
      setState(() {
        _isGoingToCloseBufferingWidget = true;
        _closeOverlayButtons = Misc.timer(3200, () {
          if (mounted && _isPlaying) {
            setState(() => _showButtons = false);
            _cancelCloseOverlayButtons();
          }
        });
      });
    }
  }

  void _createBufferTimer() {
    if (mounted)
      setState(() {
        _timerPosition = Misc.periodic(1000, () {
          int position = _controller.value.position.inMilliseconds;
          if (mounted)
            setState(() {
              if (_isPlaying)
                _isBuffering = _lastPosition != position ? false : true;
              else
                _isBuffering = false;
              _lastPosition = position;
            });
        });
      });
  }

  void _cancelCloseOverlayButtons() {
    setState(() {
      _isGoingToCloseBufferingWidget = false;
      _closeOverlayButtons?.cancel();
      _closeOverlayButtons = null;
    });
  }

  //--------------//
  //MISC FUNCTIONS//
  //--------------//
  void _onTapPlayAndPause() {
    final value = _controller.value;
    setState(() {
      if (_isPlaying)
        _controller.pause();
      else {
        if (value.position >= value.duration) _controller.seekTo(Duration.zero);
        _lastPosition = _lastPosition - 1;
        _controller.play();
      }
      if (!_showButtons) {
        _showAMomentPlayAndPause = true;
        _hidePlayAndPause?.cancel();
        _hidePlayAndPause = Misc.timer(600, () {
          setState(() => _showAMomentPlayAndPause = false);
        });
      } else if (_isPlaying) _showButtons = false;
    });
  }

  void _changeIconPlayWidth() {
    Misc.delayed(
      800,
      () => setState(
        () => _iconPlayWidth = GetKey(widget.playKey)?.width ?? 500,
      ),
    );
  }

  void _showAndHideOverlay([bool show]) {
    setState(() {
      _showButtons = show ?? !_showButtons;
      if (_showButtons) _isGoingToCloseBufferingWidget = false;
    });
  }

  //------------------//
  //FORWARD AND REWIND//
  //------------------//
  void _rewind() => _showRewindAndForward(0, -10);
  void _forward() => _showRewindAndForward(1, 10);

  void _controllerSeekTo(int amount) async {
    int seconds = _controller.value.position.inSeconds;
    await _controller.seekTo(Duration(seconds: seconds + amount));
    await _controller.play();
  }

  void _showRewindAndForward(int index, int amount) async {
    _controllerSeekTo(amount);
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
    final Size size = GetMedia(context).size;
    return Stack(
      children: [
        _fadeTransition(
          visible: true,
          child: VlcPlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
            placeholder: Center(child: CircularProgressIndicator()),
          ),
        ),
        // NOTE quando for iniciado
        if (_isInitialized) ...{
          // NOTE pega todo o evento da tela
          GestureDetector(
            onTap: _showAndHideOverlay,
            onScaleStart: null,
            onScaleUpdate: null,
            child: Container(color: Colors.transparent),
          ),
          _fadeTransition(
            visible: false,
            child: GestureDetector(
              onTap: () => setState(() {
                _controller.play();
                _changeIconPlayWidth();
              }),
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
          _fadeTransition(
            visible: _isBuffering,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          _fadeTransition(
            visible: _showAMomentPlayAndPause ||
                _controller.value.position >= _controller.value.duration,
            child: _playAndPauseIconButtons(),
          ),
          _rewindAndForwardIconsIndicator(),
        },
        // NOTE ?
      ],
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

  //---------------//
  //OVERLAY BUTTONS//
  //---------------//
  Widget _playAndPauseIconButtons() {
    return Center(
      child: _playAndPause(
        !_isPlaying
            ? Icon(Icons.play_arrow, color: Colors.white)
            : Icon(Icons.pause, color: Colors.white),
      ),
    );
  }

  Widget _overlayButtons() {
    return Stack(children: [
      _swipeTransition(
        direction: SwipeDirection.fromBottom,
        visible: _showButtons,
        child: _bottomProgressBar(),
      ),
      _fadeTransition(
        visible: _showButtons && !_isPlaying,
        child: _playAndPauseIconButtons(),
      ),
      _fadeTransition(
        visible: _showButtons,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
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
    return OpacityTransition(
      visible: _isDraggingProgress,
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
    );
  }

  Widget _bottomProgressBar() {
    String position = "00:00", remaing = "-00:00";
    double padding = 12;

    if (_controller.value.isInitialized) {
      final value = _controller.value;
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
                    child: !_isPlaying
                        ? Icon(Icons.play_arrow, color: Colors.white)
                        : Icon(Icons.pause, color: Colors.white),
                  ),
                ),
                BarProgressWidget(
                  _controller,
                  padding: Margin.vertical(_progressBarMargin),
                  isBuffering: _isBuffering,
                  changePosition: (double scale, double width) {
                    if (mounted) {
                      if (scale != null) {
                        setState(() {
                          _isDraggingProgress = true;
                          _progressScale = scale;
                          _progressBarWidth = width ?? 500;
                        });
                        _cancelCloseOverlayButtons();
                      } else {
                        setState(() => _isDraggingProgress = false);
                        _startCloseOverlayButtons();
                      }
                    }
                  },
                ),
                SizedBox(width: padding),
                Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _switchRemaingText = !_switchRemaingText);
                      _cancelCloseOverlayButtons();
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
