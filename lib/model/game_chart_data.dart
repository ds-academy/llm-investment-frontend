class GameChartData {
  final int chartCurrent;
  final List<ChartInfo> gameChartInfo;
  final List<DailyChartData> dailyChartData;
  final List<DailyMoney> dailyMoney; // 추가

  GameChartData({
    required this.chartCurrent,
    required this.gameChartInfo,
    required this.dailyChartData,
    required this.dailyMoney, // 추가
  });

  factory GameChartData.fromJson(Map<String, dynamic> json) {
    final chartInfoList = (json['current_day_data'] as List<dynamic>)
        .map((item) => ChartInfo.fromJson(item))
        .toList();

    final dailyChartInfoList = (json['daily_chart_data'] as List<dynamic>)
        .map((item) => DailyChartData.fromJson(item))
        .toList();

    final dailyMoneyList = (json['daily_money'] as List<dynamic>)
        .map((item) => DailyMoney.fromJson(item))
        .toList();

    return GameChartData(
      chartCurrent: json['chart_current'],
      gameChartInfo: chartInfoList,
      dailyChartData: dailyChartInfoList,
      dailyMoney: dailyMoneyList,
    );
  }
}

class ChartInfo {
  final String time;
  final double open;
  final double high;
  final double low;
  final double current;

  ChartInfo({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.current,
  });

  factory ChartInfo.fromJson(Map<String, dynamic> json) {
    return ChartInfo(
      time: json['CHART_TIME'] ?? '',
      open: json['CHART_OPEN'] != null ? json['CHART_OPEN'].toDouble() : 0.0,
      high: json['CHART_HIGH'] != null ? json['CHART_HIGH'].toDouble() : 0.0,
      low: json['CHART_LOW'] != null ? json['CHART_LOW'].toDouble() : 0.0,
      current: json['CHART_CURRENT'] != null ? json['CHART_CURRENT'].toDouble() : 0.0,
    );
  }
}

class DailyChartData {
  final double open;
  final double close;
  final double high;
  final double low;

  DailyChartData({
    required this.open,
    required this.close,
    required this.high,
    required this.low,
  });

  factory DailyChartData.fromJson(Map<String, dynamic> json) {
    return DailyChartData(
      open: json['open'] != null ? json['open'].toDouble() : 0.0,
      close: json['close'] != null ? json['close'].toDouble() : 0.0,
      high: json['high'] != null ? json['high'].toDouble() : 0.0,
      low: json['low'] != null ? json['low'].toDouble() : 0.0,
    );
  }
}

class DailyMoney {
  final double totalMoney;

  DailyMoney({required this.totalMoney});

  factory DailyMoney.fromJson(Map<String, dynamic> json) {
    return DailyMoney(
      totalMoney: json['total_money'] != null ? json['total_money'].toDouble() : 0.0,
    );
  }
}