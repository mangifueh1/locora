import 'package:flutter/material.dart';
import 'package:locora/shared/widgets/navbar.dart';

import '../data/api_reference_data.dart';
import '../models/api_endpoint.dart';
import '../widgets/api_endpoint_detail.dart';
import '../widgets/docs_category_rail.dart';
import '../widgets/docs_header.dart';
import '../widgets/endpoint_list_panel.dart';

class ApiDocsScreen extends StatefulWidget {
  const ApiDocsScreen({super.key});

  @override
  State<ApiDocsScreen> createState() => _ApiDocsScreenState();
}

class _ApiDocsScreenState extends State<ApiDocsScreen> {
  final _searchController = TextEditingController();
  ApiEndpointCategory _category = ApiEndpointCategory.business;
  ApiEndpoint? _selected;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final endpoints = ApiReferenceData.endpoints
        .where((endpoint) => endpoint.category == _category)
        .where(
          (endpoint) => '${endpoint.name} ${endpoint.path} ${endpoint.method}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
    final selected = endpoints.contains(_selected)
        ? _selected
        : endpoints.firstOrNull;
    if (selected != _selected) _selected = selected;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Column(
          children: [
            const Navbar(),
            const DocsHeader(),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(28, 23, 28, 21),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Build with Locora',
                              style: TextStyle(
                                fontSize: 25,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF20312D),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Explore ${ApiReferenceData.endpoints.length} endpoints for deliveries, drivers, businesses, and live tracking.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF66736D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (MediaQuery.sizeOf(context).width > 720)
                        const _BaseUrlPill(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1050;
                  if (wide) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1440),
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE4E9E5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 176,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    17,
                                    12,
                                    12,
                                  ),
                                  child: DocsCategoryRail(
                                    selected: _category,
                                    onSelected: _selectCategory,
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                width: 1,
                                color: Color(0xFFE8ECE8),
                              ),
                              SizedBox(
                                width: 290,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    13,
                                    16,
                                    12,
                                    12,
                                  ),
                                  child: EndpointListPanel(
                                    endpoints: endpoints,
                                    selected: selected,
                                    onSelected: (item) =>
                                        setState(() => _selected = item),
                                    searchController: _searchController,
                                    onSearchChanged: (value) =>
                                        setState(() => _query = value),
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                width: 1,
                                color: Color(0xFFE8ECE8),
                              ),
                              Expanded(
                                child: selected == null
                                    ? const _EmptyDetail()
                                    : ApiEndpointDetail(endpoint: selected),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: DocsCategoryRail(
                          selected: _category,
                          onSelected: _selectCategory,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                height: 330,
                                color: Colors.white,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  9,
                                  16,
                                  12,
                                ),
                                child: EndpointListPanel(
                                  endpoints: endpoints,
                                  selected: selected,
                                  onSelected: (item) =>
                                      setState(() => _selected = item),
                                  searchController: _searchController,
                                  onSearchChanged: (value) =>
                                      setState(() => _query = value),
                                ),
                              ),
                              const Divider(height: 1),
                              SizedBox(
                                height: 540,
                                child: selected == null
                                    ? const _EmptyDetail()
                                    : ApiEndpointDetail(endpoint: selected),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(ApiEndpointCategory category) {
    setState(() {
      _category = category;
      _query = '';
      _searchController.clear();
      _selected = ApiReferenceData.endpoints
          .where((endpoint) => endpoint.category == category)
          .firstOrNull;
    });
  }
}

class _BaseUrlPill extends StatelessWidget {
  const _BaseUrlPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F6F4),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.link, size: 14, color: Color(0xFF527066)),
        const SizedBox(width: 7),
        Text(
          ApiReferenceData.baseUrl,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: Color(0xFF4A5C54),
          ),
        ),
      ],
    ),
  );
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'No endpoints match this search.',
      style: TextStyle(fontSize: 13, color: Color(0xFF737C7B)),
    ),
  );
}
