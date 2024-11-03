class Message {
  int? status;
  String? msg;
  List<Data>? data;

  Message({this.status, this.msg, this.data});

  Message.fromJson(Map<String, dynamic> json) {
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
  String? conversationId;
  String? sender;
  String? text;
  int? iV;

  Data({this.sId, this.conversationId, this.sender, this.text, this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    conversationId = json['conversationId'];
    sender = json['sender'];
    text = json['text'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['conversationId'] = conversationId;
    data['sender'] = sender;
    data['text'] = text;
    data['__v'] = iV;
    return data;
  }
}
