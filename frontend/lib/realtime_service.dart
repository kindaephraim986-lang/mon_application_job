import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'services/api_service.dart';
import 'candidature_service.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  socket_io.Socket? _socket;
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect({required String baseUrl}) {
    if (_socket != null && _socket!.connected) return;

    try {
      _socket = socket_io.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket!.on('connect', (_) {
        // print('Realtime connected: ${_socket!.id}');
      });

      _socket!.on('offers:refresh', (_) async {
        try {
          final offers = await ApiService.getOffers();
          CandidatureService().replaceOffers(List<Map<String, dynamic>>.from(offers));
        } catch (_) {
          // Ignore refresh failures and keep the UI responsive.
        }
      });

      _socket!.on('message:new', (data) {
        if (data is Map<String, dynamic>) {
          _messageController.add(data);
        }
      });

      _socket!.on('disconnect', (_) {
        // handle disconnect
      });
    } catch (_) {
      // Ignore socket initialization failures and let the app continue.
    }
  }

  void joinConversation(int convId) {
    _socket?.emit('joinConversation', convId);
  }

  void leaveConversation(int convId) {
    _socket?.emit('leaveConversation', convId);
  }

  void dispose() {
    _messageController.close();
    _socket?.dispose();
    _socket = null;
  }
}

