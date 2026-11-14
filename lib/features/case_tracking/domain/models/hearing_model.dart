class HearingModel {
  final String id;
  final String title;
  final String courtName;
  final DateTime hearingDate;
  final String hearingTime;
  final String caseId;
  final String notes;

  HearingModel({
    required this.id,
    required this.title,
    required this.courtName,
    required this.hearingDate,
    required this.hearingTime,
    this.caseId = '',
    this.notes = '',
  });

  factory HearingModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    final d = map['hearingDate'];
    if (d is DateTime) {
      parsedDate = d;
    } else if (d != null && d.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (d as dynamic).toDate();
    } else if (d is String) {
      parsedDate = DateTime.tryParse(d) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return HearingModel(
      id: id,
      title: map['title']?.toString() ?? '',
      courtName: map['courtName']?.toString() ?? '',
      hearingDate: parsedDate,
      hearingTime: map['hearingTime']?.toString() ?? '',
      caseId: map['caseId']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'courtName': courtName,
      'hearingDate': hearingDate.toIso8601String(),
      'hearingTime': hearingTime,
      'caseId': caseId,
      'notes': notes,
    };
  }
}
