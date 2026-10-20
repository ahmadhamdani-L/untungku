import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const privacyPolicyUrl =
    'https://ddd-dream-develop-digital.vercel.app/untungku-pro/privacy/';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final Future<Map<String, dynamic>> policy = rootBundle
      .loadString('assets/legal/privacy-id.json')
      .then((text) => jsonDecode(text) as Map<String, dynamic>);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kebijakan privasi')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: policy,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: SelectableText(
              'Kebijakan tidak dapat dimuat. Hubungi hmdhmdndani@gmail.com.\n'
              'Versi web: $privacyPolicyUrl',
            ),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final sections = (data['sections'] as List)
            .cast<Map<String, dynamic>>();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Diperbarui: ${data['updated']}\n${data['operator']}\n'
                  'Pengembang: ${data['developer']}\n${data['email']}',
                ),
                const SizedBox(height: 16),
                const Text('Kebijakan ini dapat dibaca tanpa internet.'),
                for (final section in sections) ...[
                  const SizedBox(height: 24),
                  Text(
                    section['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(section['text'] as String),
                ],
                const SizedBox(height: 24),
                const Text('Versi web: $privacyPolicyUrl'),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: privacyPolicyUrl),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan kebijakan disalin'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Salin tautan web'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
