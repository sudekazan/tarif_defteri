import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tarif_defteri/sayfalar/tarif_olusturma.dart';
import 'package:tarif_defteri/tarifler_data/klasor_data.dart';
import 'package:tarif_defteri/tarifler_data/tarif_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class KlasorIci extends StatefulWidget {
  final KlasorData klasorData;
  const KlasorIci({super.key, required this.klasorData});

  @override
  State<KlasorIci> createState() => _KlasorIciState();
}


class _KlasorIciState extends State<KlasorIci> {
  List<TarifData> tarifListesi = [];
  List<TarifData> filtreliTarifler = [];
  bool aramaYapiliyorMu = false;
  TextEditingController aramaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tarifleriYukle();
  }

  Future<void> _tarifleriYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'tarifler_${widget.klasorData.klasor_id}';
    List<String> tariflerJson = prefs.getStringList(key) ?? [];
    setState(() {
      tarifListesi = tariflerJson.map((e) {
        var map = json.decode(e);
        return TarifData(
          tarif_id: map['tarif_id'],
          tarif_adi: map['tarif_adi'],
          tarif_aciklama: map['tarif_aciklama'],
          tarif_resim: map['tarif_resim'],
          klasor_id: map['klasor_id'],
          isFavorite: map['isFavorite'] ?? false, // Yeni eklenen alanı buraya ekle
        );
      }).toList();
      filtreliTarifler = List.from(tarifListesi);
    });
  }

  void _filtreleTarifler(String arama) {
    setState(() {
      if (arama.isEmpty) {
        filtreliTarifler = List.from(tarifListesi);
      } else {
        filtreliTarifler = tarifListesi.where((tarif) =>
          tarif.tarif_adi.toLowerCase().contains(arama.toLowerCase()) ||
          tarif.tarif_aciklama.toLowerCase().contains(arama.toLowerCase())
        ).toList();
      }
    });
  }

  Future<void> _tarifEkle(TarifData yeniTarif) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'tarifler_${widget.klasorData.klasor_id}';
    List<String> tariflerJson = prefs.getStringList(key) ?? [];
    yeniTarif.tarif_id = tariflerJson.length + 1;
    tariflerJson.add(json.encode({
      'tarif_id': yeniTarif.tarif_id,
      'tarif_adi': yeniTarif.tarif_adi,
      'tarif_aciklama': yeniTarif.tarif_aciklama,
      'tarif_resim': yeniTarif.tarif_resim,
      'klasor_id': yeniTarif.klasor_id,
      'isFavorite': yeniTarif.isFavorite, // Yeni eklenen alanı buraya ekle
    }));
    await prefs.setStringList(key, tariflerJson);
    _tarifleriYukle();
  }

  Future<void> _tarifGuncelle(TarifData guncelTarif) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'tarifler_${widget.klasorData.klasor_id}';
    List<String> tariflerJson = prefs.getStringList(key) ?? [];
    int index = tariflerJson.indexWhere((e) => json.decode(e)['tarif_id'] == guncelTarif.tarif_id);
    if (index != -1) {
      tariflerJson[index] = json.encode({
        'tarif_id': guncelTarif.tarif_id,
        'tarif_adi': guncelTarif.tarif_adi,
        'tarif_aciklama': guncelTarif.tarif_aciklama,
        'tarif_resim': guncelTarif.tarif_resim,
        'klasor_id': guncelTarif.klasor_id,
        'isFavorite': guncelTarif.isFavorite, // Yeni eklenen alanı buraya ekle
      });
      await prefs.setStringList(key, tariflerJson);
      _tarifleriYukle();
    }
  }

  void _tarifDuzenle(TarifData tarif) async {
    final guncelTarif = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TarifOlusturma(tarifData: tarif)),
    );
    if (guncelTarif != null && guncelTarif is TarifData && guncelTarif.tarif_adi.isNotEmpty) {
      _tarifGuncelle(guncelTarif);
    }
  }

  Future<void> _tarifSil(int tarif_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'tarifler_${widget.klasorData.klasor_id}';
    List<String> tariflerJson = prefs.getStringList(key) ?? [];
    tariflerJson.removeWhere((e) => json.decode(e)['tarif_id'] == tarif_id);
    await prefs.setStringList(key, tariflerJson);
    _tarifleriYukle();
  }

  void _yeniTarifEkle() async {
    final yeniTarif = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TarifOlusturma(
          tarifData: TarifData(
            tarif_id: 0,
            tarif_adi: '',
            tarif_aciklama: '',
            tarif_resim: '',
            klasor_id: widget.klasorData.klasor_id,
            isFavorite: false, // Yeni eklenen alanı buraya ekle
          ),
        ),
      ),
    );
    if (yeniTarif != null && yeniTarif is TarifData && yeniTarif.tarif_adi.isNotEmpty) {
      _tarifEkle(yeniTarif);
    }
  }

  bool _isBaslik(String line) {
    final basliklar = [
      'malzemeler', 'harç', 'hamuru', 'şerbeti', 'yapılışı'
    ];
    final trimmed = line.trim().toLowerCase();
    return basliklar.any((b) => trimmed == b);
  }

  Widget _buildRichAciklama(String aciklama) {
    final lines = aciklama.split('\n');
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
        children: lines.map((line) {
          final trimmed = line.trim();
          if (_isBaslik(trimmed)) {
            return TextSpan(
              text: line + '\n',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
            );
                      } else if (trimmed.startsWith('*')) {
              return TextSpan(
                text: line + '\n',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              );
                      } else if (RegExp(r'^(\\d+)\\.').hasMatch(trimmed)) {
              return TextSpan(
                text: line + '\n',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              );
                      } else {
              return TextSpan(text: line + '\n', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color));
            }
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: aramaYapiliyorMu
              ? TextField(
                  controller: aramaController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: "Tarif ara..."),
                  onChanged: (arama) {
                    _filtreleTarifler(arama);
                  },
                )
              : Text(widget.klasorData.klasor_adi, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          actions: [
            aramaYapiliyorMu
                ? IconButton(
                    icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      setState(() {
                        aramaYapiliyorMu = false;
                        aramaController.clear();
                        filtreliTarifler = List.from(tarifListesi);
                      });
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      setState(() {
                        aramaYapiliyorMu = true;
                      });
                    },
                  ),
          ],
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor, // Dinamik tema rengi
          child: filtreliTarifler.isEmpty
              ? Center(
                  child: Text(
                    "Henüz hiç tarif yok!",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: filtreliTarifler.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    var tarif = filtreliTarifler[index];
                    return GestureDetector(
                      onTap: (){
                        _tarifDuzenle(tarif);
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Theme.of(context).cardColor,
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.restaurant_menu, color: Theme.of(context).primaryColor, size: 28),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tarif.tarif_adi,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        tarif.isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          tarif.isFavorite = !tarif.isFavorite;
                                        });
                                        // Favori durumunu kaydet
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        String key = 'tarifler_${widget.klasorData.klasor_id}';
                                        List<String> tariflerJson = prefs.getStringList(key) ?? [];
                                        int idx = tariflerJson.indexWhere((e) => (json.decode(e)['tarif_id'] == tarif.tarif_id));
                                        if (idx != -1) {
                                          var map = json.decode(tariflerJson[idx]);
                                          map['isFavorite'] = tarif.isFavorite;
                                          tariflerJson[idx] = json.encode(map);
                                          await prefs.setStringList(key, tariflerJson);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
                                      onPressed: () {
                                        Share.share(
                                          '${tarif.tarif_adi}\n\n${tarif.tarif_aciklama}',
                                          subject: 'Tarif Paylaşımı',
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Tarif Sil'),
                                            content: Text("${tarif.tarif_adi} silinsin mi?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Hayır'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _tarifSil(tarif.tarif_id);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text('Evet', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildRichAciklama(tarif.tarif_aciklama),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _yeniTarifEkle,
          backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
          child:  const Icon(Icons.add, color: Colors.white),
        ),
    );
  }
}
