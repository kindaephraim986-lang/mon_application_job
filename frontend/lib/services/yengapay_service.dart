import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import 'utils/constants.dart';

class YengaPayService {
  static final YengaPayService _instance = YengaPayService._internal();
  factory YengaPayService() => _instance;
  YengaPayService._internal();

  // Headers pour les requêtes API
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${AppConstants.yengapayApiKey}',
    'X-API-Secret': AppConstants.yengapayApiSecret,
  };

  // Initier un paiement
  Future<PaymentResponse?> initiatePayment(PaymentRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.yengapayBaseUrl}/payments/initiate'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      debugPrint('YengaPay Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'initiation du paiement');
      }
    } catch (e) {
      debugPrint('Initiation error: $e');
      rethrow;
    }
  }

  // Vérifier le statut d'un paiement
  Future<PaymentStatus> checkPaymentStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.yengapayBaseUrl}/payments/$transactionId/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentStatus.fromJson(data);
      } else {
        throw Exception('Erreur lors de la vérification du paiement');
      }
    } catch (e) {
      debugPrint('Status check error: $e');
      rethrow;
    }
  }

  // Annuler un paiement
  Future<bool> cancelPayment(String transactionId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.yengapayBaseUrl}/payments/$transactionId/cancel'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Cancel error: $e');
      return false;
    }
  }

  // Refund un paiement
  Future<bool> refundPayment(String transactionId, {double? amount, String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.yengapayBaseUrl}/payments/$transactionId/refund'),
        headers: _headers,
        body: jsonEncode({
          if (amount != null) 'amount': amount.toString(),
          if (reason != null) 'reason': reason,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Refund error: $e');
      return false;
    }
  }

  // Obtenir l'historique des transactions
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.yengapayBaseUrl}/transactions?user_id=$userId&page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions']);
      }
      return [];
    } catch (e) {
      debugPrint('History error: $e');
      return [];
    }
  }
}


