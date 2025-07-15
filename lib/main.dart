import 'package:flutter/material.dart';
import 'package:gtd/pages/inbox.dart';
import 'package:gtd/pages/projects.dart';

void main() async {
  runApp(AppAndNav());
}

class AppAndNav extends StatefulWidget {
  const AppAndNav({super.key});

  @override
  State<AppAndNav> createState() => _AppAndNavState();
}

class _AppAndNavState extends State<AppAndNav> {
  int _selectedIndex = 0;
  int _buildIter = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    _buildIter++;

    switch (_selectedIndex) {
      case 0:
        page = InboxWidget();
        break;
      case 1:
        page = Text('Need to implement calendar');
        break;
      case 2:
        page = Text('Need to implement next actions');
        break;
      case 3:
        page = ProjectsWidget(key: ValueKey(_buildIter), maybe: false);
        break;
      case 4:
        page = ProjectsWidget(key: ValueKey(_buildIter), maybe: true);
        break;
      case 5:
        page = Text('Need to implement settings');
        break;
      default:
        page = Text('Invalid page index.');
        break;
    }

    return MaterialApp(
      title: 'Getting Things Done',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.inbox),
                  label: Text('Inbox'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month),
                  label: Text('Calendar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Actions'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list),
                  label: Text('Projects'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.question_mark),
                  label: Text('Maybe'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(),
            Expanded(child: page),
          ],
        ),
      ),
    );
  }
}
