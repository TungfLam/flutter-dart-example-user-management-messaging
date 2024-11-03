import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'helpers.dart';

const String API_BASE_CO = 'http://$ipv4:3000/api/conversation/';
const String API_BASE_ME = 'http://$ipv4:3000/api/message/';

class ConversationScreen extends StatefulWidget {
  final String userId;

  const ConversationScreen({super.key, required this.userId});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class Conversation {
  final String id;
  final List<String> members;

  Conversation({required this.id, required this.members});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'],
      members: List<String>.from(json['members']),
    );
  }
}

class Message {
  final String id;
  final String conversationId;
  final String sender;
  final String text;

  Message(
      {required this.id,
      required this.conversationId,
      required this.sender,
      required this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      conversationId: json['conversationId'],
      sender: json['sender'],
      text: json['text'],
    );
  }
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Conversation> conversations = [];
  bool isLoading = true;
  late String userId;

  Future<void> fetchConversations() async {
    final response = await http.get(Uri.parse('$API_BASE_CO${widget.userId}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        conversations = List<Conversation>.from(
            jsonData['data'].map((x) => Conversation.fromJson(x)));
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    print('User IDDDDD2: $userId');
    fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Screen',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Conversation'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ListTile(
                    title: Text('Conversation ${conversation.id}'),
                    subtitle: Text(conversation.members.join(', ')),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageScreen(
                            conversationId: conversation.id,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class MessageScreen extends StatefulWidget {
  final String conversationId;
  final String userId;

  const MessageScreen({
    Key? key,
    required this.conversationId,
    required this.userId,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController _controller = ScrollController();
  List<Message> messages = [];
  bool isLoading = true;
  late IO.Socket socket;
  @override
  void initState() {
    super.initState();
    fetchMessages();
    // initSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  // void initSocket() {
  //   socket = IO.io('http://192.168.1.9:3000');
  //   socket.onConnect((_) {
  //     print('Connected to the server');
  //   });
  //   socket.on('receive_message', (data) {
  //     print('New message received: $data');
  //     // You can parse the data into a Message object and add it to your messages list
  //     // Phân giải dữ liệu thành một đối tượng Message
  //     final newMessage = Message.fromJson(data);
  //     // Thêm tin nhắn mới vào danh sách messages
  //     setState(() {
  //       messages.insert(0, newMessage);
  //     });
  //   });
  //   socket.connect();
  // }

  Future<void> fetchMessages() async {
    final response =
        await http.get(Uri.parse('$API_BASE_ME${widget.conversationId}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        messages = List<Message>.from(
            jsonData['data'].map((x) => Message.fromJson(x)));
        isLoading = false;
      });
    }
  }

  Future<void> createMessage(String text) async {
    final message = {
      "conversationId": widget.conversationId,
      "sender": widget.userId,
      "text": text,
    };
    // socket.emit('send_message', message);
    final response = await http.post(
      Uri.parse(API_BASE_ME),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      // Tin nhắn được gửi thành công
      final jsonData = jsonDecode(response.body);
      final newMessage = Message.fromJson(jsonData);

      setState(() {
        //chèn một đối tượng newMessage vào vị trí đầu tiên (vị trí 0) của danh sách
        messages.insert(0, newMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller,
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.sender ==
                    widget.userId; // Thay 'me' bằng tên người dùng của bạn
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          'From: ${message.sender}',
                          style: const TextStyle(
                              fontSize: 12.0, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        messageText = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () async {
                    createMessage(messageText);
                    _textController.clear();
                    await Future.delayed(const Duration(milliseconds: 500));
                    fetchMessages();
                    _controller.jumpTo(_controller.position.minScrollExtent);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController _textController = TextEditingController();
  String messageText = '';
}
