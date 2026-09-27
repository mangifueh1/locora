import 'package:flutter/material.dart';

import '../data/api_reference_data.dart';
import '../models/api_endpoint.dart';
import 'docs_code_block.dart';
import 'endpoint_method_badge.dart';

class ApiEndpointDetail extends StatelessWidget {
  const ApiEndpointDetail({required this.endpoint, super.key});

  final ApiEndpoint endpoint;

  @override
  Widget build(BuildContext context) {
    final request = endpoint.requestExample;
    final response = endpoint.responseExample;
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 25, 28, 36),
      children: [
        Row(
          children: [
            EndpointMethodBadge(method: endpoint.method),
            const SizedBox(width: 10),
            Text(
              endpoint.auth,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF65716D),
              ),
            ),
            const Spacer(),
            Text(
              endpoint.category.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF87908D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          endpoint.name,
          style: const TextStyle(
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: Color(0xFF20312D),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          endpoint.description,
          style: const TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF5C6863),
          ),
        ),
        const SizedBox(height: 22),
        _RouteLine(endpoint: endpoint),
        const SizedBox(height: 27),
        if (endpoint.parameters.isNotEmpty) ...[
          const _SectionHeading(
            title: 'Parameters',
            subtitle: 'Fields accepted by this endpoint',
          ),
          const SizedBox(height: 10),
          _ParametersTable(parameters: endpoint.parameters),
          const SizedBox(height: 25),
        ],
        if (request != null) ...[
          DocsCodeBlock(
            title: endpoint.method == 'SOCKET'
                ? 'EVENT PAYLOAD'
                : 'REQUEST BODY',
            code: request,
          ),
          const SizedBox(height: 15),
        ],
        if (response != null) ...[
          DocsCodeBlock(
            title: endpoint.method == 'EVENT'
                ? 'EVENT PAYLOAD'
                : '200 RESPONSE',
            code: response,
          ),
          const SizedBox(height: 19),
        ],
        if (endpoint.errors.isNotEmpty) ...[
          const _SectionHeading(
            title: 'Error responses',
            subtitle: 'Possible non-success responses',
          ),
          const SizedBox(height: 10),
          ...endpoint.errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    error.split(' ').first,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFAC5046),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error.substring(error.indexOf(' ') + 1),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF5D6763),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (endpoint.category == ApiEndpointCategory.delivery &&
            endpoint.path == '/deliveries') ...[
          const SizedBox(height: 12),
          const _Note(
            text: 'When the customer has no saved location, the response includes a picker URL. PUBLIC_APP_URL controls the picker and tracking link origins.',
          ),
        ],
      ],
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.endpoint});
  final ApiEndpoint endpoint;

  @override
  Widget build(BuildContext context) {
    final origin = endpoint.category == ApiEndpointCategory.realtime
        ? 'Socket.IO event'
        : ApiReferenceData.baseUrl;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F2),
        border: Border.all(color: const Color(0xFFE3E9E4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REQUEST',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFF79847F),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            '$origin${endpoint.category == ApiEndpointCategory.realtime ? ' · ' : ''}${endpoint.path}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF273A34),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF263832),
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Color(0xFF7A8580)),
      ),
    ],
  );
}

class _ParametersTable extends StatelessWidget {
  const _ParametersTable({required this.parameters});
  final List<ApiParameter> parameters;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.05),
        1: FlexColumnWidth(.75),
        2: FlexColumnWidth(2.4),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFF3F5F3)),
          children: [
            _Cell('NAME', heading: true),
            _Cell('TYPE', heading: true),
            _Cell('DETAILS', heading: true),
          ],
        ),
        ...parameters.map(
          (parameter) => TableRow(
            children: [
              _Cell(
                '${parameter.name}${parameter.required ? ' *' : ''}\n${parameter.location}',
                mono: true,
              ),
              _Cell(parameter.type, mono: true),
              _Cell(parameter.description),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.heading = false, this.mono = false});
  final String text;
  final bool heading;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
    child: Text(
      text,
      style: TextStyle(
        fontSize: heading ? 9 : 11,
        height: 1.4,
        fontWeight: heading ? FontWeight.w800 : FontWeight.w500,
        letterSpacing: heading ? .6 : 0,
        fontFamily: mono && !heading ? 'monospace' : null,
        color: heading ? const Color(0xFF7A8580) : const Color(0xFF42504A),
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF3EF),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: Color(0xFF347461)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              height: 1.45,
              color: Color(0xFF42675B),
            ),
          ),
        ),
      ],
    ),
  );
}
