import 'package:appchat_firebase/services/chats/chat_services.dart';
import 'package:appchat_firebase/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.messageId,
      required this.userId});

  // show options
  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
            child: Wrap(
          children: [
            // repore message button
            ListTile(
                leading: Icon(Icons.flag),
                title: Text(
                  'Report',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _reportContent(context, messageId, userId);
                }),

            // block user button
            ListTile(
                leading: Icon(Icons.block),
                title: Text(
                  'Block user',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userId);
                }),

            // cancel button
            ListTile(
                leading: Icon(Icons.cancel),
                title: Text(
                  'Cancel',
                ),
                onTap: () {
                  Navigator.pop(context);
                }),
          ],
        ));
      },
    );
  }

  // report message
  void _reportContent(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report message"),
        content: Text("Are you sure want to report this message"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),

          // report button
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Message Reported"),
              ));
            },
            child: Text("Report"),
          ),
        ],
      ),
    );
  }

  // block user
  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Block User"),
        content: Text("Are you sure want to block this message"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),

          // block button
          TextButton(
            onPressed: () {
              ChatService().blockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("User blocked!"),
              ));
            },
            child: Text("Block"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // light vs dark mode for correct bubble colors
    bool isDarkMode =
        Provider.of<ThemProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser
              ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade500)
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
        child: Text(
          message,
          style: TextStyle(
              color: isCurrentUser
                  ? Colors.white
                  : (isDarkMode ? Colors.white : Colors.black)),
        ),
      ),
    );
  }
}
