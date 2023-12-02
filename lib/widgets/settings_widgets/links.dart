import 'package:flutter/material.dart';

import 'package:daily_diary/backend_classes/localization.dart';

import 'package:url_launcher/url_launcher.dart';

class RepoLink extends StatelessWidget {
  const RepoLink({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _openRepoLink(() => _showError(context)),
      title: Text(locale(context).openRepo),
      leading: const Icon(Icons.code),
    );
  }

  Future<void> _openRepoLink(void Function() onError) async {
    Uri url = Uri.parse('https://github.com/Voklen/Daily-Diary');
    bool successfullyOpened = await launchUrl(url);
    if (!successfullyOpened) {
      onError();
    }
  }

  void _showError(BuildContext context) {
    SnackBar snackBar = SnackBar(
      content: Text(locale(context).unableToOpenLink),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
