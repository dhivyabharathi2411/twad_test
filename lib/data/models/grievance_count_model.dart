class GrievanceCount {
  final int total;
  final int inProgress;
  final int onHold;
  final int closed;
  final int reopened;

  GrievanceCount({
    required this.total,
    required this.inProgress,
    required this.onHold,
    required this.closed,
    required this.reopened,
  });

  factory GrievanceCount.fromJson(Map<String, dynamic> json) {
    return GrievanceCount(
      total: json['total_grievance'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      onHold: json['on_hold'] ?? 0,
      closed: json['closed'] ?? 0,
      reopened: json['reopend'] ?? 0,
    );
  }
}
