import 'dart:convert';
class Sumsel {
  final String provinsi;
  final List<Kota> kota;

  Sumsel({
    required this.provinsi,
    required this.kota,
  });

  factory Sumsel.fromJson(Map<String, dynamic> json) {
    var kotaList = json['kota'] as List;
    List<Kota> kotaItems = kotaList.map((data) => Kota.fromJson(data)).toList();
    return Sumsel(provinsi: json['provinsi'], kota: kotaItems);
  }
}

class Kota {
  final String nama;
  final List<String> daerah;

  Kota({
    required this.nama,
    required this.daerah,
  });

  factory Kota.fromJson(Map<String, dynamic> data) {
    var daerahList = data['daerah'] as List;
    List<String> derahItems =
        daerahList.map((data) => data.toString()).toList();
    return Kota(
      nama: data['nama'], 
      daerah: derahItems);
  }
}
