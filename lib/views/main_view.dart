import 'package:flutter/material.dart';
import 'package:sapphire_editor/views/loottable_editor_view.dart';
import 'package:sapphire_editor/views/settings_view.dart';
import 'package:sapphire_editor/views/timeline_editor_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _tabIndex = 0;

  final List<Widget> _navChildren = [
    const TimelineEditorView(),
    const LootTableEditorView(),
    const SettingsView()
  ];

  void _onTabTapped(int index) {
    setState(() {
      _tabIndex = index; 
    });
  }

  bool _isLargeScreen(BuildContext context) {
    // https://github.com/flutter/samples/blob/main/experimental/web_dashboard/lib/src/widgets/third_party/adaptive_scaffold.dart
    return MediaQuery.of(context).size.width > 1180.0;
  }

  @override
  Widget build(BuildContext context) {
    bool isMediumScreen = _isLargeScreen(context);
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isMediumScreen ? NavigationRail(
            leading: Image.asset("assets/images/sapphire_logo.png", width: 56.0,),
            destinations: [
              NavigationRailDestination(
                icon: Image.asset("assets/images/icon_trials_rounded.png", width: 24.0,),
                label: Text("Timeline")
              ), 
              NavigationRailDestination(
                icon: Image.asset("assets/images/icon_loottables_rounded.png", width: 24.0,),
                label: Text("Loot Tables")
              ), 
              NavigationRailDestination(
                icon: Icon(Icons.settings_rounded),
                label: Text("Settings")
              )
            ],
            onDestinationSelected: (i) {
              _onTabTapped(i);
            },
            selectedIndex: _tabIndex
          ) : Container(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child,);
              },
              child: _navChildren[_tabIndex],
              ),
          ),
        ],
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: isMediumScreen ? null : BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (i) {
          _onTabTapped(i);
        },
        currentIndex: _tabIndex,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/icon_trials_rounded.png", width: 24.0,),
            label: "Timeline"
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/icon_loottables_rounded.png", width: 24.0,),
            label: "Loot Tables"
          ), 
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: "Settings"
          )
        ],
      ),
    );
  }
}