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
  bool isBookmarked;
  DateTime? createdAt;

  Sampah({
    required this.id,
    required this.kota,
    required this.status,
    required this.daerah,
    required this.lokasiDetail,
    required this.deskripsi,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.isBookmarked,
    required this.createdAt,
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
      isBookmarked: (json['is_bookmarked'] as bool?) ?? false,
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
    );
  }
}

class Comments {
  String? idRoom;
  String? sampahId;
  String? userImage;
  String? userName;
  String? userId;
  String? comment;
  DateTime? createdAt;

  Comments({
    this.idRoom,
    this.sampahId,
    this.userImage,
    this.userName,
    this.userId,
    this.comment,
    this.createdAt,
  });

  factory Comments.fromToJson(DocumentSnapshot data) {
    final json = data.data() as Map<String, dynamic>;
    return Comments(
      idRoom: data.id,
      sampahId: json['sampah_id'],
      userImage: json['user_image'],
      userName: json['user_name'],
      comment: json['comment'],
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
    );
  }
}

class MarksBooks {
  String? sampahId;
  String? image;
  String? location;
  String? status;
  String? daerah;
  DateTime? createdAt;

  MarksBooks({
    this.sampahId,
    this.image,
    this.location,
    this.status,
    this.daerah,
    this.createdAt,
  });

  factory MarksBooks.fromToJson(DocumentSnapshot data) {
    final json = data.data() as Map<String, dynamic>;
    return MarksBooks(
      sampahId: json['sampah_id'] ?? '',
      image: json['image'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      daerah: json['daerah'] ?? '',
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
