import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gemini_chatbot/widgets/mywidgest.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;
  ChatUser currentUser = ChatUser(
    firstName: "Ansaf",
    uid: "0",
    avatar: "https://i.ibb.co/brCfmZ5/IMG-2416.jpg",
  );
  ChatUser geminiUser =
      ChatUser(firstName: "Gemini", uid: "1", avatar: "gemini_avatar");
  bool isKeyboardVisible = false;
  bool isLoading = true;
  bool isConnected = true;
  bool bar = true;
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0.0) {
      setState(() {
        isKeyboardVisible = true;
      });
    } else {
      setState(() {
        isKeyboardVisible = false;
      });
    }
    print("keyaboard$isKeyboardVisible");
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isConnected = false;
      });
    } else {
      setState(() {
        isConnected = true;
      });
      _simulateLoading();
    }
  }

  void _simulateLoading() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient appBarGradient = LinearGradient(
      colors: isKeyboardVisible
          ? [Colors.purple.shade200, const Color(0xff8b8be9)]
          : [Colors.purple.shade200, const Color(0xffae90e1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      appBar: bar
          ? AppBar(
              centerTitle: true,
              title: GradientText(
                'Gemini Chat',
                colors: [
                  Colors.purple.shade200,
                  Colors.blueAccent.shade200,
                ],
              ),
            )
          : AppBar(
              title: Text(
                'Gemini Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: appBarGradient,
                ),
              ),
              centerTitle: true,
            ),
      body: isLoading
          ? buildLoading()
          : isConnected
              ? _buildUI()
              : buildNoConnectionMessage(),
    );
  }

  Widget _buildUI() {
    return Stack(
      children: [
        const contt(),
        mysvg(),
        DashChat(
          scrollToBottomStyle:
              ScrollToBottomStyle(backgroundColor: Colors.white,textColor: Colors.purple.shade200),
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
                    colors: [
                      Colors.purple.shade200,
                      Colors.blueAccent.shade200
                    ],
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
                  height: 40.0,
                ),
              );
            } else {
              return CircleAvatar(
                backgroundImage: NetworkImage(user.avatar.toString()),
                radius: 23.0,
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
      ],
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
      bar = false;
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
