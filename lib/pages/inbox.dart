import 'package:flutter/material.dart';
import 'package:gtd/data/data.dart';
import 'package:provider/provider.dart';

class InboxWidget extends StatelessWidget {
  const InboxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DB(),
      child: InboxListWidget(),
    );
  }
}

class InboxListWidget extends StatelessWidget {
  const InboxListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    DB db = context.watch<DB>();

    return Column(
      children: [
        FutureBuilder<List<(int, String)>>(
          future: db.getInbox(),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<(int, String)>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return Expanded(
                    child: ListView(
                      children: [
                        for ((int, String) row in snapshot.data ?? [])
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(child: Text(row.$2)),
                                  IconButton(
                                    icon: Icon(Icons.cancel),
                                    onPressed: () {
                                      db.removeInboxEntry(row.$1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              },
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'New Inbox Entry',
                  ),
                  onSubmitted: (value) {
                    db.addInboxEntry(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
