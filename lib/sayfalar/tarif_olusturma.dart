import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tarif_defteri/tarifler_data/tarif_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class TarifOlusturma extends StatefulWidget {
  @override
  State<TarifOlusturma> createState() => _TarifOlusturmaState();
  TarifData tarifData;

  TarifOlusturma({required this.tarifData});

}

class _TarifOlusturmaState extends State<TarifOlusturma> {
  var tfTaridAdi = TextEditingController();
  final FocusNode _aciklamaFocus = FocusNode();
  List<Map<String, dynamic>> sections = [];
  List<XFile> photos = [];
  final ImagePicker _picker = ImagePicker();
  
  // Her section için TextField controller'ı
  Map<int, TextEditingController> sectionControllers = {};
  Future<void> tarifiKaydet(String tarif_adi, String tarif_aciklama) async {
    print("Tarif Kayıt Edildi: ${tarif_adi} - ${tarif_aciklama}");
  }
  @override
  void initState() {
    super.initState();
    var tarifData = widget.tarifData;
    tfTaridAdi.text = tarifData.tarif_adi;
    // Mevcut tarif açıklamasını sections'a dönüştür
    _parseExistingTarif(tarifData.tarif_aciklama);
  }
  @override
  void dispose() {
    _aciklamaFocus.dispose();
    // Section controller'larını temizle
    for (var controller in sectionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  void _parseExistingTarif(String tarifAciklama) {
    if (tarifAciklama.isEmpty) return;
    
    final lines = tarifAciklama.split('\n');
    String currentSection = '';
    String currentType = '';
    List<String> currentItems = [];
    
    for (String line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      // Başlık kontrolü
      if (trimmed.toLowerCase() == 'malzemeler') {
        _addSectionIfNotEmpty(currentSection, currentType, currentItems);
        currentSection = 'Malzemeler';
        currentType = 'malzemeler';
        currentItems = [];
      } else if (trimmed.toLowerCase() == 'harç') {
        _addSectionIfNotEmpty(currentSection, currentType, currentItems);
        currentSection = 'Harç';
        currentType = 'harc';
        currentItems = [];
      } else if (trimmed.toLowerCase() == 'hamuru') {
        _addSectionIfNotEmpty(currentSection, currentType, currentItems);
        currentSection = 'Hamuru';
        currentType = 'hamur';
        currentItems = [];
      } else if (trimmed.toLowerCase() == 'şerbeti') {
        _addSectionIfNotEmpty(currentSection, currentType, currentItems);
        currentSection = 'Şerbeti';
        currentType = 'serbet';
        currentItems = [];
      } else if (trimmed.toLowerCase() == 'yapılışı') {
        _addSectionIfNotEmpty(currentSection, currentType, currentItems);
        currentSection = 'Yapılışı';
        currentType = 'yapilis';
        currentItems = [];
      } else if (trimmed.startsWith('*') || trimmed.startsWith('•') || RegExp(r'^\d+\.').hasMatch(trimmed)) {
        // Madde ekle
        String item = trimmed;
        if (trimmed.startsWith('*') || trimmed.startsWith('•')) {
          item = trimmed.substring(1).trim();
        } else {
          item = trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
        }
        if (item.isNotEmpty) {
          currentItems.add(item);
        }
      }
    }
    
    // Son section'ı ekle
    _addSectionIfNotEmpty(currentSection, currentType, currentItems);
  }
  
  void _addSectionIfNotEmpty(String title, String type, List<String> items) {
    if (title.isNotEmpty && items.isNotEmpty) {
      sections.add({
        'title': title,
        'type': type,
        'items': List.from(items),
      });
    }
  }
  


  void _showBigPhoto(File file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında uyarı göster
        if (tfTaridAdi.text.isNotEmpty || sections.isNotEmpty || photos.isNotEmpty) {
          // İlk kez oluşturuyor mu yoksa düzenliyor mu kontrol et
          bool isEditing = widget.tarifData.tarif_adi.isNotEmpty;
          
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_off : Icons.cancel_outlined,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Düzenlemeyi İptal Et' : 'Tarif Oluşturmayı İptal Et',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing 
                      ? 'Yaptığınız değişiklikler kaybolur!'
                      : 'Bütün yaptıklarınız silinecek!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Devam etmek istiyor musunuz?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Devam Et',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'İptal Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true; // Hiçbir veri yoksa direkt çık
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tarif Ekleme"),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.add_circle_outline, color: Theme.of(context).iconTheme.color),
              onSelected: (value) async {
                if (value == 'foto') {
                  final picked = await _picker.pickMultiImage();
                  if (picked != null && picked.isNotEmpty) {
                    setState(() {
                      photos.addAll(picked);
                    });
                  }
                } else {
                  // Eğer bu türde section yoksa ekle, varsa ekleme
                  bool sectionExists = sections.any((section) => section['type'] == value);
                  if (!sectionExists) {
                    Map<String, dynamic> yeniSection = {
                      'title': _getSectionTitle(value),
                      'type': value,
                      'items': []
                    };
                    setState(() {
                      sections.add(yeniSection);
                    });
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'malzemeler', child: Text('Malzemeler')),
                const PopupMenuItem(value: 'harc', child: Text('Harç')),
                const PopupMenuItem(value: 'yapilis', child: Text('Yapılışı')),
                const PopupMenuItem(value: 'hamur', child: Text('Hamuru')),
                const PopupMenuItem(value: 'serbet', child: Text('Şerbeti')),
                const PopupMenuItem(value: 'foto', child: Text('Fotoğraf Ekle')),
              ],
            ),
          ],
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (photos.isNotEmpty)
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Fotoğraflar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        photos.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                children: photos.map((photo) => Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showBigPhoto(File(photo.path));
                                      },
                                      child: Image.file(
                                        File(photo.path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          photos.remove(photo);
                                        });
                                      },
                                      child: Container(
                                        color: Colors.black,
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ],
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tarif Adı",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: tfTaridAdi,
                            decoration: InputDecoration(
                              hintText: "Tarif Adı Giriniz",
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Tarif Bölümleri",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Aşağıdaki + butonundan tarif bölümlerini ekleyebilirsiniz",
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                   // Dinamik başlık ve içerik ekleme alanları açıklama kutusunun ALTINA taşındı
                   ...sections.asMap().entries.map((entry) {
                      int secIndex = entry.key;
                      var section = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: Theme.of(context).cardColor,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Başlık ve silme butonu
                              Row(
                                children: [
                                  Icon(
                                    _getSectionIcon(section['type']),
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      section['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context).textTheme.bodyLarge?.color
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        sections.removeAt(secIndex);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              // İçerik listesi - daha kompakt tasarım
                              if (section['items'].isNotEmpty) ...[
                                ...List.generate(section['items'].length, (i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        // Numaralandırma veya bullet point
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: section['type'] == 'yapilis'
                                                ? Text(
                                                    "${i + 1}",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.circle,
                                                    size: 10,
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Madde metni
                                        Expanded(
                                          child: Text(
                                            section['items'][i],
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.bodyMedium?.color,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        // Silme butonu
                                        IconButton(
                                          icon: const Icon(Icons.clear, size: 20, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              section['items'].removeAt(i);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 16),
                              ],
                              // Tek TextField
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: sectionControllers[secIndex] ??= TextEditingController(),
                                        decoration: InputDecoration(
                                          hintText: section['type'] == 'yapilis' ? 'Adım ekle...' : 'Madde ekle...',
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(16),
                                        ),
                                        onSubmitted: (val) {
                                          // Enter'a basınca malzeme ekle
                                          if (val.trim().isNotEmpty) {
                                            setState(() {
                                              section['items'].add(val.trim());
                                            });
                                            // TextField'ı temizle
                                            final controller = sectionControllers[secIndex];
                                            if (controller != null) {
                                              controller.clear();
                                              // Focus'u koru
                                              Future.delayed(const Duration(milliseconds: 50), () {
                                                if (mounted) {
                                                  // TextField'a tekrar focus ver
                                                  FocusScope.of(context).requestFocus(
                                                    FocusNode()..requestFocus()
                                                  );
                                                }
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        // + butonuna basarak malzeme ekle
                                        final controller = sectionControllers[secIndex];
                                        if (controller != null && controller.text.trim().isNotEmpty) {
                                          setState(() {
                                            section['items'].add(controller.text.trim());
                                          });
                                          // TextField'ı temizle
                                          controller.clear();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // Tarif adı kontrolü
                          if (tfTaridAdi.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen tarif adını giriniz!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          // En az bir section olmalı
                          if (sections.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen en az bir tarif bölümü ekleyiniz!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          // En az bir madde olmalı
                          bool hasItems = false;
                          for (var section in sections) {
                            if (section['items'].isNotEmpty) {
                              hasItems = true;
                              break;
                            }
                          }
                          
                          if (!hasItems) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen en az bir madde ekleyiniz!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          // Sections verilerini tarif açıklamasına dönüştür
                          String tarifAciklama = '';
                          for (var section in sections) {
                            tarifAciklama += '\n${section['title']}\n';
                            if (section['type'] == 'yapilis') {
                              for (int i = 0; i < section['items'].length; i++) {
                                tarifAciklama += '${i + 1}. ${section['items'][i]}\n';
                              }
                            } else {
                              for (String item in section['items']) {
                                tarifAciklama += '* $item\n';
                              }
                            }
                          }
                          
                          // Başarılı mesajı göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${tfTaridAdi.text} tarifi kaydediliyor...'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          
                          Navigator.pop(context, TarifData(
                            tarif_id: widget.tarifData.tarif_id,
                            tarif_adi: tfTaridAdi.text.trim(),
                            tarif_aciklama: tarifAciklama.trim(),
                            tarif_resim: widget.tarifData.tarif_resim,
                            klasor_id: widget.tarifData.klasor_id,
                          ));
                        },
                        child: const Text(
                          "Kaydet",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSectionTitle(String type) {
    switch (type) {
      case 'malzemeler':
        return 'Malzemeler';
      case 'harc':
        return 'Harç';
      case 'yapilis':
        return 'Yapılışı';
      case 'hamur':
        return 'Hamuru';
      case 'serbet':
        return 'Şerbeti';
      default:
        return '';
    }
  }

  IconData _getSectionIcon(String type) {
    switch (type) {
      case 'malzemeler':
        return Icons.shopping_basket;
      case 'harc':
        return Icons.blender;
      case 'yapilis':
        return Icons.format_list_numbered;
      case 'hamur':
        return Icons.circle;
      case 'serbet':
        return Icons.water_drop;
      default:
        return Icons.category;
    }
  }
}
