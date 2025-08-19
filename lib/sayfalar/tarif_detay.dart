import 'package:flutter/material.dart';
import 'package:tarif_defteri/tarifler_data/tarif_data.dart';
import 'package:tarif_defteri/sayfalar/tarif_olusturma.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TarifDetay extends StatelessWidget {
  final TarifData tarif;

  const TarifDetay({super.key, required this.tarif});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tarif.tarif_adi),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          // Düzenle butonu
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
            onPressed: () async {
              final guncelTarif = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TarifOlusturma(tarifData: tarif),
                ),
              );
              if (guncelTarif != null && guncelTarif is TarifData) {
                // Ana sayfaya geri dön ve güncelleme yap
                Navigator.pop(context, guncelTarif);
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görseller
              if (tarif.tarif_resimler.isNotEmpty)
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: PageView.builder(
                    itemCount: tarif.tarif_resimler.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(tarif.tarif_resimler[index]),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Tarif açıklaması
              Card(
                color: Theme.of(context).cardColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildRichAciklama(context, tarif.tarif_aciklama),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichAciklama(BuildContext context, String aciklama) {
    final lines = aciklama.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 8);
        
        // Başlık kontrolü
        if (_isBaslik(trimmed)) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              children: [
                Icon(
                  _getSectionIcon(trimmed),
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Numaralı liste (yapılış)
        if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      trimmed.split('.')[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Link kontrolü
        if (trimmed.startsWith('🔗')) {
          final linkText = trimmed.substring(1).trim();
          // Sadece URL kısmını al, basit temizleme
          final urlText = linkText
              .replaceFirst(RegExp(r'^Link:\s*'), '')
              .replaceAll(RegExp(r"[^\w\s\-\.:/?#[\]@!$&'()*+,;=]"), '')
              .trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.link,
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _launchUrl(context, urlText),
                    child: Text(
                      linkText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Madde işareti
        if (trimmed.startsWith('*')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trimmed.substring(1).trim(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Normal metin
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isBaslik(String line) {
    final basliklar = [
      'malzemeler', 'harç', 'hamuru', 'şerbeti', 'yapılışı', 'linkler'
    ];
    final trimmed = line.trim().toLowerCase();
    return basliklar.any((b) => trimmed == b);
  }

  IconData _getSectionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'malzemeler':
        return Icons.shopping_basket;
      case 'harç':
        return Icons.blender;
      case 'yapılışı':
        return Icons.format_list_numbered;
      case 'hamuru':
        return Icons.circle;
      case 'şerbeti':
        return Icons.water_drop;
      case 'linkler':
        return Icons.link;
      default:
        return Icons.category;
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      // URL'yi temizle ve formatla
      String cleanUrl = url.trim();
      
      // Eğer URL http:// veya https:// ile başlamıyorsa ekle
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }
      
      final Uri uri = Uri.parse(cleanUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // URL açılamazsa hata mesajı göster
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Link açılamadı: $cleanUrl'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geçersiz link formatı: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
