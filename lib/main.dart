import 'package:flutter/material.dart';
import 'package:tarif_defteri/sayfalar/klasorler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:tarif_defteri/auth_screen.dart';
import 'package:tarif_defteri/sayfalar/klasorler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp()); // MyApp zaten var ve buradan çağrılıyor.
}

enum AppTheme {
  pastelYesil,
  pastelMavi,
  pastelLila,
  pastelPembe,
  pastelTuruncu,
  pastelGri,
  pastelTurkuaz,
  pastelKirmizi,
  pastelMor,
  pastelSari,
}

Map<AppTheme, MaterialColor> appThemeColors = {
  AppTheme.pastelYesil: MaterialColor(0xFFA5D6A7, <int, Color>{
    50: Color(0xFFE8F5E9),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF4CAF50),
    600: Color(0xFF43A047),
    700: Color(0xFF388E3C),
    800: Color(0xFF2E7D32),
    900: Color(0xFF1B5E20),
  }),
  AppTheme.pastelMavi: MaterialColor(0xFF81D4FA, <int, Color>{
    50: Color(0xFFE1F5FE),
    100: Color(0xFFB3E5FC),
    200: Color(0xFF81D4FA),
    300: Color(0xFF4FC3F7),
    400: Color(0xFF29B6F6),
    500: Color(0xFF03A9F4),
    600: Color(0xFF039BE5),
    700: Color(0xFF0288D1),
    800: Color(0xFF0277BD),
    900: Color(0xFF01579B),
  }),
  AppTheme.pastelLila: MaterialColor(0xFFCE93D8, <int, Color>{
    50: Color(0xFFF3E5F5),
    100: Color(0xFFE1BEE7),
    200: Color(0xFFCE93D8),
    300: Color(0xFFBA68C8),
    400: Color(0xFFAB47BC),
    500: Color(0xFF9C27B0),
    600: Color(0xFF8E24AA),
    700: Color(0xFF7B1FA2),
    800: Color(0xFF6A1B9A),
    900: Color(0xFF4A148C),
  }),
  AppTheme.pastelPembe: MaterialColor(0xFFF8BBD0, <int, Color>{
    50: Color(0xFFFCE4EC),
    100: Color(0xFFF8BBD0),
    200: Color(0xFFF48FB1),
    300: Color(0xFFF06292),
    400: Color(0xFFEC407A),
    500: Color(0xFFE91E63),
    600: Color(0xFFD81B60),
    700: Color(0xFFC2185B),
    800: Color(0xFFAD1457),
    900: Color(0xFF880E4F),
  }),
  AppTheme.pastelTuruncu: MaterialColor(0xFFFFF59D, <int, Color>{
    50: Color(0xFFFFFDE7),
    100: Color(0xFFFFF9C4),
    200: Color(0xFFFFF59D),
    300: Color(0xFFFFF176),
    400: Color(0xFFFFEE58),
    500: Color(0xFFFFEB3B),
    600: Color(0xFFFDD835),
    700: Color(0xFFFBC02D),
    800: Color(0xFFF9A825),
    900: Color(0xFFF57C00),
  }),
  AppTheme.pastelGri: MaterialColor(0xFFCFD8DC, <int, Color>{
    50: Color(0xFFECEFF1),
    100: Color(0xFFCFD8DC),
    200: Color(0xFFB0BEC5),
    300: Color(0xFF90A4AE),
    400: Color(0xFF78909C),
    500: Color(0xFF607D8B),
    600: Color(0xFF546E7A),
    700: Color(0xFF455A64),
    800: Color(0xFF37474F),
    900: Color(0xFF263238),
  }),
  AppTheme.pastelTurkuaz: MaterialColor(0xFF80DEEA, <int, Color>{
    50: Color(0xFFE0F7FA),
    100: Color(0xFFB2EBF2),
    200: Color(0xFF80DEEA),
    300: Color(0xFF4DD0E1),
    400: Color(0xFF26C6DA),
    500: Color(0xFF00BCD4),
    600: Color(0xFF00ACC1),
    700: Color(0xFF0097A7),
    800: Color(0xFF00838F),
    900: Color(0xFF006064),
  }),
  AppTheme.pastelKirmizi: MaterialColor(0xFFFF8A80, <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFFF8A80),
    300: Color(0xFFFF5252),
    400: Color(0xFFFF1744),
    500: Color(0xFFD50000),
    600: Color(0xFFC51162),
    700: Color(0xFFB71C1C),
    800: Color(0xFF880E4F),
    900: Color(0xFF560027),
  }),
  AppTheme.pastelMor: MaterialColor(0xFFB39DDB, <int, Color>{
    50: Color(0xFFEDE7F6),
    100: Color(0xFFD1C4E9),
    200: Color(0xFFB39DDB),
    300: Color(0xFF9575CD),
    400: Color(0xFF7E57C2),
    500: Color(0xFF673AB7),
    600: Color(0xFF5E35B1),
    700: Color(0xFF512DA8),
    800: Color(0xFF4527A0),
    900: Color(0xFF311B92),
  }),
  AppTheme.pastelSari: MaterialColor(0xFFFFF9C4, <int, Color>{
    50: Color(0xFFFFFDE7),
    100: Color(0xFFFFF9C4),
    200: Color(0xFFFFF59D),
    300: Color(0xFFFFF176),
    400: Color(0xFFFFEE58),
    500: Color(0xFFFFEB3B),
    600: Color(0xFFFDD835),
    700: Color(0xFFFBC02D),
    800: Color(0xFFF9A825),
    900: Color(0xFFF57C00),
  }),
};

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

  Future<void> _changeTheme(AppTheme theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme', theme.index);
    setState(() {
      _currentTheme = theme;
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
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appThemeColors[_currentTheme],
      ),
        appBarTheme: AppBarTheme(
          backgroundColor: appThemeColors[_currentTheme],
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>( // Firebase Auth'u import ettiğinizden emin olun: import 'package:firebase_auth/firebase_auth.dart';
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            // Kullanıcı oturum açmışsa ana klasör ekranını göster
            return KlasorlerWithTheme(onThemeChanged: _changeTheme, currentTheme: _currentTheme);
          }
          // Kullanıcı oturum açmamışsa kimlik doğrulama ekranını göster
          return const AuthScreen();
        },
      ),      routes: {
        '/settings': (context) => SettingsPage(
          onThemeChanged: _changeTheme,
          currentTheme: _currentTheme,
          isDarkMode: _isDarkMode,
          onDarkModeChanged: (val) {
            setState(() {
              _isDarkMode = val;
            });
          },
        ),
      },
    );
  }
}

class KlasorlerWithTheme extends StatelessWidget {
  final Function(AppTheme) onThemeChanged;
  final AppTheme currentTheme;
  const KlasorlerWithTheme({super.key, required this.onThemeChanged, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Ayarlar')), 
            ListTile(
              title: const Text('Tema Seç'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettingsPage(onThemeChanged: onThemeChanged, currentTheme: currentTheme)));
              },
            ),
          ],
        ),
      ),
      body: Klasorler(),
    );
  }
}

class ThemeSettingsPage extends StatelessWidget {
  final Function(AppTheme) onThemeChanged;
  final AppTheme currentTheme;
  const ThemeSettingsPage({super.key, required this.onThemeChanged, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tema Seçimi')),
      body: ListView(
        children: AppTheme.values.map((theme) {
          return RadioListTile<AppTheme>(
            title: Text(theme.toString().split('.').last),
            value: theme,
            groupValue: currentTheme,
            onChanged: (AppTheme? value) {
              if (value != null) {
                onThemeChanged(value);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Function(AppTheme) onThemeChanged;
  final AppTheme currentTheme;
  final bool isDarkMode;
  final Function(bool) onDarkModeChanged;
  const SettingsPage({super.key, required this.onThemeChanged, required this.currentTheme, required this.isDarkMode, required this.onDarkModeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Tema Seçimi', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppTheme.values.map((theme) {
                final color = appThemeColors[theme]!;
                final isSelected = theme == currentTheme;
                return GestureDetector(
                  onTap: () => onThemeChanged(theme),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(Icons.check, color: Colors.white, size: 22),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Koyu Mod'),
            value: isDarkMode,
            onChanged: onDarkModeChanged,
          ),
        ],
      ),
    );
  }
}