import 'package:flutter/material.dart';
import 'package:gtd/data/data.dart';
import 'package:provider/provider.dart';

class ProjectsWidget extends StatelessWidget {
  final bool maybe;

  const ProjectsWidget({super.key, required this.maybe});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => DB()),
        ListenableProvider(create: (_) => ProjectsState()),
      ],
      child: ProjectsPageSelector(maybe: maybe),
    );
  }
}

class ProjectsState extends ChangeNotifier {
  int? _projectID;

  int? get projectID {
    return _projectID;
  }

  set projectID(int? newID) {
    _projectID = newID;
    notifyListeners();
  }
}

class ProjectsPageSelector extends StatelessWidget {
  final bool maybe;
  const ProjectsPageSelector({super.key, required this.maybe});

  @override
  Widget build(BuildContext context) {
    ProjectsState state = context.watch<ProjectsState>();

    if (state.projectID == null) {
      return ProjectsList(maybe: maybe);
    } else {
      return ProjectPage(id: state.projectID!);
    }
  }
}

class ProjectsList extends StatelessWidget {
  final bool maybe;
  const ProjectsList({super.key, required this.maybe});

  @override
  Widget build(BuildContext context) {
    DB db = context.watch<DB>();
    ProjectsState state = context.watch<ProjectsState>();

    return Column(
      children: [
        FutureBuilder<List<(int, String)>>(
          future: db.getProjects(maybe),
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
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(row.$2)),
                                    IconButton(
                                      icon: Icon(Icons.cancel),
                                      onPressed: () {
                                        db.removeProject(row.$1);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                state.projectID = row.$1;
                              },
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
                    labelText: 'New Project Title',
                  ),
                  onSubmitted: (value) {
                    db.addProject(value, maybe);
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

class ProjectPage extends StatelessWidget {
  final int id;
  const ProjectPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    DB db = context.watch<DB>();

    return FutureBuilder<List<(int, String)>>(
      future: db.getTasks(id),
      builder:
          (BuildContext context, AsyncSnapshot<List<(int, String)>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Expanded(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Stack(
                children: [
                  Column(
                    children: [
                      FutureBuilder<String>(
                        future: db.getProjectTitle(id),
                        builder:
                            (
                              BuildContext context,
                              AsyncSnapshot<String> snapshot,
                            ) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Expanded(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    snapshot.data ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40.0,
                                    ),
                                  ),
                                );
                              }
                            },
                      ),
                      Expanded(
                        child: ReorderableListView(
                          onReorder: (index1, index2) {
                            if (index1 < index2) {
                              index2--;
                            }

                            db.swapTasks(
                              snapshot.data![index1].$1,
                              snapshot.data![index2].$1,
                            );
                          },
                          children: [
                            for ((int, String) row in snapshot.data ?? [])
                              Row(
                                key: ValueKey(row.$1),
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: TextFormField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        initialValue: row.$2,
                                        onChanged: (str) {
                                          db.changeTask(row.$1, str);
                                        },
                                        onTapOutside: (_) {
                                          db.notify();
                                        },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      db.removeTask(row.$1);
                                    },
                                  ),
                                  SizedBox(width: 64.0),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        child: Icon(Icons.add),
                        onPressed: () {
                          db.addTask('', id, null);
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          },
    );
  }
}
