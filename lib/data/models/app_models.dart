import 'grievance_status.dart';

/// Data models for TWAD application


/// Grievance model
class GrievanceModel {
  final String id;
  final String complaintNo;
  final String title;
  final String description;
  final GrievanceCategory category;
  final GrievanceStatus status;
  final GrievancePriority priority;
  final String userId;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final List<String>? attachments;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<GrievanceUpdate> updates;

  const GrievanceModel({
    required this.id,
    required this.complaintNo,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.userId,
    this.assignedTo,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.attachments,
    this.location,
    this.latitude,
    this.longitude,
    this.updates = const [],
  });

  factory GrievanceModel.fromJson(Map<String, dynamic> json) {
    return GrievanceModel(
      id: json['id'] as String,
      complaintNo: json['complaintNo'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: GrievanceCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      status: GrievanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      priority: GrievancePriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      userId: json['userId'] as String,
      assignedTo: json['assignedTo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      updates:
          (json['updates'] as List<dynamic>?)
              ?.map((e) => GrievanceUpdate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintNo': complaintNo,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'userId': userId,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'attachments': attachments,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'updates': updates.map((e) => e.toJson()).toList(),
    };
  }
}

/// Grievance update model
class GrievanceUpdate {
  final String id;
  final String grievanceId;
  final String message;
  final String updatedBy;
  final DateTime createdAt;
  final GrievanceStatus? statusChange;

  const GrievanceUpdate({
    required this.id,
    required this.grievanceId,
    required this.message,
    required this.updatedBy,
    required this.createdAt,
    this.statusChange,
  });

  factory GrievanceUpdate.fromJson(Map<String, dynamic> json) {
    return GrievanceUpdate(
      id: json['id'] as String,
      grievanceId: json['grievanceId'] as String,
      message: json['message'] as String,
      updatedBy: json['updatedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      statusChange: json['statusChange'] != null
          ? GrievanceStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['statusChange'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grievanceId': grievanceId,
      'message': message,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'statusChange': statusChange?.toString().split('.').last,
    };
  }
}

/// Notification model
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String userId;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId; // ID of related grievance, etc.
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.userId,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      userId: json['userId'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedId: json['relatedId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'userId': userId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
      'data': data,
    };
  }
}

/// Dashboard statistics model
class DashboardStats {
  final int totalGrievances;
  final int pendingGrievances;
  final int inProgressGrievances;
  final int resolvedGrievances;
  final int closedGrievances;
  final List<GrievanceModel> recentGrievances;
  final List<NotificationModel> recentNotifications;

  const DashboardStats({
    required this.totalGrievances,
    required this.pendingGrievances,
    required this.inProgressGrievances,
    required this.resolvedGrievances,
    required this.closedGrievances,
    required this.recentGrievances,
    required this.recentNotifications,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalGrievances: json['totalGrievances'] as int,
      pendingGrievances: json['pendingGrievances'] as int,
      inProgressGrievances: json['inProgressGrievances'] as int,
      resolvedGrievances: json['resolvedGrievances'] as int,
      closedGrievances: json['closedGrievances'] as int,
      recentGrievances: (json['recentGrievances'] as List<dynamic>)
          .map((e) => GrievanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentNotifications: (json['recentNotifications'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGrievances': totalGrievances,
      'pendingGrievances': pendingGrievances,
      'inProgressGrievances': inProgressGrievances,
      'resolvedGrievances': resolvedGrievances,
      'closedGrievances': closedGrievances,
      'recentGrievances': recentGrievances.map((e) => e.toJson()).toList(),
      'recentNotifications': recentNotifications
          .map((e) => e.toJson())
          .toList(),
    };
  }
}


enum GrievanceCategory {
  waterSupply,
  drainage,
  sewage,
  waterQuality,
  billing,
  newConnection,
  maintenance,
  other,
}

enum GrievancePriority { low, medium, high, urgent }

enum NotificationType {
  grievanceUpdate,
  statusChange,
  systemAlert,
  reminder,
  general,
}

/// Extension methods for enums
extension GrievanceStatusExtension on GrievanceStatus {
  String get displayName {
    switch (this) {
      case GrievanceStatus.draft:
        return 'Draft';
      case GrievanceStatus.submitted:
        return 'Submitted';
      case GrievanceStatus.acknowledged:
        return 'Acknowledged';
      case GrievanceStatus.inProgress:
        return 'In Progress';
      case GrievanceStatus.resolved:
        return 'Resolved';
      case GrievanceStatus.closed:
        return 'Closed';
      case GrievanceStatus.rejected:
        return 'Rejected';
      case GrievanceStatus.processing:
        return 'Processing';
    }
  }

  bool get isActive {
    return this == GrievanceStatus.submitted ||
        this == GrievanceStatus.acknowledged ||
        this == GrievanceStatus.inProgress;
  }

  bool get isCompleted {
    return this == GrievanceStatus.resolved || this == GrievanceStatus.closed;
  }
}

extension GrievanceCategoryExtension on GrievanceCategory {
  String get displayName {
    switch (this) {
      case GrievanceCategory.waterSupply:
        return 'Water Supply';
      case GrievanceCategory.drainage:
        return 'Drainage';
      case GrievanceCategory.sewage:
        return 'Sewage';
      case GrievanceCategory.waterQuality:
        return 'Water Quality';
      case GrievanceCategory.billing:
        return 'Billing';
      case GrievanceCategory.newConnection:
        return 'New Connection';
      case GrievanceCategory.maintenance:
        return 'Maintenance';
      case GrievanceCategory.other:
        return 'Other';
    }
  }
}

extension GrievancePriorityExtension on GrievancePriority {
  String get displayName {
    switch (this) {
      case GrievancePriority.low:
        return 'Low';
      case GrievancePriority.medium:
        return 'Medium';
      case GrievancePriority.high:
        return 'High';
      case GrievancePriority.urgent:
        return 'Urgent';
    }
  }
}
