class Message {
  final String id;
  final String senderId;
  final String senderName; // NOUVEAU : Ajout du nom de l'expéditeur
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName, // NOUVEAU
    required this.text,
    required this.timestamp,
  });
}

class Conversation {
  final String id;
  final String otherPartyName;
  final String otherPartyType;
  final List<Message> messages;
  int unreadCountForCandidate;
  int unreadCountForCompany;

  Conversation({
    required this.id,
    required this.otherPartyName,
    required this.otherPartyType,
    required this.messages,
    this.unreadCountForCandidate = 0,
    this.unreadCountForCompany = 0,
  });
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Map<String, Conversation> _conversations = {};

  String _generateConversationId(String party1Id, String party2Id) {
    List<String> ids = [party1Id, party2Id]..sort();
    return ids.join('_');
  }

  Conversation getOrCreateConversationForCandidate({
    required String candidatEmail,
    required String candidatName,
    required String entrepriseName,
  }) {
    final convId = _generateConversationId(candidatEmail, entrepriseName);
    if (!_conversations.containsKey(convId)) {
      _conversations[convId] = Conversation(
        id: convId,
        otherPartyName: entrepriseName,
        otherPartyType: 'entreprise',
        messages: [],
      );
    }
    return _conversations[convId]!;
  }

  // Méthode pour entreprise (créer ou récupérer une conversation)
  String getOrCreateConversationForCompany({
    required String entrepriseName,
    required String candidatEmail,
    required String candidatName,
  }) {
    final convId = _generateConversationId(entrepriseName, candidatEmail);
    if (!_conversations.containsKey(convId)) {
      _conversations[convId] = Conversation(
        id: convId,
        otherPartyName: candidatName,  // Nom complet du candidat
        otherPartyType: 'candidat',
        messages: [],
      );
    }
    return convId;
  }

  void sendMessageFromCandidate(String candidatEmail, String candidatName, String entrepriseName, String text) {
    final convId = _generateConversationId(candidatEmail, entrepriseName);
    final conv = _conversations[convId];
    if (conv == null) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'candidat:$candidatEmail',
      senderName: candidatName,  // Nom complet du candidat
      text: text,
      timestamp: DateTime.now(),
    );
    conv.messages.add(message);
    conv.unreadCountForCompany++;
  }

  void sendMessageFromCompany(String conversationId, String entrepriseName, String text) {
    final conv = _conversations[conversationId];
    if (conv == null) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'entreprise:$entrepriseName',
      senderName: entrepriseName,  // Nom de l'entreprise
      text: text,
      timestamp: DateTime.now(),
    );
    conv.messages.add(message);
    conv.unreadCountForCandidate++;
  }

  void deleteMessage(String conversationId, String messageId) {
    final conv = _conversations[conversationId];
    if (conv != null) {
      conv.messages.removeWhere((msg) => msg.id == messageId);
    }
  }

  List<Conversation> getConversationsForCandidate(String candidatEmail) {
    return _conversations.values.where((conv) => conv.id.contains(candidatEmail)).toList();
  }

  List<Conversation> getConversationsForCompany(String entrepriseName) {
    return _conversations.values.where((conv) => conv.id.contains(entrepriseName)).toList();
  }

  void markAsReadForCandidate(String conversationId) {
    final conv = _conversations[conversationId];
    if (conv != null) conv.unreadCountForCandidate = 0;
  }

  void markAsReadForCompany(String conversationId) {
    final conv = _conversations[conversationId];
    if (conv != null) conv.unreadCountForCompany = 0;
  }

  int getTotalUnreadForCandidate(String candidatEmail) {
    int total = 0;
    for (var conv in getConversationsForCandidate(candidatEmail)) {
      total += conv.unreadCountForCandidate;
    }
    return total;
  }

  int getTotalUnreadForCompany(String entrepriseName) {
    int total = 0;
    for (var conv in getConversationsForCompany(entrepriseName)) {
      total += conv.unreadCountForCompany;
    }
    return total;
  }
}