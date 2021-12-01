import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tambah_limit/screens/routing.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    Configuration(
      child: MaterialApp (
        title: config.apk_name,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0),
          )
        ),
        onGenerateRoute: (RouteSettings settings) {
          List<String> pages = [];
          int mode = 0;
          int id = 0;

          pages = settings.name.split("/");

          // contohnya route/id/mode
          // optional : arguments

          // mode 0 = gk dari mana2
          // mode 1 = api
          // mode 2 = local storage
          // mode 3 = dari model
          if (pages.length > 1) {
            id = int.tryParse(pages[1]);
          }
          if (pages.length > 2) {
            mode = int.tryParse(pages[2]);
          }
          
          return routing(mode, id, pages, settings);
        },
      ),
    )
  );
}
