import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('[Firebase] ✓ Firebase initialized successfully');

      // Request notification permissions
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM token
      String? fcmToken = await messaging.getToken();
      print('[Firebase] FCM Token: $fcmToken');

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      print('[Firebase] ✗ Initialization Error: $e');
    }
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('[Firebase] ✓ Handling background message: ${message.messageId}');
  }

  // ============== AUTH METHODS ==============

  // Get current user
  static User? getCurrentUser() {
    return auth.currentUser;
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return auth.currentUser != null;
  }

  // Sign up user
  static Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('[Firebase] ✗ Sign Up Error: $e');
      rethrow;
    }
  }

  // Sign in user
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('[Firebase] ✗ Sign In Error: $e');
      rethrow;
    }
  }

  // Sign out user
  static Future<void> signOut() async {
    try {
      await auth.signOut();
      print('[Firebase] ✓ User signed out');
    } catch (e) {
      print('[Firebase] ✗ Sign Out Error: $e');
      rethrow;
    }
  }

  // Send password reset email
  static Future<void> sendPasswordReset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      print('[Firebase] ✓ Password reset email sent');
    } catch (e) {
      print('[Firebase] ✗ Password Reset Error: $e');
      rethrow;
    }
  }

  // ============== FIRESTORE CRUD METHODS ==============

  // Add document
  static Future<DocumentReference> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final ref = await firestore.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('[Firebase] ✓ Document added: $collection/${ref.id}');
      return ref;
    } catch (e) {
      print('[Firebase] ✗ Add Document Error: $e');
      rethrow;
    }
  }

  // Set document
  static Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      await firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
      print('[Firebase] ✓ Document set: $collection/$docId');
    } catch (e) {
      print('[Firebase] ✗ Set Document Error: $e');
      rethrow;
    }
  }

  // Get document
  static Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await firestore.collection(collection).doc(docId).get();
      print('[Firebase] ✓ Document retrieved: $collection/$docId');
      return doc;
    } catch (e) {
      print('[Firebase] ✗ Get Document Error: $e');
      rethrow;
    }
  }

  // Get all documents
  static Future<QuerySnapshot> getCollection({
    required String collection,
  }) async {
    try {
      final docs = await firestore.collection(collection).get();
      print(
        '[Firebase] ✓ Collection retrieved: $collection (${docs.docs.length} docs)',
      );
      return docs;
    } catch (e) {
      print('[Firebase] ✗ Get Collection Error: $e');
      rethrow;
    }
  }

  // Query collection
  static Future<QuerySnapshot> queryCollection({
    required String collection,
    required String field,
    required dynamic value,
  }) async {
    try {
      final docs = await firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
      print('[Firebase] ✓ Query executed: $collection where $field = $value');
      return docs;
    } catch (e) {
      print('[Firebase] ✗ Query Error: $e');
      rethrow;
    }
  }

  // Update document
  static Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('[Firebase] ✓ Document updated: $collection/$docId');
    } catch (e) {
      print('[Firebase] ✗ Update Document Error: $e');
      rethrow;
    }
  }

  // Delete document
  static Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await firestore.collection(collection).doc(docId).delete();
      print('[Firebase] ✓ Document deleted: $collection/$docId');
    } catch (e) {
      print('[Firebase] ✗ Delete Document Error: $e');
      rethrow;
    }
  }

  // ============== REAL-TIME LISTENERS ==============

  // Listen to document changes
  static Stream<DocumentSnapshot> listenToDocument({
    required String collection,
    required String docId,
  }) {
    return firestore.collection(collection).doc(docId).snapshots();
  }

  // Listen to collection changes
  static Stream<QuerySnapshot> listenToCollection({
    required String collection,
  }) {
    return firestore.collection(collection).snapshots();
  }

  // Listen to query changes
  static Stream<QuerySnapshot> listenToQuery({
    required String collection,
    required String field,
    required dynamic value,
  }) {
    return firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .snapshots();
  }

  // ============== STORAGE METHODS ==============

  // Upload file
  static Future<String> uploadFile({
    required String path,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final ref = storage.ref().child(path).child(fileName);
      await ref.putData(fileBytes);
      final downloadUrl = await ref.getDownloadURL();
      print('[Firebase] ✓ File uploaded: $path/$fileName');
      return downloadUrl;
    } catch (e) {
      print('[Firebase] ✗ Upload Error: $e');
      rethrow;
    }
  }

  // Delete file
  static Future<void> deleteFile({required String fullPath}) async {
    try {
      await storage.ref(fullPath).delete();
      print('[Firebase] ✓ File deleted: $fullPath');
    } catch (e) {
      print('[Firebase] ✗ Delete File Error: $e');
      rethrow;
    }
  }

  // ============== BATCH OPERATIONS ==============

  // Batch write
  static Future<void> batchWrite(
    Future<void> Function(WriteBatch batch) updateFn,
  ) async {
    try {
      final batch = firestore.batch();
      await updateFn(batch);
      await batch.commit();
      print('[Firebase] ✓ Batch write completed');
    } catch (e) {
      print('[Firebase] ✗ Batch Write Error: $e');
      rethrow;
    }
  }
}
