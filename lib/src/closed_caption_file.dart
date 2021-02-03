class Caption {
  const Caption({this.number, this.start, this.end, this.text});

  final int number;

  final Duration start;

  final Duration end;

  final String text;

  static const Caption none = Caption(
    number: 0,
    start: Duration.zero,
    end: Duration.zero,
    text: '',
  );

  @override
  String toString() => '$runtimeType('
      'number: $number, '
      'start: $start, '
      'end: $end, '
      'text: $text)';
}
