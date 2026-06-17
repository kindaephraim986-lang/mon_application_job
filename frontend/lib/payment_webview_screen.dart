import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/yengapay_service.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;
  final Function(bool success, Map<String, dynamic>? data) onPaymentComplete;

  const PaymentWebViewScreen({
    Key? key,
    required this.paymentUrl,
    required this.transactionId,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  final YengaPayService _yengaPayService = YengaPayService();
  bool _isLoading = true;
  String? _error;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _startStatusPolling();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkPaymentCompletion(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = 'Erreur de chargement: ${error.description}';
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('success') || 
                request.url.contains('payment/success')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }
            if (request.url.contains('cancel') || 
                request.url.contains('payment/cancel')) {
              _handlePaymentCancel();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentCompletion(String url) {
    if (url.contains('success') || url.contains('payment/success')) {
      _handlePaymentSuccess();
    } else if (url.contains('cancel') || url.contains('payment/cancel')) {
      _handlePaymentCancel();
    }
  }

  void _startStatusPolling() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await _yengaPayService.checkPaymentStatus(widget.transactionId);
        if (status.isSuccess) {
          timer.cancel();
          _handlePaymentSuccess();
        } else if (status.isFailed || status.isCancelled) {
          timer.cancel();
          _handlePaymentCancel();
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  void _handlePaymentSuccess() async {
    if (_statusCheckTimer != null && _statusCheckTimer!.isActive) {
      _statusCheckTimer!.cancel();
    }
    
    try {
      final status = await _yengaPayService.checkPaymentStatus(widget.transactionId);
      if (mounted) {
        widget.onPaymentComplete(true, {
          'transaction_id': widget.transactionId,
          'status': 'success',
          'paid_at': status.paidAt?.toIso8601String(),
        });
      }
    } catch (e) {
      if (mounted) {
        widget.onPaymentComplete(true, {
          'transaction_id': widget.transactionId,
          'status': 'success',
        });
      }
    }
  }

  void _handlePaymentCancel() {
    _statusCheckTimer?.cancel();
    if (mounted) {
      widget.onPaymentComplete(false, {
        'transaction_id': widget.transactionId,
        'status': 'cancelled',
      });
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement sécurisé'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _handlePaymentCancel();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Chargement de la page de paiement...'),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _initWebView();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}


