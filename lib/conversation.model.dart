class Conversation {
  int? status;
  String? msg;
  List<Data>? data;

  Conversation({this.status, this.msg, this.data});

  Conversation.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  List<String>? members;
  int? iV;

  Data({this.sId, this.members, this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    members = json['members'].cast<String>();
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['members'] = members;
    data['__v'] = iV;
    return data;
  }
}
