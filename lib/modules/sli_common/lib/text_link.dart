import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sli_common/extension/extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TextLink extends StatefulWidget {
  final String str;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final Function(String)? onTapLink;

  const TextLink(this.str, {Key? key, this.style, this.linkStyle, this.onTapLink})
      : super(key: key);

  @override
  State<TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<TextLink> {
  List<int> arr = [];

  @override
  void initState() {
    super.initState();
    arr.add(0);
    List<RegExpMatch> arrMatch = widget.str.getAllUrlPosition;
    if (arrMatch.isNotEmpty && arrMatch[0].start != 0) {
      arr.add(0);
    }
    for (RegExpMatch match in arrMatch) {
      arr.addAll([match.start, match.end]);
    }
  }

  TextStyle? _getStyleText(int index) {
    if ((arr.length.isOdd && index.isOdd) || (arr.length.isEven && index.isEven)) {
      return widget.linkStyle ??
          TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFFF35A49));
    } else {
      return widget.style ?? TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF888888));
    }
  }

  List<TextSpan> _buildTextSpan() {
    List<TextSpan> arrTP = [];
    if (arr.length > 2) {
      for (int i = 0; i < arr.length - 1; i++) {
        TextSpan tp = TextSpan(
            text: widget.str.substring(arr[i], arr[i + 1]),
            style: _getStyleText(i),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                String url = widget.str.substring(arr[i], arr[i + 1]);
                if (widget.onTapLink != null) {
                  widget.onTapLink!(url);
                } else {
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url);
                  }
                }
              });
        arrTP.add(tp);
      }
      return arrTP;
    }
    return [
      TextSpan(text: widget.str, style: widget.style),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: _buildTextSpan()));
  }
}
