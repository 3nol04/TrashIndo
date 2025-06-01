import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashindo/model/Sampah.dart';

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
  

  Future <void> deleteSampah(String id) async {
    await FirebaseFirestore.instance.collection('sampah').doc(id).delete();
  }

 Future <void> updateSampah(String id, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('sampah').doc(id).update(data);
 } 

Future<List<Comments>> getAllComments(String idSampah) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('sampah')
      .doc(idSampah)
      .collection('comments')
      .get();

  List<Comments> comments = querySnapshot.docs
      .map((doc) => Comments.fromToJson(doc))
      .toList();

  return comments;
}

}
