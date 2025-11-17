
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for emergency hotlines
class HotlineModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String category; // 'emergency', 'health', 'police', 'fire', 'barangay', 'other'
  final String? description;
  final String barangayId;
  final bool isActive;
  final bool isEmergency;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HotlineModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.category,
    this.description,
    required this.barangayId,
    this.isActive = true,
    this.isEmergency = false,
    this.displayOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory HotlineModel.fromMap(Map<String, dynamic> map, String id) {
    return HotlineModel(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      category: map['category'] ?? 'other',
      description: map['description'],
      barangayId: map['barangayId'] ?? '',
      isActive: map['isActive'] ?? true,
      isEmergency: map['isEmergency'] ?? false,
      displayOrder: map['displayOrder'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'category': category,
      'description': description,
      'barangayId': barangayId,
      'isActive': isActive,
      'isEmergency': isEmergency,
      'displayOrder': displayOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  HotlineModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? category,
    String? description,
    String? barangayId,
    bool? isActive,
    bool? isEmergency,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HotlineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      category: category ?? this.category,
      description: description ?? this.description,
      barangayId: barangayId ?? this.barangayId,
      isActive: isActive ?? this.isActive,
      isEmergency: isEmergency ?? this.isEmergency,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
