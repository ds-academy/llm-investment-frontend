import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../model/game_chart_data.dart';
import '../../model/game_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatefulWidget {
  final int currentRange; // 현재 표시할 차트 데이터 범위

  ChartPage({super.key, required this.currentRange});

  @override
  State<ChartPage> createState() => _ChartPageState();
}
class _ChartPageState extends State<ChartPage> {
  final GameService _gameService = GameService();
  final List<String> fixedTimes = ["09:00", "11:00", "13:00", "15:00"];
  String selectedInfo = ''; // 선택된 데이터 정보를 표시할 변수

  // TooltipBehavior 인스턴스 생성
  final TooltipBehavior _tooltipBehavior = TooltipBehavior(
    enable: true,
    format: '시가: {point.open}\n고가: {point.high}\n저가: {point.low}\n종가: {point.close}',
    tooltipPosition: TooltipPosition.pointer,
    borderWidth: 2,
    borderColor: Colors.blue,
    textStyle: TextStyle(color: Colors.white),
  );

  Future<GameChartData> _fetchData() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: "token") ?? '';
    return await _gameService.fetchChartData(token);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FutureBuilder<GameChartData>(
                future: _fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text("No data available"));
                  }

                  final gameChartData = snapshot.data!;
                  final gameChartInfo = gameChartData.gameChartInfo;

                  // `currentRange`에 따라 차트 데이터 생성
                  List<CandleData> chartData = List<CandleData>.generate(4, (index) {
                    if (index < widget.currentRange) {
                      final item = gameChartInfo[index];
                      return CandleData(
                        time: fixedTimes[index],
                        open: item.open,
                        high: item.high,
                        low: item.low,
                        current: item.current,
                      );
                    } else {
                      return CandleData(time: fixedTimes[index], open: null, high: null, low: null, current: null);
                    }
                  });
                  print("차트 데이터: ${chartData.map((e) => e.toString()).toList()}");

                  return SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      interval: 1,
                      labelPlacement: LabelPlacement.onTicks,
                      majorGridLines: MajorGridLines(width: 1),
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      rangePadding: ChartRangePadding.additional,
                    ),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                      opposedPosition: true,
                    ),
                    tooltipBehavior: _tooltipBehavior,
                    series: <CandleSeries<CandleData, String>>[
                      CandleSeries<CandleData, String>(
                        dataSource: chartData,
                        xValueMapper: (CandleData data, _) => data.time,
                        lowValueMapper: (CandleData data, _) => data.low,
                        highValueMapper: (CandleData data, _) => data.high,
                        openValueMapper: (CandleData data, _) => data.open,
                        closeValueMapper: (CandleData data, _) => data.current,
                        bearColor: Colors.blueAccent, // 음봉 색상
                        bullColor: Colors.red, // 양봉 색상
                        enableTooltip: true, // 툴팁 활성화
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FutureBuilder<GameChartData>(
                future: _fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text("No data available"));
                  }

                  final gameChartData = snapshot.data!;
                  final dailyChartData = gameChartData.dailyChartData;

                  // 일별 차트 데이터 생성
                  List<CandleData> dailyChart = List<CandleData>.generate(dailyChartData.length-1, (index) {
                    final item = dailyChartData[index];
                    return CandleData(
                      time: 'Turn ${index + 1}',
                      open: item.open,
                      high: item.high,
                      low: item.low,
                      current: item.close,
                    );
                  });

                  return SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelPlacement: LabelPlacement.onTicks,
                      majorGridLines: MajorGridLines(width: 1),
                      rangePadding: ChartRangePadding.additional,
                    ),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                      opposedPosition: true,
                    ),
                    series: <CandleSeries<CandleData, String>>[
                      CandleSeries<CandleData, String>(
                        dataSource: dailyChart,
                        xValueMapper: (CandleData data, _) => data.time,
                        lowValueMapper: (CandleData data, _) => data.low,
                        highValueMapper: (CandleData data, _) => data.high,
                        openValueMapper: (CandleData data, _) => data.open,
                        closeValueMapper: (CandleData data, _) => data.current,
                        bearColor: Colors.blueAccent,
                        bullColor: Colors.red,
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CandleData {
  final String time;
  final double? open;
  final double? high;
  final double? low;
  final double? current;

  CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.current,
  });

  @override
  String toString() {
    return 'CandleData(time: $time, open: $open, high: $high, low: $low, current: $current)';
  }
}
