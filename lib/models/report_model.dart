import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for user-submitted reports
class ReportModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'emergency', 'complaint', 'suggestion', 'other'
  final String status; // 'pending', 'in_progress', 'resolved', 'rejected'
  final String userId;
  final String userName;
  final String barangayId;
  final String? imageUrl;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? adminResponse;
  final String? assignedToId;
  final String? assignedToName;
  final int priority; // 1-5, 5 being highest

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'pending',
    required this.userId,
    required this.userName,
    required this.barangayId,
    this.imageUrl,
    this.location,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.adminResponse,
    this.assignedToId,
    this.assignedToName,
    this.priority = 3,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'other',
      status: map['status'] ?? 'pending',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      barangayId: map['barangayId'] ?? '',
      imageUrl: map['imageUrl'],
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      adminResponse: map['adminResponse'],
      assignedToId: map['assignedToId'],
      assignedToName: map['assignedToName'],
      priority: map['priority'] ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'userId': userId,
      'userName': userName,
      'barangayId': barangayId,
      'imageUrl': imageUrl,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'adminResponse': adminResponse,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'priority': priority,
    };
  }

  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? status,
    String? userId,
    String? userName,
    String? barangayId,
    String? imageUrl,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? adminResponse,
    String? assignedToId,
    String? assignedToName,
    int? priority,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      barangayId: barangayId ?? this.barangayId,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      priority: priority ?? this.priority,
    );
  }
}
