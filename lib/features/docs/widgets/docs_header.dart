import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/api_reference_data.dart';

class DocsHeader extends StatelessWidget {
  const DocsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          const Text(
            'API reference',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4F5D58),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EC),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 7, color: Color(0xFF318260)),
                SizedBox(width: 7),
                Text(
                  'API v1',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF32664D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          if (MediaQuery.sizeOf(context).width > 560)
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(text: ApiReferenceData.baseUrl),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Base URL copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.content_copy, size: 14),
              label: const Text('Copy base URL'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF38685B),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
