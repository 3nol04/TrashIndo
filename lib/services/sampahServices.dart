import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashindo/model/dataSampah.dart';

class SampahServices {
  Future<List<Sampah>> getAllTempatSampah() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('sampah').get();
    List<Sampah> dataSampah =
        querySnapshot.docs.map((data) => Sampah.fromJson(data)).toList();
    return dataSampah;
  }

  Future<Sampah> getSampah(String id) async {
    final data =
        await FirebaseFirestore.instance.collection('sampah').doc(id).get();
    return Sampah.fromJson(data);
  }
}
