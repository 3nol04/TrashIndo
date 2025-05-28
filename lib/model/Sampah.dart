import 'package:cloud_firestore/cloud_firestore.dart';

class Sampah {
  String? id;
  String? kota;
  String? status;
  String? daerah;
  String? lokasiDetail;
  String? deskripsi;
  String? image;
  double? latitude;
  double? longitude;
  DateTime? createdAt;

  Sampah({
    this.id,
    this.kota,
    this.status,
    this.daerah,
    this.lokasiDetail,
    this.deskripsi,
    this.image,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory Sampah.fromJson(DocumentSnapshot data) {
    final json = data.data() as Map<String, dynamic>;
    return Sampah(
      id: data.id,
      kota: json['kota'],
      status: json['status'],
      daerah: json['daerah'],
      lokasiDetail: json['lokasi_detail'],
      deskripsi: json['deskripsi'],
      image: json['image'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}

class Comments {
  String? idRoom;
  String? sampahId;
  String? userId;
  String? comment;
  DateTime? createdAt;

  Comments({
    this.idRoom,
    this.sampahId,
    this.userId,
    this.comment,
    this.createdAt,
  });

  factory Comments.fromToJson(DocumentSnapshot data) {
    final json = data.data() as Map<String, dynamic>;
    return Comments(
      idRoom: data.id,
      sampahId: json['sampah_id'],
      userId: json['user_id'],
      comment: json['comment'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}
