import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkmode';
  _saveThemetoBox(bool isDarkmode) => _box.write(_key, isDarkmode);

  bool _loadthemefrombox() => _box.read(_key) ?? false;
  ThemeMode get theme => _loadthemefrombox() ? ThemeMode.dark : ThemeMode.light;

  void switchtheme() {
    Get.changeThemeMode(_loadthemefrombox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemetoBox(!_loadthemefrombox());
  }
}
