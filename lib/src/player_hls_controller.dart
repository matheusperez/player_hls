import 'dart:async';

import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:helpers/helpers.dart';
import 'package:mobx/mobx.dart';

import '../player_hls.dart';

part 'player_hls_controller.g.dart';

class PlayerHlsController = _PlayerHlsControllerBase with _$PlayerHlsController;

abstract class _PlayerHlsControllerBase with Store {
  final VlcPlayerController vlcPlayerController;
  final bool looping;
  final List<Caption> subtitles;
  _PlayerHlsControllerBase(
    this.vlcPlayerController, {
    StatusSubtitle statusSubtitle = StatusSubtitle.off,
    this.looping = false,
    this.subtitles = const [],
  }) {
    changeStatusSubtitle(statusSubtitle);

    vlcPlayerController.addListener(_videoListener);
  }

  // NOTE variaveis
  int lastPosition = 0;
  bool isGoingToCloseBufferingWidget = false;
  Timer closeOverlayButtons;
  Timer timerPosition;
  // NOTE acoes do vlc Player
  void _videoListener() async {
    if (vlcPlayerController.value.isInitialized && !isInitialized) {
      changeInitialized(true);
    }

    if (vlcPlayerController.value.isInitialized) {
      final value = vlcPlayerController.value;

      if (value.isPlaying != isPlaying) changeIsPlaying(value.isPlaying);
      if (isPlaying && isDraggingProgress) changeIsDraggingProgress(false);
      if (showButtons) {
        if (isPlaying) {
          if (value.position >= value.duration && looping) {
            vlcPlayerController.seekTo(Duration.zero);
          } else {
            if (timerPosition == null) {
              _createBufferTimer();
            }
            if (closeOverlayButtons == null && !isDraggingProgress) {
              startCloseOverlayButtons();
            }
          }
        } else if (isGoingToCloseBufferingWidget) cancelCloseOverlayButtons();
      }
      // NOTE logica da legenda
      if (statusSubtitle == StatusSubtitle.on) {
        await _mountSubtitle();
      }
    }
  }

  void _createBufferTimer() {
    timerPosition = Misc.periodic(1000, () {
      int position = vlcPlayerController.value.position.inMilliseconds;

      if (isPlaying) {
        changeIsBuffering(lastPosition != position ? false : true);
      } else {
        changeIsBuffering(false);
        lastPosition = position;
      }
    });
  }

  Future _mountSubtitle() async {
    if (subtitles != null && subtitles.length != 0) {
      var position = vlcPlayerController.value.position;
      var where = subtitles
          .where(
            (caption) => (caption.start <= position && caption.end >= position),
          )
          .toList();

      if (where.length != 0) {
        var caption = where.first;
        // NOTE delay da legenda
        await Future.delayed(Duration(seconds: 2));
        changeTextSubtitle(caption.text);
      }
    }
  }

  //-----//
  //TIMER//
  //-----//
  void startCloseOverlayButtons() {
    if (!isGoingToCloseBufferingWidget) {
      isGoingToCloseBufferingWidget = true;
      closeOverlayButtons = Misc.timer(3200, () {
        if (isPlaying) {
          changeShowButtons(false);
          cancelCloseOverlayButtons();
        }
      });
    }
  }

  void cancelCloseOverlayButtons() {
    isGoingToCloseBufferingWidget = false;

    closeOverlayButtons?.cancel();
    closeOverlayButtons = null;
  }

  play() => vlcPlayerController.play();
  pause() => vlcPlayerController.pause();

  @observable
  bool isBuffering = false;

  @action
  changeIsBuffering(bool value) => isBuffering = value;

  @observable
  bool showButtons = false;

  @action
  changeShowButtons(bool value) => showButtons = value;

  @observable
  bool isDraggingProgress = false;

  @action
  changeIsDraggingProgress(bool value) => isDraggingProgress = value;

  @observable
  bool isPlaying = false;

  @action
  changeIsPlaying(bool value) => isPlaying = value;

  @observable
  bool isInitialized = false;

  @action
  changeInitialized(bool value) => isInitialized = value;

  @observable
  String textSubtitle;

  @action
  changeTextSubtitle(String value) => textSubtitle = value;

  @observable
  StatusSubtitle statusSubtitle = StatusSubtitle.off;

  @action
  changeStatusSubtitle(StatusSubtitle value) => statusSubtitle = value;

  dispose() async {
    await vlcPlayerController?.pause();
    vlcPlayerController?.removeListener(_videoListener);
    vlcPlayerController?.dispose();

    timerPosition?.cancel();
    closeOverlayButtons?.cancel();

    timerPosition = null;
    closeOverlayButtons = null;
  }
}

enum StatusSubtitle { on, off }
