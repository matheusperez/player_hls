import 'dart:convert';

import 'closed_caption_file.dart';

List<Caption> parseCaptionsFromSubRipString(String file) {
  final List<Caption> captions = <Caption>[];
  for (List<String> captionLines in _readSubRipFile(file)) {
    if (captionLines.length < 3) break;

    final int captionNumber = int.parse(captionLines[0]);
    final _StartAndEnd startAndEnd =
        _StartAndEnd.fromSubRipString(captionLines[1]);

    final String text = captionLines.sublist(2).join('\n');

    final Caption newCaption = Caption(
      number: captionNumber,
      start: startAndEnd.start,
      end: startAndEnd.end,
      text: text,
    );
    if (newCaption.start != newCaption.end) {
      captions.add(newCaption);
    }
  }

  return captions;
}

class _StartAndEnd {
  final Duration start;
  final Duration end;

  _StartAndEnd(this.start, this.end);

  static _StartAndEnd fromSubRipString(String line) {
    final RegExp format =
        RegExp(_subRipTimeStamp + _subRipArrow + _subRipTimeStamp);

    if (!format.hasMatch(line)) {
      return _StartAndEnd(Duration.zero, Duration.zero);
    }

    final List<String> times = line.split(_subRipArrow);

    final Duration start = _parseSubRipTimestamp(times[0]);
    final Duration end = _parseSubRipTimestamp(times[1]);

    return _StartAndEnd(start, end);
  }
}

Duration _parseSubRipTimestamp(String timestampString) {
  if (!RegExp(_subRipTimeStamp).hasMatch(timestampString)) {
    return Duration.zero;
  }

  final List<String> commaSections = (timestampString.contains('.')
      ? timestampString.split('.')
      : timestampString.split(','));
  final List<String> hoursMinutesSeconds = commaSections[0].split(':');

  final int hours = int.parse(hoursMinutesSeconds[0]);
  final int minutes = int.parse(hoursMinutesSeconds[1]);
  final int seconds = int.parse(hoursMinutesSeconds[2]);
  final int milliseconds = int.parse(commaSections[1]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

List<List<String>> _readSubRipFile(String file) {
  final List<String> lines = LineSplitter.split(file).toList();

  final List<List<String>> captionStrings = <List<String>>[];
  List<String> currentCaption = <String>[];
  int lineIndex = 0;
  for (final String line in lines) {
    final bool isLineBlank = line.trim().isEmpty;
    if (!isLineBlank) {
      currentCaption.add(line);
    }

    if (isLineBlank || lineIndex == lines.length - 1) {
      captionStrings.add(currentCaption);
      currentCaption = <String>[];
    }

    lineIndex += 1;
  }

  return captionStrings;
}

const String _subRipTimeStamp = r'\d\d:\d\d:\d\d(\.|,)\d\d\d';
const String _subRipArrow = r' --> ';
