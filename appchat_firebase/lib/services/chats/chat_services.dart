import 'package:appchat_firebase/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class ChatService extends ChangeNotifier {
  //get instance of firestore and auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get all user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('User').snapshots().map((snapshot) {
      // return snapshot.docs.map((doc) => doc.data()).toList();
      return snapshot.docs
          .where((doc) => doc.data()['email'] != _auth.currentUser!.email)
          .map((doc) => doc.data())
          .toList();
    });
  }

  // get all user streams except block user
  Stream<List<Map<String, dynamic>>> getUserStreamExceptBlock() {
    final currentUser = _auth.currentUser;
    return _firestore
        .collection('User')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // get blocked user ids
      final blockedUsersIds = snapshot.docs.map((doc) => doc.id).toList();

      // get all user
      final userSnapshot = await _firestore.collection('User').get();

      // return as stream list, excluding current user and blocked users
      return userSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockedUsersIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  // send message
  Future<void> sendMessage(String receiverID, message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get message
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // repore user
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwner': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('Reports').add(report);
  }

  // block user
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('User')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});

    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('User')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserId)
        .delete();

    notifyListeners();
  }

// get block user stream
  Stream<List<Map<String, dynamic>>> getBlockUserStream(String userId) {
    return _firestore
        .collection('User')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(blockUserIds
          .map((id) => _firestore.collection('User').doc(id).get()));
      // return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      return userDocs
        .where((doc) => doc.exists && doc.data() != null) // Ensure data is not null
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    });
  }
}
