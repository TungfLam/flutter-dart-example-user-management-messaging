import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './user.model.dart';
import 'helpers.dart';

const String API_BASE_PAGINATION = 'http://$ipv4:3000/api/users/pagination';
const String API_BASE = 'http://$ipv4:3000/api/users';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {
  late TextEditingController _searchController;
  bool isLoading = true;

  late int currentPage = 1;
  late int currentPageL = 0;
  late int currentPageR = 2;
  late bool isLastPage;
  List<Data> users = [];
  get token => null;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Thực hiện khởi tạo
    fetchUsers();
    _searchController = TextEditingController();

    _searchController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Cập nhật lại danh sách khi người dùng xóa ký tự cuối cùng.
    if (_searchController.selection.isCollapsed) {
      setState(() {
        if (_searchController.text.isEmpty) {
          users = [];
          fetchUsers();
        } else {
          users = users.where((user) {
            return user.username?.contains(_searchController.text) ?? false;
          }).toList();
        }
      });
    }
  }

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('$API_BASE_PAGINATION?page=$currentPage'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];

      users = jsonResponse.map((user) => Data.fromJson(user)).toList();
      isLastPage = jsonResponse.length < 5;
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$API_BASE/$id'),
    );

    if (response.statusCode == 200) {
      print('User deleted successfully.');
    } else {
      throw Exception('Failed to delete user.');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$API_BASE/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('User updated successfully.');
    } else {
      throw Exception('Failed to update user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trả về widget
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Screen',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
        ),
        //====
        body: Column(
          children: [
            Expanded(
              flex: 0,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm..',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 110, 127, 142)),
                  ),
                ),
              ),
            ),
            //==

            Expanded(
              flex: 2,
              // ListView này sẽ hiển thị danh sách người dùng được lấy từ API.
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  // ignore: unnecessary_null_comparison
                  if (user != null) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'http://$ipv4:3000${user.avata ?? 'default.png'}',
                          ),
                          radius: 30,
                        ),
                        title: Text(
                          'Username: ${user.username ?? 'No username provided'}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Email: ${user.email ?? 'No email provided'}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Phone Number: ${user.phonenumber.toString()}',
                                style: const TextStyle(fontSize: 16)),
                            Text(
                                'Address: ${user.address ?? 'No address provided'}',
                                style: const TextStyle(fontSize: 16)),
                            Text('_id: ${user.sId ?? 'No address provided'}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              //===
                              // đổ dữ liệu vào TextField
                              // usernameController.text = user.username!;
                              // passwdController.text = user.passwd!;
                              // emailController.text = user.email!;
                              // phonenumberController.text =
                              //     user.phonenumber.toString();
                              // addressController.text = user.address!;
                              //===
                              final usernameController =
                                  TextEditingController(text: user.username);

                              final passwdController =
                                  TextEditingController(text: user.passwd);
                              final emailController =
                                  TextEditingController(text: user.email);
                              final phonenumberController =
                                  TextEditingController(
                                      text: user.phonenumber.toString());
                              final addressController =
                                  TextEditingController(text: user.address);
                              //==

                              return AlertDialog(
                                title:
                                    const Text('Chi tiết thông tin của user'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    key: _formKey,
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      TextFormField(
                                        controller: usernameController,
                                        decoration: const InputDecoration(
                                            labelText: 'Username'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'username không được để trống';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: passwdController,
                                        decoration: const InputDecoration(
                                            labelText: 'Password'),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'mật khẩu không được để trống';
                                          } else if (value.length < 6) {
                                            return 'mật khẩu phải lớn hơn hoặc bằng 6 ký tự';
                                          } else if (!RegExp(r'\d')
                                              .hasMatch(value)) {
                                            return 'Mật khẩu phải chứa ít nhất một chữ số';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: emailController,
                                        decoration: const InputDecoration(
                                            labelText: 'Email'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'email không được để trống';
                                          } else if (!RegExp(
                                                  r'^[^@]+@[^@]+\.[^@]+')
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
                                        decoration: const InputDecoration(
                                            labelText: 'Phone Number'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'số điện thoại không được để trống';
                                          } else if (value.length < 14 ||
                                              value.length > 14) {
                                            return 'độ dài số điện thoại là 14';
                                          }
                                          return null;
                                        },
                                      ),
                                      TextFormField(
                                        controller: addressController,
                                        decoration: const InputDecoration(
                                            labelText: 'Address'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'địa chỉ không được để trống';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      // Hiển thị dialog hiển thị chi tiết thông tin của user
                                      //==
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Xác nhận'),
                                            content: const Text(
                                                'Bạn có chắc chắn muốn cập nhật người dùng này'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Hủy'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Đóng hộp thoại
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Đồng ý'),
                                                onPressed: () async {
                                                  // Thực hiện hành động của bạn tại đây

                                                  if (user.sId != null) {
                                                    // print(usernameController.text);

                                                    String username =
                                                        usernameController.text;
                                                    String password =
                                                        passwdController.text;
                                                    String email =
                                                        emailController.text;
                                                    int phonenumber = int.parse(
                                                        phonenumberController
                                                            .text);
                                                    String address =
                                                        addressController.text;

                                                    Map<String, dynamic>
                                                        dataUpdate = {
                                                      "username": username,
                                                      "passwd": password,
                                                      "email": email,
                                                      "phonenumber":
                                                          phonenumber,
                                                      "address": address,
                                                    };
                                                    //==
                                                    print(usernameController
                                                        .text);
                                                    print(user.sId);
                                                    print(dataUpdate);

                                                    await updateUser(
                                                        (user.sId!),
                                                        dataUpdate);

                                                    fetchUsers();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Cập nhật thành công'),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Cập nhật thất bại'),
                                                      ),
                                                    );
                                                  }
                                                  Navigator.pop(context);
                                                  Navigator.of(context)
                                                      .pop(); // Đóng hộp thoại
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Cập nhật'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Xác nhận'),
                                            content: const Text(
                                                'Bạn có chắc chắn muốn xóa người dùng này'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Hủy'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Đóng hộp thoại
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Đồng ý'),
                                                onPressed: () async {
                                                  // Thực hiện hành động của bạn tại đây

                                                  if (user.sId != null) {
                                                    await deleteUser(user.sId!);
                                                    fetchUsers();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Xóa thành công'),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Xóa thất bại'),
                                                      ),
                                                    );
                                                  }
                                                  Navigator.pop(context);
                                                  Navigator.of(context)
                                                      .pop(); // Đóng hộp thoại
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Xóa'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Hủy'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    currentPage--;
                    currentPageR--;
                    currentPageL--;
                    if (currentPage < 1) {
                      currentPage = 1;
                      currentPageL = 0;
                      currentPageR = 2;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn đang ở trang đầu tiên'),
                        ),
                      );
                    }
                    fetchUsers();
                  },
                  child: Text('<<   $currentPageL   |'),
                ),
                Text(currentPage.toString(),
                    style: const TextStyle(fontSize: 15)),
                // nút "Next"
                TextButton(
                  onPressed: () {
                    if (!isLastPage) {
                      currentPage++;
                      currentPageR++;
                      currentPageL++;
                      fetchUsers();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã đến trang cuối cùng'),
                        ),
                      );
                    }
                  },
                  child: Text('|   $currentPageR   >>'),
                ),
                // nút "Previous"
              ],
            ),
          ],
        ),
      ),
    );
  }
}
