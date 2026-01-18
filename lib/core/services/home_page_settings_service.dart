import 'package:cloud_firestore/cloud_firestore.dart';

class HomePageSettingsService {
  final CollectionReference _settings = FirebaseFirestore.instance.collection(
    'settings',
  );

  Stream<DocumentSnapshot> getHomePageSettings() {
    return _settings.doc('home_page').snapshots();
  }

  Future<Map<String, dynamic>> getHomePageSettingsOnce() async {
    final doc = await _settings.doc('home_page').get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }
}
