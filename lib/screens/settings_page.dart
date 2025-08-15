import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  final Function(AppTheme) onThemeChanged;
  final AppTheme currentTheme;
  final bool isDarkMode;
  final Function(bool) onDarkModeChanged;
  
  const SettingsPage({
    super.key, 
    required this.onThemeChanged, 
    required this.currentTheme, 
    required this.isDarkMode, 
    required this.onDarkModeChanged
  });

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
