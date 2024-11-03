class User {
  List<Data>? data;
  int? pAGESIZE;
  int? soLuongBoQua;
  int? page;

  User({this.data, this.pAGESIZE, this.soLuongBoQua, this.page});

  User.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    pAGESIZE = json['PAGE_SIZE'];
    soLuongBoQua = json['soLuongBoQua'];
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['PAGE_SIZE'] = pAGESIZE;
    data['soLuongBoQua'] = soLuongBoQua;
    data['page'] = page;
    return data;
  }
}

class Data {
  String? sId;
  String? username;
  String? passwd;
  String? email;
  String? avata;
  int? phonenumber;
  String? address;
  int? iV;

  Data(
      {this.sId,
      this.username,
      this.passwd,
      this.email,
      this.avata,
      this.phonenumber,
      this.address,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    passwd = json['passwd'];
    email = json['email'];
    avata = json['avata'];
    phonenumber = json['phonenumber'];
    address = json['address'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['username'] = username;
    data['passwd'] = passwd;
    data['email'] = email;
    data['avata'] = avata;
    data['phonenumber'] = phonenumber;
    data['address'] = address;
    data['__v'] = iV;
    return data;
  }
}
