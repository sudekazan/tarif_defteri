import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'widgets/klasorler_with_theme.dart';
import 'screens/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme _currentTheme = AppTheme.pastelYesil;
  bool _isDarkMode = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadDarkMode(); // Koyu mod durumunu yükle
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('app_theme');
    if (themeIndex != null) {
      setState(() {
        _currentTheme = AppTheme.values[themeIndex];
      });
    }
  }

  Future<void> _loadDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedDarkMode = prefs.getBool('is_dark_mode');
    if (savedDarkMode != null) {
      setState(() {
        _isDarkMode = savedDarkMode;
      });
    }
  }

  Future<void> _changeTheme(AppTheme theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', theme.index);
    setState(() {
      _currentTheme = theme;
    });
  }

  Future<void> _changeDarkMode(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarif Defteri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: appThemeColors[_currentTheme]!,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appThemeColors[_currentTheme],
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: appThemeColors[_currentTheme],
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: appThemeColors[_currentTheme],
        scaffoldBackgroundColor: const Color(0xFF121212), // Koyu arka plan
        cardColor: const Color(0xFF1E1E1E), // Koyu kart rengi
        dividerColor: const Color(0xFF2C2C2C), // Koyu ayırıcı
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appThemeColors[_currentTheme],
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: appThemeColors[_currentTheme],
          foregroundColor: Colors.white, // Beyaz metin
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white, // Beyaz metin
          displayColor: Colors.white,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: KlasorlerWithTheme(
        onThemeChanged: _changeTheme, 
        currentTheme: _currentTheme,
        isDarkMode: _isDarkMode, // Koyu mod durumu
        onDarkModeChanged: _changeDarkMode, // Koyu mod değiştirme
      ),
      routes: {
        '/settings': (context) => SettingsPage(
          onThemeChanged: _changeTheme,
          currentTheme: _currentTheme,
          isDarkMode: _isDarkMode,
          onDarkModeChanged: _changeDarkMode, // Yeni fonksiyonu kullan
        ),
      },
    );
  }
}