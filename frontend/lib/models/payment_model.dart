class PaymentRequest {
  final double amount;
  final String currency;
  final String description;
  final String customerEmail;
  final String customerPhone;
  final String callbackUrl;
  final String returnUrl;
  final Map<String, dynamic>? metadata;

  PaymentRequest({
    required this.amount,
    this.currency = 'XOF',
    required this.description,
    required this.customerEmail,
    required this.customerPhone,
    required this.callbackUrl,
    required this.returnUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'description': description,
    'customer_email': customerEmail,
    'customer_phone': customerPhone,
    'callback_url': callbackUrl,
    'return_url': returnUrl,
    if (metadata != null) 'metadata': metadata,
  };
}

class PaymentResponse {
  final String transactionId;
  final String paymentUrl;
  final String status;

  PaymentResponse({
    required this.transactionId,
    required this.paymentUrl,
    required this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      transactionId: json['transaction_id'] ?? '',
      paymentUrl: json['payment_url'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class PaymentStatus {
  final String transactionId;
  final String status;
  final double amount;
  final DateTime? paidAt;

  PaymentStatus({
    required this.transactionId,
    required this.status,
    required this.amount,
    this.paidAt,
  });

  bool get isSuccess => status == 'success' || status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      transactionId: json['transaction_id'] ?? '',
      status: json['status'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }
}


