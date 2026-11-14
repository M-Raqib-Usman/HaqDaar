class CaseModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'Active', 'Closed', 'Pending'
  final DateTime nextHearingDate;
  final String courtName;
  final String lawyerName;

  CaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.nextHearingDate,
    required this.courtName,
    required this.lawyerName,
  });

  factory CaseModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedHearingDate;
    final d = map['nextHearingDate'];
    if (d is DateTime) {
      parsedHearingDate = d;
    } else if (d != null && d.runtimeType.toString().contains('Timestamp')) {
      parsedHearingDate = (d as dynamic).toDate();
    } else if (d is String) {
      parsedHearingDate = DateTime.tryParse(d) ?? DateTime.now();
    } else {
      parsedHearingDate = DateTime.now();
    }

    return CaseModel(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Pending',
      nextHearingDate: parsedHearingDate,
      courtName: map['courtName']?.toString() ?? '',
      lawyerName: map['lawyerName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'nextHearingDate': nextHearingDate.toIso8601String(),
      'courtName': courtName,
      'lawyerName': lawyerName,
    };
  }
}
