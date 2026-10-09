class IbTransactionResponse {
  final bool done;
  final List<IbTransaction> list;
  final int count;

  IbTransactionResponse({
    required this.done,
    required this.list,
    required this.count,
  });

  factory IbTransactionResponse.fromJson(Map<String, dynamic> json) {
    return IbTransactionResponse(
      done: json['done'] ?? false,
      list: (json['list'] as List?)?.map((e) => IbTransaction.fromJson(e)).toList() ?? [],
      count: json['count'] ?? 0,
    );
  }
}

class IbTransaction {
  final String? sId;
  final int? id;
  final num amount;
  final String? comment;
  final String? date;
  final IbTransactionType? type;
  final IbTransactionType? operation;
  final IbTransactionUser? user;
  final IbTransactionUser? addUserInfo;

  IbTransaction({
    this.sId,
    this.id,
    this.amount = 0,
    this.comment,
    this.date,
    this.type,
    this.operation,
    this.user,
    this.addUserInfo,
  });

  factory IbTransaction.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) => val is num ? val : num.tryParse(val?.toString() ?? '') ?? 0;
    
    return IbTransaction(
      sId: json['_id'],
      id: int.tryParse(json['id']?.toString() ?? ''),
      amount: parseNum(json['amount']),
      comment: json['comment'],
      date: json['date'],
      type: json['type'] != null ? IbTransactionType.fromJson(json['type']) : null,
      operation: json['operation'] != null ? IbTransactionType.fromJson(json['operation']) : null,
      user: json['user'] != null ? IbTransactionUser.fromJson(json['user']) : null,
      addUserInfo: json['addUserInfo'] != null ? IbTransactionUser.fromJson(json['addUserInfo']) : null,
    );
  }
}

class IbTransactionType {
  final String? code;
  final String? name;

  IbTransactionType({this.code, this.name});

  factory IbTransactionType.fromJson(Map<String, dynamic> json) {
    return IbTransactionType(
      code: json['code']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

class IbTransactionUser {
  final String? sId;
  final int? id;
  final String? name;
  final String? email;

  IbTransactionUser({this.sId, this.id, this.name, this.email});

  factory IbTransactionUser.fromJson(Map<String, dynamic> json) {
    return IbTransactionUser(
      sId: json['_id'],
      id: int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? json['name_en']?.toString(),
      email: json['email']?.toString(),
    );
  }
}
