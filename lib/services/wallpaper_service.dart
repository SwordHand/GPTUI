import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class WallpaperService extends ChangeNotifier {
  static const String _wallpaperPrefsKey = 'selected_wallpaper';
  static const String _customWallpapersKey = 'custom_wallpapers';
  static const String _wallpaperDir = 'wallpapers';

  final SharedPreferences _prefs;

  WallpaperService(this._prefs);

  static Future<WallpaperService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return WallpaperService(prefs);
  }

  // 获取壁纸目录
  Future<String> get _wallpaperPath async {
    final directory = await getApplicationDocumentsDirectory();
    final wallpaperPath = '${directory.path}/$_wallpaperDir';
    await Directory(wallpaperPath).create(recursive: true);
    return wallpaperPath;
  }

  // 获取所有自定义壁纸
  List<String> get customWallpapers {
    return _prefs.getStringList(_customWallpapersKey) ?? [];
  }

  // 获取当前选中的壁纸
  String? get selectedWallpaper {
    return _prefs.getString(_wallpaperPrefsKey);
  }

  // 设置当前壁纸
  Future<void> setWallpaper(String? wallpaper) async {
    if (wallpaper == null) {
      await _prefs.remove(_wallpaperPrefsKey);
    } else {
      await _prefs.setString(_wallpaperPrefsKey, wallpaper);
    }
    notifyListeners();
  }

  // 添加自定义壁纸
  Future<String?> addCustomWallpaper() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    final wallpaperPath = await _wallpaperPath;
    final fileName = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final savedFile = File('$wallpaperPath/$fileName');

    // 复制图片到应用目录
    await savedFile.writeAsBytes(await image.readAsBytes());

    // 保存到自定义壁纸列表
    final wallpapers = customWallpapers;
    wallpapers.add(fileName);
    await _prefs.setStringList(_customWallpapersKey, wallpapers);

    notifyListeners();
    return fileName;
  }

  // 删除自定义壁纸
  Future<void> removeCustomWallpaper(String wallpaper) async {
    final wallpapers = customWallpapers;
    wallpapers.remove(wallpaper);
    await _prefs.setStringList(_customWallpapersKey, wallpapers);

    // 如果是当前壁纸，清除选择
    if (selectedWallpaper == wallpaper) {
      await setWallpaper(null);
    }

    // 删除文件
    final wallpaperPath = await _wallpaperPath;
    final file = File('$wallpaperPath/$wallpaper');
    if (await file.exists()) {
      await file.delete();
    }

    notifyListeners();
  }

  // 获取壁纸完整路径
  Future<String> getWallpaperPath(String wallpaper) async {
    final wallpaperDir = await _wallpaperPath;
    return '$wallpaperDir/$wallpaper';
  }
}