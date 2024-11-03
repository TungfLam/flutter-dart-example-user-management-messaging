import 'package:flutter/material.dart';
import './home_screen.dart';
import './add_screen.dart';
import './conversation_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers.dart';

// import './backupHome.dart';

const String API_BASE = 'http://$ipv4:3000/api/userslogin';
const String API_BASE_username = 'http://$ipv4:3000/api';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: const Material(child: LoginForm()),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isButtonEnabled = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      isButtonEnabled = usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  //=========

  Future<void> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse(API_BASE),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'passwd': password,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(
                  userId: '',
                )),
      );
      getUserByUsername(username);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('thông tin tài khoản hoặc mật khẩu không chính xác'),
        ),
      );
      throw Exception('Failed to login.');
    }
  }

  // =========
  Future<void> getUserByUsername(String username) async {
    final response = await http.get(
      Uri.parse('$API_BASE_username/users/r/$username'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      var userId = jsonResponse['data']['id'];
      print('User ID: $userId');

      navigateToNextScreen(context, userId);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('đã tìm thấy người dùng'),
      //   ),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy người dùng với tên người dùng này'),
        ),
      );
      throw Exception('Failed to get user.');
    }
  }

  void navigateToNextScreen(BuildContext context, String userId) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MyHomePage(userId: userId)));
  }
  // =========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50.0),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: _obscureText,
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                        String username = usernameController.text;
                        String password = passwordController.text;

                        loginUser(username, password);
                        print(username + password);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? Colors.blue : Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String userId;

  const MyHomePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Flutter Bottom Navigation Bar'),
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const AddScreen(),
          ConversationScreen(
            // userId: '648825983f38c4c4f33a9eaf',
            // Sử dụng userId ở đây
            userId: widget.userId,
            // Sử dụng userId ở đây
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add user',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Conversation',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.people),
          //   label: 'Chat',
          // ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
