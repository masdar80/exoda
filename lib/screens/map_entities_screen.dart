import 'package:flutter/material.dart';
import 'package:exoda/l10n/app_localizations.dart';

class MapEntitiesScreen extends StatefulWidget {
  final List<String> unknownEntities;
  final List<String> availableEntities;

  const MapEntitiesScreen({
    super.key,
    required this.unknownEntities,
    required this.availableEntities,
  });

  @override
  State<MapEntitiesScreen> createState() => _MapEntitiesScreenState();
}

class _MapEntitiesScreenState extends State<MapEntitiesScreen> {
  late Map<String, String> entityMapping;

  @override
  void initState() {
    super.initState();
    entityMapping = {
      for (var e in widget.unknownEntities)
        e: widget.availableEntities.isNotEmpty
            ? widget.availableEntities.first
            : ''
    };
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.entity),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.pleaseSelectEntity,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.unknownEntities.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final unknown = widget.unknownEntities[index];
                  return Row(
                    children: [
                      Expanded(
                          child: Text(unknown,
                              style: const TextStyle(fontSize: 16))),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: entityMapping[unknown],
                        items: widget.availableEntities
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            entityMapping[unknown] = value ?? '';
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (entityMapping.values.any((v) => v.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr.pleaseSelectEntity)),
                        );
                        return;
                      }
                      Navigator.of(context).pop(entityMapping);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text(tr.confirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
