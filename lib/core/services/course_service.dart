import 'package:cloud_firestore/cloud_firestore.dart';

class CourseService {
  final CollectionReference _courses = FirebaseFirestore.instance.collection(
    'courses',
  );

  Stream<QuerySnapshot> getCourses() {
    return _courses.orderBy('createdAt', descending: true).snapshots();
  }

  Future<List<Map<String, dynamic>>> getCoursesOnce() async {
    final snapshot = await _courses
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }
}
