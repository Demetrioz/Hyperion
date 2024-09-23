import 'package:flutter/material.dart';
import 'package:hyperion/pages/notifications.dart';
import 'package:hyperion/pages/settings.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int selectedPage = 0;

  static const List<Widget> _pages = <Widget>[Notifications(), Settings()];

  void _setSelectedPage(int page) {
    setState(() {
      selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hyperion'),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _pages.elementAt(selectedPage),
            ),
          ),
        );
      }),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPage,
        destinations: const <NavigationDestination>[
          NavigationDestination(
              icon: Icon(Icons.message), label: 'Notifications'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings')
        ],
        onDestinationSelected: _setSelectedPage,
      ),
    );
  }
}
