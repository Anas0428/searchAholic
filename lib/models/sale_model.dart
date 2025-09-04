import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  final String saleId;
  final String customerPhone;
  final double saleAmount;
  final Map<String, int> saleProducts;
  final String notes;
  final DateTime? saleDate;
  final String userId;
  final DateTime? createdAt;

  SaleModel({
    required this.id,
    required this.saleId,
    required this.customerPhone,
    required this.saleAmount,
    required this.saleProducts,
    required this.notes,
    this.saleDate,
    required this.userId,
    this.createdAt,
  });

  // Create SaleModel from Firestore document
  factory SaleModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SaleModel(
      id: documentId,
      saleId: data['saleId'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      saleAmount: (data['saleAmount'] ?? 0).toDouble(),
      saleProducts: Map<String, int>.from(data['saleProducts'] ?? {}),
      notes: data['notes'] ?? '',
      saleDate: data['saleDate'] is Timestamp 
          ? (data['saleDate'] as Timestamp).toDate()
          : data['saleDate'] is String
              ? DateTime.tryParse(data['saleDate'])
              : null,
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : data['createdAt'] is String
              ? DateTime.tryParse(data['createdAt'])
              : null,
    );
  }

  // Convert SaleModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'customerPhone': customerPhone,
      'saleAmount': saleAmount,
      'saleProducts': saleProducts,
      'notes': notes,
      'saleDate': saleDate != null ? Timestamp.fromDate(saleDate!) : FieldValue.serverTimestamp(),
      'userId': userId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  SaleModel copyWith({
    String? id,
    String? saleId,
    String? customerPhone,
    double? saleAmount,
    Map<String, int>? saleProducts,
    String? notes,
    DateTime? saleDate,
    String? userId,
    DateTime? createdAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      customerPhone: customerPhone ?? this.customerPhone,
      saleAmount: saleAmount ?? this.saleAmount,
      saleProducts: saleProducts ?? this.saleProducts,
      notes: notes ?? this.notes,
      saleDate: saleDate ?? this.saleDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SaleModel(id: $id, saleId: $saleId, customerPhone: $customerPhone, saleAmount: $saleAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
