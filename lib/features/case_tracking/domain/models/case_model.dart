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
    return CaseModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      nextHearingDate: map['nextHearingDate'] != null 
          ? DateTime.parse(map['nextHearingDate']) 
          : DateTime.now(),
      courtName: map['courtName'] ?? '',
      lawyerName: map['lawyerName'] ?? '',
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
