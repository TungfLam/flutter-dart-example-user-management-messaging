import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helpers.dart';

const String API_BASE = 'http://$ipv4:3000/api/users';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create New User'),
        ),
        body: const CreateUserForm(),
      ),
    );
  }
}

class CreateUserForm extends StatefulWidget {
  const CreateUserForm({super.key});

  @override
  _CreateUserFormState createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwdController = TextEditingController();
  final emailController = TextEditingController();
  final phonenumberController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> createUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(API_BASE),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('User created successfully.');
    } else {
      throw Exception('Failed to create user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Thêm dòng này
      body: SingleChildScrollView(
        // Thêm widget này
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'username không được để trống';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwdController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'mật khẩu không được để trống';
                    } else if (value.length < 6) {
                      return 'mật khẩu phải lớn hơn hoặc bằng 6 ký tự';
                    } else if (!RegExp(r'\d').hasMatch(value)) {
                      return 'Mật khẩu phải chứa ít nhất một chữ số';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'email không được để trống';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'email không đúng định dạng';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: phonenumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'số điện thoại không được để trống';
                    } else if (value.length < 14 || value.length > 14) {
                      return 'độ dài số điện thoại là 14';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'địa chỉ không được để trống';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String username = usernameController.text;
                      String password = passwdController.text;
                      String email = emailController.text;
                      int phonenumber = int.parse(phonenumberController.text);
                      String address = addressController.text;
                      Map<String, dynamic> dataUpdate = {
                        "username": username,
                        "passwd": password,
                        "email": email,
                        "phonenumber": phonenumber,
                        "address": address,
                      };
                      await createUser(dataUpdate);
                      // Clear the text fields
                      usernameController.clear();
                      passwdController.clear();
                      emailController.clear();
                      phonenumberController.clear();
                      addressController.clear();
                      // Unfocus all text fields to close the keyboard
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thêm người dùng thành công'),
                        ),
                      );
                      // Thực hiện hành động của bạn tại đây
                      Navigator.of(context).pop(); // Đóng hộp thoại
                    }
                  },
                  child: const Text('Create User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
