import 'package:cloud_firestore/cloud_firestore.dart';

class CourseService {
  final CollectionReference _courses = FirebaseFirestore.instance.collection(
    'courses',
  );

  Future<void> createCourse(Map<String, dynamic> courseData) async {
    try {
      await _courses.add({
        ...courseData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  Future<void> addLesson(
    String courseId,
    Map<String, dynamic> lessonData,
  ) async {
    try {
      await _courses.doc(courseId).collection('lessons').add({
        ...lessonData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add lesson: $e');
    }
  }

  Stream<QuerySnapshot> getCourses() {
    return _courses.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    try {
      await _courses.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _courses.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }
}
