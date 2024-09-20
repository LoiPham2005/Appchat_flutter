import 'package:appchat_firebase/components/chat_bubble.dart';
import 'package:appchat_firebase/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';
import '../services/chats/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  // txt controller
  final TextEditingController _messageController = TextEditingController();

  // chat and auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // for text field focus
  FocusNode _myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Đăng ký WidgetsBindingObserver
    _myFocusNode.addListener(() {
      if (_myFocusNode.hasFocus) {
        // Changed condition to hasFocus
        Future.delayed(
          Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this); // Hủy đăng ký WidgetsBindingObserver
    _myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll contrller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300), // Changed duration to 300ms
      curve: Curves.easeOut,
    );
  }

  // send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();

      // Cuộn xuống sau khi gửi tin nhắn
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }

        // data
        return ListView(
            controller: _scrollController,
            // khi vào để nhắn tin sẽ bị lộn ngược ko nên dùng
            // reverse: true,
            
            // display messages in reverse order
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList());
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser, messageId: doc.id,userId: data["senderID"],)
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message",
              obcureText: false,
              focusNode: _myFocusNode,
            ),
          ),

          // send button
          Container(
              decoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              margin: EdgeInsets.only(right: 25),
              child: IconButton(
                onPressed: sendMessage,
                icon: Icon(Icons.arrow_upward),
                color: Colors.white,
              ))
        ],
      ),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Phát hiện sự thay đổi kích thước (khi bàn phím bật/tắt)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollDown();
    });
  }
}
