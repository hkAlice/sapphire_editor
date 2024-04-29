import 'package:flutter/material.dart';
import 'package:sapphirexiv_timeline_editor/views/timeline_editor_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _tabIndex = 0;

  final List<Widget> _navChildren = [
    TimelineEditorView(),
  ];

  void onTabTapped(int index) {
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
        onTap: (i) {},
        currentIndex: _tabIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Timeline"
          ), 
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings"
          )
        ],
      ),
    );
  }
}