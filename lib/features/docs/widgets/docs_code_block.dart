import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocsCodeBlock extends StatelessWidget {
  const DocsCodeBlock({required this.title, required this.code, super.key});

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF202A28),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFCFD8D4),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy example',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.content_copy,
                    size: 15,
                    color: Color(0xFFAFBBB5),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF35413D)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.55,
                color: Color(0xFFDCE6E1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
