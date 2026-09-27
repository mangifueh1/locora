import 'package:flutter/material.dart';

class EndpointMethodBadge extends StatelessWidget {
  const EndpointMethodBadge({required this.method, super.key});

  final String method;

  @override
  Widget build(BuildContext context) {
    final color = switch (method) {
      'GET' => const Color(0xFF20765B),
      'POST' => const Color(0xFF2465A6),
      'DELETE' => const Color(0xFFB34D42),
      _ => const Color(0xFF745A9E),
    };
    return Container(
      constraints: const BoxConstraints(minWidth: 54),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
