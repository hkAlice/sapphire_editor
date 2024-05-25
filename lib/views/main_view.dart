import 'package:flutter/material.dart';
import 'package:sapphire_editor/views/settings_view.dart';
import 'package:sapphire_editor/views/timeline_editor_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _tabIndex = 0;
  final _pageViewController = PageController();

  final List<Widget> _navChildren = [
    const TimelineEditorView(),
    const SettingsView()
  ];

  void _onTabTapped(int index) {
   setState(() {
     _tabIndex = index;
   });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navChildren[_tabIndex],
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: BottomNavigationBar(
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings"
          )
        ],
      ),
    );
  }
}