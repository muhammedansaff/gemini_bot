import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;
  ChatUser currentUser = ChatUser(
    firstName: "Ansaf",
    uid: "0",
    avatar: "https://i.ibb.co/brCfmZ5/IMG-2416.jpg",
  );
  ChatUser geminiUser =
      ChatUser(firstName: "Gemini", uid: "1", avatar: "gemini_avatar");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GradientText(
          'Gemini Chat',
          colors: [
            Colors.purple.shade200,
            Colors.blueAccent.shade200,
          ],
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade200, // Light blue
            Colors.blueAccent.shade200, // Dark blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: DashChat(
        scrollToBottomStyle: ScrollToBottomStyle(
          backgroundColor: Colors.blueAccent,
        ),
        messages: messages,
        user: currentUser,
        onSend: _sendMessages,
        inputCursorColor: Colors.blueAccent,
        inputDecoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: "Type your message...",
        ),
        inputToolbarPadding: const EdgeInsets.all(8.0),
        sendButtonBuilder: (Function onSend) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: GestureDetector(
              onTap: () {
                onSend();
              },
              child: GradientIcon(
                icon: Icons.send,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade200, Colors.blueAccent.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                size: 30,
              ),
            ),
          );
        },
        avatarBuilder: (ChatUser user) {
          if (user.avatar == "gemini_avatar") {
            return CircleAvatar(
              backgroundColor: Colors.white,
              radius: 23,
              child: SvgPicture.asset(
                "assets/images/google-gemini-icon.svg",
                colorFilter:
                    ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
                height: 40.0,
              ),
            );
          } else {
            return CircleAvatar(
              backgroundImage: NetworkImage(user.avatar.toString()),
              radius: 20.0,
            );
          }
        },
        messageContainerPadding: const EdgeInsets.symmetric(horizontal: 5.0),
        avatarMaxSize: 40.0,
        showUserAvatar: true,
        onLoadEarlier: () {
          // Handle loading earlier messages here
          print("Load earlier messages");
        },
        messageBuilder: _messageBuilder,
      ),
    );
  }

  Widget _messageBuilder(ChatMessage message) {
    bool isCurrentUser = message.user.uid == currentUser.uid;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.purple.shade200 : Colors.grey.shade300,
          borderRadius: isCurrentUser
              ? const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                message.user.firstName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
            Text(
              message.text!,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessages(ChatMessage chatMessage) {
    setState(() {
      messages = [...messages, chatMessage];
    });

    try {
      String question = chatMessage.text!;
      gemini.streamGenerateContent(question).listen((event) {
        String response = event.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";

        setState(() {
          // Check if the last message is from Gemini
          ChatMessage? lastMessage = messages.isNotEmpty ? messages.last : null;
          if (lastMessage != null && lastMessage.user.uid == geminiUser.uid) {
            // Append the response to the existing Gemini message
            lastMessage.text = (lastMessage.text ?? '') + response;
          } else {
            // Create a new Gemini message
            ChatMessage newMessage = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: response,
            );
            messages = [...messages, newMessage];
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }
}
