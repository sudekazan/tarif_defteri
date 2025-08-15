class TarifData{
  late int tarif_id;
  late String tarif_adi;
  late String tarif_aciklama;
  late String tarif_resim;
  late int klasor_id;
  bool isFavorite;

  TarifData({
    required this.tarif_id,
    required this.tarif_adi,
    required this.tarif_aciklama,
    required this.tarif_resim,
    required this.klasor_id,
    this.isFavorite = false,
  });

  factory TarifData.fromMap(Map<String, dynamic> map) => TarifData(
    tarif_id: map['tarif_id'],
    tarif_adi: map['tarif_adi'],
    tarif_aciklama: map['tarif_aciklama'],
    tarif_resim: map['tarif_resim'],
    klasor_id: map['klasor_id'],
    isFavorite: map['isFavorite'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'tarif_id': tarif_id,
    'tarif_adi': tarif_adi,
    'tarif_aciklama': tarif_aciklama,
    'tarif_resim': tarif_resim,
    'klasor_id': klasor_id,
    'isFavorite': isFavorite,
  };
}