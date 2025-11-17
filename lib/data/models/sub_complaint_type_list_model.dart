class ComplaintSubTypeModel {
  final int id;
  final int complaintTypeId;
  final String complaintSubType;
  final int status;
  final DateTime createdDate;
  final int entryBy;
  final String tamilText;
  final String priority;
  final String assignType;
  final String complaintType;
  final List<TemplateModel> templates;

  ComplaintSubTypeModel({
    required this.id,
    required this.complaintTypeId,
    required this.complaintSubType,
    required this.status,
    required this.createdDate,
    required this.entryBy,
    required this.tamilText,
    required this.priority,
    required this.assignType,
    required this.complaintType,
    required this.templates,
  });

  factory ComplaintSubTypeModel.fromJson(Map<String, dynamic> json) {
    return ComplaintSubTypeModel(
      id: json['id'],
      complaintTypeId: json['complaint_type_id'],
      complaintSubType: json['complaint_sub_type'],
      status: json['status'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      tamilText: json['tamil_text'],
      priority: json['priority'],
      assignType: json['assign_type'],
      complaintType: json['complaint_type'],
      templates: (json['templates'] as List)
          .map((e) => TemplateModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_type_id': complaintTypeId,
      'complaint_sub_type': complaintSubType,
      'status': status,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'tamil_text': tamilText,
      'priority': priority,
      'assign_type': assignType,
      'complaint_type': complaintType,
      'templates': templates.map((e) => e.toJson()).toList(),
    };
  }
}
class TemplateModel {
  final int id;
  final int complaintSubTypeId;
  final String template;
  final String tamilText;
  final DateTime createdDate;
  final int entryBy;
  final int status;
  final String variableId;

  TemplateModel({
    required this.id,
    required this.complaintSubTypeId,
    required this.template,
    required this.tamilText,
    required this.createdDate,
    required this.entryBy,
    required this.status,
    required this.variableId,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'],
      complaintSubTypeId: json['complaint_sub_type_id'],
      template: json['template'],
      tamilText: json['tamil_text'],
      createdDate: DateTime.parse(json['created_date']),
      entryBy: json['entry_by'],
      status: json['status'],
      variableId: json['variable_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_sub_type_id': complaintSubTypeId,
      'template': template,
      'tamil_text': tamilText,
      'created_date': createdDate.toIso8601String(),
      'entry_by': entryBy,
      'status': status,
      'variable_id': variableId,
    };
  }
}
