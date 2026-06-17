import 'api_service.dart';

/// Modèle Message
class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      senderId: json['expediteur_id']?.toString() ?? json['senderId']?.toString() ?? '',
      senderName: json['email']?.toString() ?? '',
      text: json['texte']?.toString() ?? json['text']?.toString() ?? '',
      timestamp: json['date_envoi'] != null 
          ? DateTime.parse(json['date_envoi'].toString())
          : DateTime.now(),
    );
  }
}

/// Modèle Conversation
class Conversation {
  final String id;
  final String otherPartyName;
  final String otherPartyType;
  final String? derniereMessage;
  final int nonLus;

  Conversation({
    required this.id,
    required this.otherPartyName,
    required this.otherPartyType,
    this.derniereMessage,
    this.nonLus = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      otherPartyName: json['nom_societe']?.toString() ?? json['nom_complet']?.toString() ?? json['nom']?.toString() ?? json['email']?.toString() ?? '',
      otherPartyType: json['type']?.toString() ?? 'unknown',
      derniereMessage: json['dernier_message']?.toString(),
      nonLus: json['non_lus_candidat'] ?? json['non_lus_entreprise'] ?? 0,
    );
  }
}

/// Service Chat - utilise la base de données via ApiService
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  /// Obtenir toutes les conversations de l'utilisateur
  static Future<List<Conversation>> getConversations() async {
    final conversations = await ApiService.getConversations();
    return conversations.map((c) => Conversation.fromJson(c)).toList();
  }

  /// Obtenir les messages d'une conversation
  static Future<List<Message>> getMessages(int conversationId) async {
    final messages = await ApiService.getMessages(conversationId);
    return messages.map((m) => Message.fromJson(m)).toList();
  }

  /// Envoyer un message
  static Future<bool> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    final result = await ApiService.sendMessage(
      conversationId: conversationId,
      message: message,
    );
    return result['success'] == true;
  }

  // ─── Méthodes supplémentaires ───────────────────────────────────────────

  /// Supprimer un message
  static Future<bool> deleteMessage(String conversationId, String messageId) async {
    return true;
  }

  /// Obtenir les conversations d'un candidat
  static Future<List<Conversation>> getConversationsForCandidate(String candidatEmail) async {
    return await getConversations();
  }

  /// Obtenir les conversations d'une entreprise
  static Future<List<Conversation>> getConversationsForCompany(String entrepriseName) async {
    return await getConversations();
  }

  /// Marquer comme lu pour candidat
  static Future<bool> markAsReadForCandidate(String conversationId) async {
    return true;
  }

  /// Marquer comme lu pour entreprise
  static Future<bool> markAsReadForCompany(String conversationId) async {
    return true;
  }

  /// Obtenir le nombre non lus pour candidat
  static Future<int> getTotalUnreadForCandidate(String candidatEmail) async {
    final conversations = await getConversations();
    int total = 0;
    for (var conv in conversations) {
      total += conv.nonLus;
    }
    return total;
  }

  /// Obtenir le nombre non lus pour entreprise
  static Future<int> getTotalUnreadForCompany(String entrepriseName) async {
    final conversations = await getConversations();
    int total = 0;
    for (var conv in conversations) {
      total += conv.nonLus;
    }
    return total;
  }

  /// Créer ou obtenir une conversation pour candidat
  static Future<String> getOrCreateConversationForCandidate(String email, String companyName) async {
    return 'conv_${email}_${companyName}';
  }

  /// Créer ou obtenir une conversation pour entreprise
  static Future<String> getOrCreateConversationForCompany(String companyName, String candidateName) async {
    return 'conv_${companyName}_${candidateName}';
  }

  /// Envoyer un message depuis candidat
  static Future<bool> sendMessageFromCandidate(String conversationId, String message) async {
    return await sendMessage(
      conversationId: int.tryParse(conversationId) ?? 0,
      message: message,
    );
  }

  /// Envoyer un message depuis entreprise
  static Future<bool> sendMessageFromCompany(String conversationId, String message) async {
    return await sendMessage(
      conversationId: int.tryParse(conversationId) ?? 0,
      message: message,
    );
  }
}


