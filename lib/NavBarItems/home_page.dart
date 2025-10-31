import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gez_gor_saticii/HomePage/aksiyonlar.dart';
import 'package:gez_gor_saticii/HomePage/home_page_drawer.dart';
import 'package:gez_gor_saticii/NavBarItems/navbar.dart';
import 'package:gez_gor_saticii/Pages/Musterilerim/satilan_turlar.dart';
import 'package:gez_gor_saticii/Widgets/Reklamlar/home_page_reklam.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Acente Paneli"),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        drawer: const DrawerSayfasi(),
        bottomNavigationBar: const BottomNavBar(
          index: 0,
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              HomePageReklam(),
              SizedBox(
                height: 15,
              ),
              HomePageAksiyonlar(),
              SizedBox(
                height: 15,
              ),
              SatilanTurlar(),
            ],
          ),
        ),
      ),
    );
  }
}
