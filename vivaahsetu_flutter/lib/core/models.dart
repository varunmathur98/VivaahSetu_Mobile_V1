class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.plan,
    required this.photos,
    this.city = '',
    this.state = '',
    this.occupation = '',
    this.religion = '',
    this.caste = '',
    this.about = '',
    this.phone = '',
  });

  final String id;
  final String email;
  final String name;
  final String plan;
  final List<String> photos;
  final String city;
  final String state;
  final String occupation;
  final String religion;
  final String caste;
  final String about;
  final String phone;

  factory UserProfile.fromMap(Map<String, dynamic> raw) {
    final id = (raw['id'] ?? raw['_id'] ?? raw['user_id'] ?? '').toString();
    final occupation = (raw['occupation'] ?? raw['profession'] ?? '')
        .toString();
    final photosRaw = raw['photos'] is List
        ? List<dynamic>.from(raw['photos'] as List)
        : <dynamic>[];
    final photos = photosRaw
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
    final preferredPhoto =
        (raw['photoUrl'] ?? raw['profile_photo'] ?? raw['profilePhoto'] ?? '')
            .toString();
    if (preferredPhoto.isNotEmpty && !photos.contains(preferredPhoto)) {
      photos.insert(0, preferredPhoto);
    }
    return UserProfile(
      id: id,
      email: (raw['email'] ?? '').toString(),
      name: (raw['name'] ?? '').toString(),
      plan: (raw['plan'] ?? 'free').toString(),
      photos: photos,
      city: (raw['city'] ?? '').toString(),
      state: (raw['state'] ?? '').toString(),
      occupation: occupation,
      religion: (raw['religion'] ?? '').toString(),
      caste: (raw['caste'] ?? '').toString(),
      about: (raw['about'] ?? '').toString(),
      phone: (raw['phone'] ?? '').toString(),
    );
  }
}

class MatchCard {
  MatchCard({
    required this.profile,
    required this.requestSent,
    required this.requestReceived,
    required this.alreadyConnected,
  });

  final UserProfile profile;
  final bool requestSent;
  final bool requestReceived;
  final bool alreadyConnected;

  factory MatchCard.fromMap(Map<String, dynamic> raw) {
    return MatchCard(
      profile: UserProfile.fromMap(raw),
      requestSent: (raw['requestSent'] ?? raw['request_sent'] ?? false) == true,
      requestReceived:
          (raw['requestReceived'] ?? raw['request_received'] ?? false) == true,
      alreadyConnected:
          (raw['alreadyConnected'] ?? raw['already_connected'] ?? false) ==
          true,
    );
  }
}

class ConnectionItem {
  ConnectionItem({
    required this.profile,
    this.connectionId = '',
    this.connectedAt = '',
    this.expiresAt = '',
  });

  final UserProfile profile;
  final String connectionId;
  final String connectedAt;
  final String expiresAt;

  factory ConnectionItem.fromMap(Map<String, dynamic> raw) {
    return ConnectionItem(
      profile: UserProfile.fromMap(raw),
      connectionId: (raw['connectionId'] ?? '').toString(),
      connectedAt: (raw['connectedAt'] ?? raw['connected_at'] ?? '').toString(),
      expiresAt: (raw['expiresAt'] ?? raw['expires_at'] ?? '').toString(),
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.read = false,
    this.status = ChatMessageStatus.sent,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String createdAt;
  final bool read;
  final ChatMessageStatus status;

  factory ChatMessage.fromMap(Map<String, dynamic> raw) {
    return ChatMessage(
      id: (raw['id'] ?? raw['_id'] ?? '').toString(),
      senderId: (raw['senderId'] ?? raw['sender_id'] ?? '').toString(),
      receiverId: (raw['receiverId'] ?? raw['receiver_id'] ?? '').toString(),
      content: (raw['content'] ?? '').toString(),
      createdAt: (raw['createdAt'] ?? raw['created_at'] ?? '').toString(),
      read: (raw['read'] ?? false) == true,
      status: _statusFromRaw(raw['status']?.toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'createdAt': createdAt,
      'read': read,
      'status': status.name,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    String? createdAt,
    bool? read,
    ChatMessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      status: status ?? this.status,
    );
  }

  static ChatMessageStatus _statusFromRaw(String? value) {
    switch (value) {
      case 'sending':
        return ChatMessageStatus.sending;
      case 'failed':
        return ChatMessageStatus.failed;
      default:
        return ChatMessageStatus.sent;
    }
  }
}

enum ChatMessageStatus { sending, sent, failed }

class Plan {
  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.discountedPrice,
    required this.available,
    required this.features,
    this.badge = '',
    this.tagline = '',
  });

  final String id;
  final String name;
  final double price;
  final double discountedPrice;
  final bool available;
  final List<String> features;
  final String badge;
  final String tagline;

  factory Plan.fromMap(Map<String, dynamic> raw) {
    final featureList = raw['features'] is List
        ? List<dynamic>.from(raw['features'] as List)
        : <dynamic>[];
    final available =
        (raw['available'] ?? raw['is_available_for_checkout'] ?? true) == true;
    final discounted =
        raw['discountedPrice'] ?? raw['discounted_price'] ?? raw['price'] ?? 0;
    final price = raw['price'] ?? raw['original_price'] ?? discounted;
    return Plan(
      id: (raw['id'] ?? '').toString(),
      name: (raw['name'] ?? '').toString(),
      price: (price as num?)?.toDouble() ?? 0,
      discountedPrice: (discounted as num?)?.toDouble() ?? 0,
      available: available,
      features: featureList.map((item) => item.toString()).toList(),
      badge: (raw['badge'] ?? '').toString(),
      tagline: (raw['tagline'] ?? '').toString(),
    );
  }
}

class PaymentStatus {
  PaymentStatus({
    required this.orderId,
    required this.status,
    this.paymentLink = '',
    this.message = '',
  });

  final String orderId;
  final String status;
  final String paymentLink;
  final String message;

  factory PaymentStatus.fromMap(Map<String, dynamic> raw) {
    String firstNonEmpty(List<dynamic> values) {
      for (final value in values) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    return PaymentStatus(
      orderId: (raw['orderId'] ?? raw['order_id'] ?? '').toString(),
      status: (raw['status'] ?? 'pending').toString(),
      paymentLink: firstNonEmpty([
        raw['paymentLink'],
        raw['payment_link'],
        raw['checkoutUrl'],
        raw['checkout_url'],
        raw['redirect_url'],
      ]),
      message: (raw['message'] ?? '').toString(),
    );
  }
}
