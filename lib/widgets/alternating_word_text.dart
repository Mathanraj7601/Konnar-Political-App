import "package:flutter/material.dart";

class AlternatingWordText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color firstColor;
  final Color secondColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AlternatingWordText({
    super.key,
    required this.text,
    this.style,
    required this.firstColor,
    required this.secondColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.trim().split(RegExp(r"\s+"));
    if (words.isEmpty || (words.length == 1 && words.first.isEmpty)) {
      return const SizedBox.shrink();
    }

    final spans = <TextSpan>[];
    for (var i = 0; i < words.length; i++) {
      final color = i.isEven ? firstColor : secondColor;
      spans.add(TextSpan(text: words[i], style: style?.copyWith(color: color)));
      if (i != words.length - 1) {
        spans.add(TextSpan(text: " ", style: style));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
