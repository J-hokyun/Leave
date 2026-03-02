class UsedHistoryRequest {
  final String id;
  final String userId;
  final String date;

  UsedHistoryRequest({
    required this.id,
    required this.userId,
    required this.date,
  });

  // 객체를 JSON(Map)으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {'id': id, 'userId': userId, 'date': date};
  }
}
