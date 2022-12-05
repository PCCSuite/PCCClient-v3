import 'package:flutter/material.dart';
import 'package:pccclient/utils/general.dart';
import 'package:pccclient/utils/get_uri.dart';
import 'package:pccclient/utils/local_config.dart';
import 'package:pccclient/utils/server_info.dart';

TipsBar? _tips;

TipsBar getTipsBar() {
  _tips ??= const TipsBar._();
  return _tips!;
}

class TipsBar extends StatefulWidget {
  const TipsBar._({Key? key}) : super(key: key);

  @override
  State<TipsBar> createState() => _TipsBarState();
}

class _TipsBarState extends State<TipsBar> {
  String text = str.tips_unloaded;

  @override
  void initState() {
    refreshTips();
    super.initState();
  }

  Future<void> refreshTips() async {
    String got = await getStringFromURIString(serverInfo.tipsURL);
    setState(() {
      text = got;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> splitText = text.split("\n");
    String showText = splitText[0];
    if (splitText.length > 2) {
      showText += "...";
    }
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(str.tips_dialog_title),
                  content: SelectableText(text),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Theme.of(context).hoverColor,
              child: Row(
                children: [
                  const Text(
                    "Tips: ",
                    textScaleFactor: 1.2,
                  ),
                  Expanded(
                    child: Text(
                      showText,
                      textScaleFactor: 1.5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            refreshTips();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
