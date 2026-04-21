Map<String, dynamic> asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<dynamic> asList(dynamic value) =>
    value is List ? List<dynamic>.from(value) : <dynamic>[];

String? resolveMediaUrl(String baseUrl, String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('data:')) {
    return value;
  }
  final clean = baseUrl.replaceAll(RegExp(r'/+$'), '');
  if (value.startsWith('/')) {
    return '$clean$value';
  }
  return '$clean/$value';
}

List<String> photoUrls(String baseUrl, Map<String, dynamic> data) {
  final urls = <String>{};
  for (final item in asList(data['photos'])) {
    final resolved = resolveMediaUrl(baseUrl, item?.toString());
    if (resolved != null) urls.add(resolved);
  }
  for (final candidate in [
    data['photoUrl'],
    data['profilePhoto'],
    data['profile_photo'],
    data['avatar'],
    data['image'],
    data['imageUrl'],
    data['image_url'],
  ]) {
    final preferred = resolveMediaUrl(baseUrl, candidate?.toString());
    if (preferred != null) urls.add(preferred);
  }
  return urls.toList();
}

Map<String, dynamic> normalizeUserPayload(Map<String, dynamic> raw) {
  final user = Map<String, dynamic>.from(raw);
  final location = user['location']?.toString().trim() ?? '';
  final locationParts = location
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  final photos = asList(user['photos']);
  final photoUrl = (user['photoUrl']?.toString().trim().isNotEmpty == true)
      ? user['photoUrl'].toString().trim()
      : (user['profile_photo']?.toString().trim().isNotEmpty == true)
      ? user['profile_photo'].toString().trim()
      : (user['profilePhoto']?.toString().trim().isNotEmpty == true)
      ? user['profilePhoto'].toString().trim()
      : (photos.isNotEmpty ? photos.first.toString() : '');
  user['id'] ??= user['_id']?.toString() ?? user['user_id']?.toString();
  user['dob'] ??= user['date_of_birth'];
  user['dateOfBirth'] ??= user['date_of_birth'];
  user['city'] ??= locationParts.isNotEmpty ? locationParts.first : '';
  user['state'] ??= locationParts.length > 1
      ? locationParts.sublist(1).join(', ')
      : '';
  user['occupation'] ??= user['profession'];
  user['familyDetails'] ??= user['family_details'];
  user['partnerPreferences'] ??= user['partner_preferences'];
  user['maritalStatus'] ??= user['marital_status'];
  user['photoUrl'] ??= photoUrl;
  final relStatus =
      (user['relationshipStatus'] ?? user['relationship_status'] ?? '')
          .toString()
          .toUpperCase();
  if (relStatus.isNotEmpty) {
    user['relationshipStatus'] = relStatus;
    user['relationship_status'] = relStatus;
  }
  user['requestSent'] ??=
      relStatus == 'REQUEST_SENT' || user['request_sent'] == true;
  user['alreadyConnected'] ??=
      relStatus == 'CONNECTED' || user['already_connected'] == true;
  user['requestReceived'] ??=
      relStatus == 'REQUEST_RECEIVED' || user['request_received'] == true;
  user['connectedAt'] ??= user['connected_at'];
  user['expiresAt'] ??= user['expires_at'];
  user['planExpiresAt'] ??= user['plan_expires_at'];
  user['emailVerified'] ??= user['email_verified'];
  user['isVerified'] ??= user['is_verified'];
  user['authProvider'] ??= user['auth_provider'];
  user['firebaseUid'] ??= user['firebase_uid'];
  user['motherTongue'] ??= user['mother_tongue'];
  user['subCaste'] ??= user['sub_caste'];
  user['subCaste'] ??= user['subcast'];
  user['profilePhoto'] ??= user['profile_photo'];
  return user;
}

Map<String, dynamic> normalizeResponseMap(Map<String, dynamic> raw) {
  final data = Map<String, dynamic>.from(raw);
  if (data.length == 1 && data['user'] is Map) {
    return normalizeUserPayload(asMap(data['user']));
  }
  if (data.containsKey('user') && data['user'] is Map) {
    data['user'] = normalizeUserPayload(asMap(data['user']));
  }
  if (data.containsKey('matches')) {
    data['matches'] = asList(
      data['matches'],
    ).map((item) => normalizeUserPayload(asMap(item))).toList();
  }
  if (data.containsKey('connections')) {
    data['connections'] = asList(
      data['connections'],
    ).map((item) => normalizeUserPayload(asMap(item))).toList();
  }
  final pendingReceived = data.containsKey('pending_received')
      ? data['pending_received']
      : data['pendingReceived'];
  final pendingSent = data.containsKey('pending_sent')
      ? data['pending_sent']
      : data['pendingSent'];
  if (pendingReceived != null) {
    data['pendingReceived'] = asList(
      pendingReceived,
    ).map((item) => normalizeUserPayload(asMap(item))).toList();
  }
  if (pendingSent != null) {
    data['pendingSent'] = asList(
      pendingSent,
    ).map((item) => normalizeUserPayload(asMap(item))).toList();
  }
  if (data.containsKey('messages')) {
    data['messages'] = asList(
      data['messages'],
    ).map((item) => asMap(item)).toList();
  }
  if (data.containsKey('notifications')) {
    data['notifications'] = asList(
      data['notifications'],
    ).map((item) => asMap(item)).toList();
  }
  if (data.containsKey('plans')) {
    data['plans'] = asList(data['plans']).map((item) => asMap(item)).toList();
  }
  return data;
}

Map<String, dynamic> normalizeMatchFilters(Map<String, dynamic> raw) {
  final input = Map<String, dynamic>.from(raw);
  final normalized = <String, dynamic>{};
  final minAge = input['age_min'] ?? input['minAge'];
  final maxAge = input['age_max'] ?? input['maxAge'];
  final location = input['location'] ?? input['city'];
  final profession = input['profession'] ?? input['occupation'];
  if (minAge != null) {
    normalized['age_min'] = minAge;
    normalized['minAge'] = minAge;
  }
  if (maxAge != null) {
    normalized['age_max'] = maxAge;
    normalized['maxAge'] = maxAge;
  }
  if (location != null && location.toString().trim().isNotEmpty) {
    normalized['location'] = location;
    normalized['city'] = location;
  }
  if (profession != null && profession.toString().trim().isNotEmpty) {
    normalized['profession'] = profession;
    normalized['occupation'] = profession;
  }
  final religion = input['religion'];
  if (religion != null && religion.toString().trim().isNotEmpty) {
    normalized['religion'] = religion;
  }
  final caste = input['caste'];
  if (caste != null && caste.toString().trim().isNotEmpty) {
    normalized['caste'] = caste;
  }
  for (final key in [
    'sub_caste',
    'subCaste',
    'education',
    'marital_status',
    'maritalStatus',
    'mother_tongue',
    'motherTongue',
    'state',
    'height_min',
    'height_max',
    'income_min',
    'income_max',
  ]) {
    final value = input[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      normalized[key] = value;
    }
  }
  final page = input['page'];
  final limit = input['limit'];
  if (page != null) normalized['page'] = page;
  if (limit != null) normalized['limit'] = limit;
  return normalized;
}
