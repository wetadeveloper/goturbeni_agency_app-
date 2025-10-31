import 'package:flutter/material.dart';
import 'package:gez_gor_saticii/NavBarItems/home_page.dart';
import 'package:gez_gor_saticii/NavBarItems/musterilerim.dart';
import 'package:gez_gor_saticii/NavBarItems/profil.dart';
import 'package:gez_gor_saticii/NavBarItems/turlarim.dart';

class BottomNavBar extends StatefulWidget {
  final int index;
  const BottomNavBar({Key? key, required this.index}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  final Color _unselectedItemColor = Colors.grey;
  final Color _selectedItemColor = Colors.orange;
  late int _selectedIndex;
  final List<Widget> _pages = [
    const HomePage(),
    const Turlarim(),
    const MusterilerSayfasi(),
    const Profil(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Anasayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Turlarım',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Müşterilerim',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: _selectedItemColor,
      unselectedItemColor: _unselectedItemColor,
      onTap: _onItemTapped,
    );
  }
}
