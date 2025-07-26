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
  var tfTarifAciklama = TextEditingController();
  final FocusNode _aciklamaFocus = FocusNode();
  List<Map<String, dynamic>> sections = [];
  List<XFile> photos = [];
  final ImagePicker _picker = ImagePicker();
  Future<void> tarifiKaydet(String tarif_adi, String tarif_aciklama) async {
    print("Tarif Kayıt Edildi: ${tarif_adi} - ${tarif_aciklama}");
  }
  @override
  void initState() {
    super.initState();
    var tarifData = widget.tarifData;
    tfTaridAdi.text = tarifData.tarif_adi;
    tfTarifAciklama.text = tarifData.tarif_aciklama;
    tfTarifAciklama.addListener(_otoMaddeEkle);
  }
  @override
  void dispose() {
    tfTarifAciklama.removeListener(_otoMaddeEkle);
    tfTarifAciklama.dispose();
    _aciklamaFocus.dispose();
    super.dispose();
  }
  bool _isAutoAdding = false;
  void _otoMaddeEkle() {
    if (_isAutoAdding) return;
    final text = tfTarifAciklama.text;
    final selection = tfTarifAciklama.selection;
    if (text.isEmpty || selection.baseOffset < 1) return;
    // Sadece Enter ile ekleme
    if (text.length > 1 && text[selection.baseOffset - 1] == '\n' &&
        (selection.baseOffset == text.length || text[selection.baseOffset] != '\n')) {
      final lines = text.substring(0, selection.baseOffset - 1).split('\n');
      String lastHeader = '';
      for (int i = lines.length - 1; i >= 0; i--) {
        final l = lines[i].trim().toLowerCase();
        if (l == 'malzemeler' || l == 'harç' || l == 'hamuru' || l == 'şerbeti') {
          lastHeader = l;
          break;
        } else if (l == 'yapılışı') {
          lastHeader = l;
          break;
        }
      }
      String ek = '';
      if (lastHeader == 'malzemeler' || lastHeader == 'harç' || lastHeader == 'hamuru' || lastHeader == 'şerbeti') {
        ek = '* ';
      } else if (lastHeader == 'yapılışı') {
        int lastNum = 1;
        for (int i = lines.length - 1; i >= 0; i--) {
          final l = lines[i].trim();
          final match = RegExp(r'^(\d+)\.').firstMatch(l);
          if (match != null) {
            lastNum = int.tryParse(match.group(1) ?? '1') ?? 1;
            break;
          }
        }
        ek = '${lastNum + 1}. ';
      }
      if (ek.isNotEmpty) {
        _isAutoAdding = true;
        final newText = text.substring(0, selection.baseOffset) + ek + text.substring(selection.baseOffset);
        tfTarifAciklama.text = newText;
        tfTarifAciklama.selection = TextSelection.fromPosition(TextPosition(offset: selection.baseOffset + ek.length));
        _isAutoAdding = false;
      }
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tarif Ekleme"),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.add_circle_outline, color: Colors.black),
              onSelected: (value) async {
                if (value == 'foto') {
                  final picked = await _picker.pickMultiImage();
                  if (picked != null && picked.isNotEmpty) {
                    setState(() {
                      photos.addAll(picked);
                    });
                  }
                } else {
                  String ekMetin = '';
                  if (value == 'malzemeler') {
                    ekMetin = '\nMalzemeler\n* ';
                  } else if (value == 'harc') {
                    ekMetin = '\nHarç\n* ';
                  } else if (value == 'hamur') {
                    ekMetin = '\nHamur\n* ';
                  } else if (value == 'serbet') {
                    ekMetin = '\nŞerbet\n* ';
                  } else if (value == 'yapilis') {
                    ekMetin = '\nYapılışı\n1. ';
                  }
                  setState(() {
                    final offset = tfTarifAciklama.text.length;
                    tfTarifAciklama.text += ekMetin;
                  });
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
          color: const Color(0xFFF5F6FA),
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
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Fotoğraflar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        color: Colors.white,
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
                          const Text(
                            "Tarif Adı",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: tfTaridAdi,
                            decoration: InputDecoration(
                              hintText: "Tarif Adı Giriniz",
                              filled: true,
                              fillColor: const Color(0xFFF5F6FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Tarif Açıklaması",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          // Açıklama alanında sadece klasik TextField kalsın, RawKeyboardListener ve özel backspace silme kodunu kaldır.
                          TextField(
                            maxLines: 12,
                            controller: tfTarifAciklama,
                            decoration: InputDecoration(
                              hintText: "Tarif Açıklaması Giriniz",
                              filled: true,
                              fillColor: const Color(0xFFF5F6FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
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
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(section['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Spacer(),
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
                              ...List.generate(section['items'].length, (i) {
                                return Row(
                                  children: [
                                    section['type'] == 'yapilis'
                                        ? Text("${i + 1}.", style: const TextStyle(fontWeight: FontWeight.bold))
                                        : const Text("•", style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(section['items'][i])),
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          section['items'].removeAt(i);
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: section['type'] == 'yapilis' ? 'Adım ekle' : 'Madde ekle',
                                      ),
                                      onSubmitted: (val) {
                                        if (val.trim().isNotEmpty) {
                                          setState(() {
                                            section['items'].add(val.trim());
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {}, // Sadece Enter ile ekleniyor
                                  ),
                                ],
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
                          if (tfTaridAdi.text.isNotEmpty) {
                            Navigator.pop(context, TarifData(
                              tarif_id: widget.tarifData.tarif_id,
                              tarif_adi: tfTaridAdi.text,
                              tarif_aciklama: tfTarifAciklama.text,
                              tarif_resim: widget.tarifData.tarif_resim,
                              klasor_id: widget.tarifData.klasor_id,
                            ));
                          }
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
}
