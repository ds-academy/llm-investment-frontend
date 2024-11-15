class GameBottomBarData {
  final int currentMoney;
  final int positionMoney;
  final int chartCurrent;
  final int gameDetailTurn;

  GameBottomBarData({
    required this.currentMoney,
    required this.positionMoney,
    required this.chartCurrent,
    required this.gameDetailTurn,
  });

  factory GameBottomBarData.fromJson(Map<String, dynamic> json) {
    return GameBottomBarData(
      currentMoney: json['current_money'] ?? 0,
      positionMoney: json['position_money'] ?? 0,
      chartCurrent: json['chart_current'] ?? 0,
      gameDetailTurn: json['game_detail_turn'] ?? 0,
    );
  }
}
