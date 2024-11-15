class GameNewsData {
  final String inNewsTitle; // 내부 뉴스 제목
  final String inNewsInfo;  // 내부 뉴스 내용
  final String outNewsTitle; // 외부 뉴스 제목
  final String outNewsInfo;  // 외부 뉴스 내용

  // 생성자
  GameNewsData({
    required this.inNewsTitle,
    required this.inNewsInfo,
    required this.outNewsTitle,
    required this.outNewsInfo,
  });

  // JSON 데이터를 받아서 객체로 변환하는 팩토리 생성자
  factory GameNewsData.fromJson(Map<String, dynamic> json) {
    return GameNewsData(
      inNewsTitle: json['innews_title'] ?? '',
      inNewsInfo: json['innews_info'] ?? '',
      outNewsTitle: json['outnews_title'] ?? '',
      outNewsInfo: json['outnews_info'] ?? '',
    );
  }

  // 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'innews_title': inNewsTitle,
      'innews_info': inNewsInfo,
      'outnews_title': outNewsTitle,
      'outnewes_info': outNewsInfo,
    };
  }
}