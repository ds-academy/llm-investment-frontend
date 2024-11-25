class GameAppBarData {
  final String companyName;
  final int currentTurn;
  final String chartTime;

  GameAppBarData({
    required this.companyName,
    required this.currentTurn,
    required this.chartTime,
  });

  // JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory GameAppBarData.fromJson(Map<String, dynamic> json) {
    final companyAliasList = json['company_alias'] as List<dynamic>;
    final companyInfo = companyAliasList.isNotEmpty ? companyAliasList[0] : null;

    return GameAppBarData(
      companyName: companyInfo != null ? companyInfo['COMPANY_ALIAS'] : 'Unknown Company',
      currentTurn: json['current_turn'] ?? 0,
      chartTime: json['chart_time'] ?? 'N/A',
    );
  }
}