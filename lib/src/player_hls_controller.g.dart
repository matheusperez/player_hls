// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_hls_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PlayerHlsController on _PlayerHlsControllerBase, Store {
  final _$isBufferingAtom = Atom(name: '_PlayerHlsControllerBase.isBuffering');

  @override
  bool get isBuffering {
    _$isBufferingAtom.reportRead();
    return super.isBuffering;
  }

  @override
  set isBuffering(bool value) {
    _$isBufferingAtom.reportWrite(value, super.isBuffering, () {
      super.isBuffering = value;
    });
  }

  final _$showButtonsAtom = Atom(name: '_PlayerHlsControllerBase.showButtons');

  @override
  bool get showButtons {
    _$showButtonsAtom.reportRead();
    return super.showButtons;
  }

  @override
  set showButtons(bool value) {
    _$showButtonsAtom.reportWrite(value, super.showButtons, () {
      super.showButtons = value;
    });
  }

  final _$isDraggingProgressAtom =
      Atom(name: '_PlayerHlsControllerBase.isDraggingProgress');

  @override
  bool get isDraggingProgress {
    _$isDraggingProgressAtom.reportRead();
    return super.isDraggingProgress;
  }

  @override
  set isDraggingProgress(bool value) {
    _$isDraggingProgressAtom.reportWrite(value, super.isDraggingProgress, () {
      super.isDraggingProgress = value;
    });
  }

  final _$isPlayingAtom = Atom(name: '_PlayerHlsControllerBase.isPlaying');

  @override
  bool get isPlaying {
    _$isPlayingAtom.reportRead();
    return super.isPlaying;
  }

  @override
  set isPlaying(bool value) {
    _$isPlayingAtom.reportWrite(value, super.isPlaying, () {
      super.isPlaying = value;
    });
  }

  final _$isInitializedAtom =
      Atom(name: '_PlayerHlsControllerBase.isInitialized');

  @override
  bool get isInitialized {
    _$isInitializedAtom.reportRead();
    return super.isInitialized;
  }

  @override
  set isInitialized(bool value) {
    _$isInitializedAtom.reportWrite(value, super.isInitialized, () {
      super.isInitialized = value;
    });
  }

  final _$textSubtitleAtom =
      Atom(name: '_PlayerHlsControllerBase.textSubtitle');

  @override
  String get textSubtitle {
    _$textSubtitleAtom.reportRead();
    return super.textSubtitle;
  }

  @override
  set textSubtitle(String value) {
    _$textSubtitleAtom.reportWrite(value, super.textSubtitle, () {
      super.textSubtitle = value;
    });
  }

  final _$statusSubtitleAtom =
      Atom(name: '_PlayerHlsControllerBase.statusSubtitle');

  @override
  StatusSubtitle get statusSubtitle {
    _$statusSubtitleAtom.reportRead();
    return super.statusSubtitle;
  }

  @override
  set statusSubtitle(StatusSubtitle value) {
    _$statusSubtitleAtom.reportWrite(value, super.statusSubtitle, () {
      super.statusSubtitle = value;
    });
  }

  final _$_PlayerHlsControllerBaseActionController =
      ActionController(name: '_PlayerHlsControllerBase');

  @override
  dynamic changeIsBuffering(bool value) {
    final _$actionInfo = _$_PlayerHlsControllerBaseActionController.startAction(
        name: '_PlayerHlsControllerBase.changeIsBuffering');
    try {
      return super.changeIsBuffering(value);
    } finally {
      _$_PlayerHlsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeShowButtons(bool value) {
    final _$actionInfo = _$_PlayerHlsControllerBaseActionController.startAction(
        name: '_PlayerHlsControllerBase.changeShowButtons');
    try {
      return super.changeShowButtons(value);
    } finally {
      _$_PlayerHlsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeIsDraggingProgress(bool value) {
    final _$actionInfo = _$_PlayerHlsControllerBaseActionController.startAction(
        name: '_PlayerHlsControllerBase.changeIsDraggingProgress');
    try {
      return super.changeIsDraggingProgress(value);
    } finally {
      _$_PlayerHlsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeIsPlaying(bool value) {
    final _$actionInfo = _$_PlayerHlsControllerBaseActionController.startAction(
        name: '_PlayerHlsControllerBase.changeIsPlaying');
    try {
      return super.changeIsPlaying(value);
    } finally {
      _$_PlayerHlsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeInitialized(bool value) {
    final _$actionInfo = _$_PlayerHlsControllerBaseActionController.startAction(
        name: '_PlayerHlsControllerBase.changeInitialized');
    try {
      return super.changeInitialized(value);
    } finally {
      _$_PlayerHlsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeTextSubtitle(String value) {
    final _$actionInfo = _$_PlayerHlsControllerBaseActionController.startAction(
        name: '_PlayerHlsControllerBase.changeTextSubtitle');
    try {
      return super.changeTextSubtitle(value);
    } finally {
      _$_PlayerHlsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic changeStatusSubtitle(StatusSubtitle value) {
    final _$actionInfo = _$_PlayerHlsControllerBaseActionController.startAction(
        name: '_PlayerHlsControllerBase.changeStatusSubtitle');
    try {
      return super.changeStatusSubtitle(value);
    } finally {
      _$_PlayerHlsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isBuffering: ${isBuffering},
showButtons: ${showButtons},
isDraggingProgress: ${isDraggingProgress},
isPlaying: ${isPlaying},
isInitialized: ${isInitialized},
textSubtitle: ${textSubtitle},
statusSubtitle: ${statusSubtitle}
    ''';
  }
}
