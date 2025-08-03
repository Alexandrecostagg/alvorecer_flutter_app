// bible_version_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bible_version_service.dart';

class BibleVersionSelector extends StatelessWidget {
  const BibleVersionSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final versionService = Provider.of<BibleVersionService>(context);
    
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            versionService.currentVersion.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Para garantir visibilidade na AppBar
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
      onSelected: (String version) {
        versionService.setVersion(version);
      },
      itemBuilder: (BuildContext context) {
        return versionService.availableVersions.map((String version) {
          return PopupMenuItem<String>(
            value: version,
            child: Row(
              children: [
                if (version == versionService.currentVersion)
                  const Icon(Icons.check, color: Colors.green)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 8),
                Text(versionService.getVersionFullName(version)),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}