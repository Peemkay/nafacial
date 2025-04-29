
/// Model for a Communication Center log entry
class ComCenLog {
  final String id;
  final String messageReference;
  final DateTime dateTime;
  final String messageType;
  final String precedence;
  final String originatorCallSign;
  final String addresseeCallSign;
  final String messageContent;
  final String operatorName;
  final String operatorRank;
  final String operatorArmyNumber;
  final String status;
  final String? remarks;
  final List<String>? attachments;

  ComCenLog({
    required this.id,
    required this.messageReference,
    required this.dateTime,
    required this.messageType,
    required this.precedence,
    required this.originatorCallSign,
    required this.addresseeCallSign,
    required this.messageContent,
    required this.operatorName,
    required this.operatorRank,
    required this.operatorArmyNumber,
    required this.status,
    this.remarks,
    this.attachments,
  });

  /// Create a ComCenLog from a map (e.g., from JSON)
  factory ComCenLog.fromMap(Map<String, dynamic> map) {
    return ComCenLog(
      id: map['id'] ?? '',
      messageReference: map['messageReference'] ?? '',
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'])
          : DateTime.now(),
      messageType: map['messageType'] ?? '',
      precedence: map['precedence'] ?? '',
      originatorCallSign: map['originatorCallSign'] ?? '',
      addresseeCallSign: map['addresseeCallSign'] ?? '',
      messageContent: map['messageContent'] ?? '',
      operatorName: map['operatorName'] ?? '',
      operatorRank: map['operatorRank'] ?? '',
      operatorArmyNumber: map['operatorArmyNumber'] ?? '',
      status: map['status'] ?? 'Pending',
      remarks: map['remarks'],
      attachments: map['attachments'] != null
          ? List<String>.from(map['attachments'])
          : null,
    );
  }

  /// Convert ComCenLog to a map (e.g., for JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'messageReference': messageReference,
      'dateTime': dateTime.toIso8601String(),
      'messageType': messageType,
      'precedence': precedence,
      'originatorCallSign': originatorCallSign,
      'addresseeCallSign': addresseeCallSign,
      'messageContent': messageContent,
      'operatorName': operatorName,
      'operatorRank': operatorRank,
      'operatorArmyNumber': operatorArmyNumber,
      'status': status,
      'remarks': remarks,
      'attachments': attachments,
    };
  }

  /// Create a copy of this ComCenLog with the given fields replaced
  ComCenLog copyWith({
    String? id,
    String? messageReference,
    DateTime? dateTime,
    String? messageType,
    String? precedence,
    String? originatorCallSign,
    String? addresseeCallSign,
    String? messageContent,
    String? operatorName,
    String? operatorRank,
    String? operatorArmyNumber,
    String? status,
    String? remarks,
    List<String>? attachments,
  }) {
    return ComCenLog(
      id: id ?? this.id,
      messageReference: messageReference ?? this.messageReference,
      dateTime: dateTime ?? this.dateTime,
      messageType: messageType ?? this.messageType,
      precedence: precedence ?? this.precedence,
      originatorCallSign: originatorCallSign ?? this.originatorCallSign,
      addresseeCallSign: addresseeCallSign ?? this.addresseeCallSign,
      messageContent: messageContent ?? this.messageContent,
      operatorName: operatorName ?? this.operatorName,
      operatorRank: operatorRank ?? this.operatorRank,
      operatorArmyNumber: operatorArmyNumber ?? this.operatorArmyNumber,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      attachments: attachments ?? this.attachments,
    );
  }
}
