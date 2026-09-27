import 'package:flutter/material.dart';

import '../models/api_endpoint.dart';
import 'endpoint_method_badge.dart';

class EndpointListPanel extends StatelessWidget {
  const EndpointListPanel({
    required this.endpoints,
    required this.selected,
    required this.onSelected,
    required this.searchController,
    required this.onSearchChanged,
    super.key,
  });

  final List<ApiEndpoint> endpoints;
  final ApiEndpoint? selected;
  final ValueChanged<ApiEndpoint> onSelected;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search endpoints',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF87908E)),
            prefixIcon: const Icon(Icons.search, size: 18),
            prefixIconColor: const Color(0xFF737C7B),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF4F6F4),
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 17),
        Text(
          '${endpoints.length} ENDPOINT${endpoints.length == 1 ? '' : 'S'}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF828A88),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: endpoints.isEmpty
              ? const Center(
                  child: Text(
                    'No matching endpoints',
                    style: TextStyle(fontSize: 13, color: Color(0xFF737C7B)),
                  ),
                )
              : ListView.separated(
                  itemCount: endpoints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    final endpoint = endpoints[index];
                    final active = endpoint == selected;
                    return InkWell(
                      onTap: () => onSelected(endpoint),
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 9, 7, 9),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFF0F4F1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border(
                            left: BorderSide(
                              color: active
                                  ? const Color(0xFF287765)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                EndpointMethodBadge(method: endpoint.method),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    endpoint.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: active
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: const Color(0xFF263330),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 62),
                              child: Text(
                                endpoint.path,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF76807D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
