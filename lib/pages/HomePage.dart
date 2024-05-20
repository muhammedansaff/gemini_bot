import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;
  ChatUser curentuser = ChatUser(
    firstName: "ansaf",
    uid: "0",
    avatar: "https://i.ibb.co/brCfmZ5/IMG-2416.jpg",
  );
  ChatUser geminiuser = ChatUser(
    firstName: "Gemini",
    uid: "1",
    avatar: "https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/google-gemini-icon.png",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Gemini Chat"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      messages: messages,
      user: curentuser,
      onSend: _sendMessages,
      inputCursorColor: Colors.purple,
      inputDecoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(color: Colors.purple),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: "Type your message...",
      ),
      inputToolbarPadding: EdgeInsets.all(8.0),
      sendButtonBuilder: (Function onSend) {
        return IconButton(
          icon: Icon(Icons.send),
          color: Colors.purple,
          onPressed: () => onSend(),
        );
      },
      avatarBuilder: (ChatUser user) {
        return CircleAvatar(
          backgroundImage: NetworkImage(user.avatar.toString()),
          radius: 20.0,
        );
      },
      messageContainerPadding: EdgeInsets.symmetric(horizontal: 5.0),
      avatarMaxSize: 40.0,
      showUserAvatar: true,
    );
  }

  void _sendMessages(ChatMessage chatmessage) {
    setState(() {
      messages = [...messages, chatmessage];
    });
    try {
      String question = chatmessage.text!;
      gemini.streamGenerateContent(question).listen((event) {
        ChatMessage? lastmessage = messages.isNotEmpty ? messages.last : null;
        if (lastmessage != null && lastmessage.user.uid == geminiuser.uid) {
          lastmessage = messages.removeLast();
          String response = event.content?.parts
              ?.fold("", (previous, curent) => "$previous${curent.text}") ??
              "";
          setState(() {
            messages = [lastmessage!, ...messages];
          });
        } else {
          String response = event.content?.parts
              ?.fold("", (previous, curent) => "$previous${curent.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiuser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [...messages, message];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
