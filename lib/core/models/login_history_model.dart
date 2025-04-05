class LoginHistory {
  final String id;
  final DateTime date;
  final String ipAddress;
  final String userAgent;
  final String location;
  final String browser;

  LoginHistory({
    required this.id,
    required this.date,
    required this.ipAddress,
    required this.userAgent,
    required this.location,
    required this.browser,
  });

  factory LoginHistory.fromJson(Map<String, dynamic> json) {
    return LoginHistory(
      id: json['id'],
      date: DateTime.parse(json['date']),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      location: json['location'],
      browser: json['browser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'location': location,
      'browser': browser,
    };
  }
}
