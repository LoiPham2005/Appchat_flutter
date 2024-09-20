import 'package:appchat_firebase/components/user_tile.dart';
import 'package:appchat_firebase/services/auth/auth_service.dart';
import 'package:appchat_firebase/services/chats/chat_services.dart';
import 'package:flutter/material.dart';

class BlockedUserPage extends StatelessWidget {
  BlockedUserPage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  // show confirm unblock box
  void _showUnblockBox(BuildContext context, String userId){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unblock User'),
        content: Text('Are you sure you want to unblock this user?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Unblock'),
            onPressed: () {
              chatService.unblockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Unblocked!")));
            }
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //get current User id
    String userId = authService.getCurrentUser()!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Blocked Users'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getBlockUserStream(userId),
        builder: (context, snapshot) {
          // error...
          if (snapshot.hasError) {
            return Center(child: Text('Error loading: ${snapshot.error}')); // Cập nhật để hiển thị thông báo lỗi
          }

          // loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Kiểm tra xem snapshot.data có phải là null không
          final blockedUsers = snapshot.data ?? []; // Đảm bảo blockedUsers không phải là null

          // no users
          if (blockedUsers.isEmpty) {
            return Center(child: Text('No blocked users'));
          }

          // load completed
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                  text: user["email"],
                      onTap: () => _showUnblockBox(context, user['uid']),
              );
            },
          );

        },
      ),
    );
  }
}
