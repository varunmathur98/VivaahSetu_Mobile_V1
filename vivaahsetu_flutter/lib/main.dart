import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/design_system.dart';
import 'core/models.dart';
import 'core/normalization.dart' as adapter;

const _baseUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'https://api.vivaahsetu.in',
);
const _primaryColor = VSColors.primary;
const _secondaryColor = VSColors.secondary;
const _backgroundColor = VSColors.background;
const _surfaceColor = VSColors.surface;
const _textColor = VSColors.text;
const _textSecondaryColor = VSColors.textSecondary;
const _borderColor = VSColors.border;
const _postLoginBackground = VSColors.postLoginBackground;
const _shaadiMaroon = VSColors.primary;
const _shaadiRose = VSColors.shaadiRose;

const List<String> _religionOptions = [
  'Hindu',
  'Muslim',
  'Christian',
  'Sikh',
  'Jain',
  'Buddhist',
  'Parsi',
  'Jewish',
  'Other',
  'No Religion',
];

const List<String> _maritalStatusOptions = [
  'Never Married',
  'Divorced',
  'Widowed',
  'Separated',
  'Annulled',
];

const List<String> _educationOptions = [
  'High School',
  'Intermediate',
  'Diploma',
  'Bachelors (B.Tech/B.E.)',
  'Bachelors (B.Com)',
  'Bachelors (B.Sc)',
  'Bachelors (BA)',
  'Bachelors (BBA)',
  'Bachelors (BCA)',
  'Masters (M.Tech/M.E.)',
  'Masters (MBA)',
  'Masters (M.Sc)',
  'Masters (MA)',
  'Masters (MCA)',
  'Doctorate (Ph.D)',
  'Medical (MBBS)',
  'Medical (MD/MS)',
  'Law (LLB/LLM)',
  'CA/CS/CFA',
  'Other',
];

const List<String> _professionOptions = [
  'Software Engineer',
  'IT Professional',
  'Data Scientist',
  'Doctor',
  'Dentist',
  'Nurse',
  'Lawyer',
  'Chartered Accountant',
  'Teacher/Professor',
  'Civil Engineer',
  'Mechanical Engineer',
  'Electrical Engineer',
  'Architect',
  'Business Owner',
  'Entrepreneur',
  'Manager',
  'Executive',
  'Consultant',
  'Banker',
  'Government Employee',
  'Defence Services',
  'Scientist',
  'Journalist',
  'Designer',
  'Artist',
  'Pilot',
  'Farmer',
  'Freelancer',
  'Student',
  'Homemaker',
  'Not Working',
  'Other',
];

const List<String> _heightOptions = [
  "4'8\"",
  "4'9\"",
  "4'10\"",
  "4'11\"",
  "5'0\"",
  "5'1\"",
  "5'2\"",
  "5'3\"",
  "5'4\"",
  "5'5\"",
  "5'6\"",
  "5'7\"",
  "5'8\"",
  "5'9\"",
  "5'10\"",
  "5'11\"",
  "6'0\"",
  "6'1\"",
  "6'2\"",
  "6'3\"",
  "6'4\"",
  "6'5\"+",
];

const List<String> _incomeOptions = [
  '0-3 LPA',
  '3-5 LPA',
  '5-10 LPA',
  '10-15 LPA',
  '15-25 LPA',
  '25-50 LPA',
  '50 LPA+',
  'Prefer not to say',
];

const List<String> _dietOptions = [
  'Vegetarian',
  'Non-Vegetarian',
  'Eggetarian',
  'Vegan',
  'Jain',
];

const List<String> _manglikOptions = [
  'Manglik',
  'Non-Manglik',
  'Anshik Manglik',
  'Do not know',
];

const List<String> _familyFinancialStatusOptions = [
  'Middle Class',
  'Upper Middle Class',
  'Affluent',
  'High Net Worth',
];

const List<String> _hobbyOptions = [
  'Travel',
  'Music',
  'Reading',
  'Fitness',
  'Cooking',
  'Movies',
  'Sports',
  'Art',
  'Spirituality',
  'Photography',
  'Dancing',
  'Volunteering',
];

const List<String> _preferenceAnyOptions = ['Any'];

const List<String> _motherTongueOptions = [
  'Hindi',
  'English',
  'Marathi',
  'Tamil',
  'Telugu',
  'Kannada',
  'Malayalam',
  'Bengali',
  'Gujarati',
  'Punjabi',
  'Odia',
  'Assamese',
  'Urdu',
  'Sindhi',
  'Konkani',
  'Kashmiri',
  'Manipuri',
  'Nepali',
  'Sanskrit',
  'Tulu',
  'Rajasthani',
  'Haryanvi',
  'Bhojpuri',
  'Maithili',
  'Dogri',
  'Other',
];

const List<String> _stateOptions = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Delhi',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jammu and Kashmir',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Ladakh',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Chandigarh',
  'Puducherry',
];

const Map<String, List<String>> _subCasteOptions = {
  'Brahmin': ['Iyer', 'Iyengar', 'Saraswat', 'Gaur', 'Kanyakubja', 'Other'],
  'Rajput': ['Chauhan', 'Rathore', 'Sisodiya', 'Parmar', 'Solanki', 'Other'],
  'Jat': ['Dahiya', 'Malik', 'Hooda', 'Sehrawat', 'Ahlawat', 'Other'],
  'Patel': ['Leuva', 'Kadva', 'Anjana', 'Other'],
  'Maratha': ['96 Kuli', 'Kunbi', 'CKP', 'Deshastha', 'Other'],
  'Kshatriya': ['Rajput', 'Thakur', 'Nair', 'Reddy', 'Maratha', 'Other'],
  'Vaishya': ['Agarwal', 'Gupta', 'Maheshwari', 'Oswal', 'Other'],
  'Reddy': ['Panta Reddy', 'Motati', 'Kapu Reddy', 'Other'],
  'Nair': ['Menon', 'Pillai', 'Kurup', 'Panicker', 'Other'],
  'Yadav': ['Ahir', 'Gwala', 'Krishnaut', 'Other'],
  'Gupta': ['Bania', 'Agarwal', 'Mahajan', 'Other'],
  'Agarwal': ['Bisa', 'Dassa', 'Goyal', 'Mittal', 'Other'],
  'Sunni': ['Hanafi', 'Shafi', 'Maliki', 'Hanbali', 'Other'],
  'Shia': ['Ithna Ashari', 'Ismaili', 'Bohra', 'Other'],
  'Catholic': ['Roman Catholic', 'Syro-Malabar', 'Syro-Malankara', 'Other'],
  'Protestant': ['CSI', 'CNI', 'Pentecostal', 'Other'],
  'Orthodox': ['Malankara', 'Jacobite', 'Other'],
  'Jat Sikh': ['Sandhu', 'Gill', 'Brar', 'Sidhu', 'Other'],
  'Khatri': ['Kapoor', 'Khanna', 'Malhotra', 'Mehra', 'Other'],
  'Arora': ['Sachdeva', 'Taneja', 'Ahuja', 'Chopra', 'Other'],
  'Ramgarhia': ['Mistry', 'Lohar', 'Tarkhan', 'Other'],
  'Digambar': ['Bisapanthi', 'Terapanthi', 'Taranpanthi', 'Other'],
  'Shwetambar': ['Murtipujak', 'Sthanakvasi', 'Terapanthi', 'Other'],
  'Mahayana': ['Navayana', 'Other'],
  'Theravada': ['Other'],
};

Map<String, dynamic> _asMap(dynamic value) => adapter.asMap(value);

List<dynamic> _asList(dynamic value) => adapter.asList(value);

String? _resolveMediaUrl(String? raw) => adapter.resolveMediaUrl(_baseUrl, raw);

List<String> _photoUrls(Map<String, dynamic> data) =>
    adapter.photoUrls(_baseUrl, data);

bool _isPaidUser(Map<String, dynamic> user) {
  final features = _asMap(user['features']);
  final plan = (user['plan'] ?? user['subscriptionPlan'] ?? '')
      .toString()
      .toLowerCase();
  return plan.isNotEmpty && plan != 'free' ||
      features['chat_unlocked'] == true ||
      features['view_contact_details'] == true ||
      features['canViewExtraPhotos'] == true;
}

bool _canViewAllPhotosFor(
  Map<String, dynamic> currentUser,
  Map<String, dynamic> profile,
) {
  return _isPaidUser(currentUser) && _alreadyConnectedFlag(profile);
}

Map<String, dynamic> _galleryProfileFor(
  Map<String, dynamic> currentUser,
  Map<String, dynamic> profile, {
  bool forceAll = false,
}) {
  final prepared = Map<String, dynamic>.from(profile);
  final photos = _photoUrls(prepared);
  final allowAll = forceAll || _canViewAllPhotosFor(currentUser, prepared);
  prepared['photos'] = photos;
  prepared['visiblePhotoCount'] = allowAll
      ? photos.length
      : (photos.isEmpty ? 0 : 1);
  prepared['canViewAllPhotos'] = allowAll;
  return prepared;
}

String _relationshipStatus(Map<String, dynamic> data) =>
    (data['relationshipStatus'] ?? data['relationship_status'] ?? '')
        .toString()
        .toUpperCase();

void _applyRelationshipStatus(Map<String, dynamic> data, String status) {
  final normalized = status.toUpperCase();
  data['relationshipStatus'] = normalized;
  data['relationship_status'] = normalized;
  data['requestSent'] = normalized == 'REQUEST_SENT';
  data['request_sent'] = normalized == 'REQUEST_SENT';
  data['requestReceived'] = normalized == 'REQUEST_RECEIVED';
  data['request_received'] = normalized == 'REQUEST_RECEIVED';
  data['alreadyConnected'] = normalized == 'CONNECTED';
  data['already_connected'] = normalized == 'CONNECTED';
}

bool _requestSentFlag(Map<String, dynamic> data) =>
    _relationshipStatus(data) == 'REQUEST_SENT' ||
    data['requestSent'] == true ||
    data['request_sent'] == true;

bool _requestReceivedFlag(Map<String, dynamic> data) =>
    _relationshipStatus(data) == 'REQUEST_RECEIVED' ||
    data['requestReceived'] == true ||
    data['request_received'] == true;

bool _alreadyConnectedFlag(Map<String, dynamic> data) =>
    _relationshipStatus(data) == 'CONNECTED' ||
    data['alreadyConnected'] == true ||
    data['already_connected'] == true;

List<String> _mergeDropdownOptions(
  List<String> options,
  String? selectedValue,
) {
  final merged = <String>{
    ...options
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim()),
    if ((selectedValue ?? '').trim().isNotEmpty) selectedValue!.trim(),
  }.toList()..sort();
  return merged;
}

List<String> _withAnyOptions(List<String> options, String? selectedValue) {
  final merged = _mergeDropdownOptions(<String>[
    ..._preferenceAnyOptions,
    ...options,
  ], selectedValue);
  merged.remove('Any');
  return <String>['Any', ...merged];
}

bool _isAnyPreference(String? value) =>
    (value ?? '').trim().toLowerCase() == 'any';

List<String> _preferenceList(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty || _isAnyPreference(text)) return <String>[];
  return text
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty && !_isAnyPreference(item))
      .toList();
}

int? _heightToInches(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return null;
  final match = RegExp(r"^(\d+)'(\d+)").firstMatch(text);
  if (match != null) {
    final feet = int.tryParse(match.group(1) ?? '');
    final inches = int.tryParse(match.group(2) ?? '');
    if (feet != null && inches != null) return feet * 12 + inches;
  }
  return int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
}

Uint8List? _decodeDataImage(String? value) {
  final raw = value?.trim() ?? '';
  if (!raw.startsWith('data:') || !raw.contains('base64,')) return null;
  final marker = raw.indexOf('base64,');
  if (marker == -1) return null;
  try {
    return base64Decode(raw.substring(marker + 7));
  } catch (_) {
    return null;
  }
}

Future<void> _launchPaymentUrl(BuildContext context, String link) async {
  final url = link.trim();
  if (url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment link is not available yet. Please try again.'),
      ),
    );
    return;
  }
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid payment link received.')),
    );
    return;
  }
  final launched =
      await launchUrl(uri, mode: LaunchMode.externalApplication) ||
      await launchUrl(uri, mode: LaunchMode.platformDefault);
  if (launched || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Open Payment Link'),
      content: SelectableText(url),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

List<String> _subCasteChoices(String? caste, String? selectedValue) {
  final key = (caste ?? '').trim();
  if (key.isEmpty) {
    return _mergeDropdownOptions(const <String>[], selectedValue);
  }
  final exact = _subCasteOptions[key];
  if (exact != null) {
    return _mergeDropdownOptions(exact, selectedValue);
  }
  final lower = key.toLowerCase();
  for (final entry in _subCasteOptions.entries) {
    if (entry.key.toLowerCase() == lower) {
      return _mergeDropdownOptions(entry.value, selectedValue);
    }
  }
  return _mergeDropdownOptions(const <String>['Other'], selectedValue);
}

Map<String, dynamic> _normalizeUserPayload(Map<String, dynamic> raw) =>
    adapter.normalizeUserPayload(raw);

Map<String, dynamic> _normalizeResponseMap(Map<String, dynamic> raw) =>
    adapter.normalizeResponseMap(raw);

final Future<FirebaseApp> _firebaseInitFuture = Firebase.initializeApp();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _firebaseInitFuture;
  await VSNotificationService.instance.initialize();
  runApp(const VivaahSetuApp());
}

class VSNotificationService {
  VSNotificationService._();

  static final VSNotificationService instance = VSNotificationService._();
  static const String _channelId = 'vivaahsetu_alerts_v2';
  static const String _channelName = 'VivaahSetu alerts';
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _tapController =
      StreamController<String>.broadcast();
  final Map<String, DateTime> _recentNotificationKeys = <String, DateTime>{};
  final List<DateTime> _recentNotificationTimes = <DateTime>[];
  bool _initialized = false;
  int _nextId = 1000;

  Stream<String> get taps => _tapController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('ic_notification');
    const initialization = InitializationSettings(android: android);
    await _plugin.initialize(
      settings: initialization,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _tapController.add(payload);
        }
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Messages, matches, offers, and connection alerts',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
          ),
        );
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final title =
          notification?.title ?? message.data['title']?.toString() ?? '';
      final body = notification?.body ?? message.data['body']?.toString() ?? '';
      final payload =
          message.data['payload']?.toString() ??
          message.data['route']?.toString() ??
          '';
      if (title.isNotEmpty || body.isNotEmpty) {
        unawaited(
          show(
            title: title.isEmpty ? 'VivaahSetu update' : title,
            body: body.isEmpty ? 'You have a new update.' : body,
            payload: payload,
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload =
          message.data['payload']?.toString() ??
          message.data['route']?.toString() ??
          '';
      if (payload.isNotEmpty) _tapController.add(payload);
    });
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    final initialPayload =
        initialMessage?.data['payload']?.toString() ??
        initialMessage?.data['route']?.toString() ??
        '';
    if (initialPayload.isNotEmpty) {
      scheduleMicrotask(() => _tapController.add(initialPayload));
    }
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchPayload =
        launchDetails?.notificationResponse?.payload?.trim() ?? '';
    if ((launchDetails?.didNotificationLaunchApp ?? false) &&
        launchPayload.isNotEmpty) {
      scheduleMicrotask(() => _tapController.add(launchPayload));
    }
    _initialized = true;
  }

  Future<void> show({
    required String title,
    required String body,
    String payload = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('settings_push_notifications') == false) return;
    final now = DateTime.now();
    _recentNotificationKeys.removeWhere(
      (_, shownAt) => now.difference(shownAt) > const Duration(minutes: 2),
    );
    _recentNotificationTimes.removeWhere(
      (shownAt) => now.difference(shownAt) > const Duration(seconds: 60),
    );
    final key = '$title|$body|$payload';
    if (_recentNotificationKeys.containsKey(key)) return;
    if (_recentNotificationTimes.length >= 6) {
      final summaryKey =
          'VivaahSetu updates|More updates are waiting|notifications';
      if (_recentNotificationKeys.containsKey(summaryKey)) return;
      _recentNotificationKeys[summaryKey] = now;
      _recentNotificationTimes.add(now);
      const summaryAndroidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Messages, matches, offers, and connection alerts',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.status,
        audioAttributesUsage: AudioAttributesUsage.notification,
      );
      await _plugin.show(
        id: _nextId++,
        title: 'VivaahSetu updates',
        body: 'More updates are waiting in your notification center.',
        notificationDetails: const NotificationDetails(
          android: summaryAndroidDetails,
        ),
        payload: 'notifications',
      );
      return;
    }
    _recentNotificationKeys[key] = now;
    _recentNotificationTimes.add(now);
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Messages, matches, offers, and connection alerts',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.social,
      audioAttributesUsage: AudioAttributesUsage.notification,
    );
    await _plugin.show(
      id: _nextId++,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }
}

class VivaahSetuApp extends StatelessWidget {
  const VivaahSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VivaahSetu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          primary: _primaryColor,
          secondary: _secondaryColor,
          surface: _backgroundColor,
          tertiary: VSColors.sandal,
        ),
        scaffoldBackgroundColor: _backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0x00FFFFFF),
          foregroundColor: _textColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 1.5),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0x22E6A93A),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: VSColors.surface,
          selectedColor: VSColors.blush,
          side: const BorderSide(color: VSColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      home: const AppRoot(),
    );
  }
}

class ApiClient {
  ApiClient({required this.onUnauthorized, required this.onSessionRefresh})
    : _dio = Dio(
        BaseOptions(
          baseUrl: '${_baseUrl.replaceAll(RegExp(r'/+$'), '')}/api',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;
  final Future<void> Function() onUnauthorized;
  final Future<String?> Function() onSessionRefresh;

  Future<dynamic> _request(
    String method,
    String path, {
    String? token,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool allowRetry = true,
  }) async {
    try {
      final response = await _dio
          .request<dynamic>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: Options(
              method: method,
              headers: {
                if (token != null) 'Authorization': 'Bearer $token',
                if (data is FormData) 'Content-Type': 'multipart/form-data',
              },
            ),
          )
          .timeout(const Duration(seconds: 15));
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && token != null && token.isNotEmpty) {
        if (allowRetry) {
          final refreshedToken = await onSessionRefresh();
          if (refreshedToken != null &&
              refreshedToken.isNotEmpty &&
              refreshedToken != token) {
            return _request(
              method,
              path,
              token: refreshedToken,
              data: data,
              queryParameters: queryParameters,
              allowRetry: false,
            );
          }
        }
        await onUnauthorized();
      }
      final payload = e.response?.data;
      final detail = payload is Map ? payload['detail']?.toString() : null;
      throw Exception(detail ?? e.message ?? 'Request failed');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async =>
      Map<String, dynamic>.from(
        await _request(
              'POST',
              '/auth/login',
              data: {'email': email.trim(), 'password': password},
            )
            as Map,
      );

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String gender,
  ) async => Map<String, dynamic>.from(
    await _request(
          'POST',
          '/auth/register',
          data: {
            'email': email.trim(),
            'password': password,
            'name': name.trim(),
            'gender': gender,
          },
        )
        as Map,
  );

  Future<Map<String, dynamic>> firebaseSession({
    required String idToken,
    String gender = 'male',
    String name = '',
  }) async {
    try {
      return _normalizeResponseMap(
        await _request(
              'POST',
              '/auth/firebase/session',
              data: {
                'id_token': idToken,
                'gender': gender.toLowerCase(),
                'name': name.trim(),
              },
            )
            as Map<String, dynamic>,
      );
    } catch (_) {
      return _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request(
                'POST',
                '/auth/google-login',
                data: {
                  'idToken': idToken,
                  'gender': gender,
                  'name': name.trim(),
                },
              )
              as Map,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> me(String token) async {
    try {
      return _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('GET', '/auth/me', token: token) as Map,
        ),
      );
    } catch (_) {
      return _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('GET', '/profile/me', token: token) as Map,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      return _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('PUT', '/profile', token: token, data: data) as Map,
        ),
      );
    } catch (_) {
      return _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('PUT', '/profile/update', token: token, data: data)
              as Map,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> matches(
    String token,
    Map<String, dynamic> filters,
  ) async {
    final normalizedFilters = adapter.normalizeMatchFilters(filters);
    return _normalizeResponseMap(
      Map<String, dynamic>.from(
        await _request(
              'GET',
              '/matches',
              token: token,
              queryParameters: normalizedFilters,
            )
            as Map,
      ),
    );
  }

  Future<Map<String, dynamic>> connections(String token) async =>
      _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('GET', '/connections', token: token) as Map,
        ),
      );

  Future<Map<String, dynamic>> sendRequest(String token, String id) async =>
      _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('POST', '/connections/request/$id', token: token)
              as Map,
        ),
      );
  Future<Map<String, dynamic>> acceptRequest(String token, String id) async =>
      _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('POST', '/connections/accept/$id', token: token)
              as Map,
        ),
      );
  Future<Map<String, dynamic>> rejectRequest(String token, String id) async =>
      _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('POST', '/connections/reject/$id', token: token)
              as Map,
        ),
      );
  Future<Map<String, dynamic>> cancelRequest(String token, String id) async =>
      _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('POST', '/connections/cancel/$id', token: token)
              as Map,
        ),
      );
  Future<Map<String, dynamic>> removeConnection(
    String token,
    String id,
  ) async => _normalizeResponseMap(
    Map<String, dynamic>.from(
      await _request('POST', '/connections/remove/$id', token: token) as Map,
    ),
  );

  Future<Map<String, dynamic>> requestConnectionExtension(
    String token,
    String connectionId,
  ) async => _normalizeResponseMap(
    Map<String, dynamic>.from(
      await _request(
            'POST',
            '/connections/extend/request',
            token: token,
            data: {'connection_id': connectionId},
          )
          as Map,
    ),
  );

  Future<Map<String, dynamic>> approveConnectionExtension(
    String token,
    String connectionId,
  ) async => _normalizeResponseMap(
    Map<String, dynamic>.from(
      await _request(
            'POST',
            '/connections/extend/approve/$connectionId',
            token: token,
          )
          as Map,
    ),
  );

  Future<Map<String, dynamic>> profile(String token, String id) async =>
      _normalizeResponseMap(
        Map<String, dynamic>.from(
          await _request('GET', '/profile/$id', token: token) as Map,
        ),
      );

  Future<List<dynamic>> messages(String token, String partnerId) async {
    final raw = Map<String, dynamic>.from(
      await _request('GET', '/chat/$partnerId', token: token) as Map,
    );
    final normalized = _normalizeResponseMap(raw);
    final messages = _asList(normalized['messages']).map((item) {
      final message = _asMap(item);
      message['senderId'] ??= message['sender_id'];
      message['receiverId'] ??= message['receiver_id'];
      message['createdAt'] ??= message['created_at'];
      return message;
    }).toList();
    return messages;
  }

  Future<void> sendMessage(
    String token,
    String partnerId,
    String content,
  ) async {
    await _request(
      'POST',
      '/chat/send',
      token: token,
      data: {
        'receiver_id': partnerId,
        'receiverId': partnerId,
        'content': content,
      },
    );
  }

  Future<List<dynamic>> notifications(String token) async {
    final response = await _request('GET', '/notifications', token: token);
    if (response is Map) {
      return List<dynamic>.from(
        response['notifications'] as List? ?? <dynamic>[],
      );
    }
    return <dynamic>[];
  }

  Future<void> registerDeviceToken(String token, String deviceToken) async {
    if (deviceToken.trim().isEmpty) return;
    await _request(
      'POST',
      '/notifications/device-token',
      token: token,
      data: {
        'token': deviceToken.trim(),
        'platform': Platform.isAndroid ? 'android' : 'unknown',
      },
    );
  }

  Future<void> createNotificationDigest(String token) async {
    await _request('POST', '/notifications/digest', token: token);
  }

  Future<void> markNotificationsRead(String token) async {
    await _request('POST', '/notifications/read', token: token);
  }

  Future<int> unreadCount(String token) async {
    final response = await _request('GET', '/chat/unread/count', token: token);
    if (response is Map) {
      final value = response['unreadCount'] ?? response['unread_count'] ?? 0;
      return (value as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<int> markChatRead(String token, String partnerId) async {
    final response = await _request(
      'POST',
      '/chats/$partnerId/mark-read',
      token: token,
    );
    if (response is Map) {
      final value = response['unreadCount'] ?? response['unread_count'] ?? 0;
      return (value as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<List<String>> castes(String religion) async {
    if (religion.trim().isEmpty) return <String>[];
    try {
      final response = await _request(
        'GET',
        '/castes/${Uri.encodeComponent(religion.trim())}',
      );
      if (response is Map) {
        return _asList(
          response['castes'],
        ).map((item) => item.toString()).toList();
      }
      return <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  Future<List<String>> subCastes(String caste) async {
    if (caste.trim().isEmpty) return <String>[];
    try {
      final response = await _request(
        'GET',
        '/subcastes/${Uri.encodeComponent(caste.trim())}',
      );
      if (response is Map) {
        return _asList(
          response['subcastes'],
        ).map((item) => item.toString()).toList();
      }
      return <String>[];
    } catch (_) {
      return <String>[];
    }
  }

  Future<List<dynamic>> successStories() async {
    try {
      final response = await _request('GET', '/success-stories');
      if (response is Map) {
        return List<dynamic>.from(response['stories'] as List? ?? <dynamic>[]);
      }
      return List<dynamic>.from(response as List? ?? <dynamic>[]);
    } catch (_) {
      return <dynamic>[
        {
          'id': 'sample_1',
          'names': 'Aarav & Nisha',
          'location': 'Mumbai',
          'story':
              'We connected on VivaahSetu and found that our values matched from the first conversation.',
          'image':
              'https://images.pexels.com/photos/1675187/pexels-photo-1675187.jpeg?auto=compress&cs=tinysrgb&w=600',
        },
        {
          'id': 'sample_2',
          'names': 'Rohan & Priya',
          'location': 'Pune',
          'story':
              'The focused profile details and serious-intent connections helped us move quickly with confidence.',
          'image':
              'https://images.pexels.com/photos/2034866/pexels-photo-2034866.jpeg?auto=compress&cs=tinysrgb&w=600',
        },
      ];
    }
  }

  Future<List<dynamic>> uploadPhoto(String token, String filePath) async {
    final fileName = filePath.split(Platform.pathSeparator).last;
    dynamic response;
    try {
      response = await _request(
        'POST',
        '/profile/upload-photo',
        token: token,
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        }),
      );
    } catch (_) {
      final bytes = await File(filePath).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      response = await _request(
        'POST',
        '/profile/upload-photo',
        token: token,
        data: {'photo': base64Image},
      );
    }
    if (response is Map) {
      return _asList(response['photos'])
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <dynamic>[];
  }

  Future<List<dynamic>> deletePhoto(String token, int index) async {
    final response = await _request(
      'DELETE',
      '/profile/photo/$index',
      token: token,
    );
    if (response is Map) {
      return _asList(response['photos'])
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <dynamic>[];
  }

  Future<List<dynamic>> setPrimaryPhoto(String token, int index) async {
    final response = await _request(
      'POST',
      '/profile/photo/$index/primary',
      token: token,
    );
    if (response is Map) {
      return _asList(response['photos'])
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <dynamic>[];
  }

  Future<List<dynamic>> setPrimaryPhotoPath(String token, String path) async {
    final response = await _request(
      'POST',
      '/profile/set-profile-photo',
      token: token,
      data: {'path': path},
    );
    if (response is Map) {
      return _asList(response['photos'])
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <dynamic>[];
  }

  Future<Map<String, dynamic>> settings(String token) async {
    return Map<String, dynamic>.from(
      await _request('GET', '/settings', token: token) as Map,
    );
  }

  Future<Map<String, dynamic>> updateSettings(
    String token,
    Map<String, dynamic> data,
  ) async {
    return Map<String, dynamic>.from(
      await _request('PUT', '/settings', token: token, data: data) as Map,
    );
  }

  Future<Map<String, dynamic>> currentSubscription(String token) async {
    return Map<String, dynamic>.from(
      await _request('GET', '/subscriptions/current', token: token) as Map,
    );
  }

  Future<List<dynamic>> plans() async {
    dynamic response;
    try {
      response = await _request('GET', '/plans');
    } catch (_) {
      response = await _request('GET', '/subscriptions/plans');
    }
    if (response is Map) {
      final normalized = _normalizeResponseMap(
        Map<String, dynamic>.from(response),
      );
      final plans =
          List<dynamic>.from(normalized['plans'] as List? ?? <dynamic>[]).map((
            item,
          ) {
            final plan = _asMap(item);
            final planId = (plan['id'] ?? plan['plan_id'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            if (planId == 'focus') {
              plan['price'] = 4990;
              plan['discountedPrice'] = 2495;
              plan['discounted_price'] = 2495;
              plan['period'] = '3 months';
              plan['display_price'] = 'INR 2,495';
              plan['original_price'] = 4990;
              plan['discount_percent'] = 50;
              plan['promo_text'] = '50% off - pay INR 2,495 for 3 months';
              plan['available'] = true;
              plan['coming_soon'] = false;
            } else if (planId == 'commit') {
              plan['price'] = 0;
              plan['discountedPrice'] = 0;
              plan['discounted_price'] = 0;
              plan['display_price'] = '/';
              plan['available'] = false;
              plan['coming_soon'] = true;
            }
            plan['discountedPrice'] ??=
                plan['discounted_price'] ?? plan['price'] ?? 0;
            plan['price'] ??=
                plan['original_price'] ?? plan['discountedPrice'] ?? 0;
            plan['available'] ??=
                plan['is_available_for_checkout'] ??
                (plan['coming_soon'] != true);
            if (plan['coming_soon'] == null && plan['available'] != null) {
              plan['coming_soon'] = plan['available'] != true;
            }
            return plan;
          }).toList();
      return plans;
    }
    return List<dynamic>.from(response as List? ?? <dynamic>[]);
  }

  Future<Map<String, dynamic>> createOrder(String token, String planId) async {
    Map<String, dynamic> normalizeOrder(Map<String, dynamic> raw) {
      final data = Map<String, dynamic>.from(raw);
      data['orderId'] ??= data['order_id'] ?? data['id'] ?? '';
      data['paymentSessionId'] ??= data['payment_session_id'] ?? '';
      final paymentLink =
          [
                data['paymentLink'],
                data['payment_link'],
                data['checkout_url'],
                data['checkoutUrl'],
                data['redirect_url'],
              ]
              .map((item) => item?.toString().trim() ?? '')
              .firstWhere((item) => item.isNotEmpty, orElse: () => '');
      data['paymentLink'] = paymentLink;
      data['checkoutUrl'] =
          [data['checkout_url'], data['checkoutUrl'], paymentLink]
              .map((item) => item?.toString().trim() ?? '')
              .firstWhere((item) => item.isNotEmpty, orElse: () => '');
      data['status'] ??= data['order_status'] ?? 'pending';
      return data;
    }

    try {
      return normalizeOrder(
        Map<String, dynamic>.from(
          await _request(
                'POST',
                '/subscriptions/create-order',
                token: token,
                data: {
                  'planId': planId,
                  'plan_id': planId,
                  'origin_url': 'vivaahsetu://payment-result',
                  'originUrl': 'vivaahsetu://payment-result',
                },
              )
              as Map,
        ),
      );
    } catch (_) {
      return normalizeOrder(
        Map<String, dynamic>.from(
          await _request(
                'POST',
                '/cashfree/checkout',
                token: token,
                data: {
                  'planId': planId,
                  'plan_id': planId,
                  'origin_url': 'vivaahsetu://payment-result',
                  'originUrl': 'vivaahsetu://payment-result',
                },
              )
              as Map,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> verifyOrder(String token, String orderId) async {
    Map<String, dynamic> normalizeVerify(Map<String, dynamic> raw) {
      final data = Map<String, dynamic>.from(raw);
      data['orderId'] ??= data['order_id'] ?? orderId;
      data['status'] ??=
          data['order_status'] ?? data['payment_status'] ?? 'pending';
      return data;
    }

    try {
      return normalizeVerify(
        Map<String, dynamic>.from(
          await _request(
                'POST',
                '/cashfree/verify',
                token: token,
                queryParameters: {'orderId': orderId},
              )
              as Map,
        ),
      );
    } catch (_) {
      return normalizeVerify(
        Map<String, dynamic>.from(
          await _request('GET', '/payment/verify/$orderId', token: token)
              as Map,
        ),
      );
    }
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class VSStartupSplash extends StatelessWidget {
  const VSStartupSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7EF), Color(0xFFFFE3E7), Color(0xFFFFD77A)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VSColors.primary.withValues(alpha: 0.16),
                ),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -90,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VSColors.secondary.withValues(alpha: 0.22),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 172,
                    height: 172,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(42),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2A5F0924),
                          blurRadius: 42,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'VivaahSetu',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: VSColors.primary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Curating meaningful matches',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: VSColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: VSColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppRootState extends State<AppRoot> {
  bool _loading = true;
  bool _showStartupSplash = true;
  String? _token;
  Map<String, dynamic>? _user;
  bool _termsAccepted = false;
  bool _logoutInProgress = false;
  Timer? _startupSplashTimer;
  late final ApiClient _api;

  bool _needsProfileCompletion(Map<String, dynamic> user) {
    String firstValue(List<String> keys) {
      for (final key in keys) {
        final value = user[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
      return '';
    }

    bool missingAny(List<String> keys) => firstValue(keys).isEmpty;
    final gender = user['gender']?.toString().trim().toLowerCase() ?? '';
    final profileRequired =
        user['profile_required'] == true || user['profileRequired'] == true;
    final hasPhoto = _photoUrls(user).isNotEmpty;
    return profileRequired ||
        missingAny(['name']) ||
        missingAny(['dob', 'dateOfBirth', 'date_of_birth']) ||
        missingAny(['phone', 'phoneNumber', 'phone_number']) ||
        missingAny(['city', 'location']) ||
        missingAny(['religion']) ||
        missingAny(['caste']) ||
        missingAny(['motherTongue', 'mother_tongue']) ||
        missingAny(['maritalStatus', 'marital_status']) ||
        missingAny(['education']) ||
        missingAny(['occupation', 'profession']) ||
        missingAny(['height']) ||
        missingAny(['income']) ||
        missingAny(['diet']) ||
        missingAny(['manglik']) ||
        missingAny(['about']) ||
        missingAny(['hobbies']) ||
        missingAny(['familyDetails', 'family_details']) ||
        missingAny(['familyFinancialStatus', 'family_financial_status']) ||
        !hasPhoto ||
        !(gender == 'male' || gender == 'female');
  }

  @override
  void initState() {
    super.initState();
    _api = ApiClient(
      onUnauthorized: _logout,
      onSessionRefresh: _refreshSessionFromFirebase,
    );
    _startupSplashTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _showStartupSplash = false);
    });
    _load();
  }

  @override
  void dispose() {
    _startupSplashTimer?.cancel();
    super.dispose();
  }

  String? _extractToken(Map<String, dynamic> payload) {
    const tokenKeys = ['token', 'access_token', 'session_token', 'accessToken'];
    for (final key in tokenKeys) {
      final value = payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractUser(Map<String, dynamic> payload) {
    final nestedUser = payload['user'];
    if (nestedUser is Map) {
      return _normalizeUserPayload(Map<String, dynamic>.from(nestedUser));
    }
    if (payload.containsKey('email') || payload.containsKey('id')) {
      return _normalizeUserPayload(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  Future<void> _refreshUserSilently(String token) async {
    try {
      final freshResponse = await _api.me(token);
      final freshUser = _extractUser(freshResponse) ?? freshResponse;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(freshUser));
      if (!mounted) return;
      setState(() => _user = freshUser);
    } catch (_) {
      // Keep the cached session to match the React client more closely.
    }
  }

  Future<String?> _refreshSessionFromFirebase() async {
    try {
      await _firebaseInitFuture;
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;
      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) return null;
      final payload = await _api.firebaseSession(
        idToken: idToken,
        gender: _user?['gender']?.toString() ?? '',
        name: _user?['name']?.toString() ?? firebaseUser.displayName ?? '',
      );
      await _saveAuth(payload);
      return _extractToken(payload);
    } catch (_) {
      return null;
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    final token = prefs.getString('auth_token');
    final cachedUser = raw == null
        ? null
        : _normalizeResponseMap(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          );
    if (token == null || cachedUser == null) {
      setState(() {
        _token = null;
        _user = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _token = token;
      _user = cachedUser;
      _termsAccepted =
          prefs.getBool('terms_accepted') ??
          (_asMap(cachedUser['settings'])['termsAccepted'] == true);
      _loading = false;
    });
    unawaited(_refreshUserSilently(token));
  }

  Future<void> _saveAuth(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = _extractToken(payload);
    final user = _extractUser(payload);
    if (token == null || user == null) {
      throw Exception('Authentication response was incomplete.');
    }
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user));
    _termsAccepted =
        prefs.getBool('terms_accepted') ??
        (_asMap(user['settings'])['termsAccepted'] == true);
    if (!mounted) return;
    setState(() {
      _token = token;
      _user = user;
    });
  }

  Future<void> _acceptTerms() async {
    final acceptedAt = DateTime.now().toUtc().toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);
    try {
      if (_token != null) {
        await _api.updateSettings(_token!, {
          'termsAccepted': true,
          'termsAcceptedAt': acceptedAt,
          'privacyAcceptedAt': acceptedAt,
        });
      }
    } catch (_) {
      // Keep the user unblocked; consent is retained locally and resynced later.
    }
    if (!mounted) return;
    setState(() => _termsAccepted = true);
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeUserPayload(user);
    await prefs.setString('user_data', jsonEncode(normalized));
    if (!mounted) return;
    setState(() => _user = normalized);
  }

  Future<void> _logout() async {
    if (_logoutInProgress) return;
    _logoutInProgress = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      try {
        await _firebaseInitFuture;
      } catch (_) {
        // Logout should still clear the local app session if Firebase init fails.
      }
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut().catchError((_) => null);
      }
      await GoogleSignIn().signOut().catchError((_) => null);
      if (!mounted) return;
      setState(() {
        _token = null;
        _user = null;
      });
    } finally {
      _logoutInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _showStartupSplash) {
      return const VSStartupSplash();
    }
    if (_token == null || _user == null) {
      return LoginPage(api: _api, onAuth: _saveAuth);
    }
    if (_needsProfileCompletion(_user!)) {
      return EditProfilePage(
        api: _api,
        token: _token!,
        initialProfile: _user!,
        requireProfileCompletion: true,
        onProfileSaved: _saveUser,
      );
    }
    if (!_termsAccepted) {
      return TermsConsentPage(onAccept: _acceptTerms);
    }
    return ShellPage(
      api: _api,
      token: _token!,
      user: _user!,
      onUserChanged: _saveUser,
      onLogout: _logout,
    );
  }
}

class TermsConsentPage extends StatefulWidget {
  const TermsConsentPage({super.key, required this.onAccept});

  final Future<void> Function() onAccept;

  @override
  State<TermsConsentPage> createState() => _TermsConsentPageState();
}

class _TermsConsentPageState extends State<TermsConsentPage> {
  bool _accepted = false;
  bool _saving = false;

  Future<void> _continue() async {
    if (!_accepted || _saving) return;
    setState(() => _saving = true);
    await widget.onAccept();
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'VivaahSetu Consent',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please review and accept the Terms, Privacy Policy, and Safety guidance before continuing.',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondaryColor,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LegalTextBlock(
                    title: 'Terms & Privacy',
                    body: _termsPrivacyText,
                  ),
                  _LegalTextBlock(title: 'Safety', body: _securitySafetyText),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _accepted,
                    onChanged: (value) =>
                        setState(() => _accepted = value ?? false),
                    title: const Text(
                      'I consent to VivaahSetu processing my data for matchmaking and communication services.',
                      style: TextStyle(fontSize: 13, color: _textColor),
                    ),
                  ),
                  FilledButton(
                    onPressed: _accepted && !_saving ? _continue : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: VSColors.primary,
                    ),
                    child: Text(_saving ? 'Saving...' : 'Accept & Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.api, required this.onAuth});

  final ApiClient api;
  final Future<void> Function(Map<String, dynamic>) onAuth;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _googleSignIn = GoogleSignIn(scopes: const ['email', 'profile']);
  bool _googleLoading = false;

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    try {
      await _firebaseInitFuture;
      final account = await _googleSignIn.signIn();
      if (account == null) {
        _toast('Google sign-in was cancelled.');
        return;
      }
      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      final idToken = auth.idToken;
      if (idToken == null || accessToken == null) {
        throw const FormatException(
          'Google did not return the required authentication tokens.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      final firebaseUser = (await FirebaseAuth.instance.signInWithCredential(
        credential,
      )).user;
      if (firebaseUser == null) {
        throw const FormatException('Firebase sign-in did not return a user.');
      }
      final firebaseToken = await firebaseUser.getIdToken();
      if (firebaseToken == null || firebaseToken.isEmpty) {
        throw const FormatException('Firebase id token was empty.');
      }

      final payload = await widget.api.firebaseSession(
        idToken: firebaseToken,
        gender: '',
        name: firebaseUser.displayName ?? account.displayName ?? '',
      );
      await widget.onAuth(payload);
    } on PlatformException catch (e) {
      final details = [
        if (e.code.isNotEmpty) 'code=${e.code}',
        if ((e.message ?? '').isNotEmpty) e.message!,
        if (e.details != null && e.details.toString().trim().isNotEmpty)
          'details=${e.details}',
      ].join(' | ');
      _toast('Google sign-in failed: $details');
    } on FirebaseAuthException catch (e) {
      final details = [
        if (e.code.isNotEmpty) 'code=${e.code}',
        if ((e.message ?? '').isNotEmpty) e.message!,
      ].join(' | ');
      _toast('Firebase Auth failed: $details');
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to VivaahSetu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: const BorderSide(color: _borderColor),
                      elevation: 0,
                    ),
                    onPressed: _googleLoading ? null : _google,
                    child: _googleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4285F4),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Trusted matrimonial experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: const [
                      _FeaturePill(
                        icon: Icons.verified,
                        text: 'Verified Profiles',
                      ),
                      _FeaturePill(
                        icon: Icons.favorite,
                        text: 'Serious Matchmaking',
                      ),
                      _FeaturePill(icon: Icons.schedule, text: '15-Day Timer'),
                      _FeaturePill(
                        icon: Icons.people,
                        text: 'Max 5 Connections',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({
    super.key,
    required this.api,
    required this.token,
    required this.user,
    required this.onUserChanged,
    required this.onLogout,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> user;
  final Future<void> Function(Map<String, dynamic>) onUserChanged;
  final Future<void> Function() onLogout;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;
  int _chatUnreadCount = 0;
  int _realtimeRevision = 0;
  late Map<String, dynamic> _currentUser;
  Timer? _unreadPollTimer;
  Timer? _reconnectTimer;
  StreamSubscription<String>? _notificationTapSub;
  StreamSubscription<Uri>? _deepLinkSub;
  WebSocket? _realtimeSocket;
  bool _shouldReconnect = true;
  String? _pendingChatPartnerId;

  @override
  void initState() {
    super.initState();
    _currentUser = _normalizeUserPayload(widget.user);
    unawaited(_refreshUnreadCount());
    _unreadPollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(_refreshUnreadCount()),
    );
    _notificationTapSub = VSNotificationService.instance.taps.listen(
      _handleNotificationPayload,
    );
    unawaited(_listenForPaymentLinks());
    unawaited(_connectRealtimeSocket());
    unawaited(_registerPushToken());
    unawaited(_showDailyRecommendationIfNeeded());
  }

  @override
  void didUpdateWidget(covariant ShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextUser = _normalizeUserPayload(widget.user);
    if (jsonEncode(nextUser) != jsonEncode(_currentUser)) {
      _currentUser = nextUser;
    }
  }

  Future<void> _syncUser(Map<String, dynamic> user) async {
    final normalized = _normalizeUserPayload(user);
    if (mounted) {
      setState(() {
        _currentUser = normalized;
      });
    }
    await widget.onUserChanged(normalized);
  }

  @override
  void dispose() {
    _shouldReconnect = false;
    _unreadPollTimer?.cancel();
    _reconnectTimer?.cancel();
    _notificationTapSub?.cancel();
    _deepLinkSub?.cancel();
    _realtimeSocket?.close(WebSocketStatus.normalClosure);
    super.dispose();
  }

  Future<void> _listenForPaymentLinks() async {
    try {
      final appLinks = AppLinks();
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        unawaited(_handleDeepLink(initial));
      }
      _deepLinkSub = appLinks.uriLinkStream.listen((uri) {
        unawaited(_handleDeepLink(uri));
      });
    } catch (_) {
      // Payment verification can still run through the subscription page fallback.
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme != 'vivaahsetu' || uri.host != 'payment-result') return;
    final orderId =
        uri.queryParameters['order_id'] ??
        uri.queryParameters['orderId'] ??
        uri.queryParameters['order'];
    if (orderId == null || orderId.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Returned from payment checkout.')),
      );
      return;
    }
    try {
      final result = await widget.api.verifyOrder(widget.token, orderId.trim());
      final status = (result['status'] ?? result['payment_status'] ?? '')
          .toString()
          .toLowerCase();
      if (!mounted) return;
      if (status == 'success' || status == 'paid' || status == 'complete') {
        final fresh = await widget.api.me(widget.token);
        if (!mounted) return;
        await _syncUser(
          _asMap(fresh['user']).isNotEmpty ? _asMap(fresh['user']) : fresh,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful. Focus plan active.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'failed' || status == 'cancelled'
                  ? 'Payment $status. Your plan was not changed.'
                  : 'Payment is pending. We will update your plan after confirmation.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _handleNotificationPayload(String payload) {
    if (!mounted) return;
    if (payload.startsWith('chat:')) {
      final partnerId = payload.substring('chat:'.length).trim();
      setState(() {
        _pendingChatPartnerId = partnerId.isEmpty ? null : partnerId;
        _index = 2;
        _chatUnreadCount = 0;
      });
      return;
    }
    if (payload == 'connections') {
      setState(() {
        _index = 1;
      });
      return;
    }
    if (payload == 'subscription' || payload == 'upgrade') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReactSubscriptionPage(
            api: widget.api,
            token: widget.token,
            currentPlan:
                _currentUser['plan']?.toString().toLowerCase() ?? 'free',
          ),
        ),
      );
      return;
    }
    if (payload.startsWith('profile:')) {
      final profileId = payload.substring('profile:'.length).trim();
      setState(() {
        _index = 0;
      });
      if (profileId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MatchProfilePage(
                api: widget.api,
                token: widget.token,
                user: _currentUser,
                profileId: profileId,
              ),
            ),
          );
        });
      }
      return;
    }
    if (payload == 'matches' || payload == 'notifications') {
      setState(() {
        _index = 0;
      });
      return;
    }
    setState(() {
      _index = 0;
    });
  }

  Future<void> _showDailyRecommendationIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('settings_push_notifications') == false) return;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (prefs.getString('daily_recommendation_notified_on') == today) {
        return;
      }
      await prefs.setString('daily_recommendation_notified_on', today);
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      // The backend stores the digest and emits the actual push/realtime event.
      // Avoid a second local notification for the same daily reminder.
      unawaited(widget.api.createNotificationDigest(widget.token));
    } catch (_) {
      // Recommendation notifications should never block app startup.
    }
  }

  Future<void> _registerPushToken() async {
    try {
      await _firebaseInitFuture;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.trim().isNotEmpty) {
        await widget.api.registerDeviceToken(widget.token, token);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        unawaited(widget.api.registerDeviceToken(widget.token, newToken));
      });
    } catch (_) {
      // Local/realtime notifications still work if FCM is not available.
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('settings_push_notifications') == false) return;
    await VSNotificationService.instance.show(
      title: title,
      body: body,
      payload: payload,
    );
  }

  void _scheduleRealtimeReconnect() {
    if (!_shouldReconnect) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      const Duration(seconds: 5),
      () => unawaited(_connectRealtimeSocket()),
    );
  }

  Future<void> _connectRealtimeSocket() async {
    final backend = _baseUrl.replaceAll(RegExp(r'^http'), 'ws');
    try {
      final socket = await WebSocket.connect(
        '$backend/ws/chat/${widget.token}',
      );
      _realtimeSocket = socket;
      socket.listen(
        _handleRealtimeEvent,
        onDone: _scheduleRealtimeReconnect,
        onError: (_) => _scheduleRealtimeReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleRealtimeReconnect();
    }
  }

  void _handleRealtimeEvent(dynamic event) {
    dynamic decoded;
    try {
      decoded = jsonDecode(event.toString());
    } catch (_) {
      return;
    }
    if (decoded is! Map) return;
    final data = _asMap(decoded);
    final type = data['type']?.toString() ?? '';
    if (type == 'notifications_read') {
      return;
    }
    final unread = data['unreadCount'] ?? data['unread_count'];
    if (unread is num && mounted) {
      setState(() => _chatUnreadCount = unread.toInt());
    }
    if (type == 'new_message') {
      final message = _asMap(data['message']);
      final myId = _currentUser['id']?.toString() ?? '';
      final senderId = (message['sender_id'] ?? message['senderId'] ?? '')
          .toString();
      final content = message['content']?.toString().trim() ?? '';
      if (senderId.isNotEmpty && senderId != myId && _index != 2) {
        unawaited(
          _showLocalNotification(
            title: 'New message on VivaahSetu',
            body: content.isEmpty
                ? 'You received a new chat message.'
                : content,
            payload: 'chat:$senderId',
          ),
        );
      }
    } else if (type == 'notification_created') {
      final notification = _asMap(data['notification']);
      final message = notification['message']?.toString().trim() ?? '';
      final notificationType =
          notification['type']?.toString().toLowerCase() ?? '';
      final lowered = message.toLowerCase();
      final payload =
          notificationType.contains('chat') || lowered.contains('message')
          ? 'chat:${notification['sender_id'] ?? notification['senderId'] ?? ''}'
          : notificationType.contains('upgrade') ||
                notificationType.contains('offer') ||
                notificationType.contains('renewal') ||
                lowered.contains('upgrade') ||
                lowered.contains('renew')
          ? 'subscription'
          : notificationType.contains('visitor')
          ? 'profile:${notification['from_user_id'] ?? notification['fromUserId'] ?? ''}'
          : notificationType.contains('connection') ||
                lowered.contains('request') ||
                lowered.contains('accepted') ||
                lowered.contains('connected')
          ? 'connections'
          : 'notifications';
      unawaited(
        _showLocalNotification(
          title: 'VivaahSetu update',
          body: message.isEmpty ? 'You have a new notification.' : message,
          payload: payload,
        ),
      );
    }
    if (type == 'relationship_changed' ||
        type == 'profile_updated' ||
        type == 'settings_updated' ||
        type == 'subscription_changed' ||
        type == 'notification_created' ||
        type == 'new_message') {
      unawaited(_refreshUnreadCount());
      if (type == 'profile_updated' && data['profile'] is Map) {
        unawaited(_syncUser(_asMap(data['profile'])));
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final count = await widget.api.unreadCount(widget.token);
      if (!mounted) return;
      setState(() => _chatUnreadCount = count);
    } catch (_) {
      // Keep last known unread count on transient failures.
    }
  }

  void _goToTab(int index) {
    if (_index == index) return;
    setState(() {
      _index = index;
      if (index == 2) {
        _chatUnreadCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        key: const ValueKey('home'),
        api: widget.api,
        token: widget.token,
        user: _currentUser,
        onNavigate: _goToTab,
        onNotificationPayload: _handleNotificationPayload,
        onUserChanged: _syncUser,
      ),
      ConnectionsTab(
        key: const ValueKey('connections'),
        api: widget.api,
        token: widget.token,
        user: _currentUser,
      ),
      MessagesTab(
        key: const ValueKey('messages'),
        api: widget.api,
        token: widget.token,
        user: _currentUser,
        initialPartnerId: _pendingChatPartnerId,
        onInitialPartnerConsumed: () {
          if (!mounted) return;
          _pendingChatPartnerId = null;
        },
      ),
      ProfileTab(
        key: const ValueKey('profile'),
        api: widget.api,
        token: widget.token,
        user: _currentUser,
        onUserChanged: _syncUser,
        onLogout: widget.onLogout,
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: VSColors.border.withValues(alpha: 0.72)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1C5F0924),
                blurRadius: 26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _BottomNavItem(
                label: 'Home',
                icon: Icons.home_rounded,
                selected: _index == 0,
                onTap: () => _goToTab(0),
              ),
              _BottomNavItem(
                label: 'Connect',
                icon: Icons.people_alt_rounded,
                selected: _index == 1,
                onTap: () => _goToTab(1),
              ),
              _BottomNavItem(
                label: 'Chats',
                icon: Icons.chat_bubble_rounded,
                selected: _index == 2,
                badgeCount: _chatUnreadCount,
                onTap: () => _goToTab(2),
              ),
              _BottomNavItem(
                label: 'Profile',
                icon: Icons.person_rounded,
                selected: _index == 3,
                onTap: () => _goToTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.api,
    required this.token,
    required this.user,
    required this.onNavigate,
    required this.onNotificationPayload,
    required this.onUserChanged,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> user;
  final void Function(int index) onNavigate;
  final void Function(String payload) onNotificationPayload;
  final Future<void> Function(Map<String, dynamic>) onUserChanged;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _connections;
  int _unreadChats = 0;
  int _unreadNotifications = 0;
  List<dynamic> _previewMatches = <dynamic>[];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _profile = _normalizeUserPayload(widget.user);
    _connections = {
      'connections': List<dynamic>.from(
        widget.user['connections'] as List? ?? const <dynamic>[],
      ),
      'pendingReceived': List<dynamic>.from(
        widget.user['connectionRequestsReceived'] as List? ??
            widget.user['connection_requests_received'] as List? ??
            const <dynamic>[],
      ),
      'pendingSent': List<dynamic>.from(
        widget.user['connectionRequestsSent'] as List? ??
            widget.user['connection_requests_sent'] as List? ??
            const <dynamic>[],
      ),
      'count': List<dynamic>.from(
        widget.user['connections'] as List? ?? const <dynamic>[],
      ).length,
      'max': 5,
    };
    _loading = false;
    _load(silent: true);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _partnerFilters(Map<String, dynamic> profile) {
    return <String, dynamic>{'page': 1, 'limit': 4};
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (_) => EditProfilePage(
          api: widget.api,
          token: widget.token,
          initialProfile: _profile ?? widget.user,
          onProfileSaved: (user) async {
            if (!mounted) return;
            setState(() => _profile = user);
            await widget.onUserChanged(user);
          },
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
      await widget.onUserChanged(updated);
      await _load();
    }
  }

  Future<void> _openBrowse() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BrowseTab(
          api: widget.api,
          token: widget.token,
          user: _profile ?? widget.user,
          initialFilters: _partnerFilters(_profile ?? widget.user),
          showBackButton: true,
        ),
      ),
    );
  }

  Future<void> _load({bool silent = false}) async {
    final firstPaintLoad =
        _profile == null && _connections == null && _previewMatches.isEmpty;
    if (!silent && firstPaintLoad) {
      setState(() => _loading = true);
    }

    Future<T?> safe<T>(Future<T> Function() action) async {
      try {
        return await action().timeout(const Duration(seconds: 8));
      } catch (_) {
        return null;
      }
    }

    final seedProfile = _profile ?? widget.user;
    final profileFuture = safe(() => widget.api.me(widget.token));
    final connectionsFuture = safe(() => widget.api.connections(widget.token));
    final unreadFuture = safe(() => widget.api.unreadCount(widget.token));
    final notificationsFuture = safe(
      () => widget.api.notifications(widget.token),
    );
    final previewMatchesFuture = safe(
      () => widget.api.matches(widget.token, _partnerFilters(seedProfile)),
    );

    final baseResults = await Future.wait([connectionsFuture, unreadFuture]);
    if (!mounted) return;
    setState(() {
      final connections = baseResults[0];
      final unread = baseResults[1];
      if (connections != null) {
        _connections = _asMap(connections);
      }
      if (unread != null) {
        _unreadChats = (unread as num?)?.toInt() ?? _unreadChats;
      }
      if (!silent || firstPaintLoad) _loading = false;
    });

    final details = await Future.wait([
      profileFuture,
      notificationsFuture,
      previewMatchesFuture,
    ]);
    if (!mounted) return;

    final profileResult = details[0];
    final notifications = List<dynamic>.from(
      details[1] as List? ?? <dynamic>[],
    );
    final unreadNotifications = notifications
        .where((item) => _asMap(item)['read'] != true)
        .length;
    final previewPayload = _asMap(details[2]);

    setState(() {
      if (profileResult != null) {
        _profile = _asMap(profileResult);
      }
      if (!silent || firstPaintLoad) _loading = false;
      _unreadNotifications = unreadNotifications;
      if (previewPayload.containsKey('matches')) {
        _previewMatches = List<dynamic>.from(
          previewPayload['matches'] as List? ?? <dynamic>[],
        );
      }
    });

    final latestProfile = _profile;
    if (latestProfile != null) {
      final seedFilters = jsonEncode(_partnerFilters(seedProfile));
      final latestFilters = jsonEncode(_partnerFilters(latestProfile));
      if (seedFilters != latestFilters) {
        unawaited(_refreshPreviewMatches(latestProfile));
      }
    }
  }

  Future<void> _refreshPreviewMatches(Map<String, dynamic> profile) async {
    try {
      final payload = await widget.api
          .matches(widget.token, _partnerFilters(profile))
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      final map = _asMap(payload);
      setState(() {
        _previewMatches = List<dynamic>.from(
          map['matches'] as List? ?? <dynamic>[],
        );
      });
    } catch (_) {
      // Keep existing match preview on transient failures.
    }
  }

  int _progress(Map<String, dynamic> p) {
    const fieldGroups = [
      ['name'],
      ['age'],
      ['gender'],
      ['height'],
      ['religion'],
      ['city', 'location'],
      ['education'],
      ['occupation', 'profession'],
      ['about'],
      ['phone'],
      ['motherTongue', 'mother_tongue'],
      ['maritalStatus', 'marital_status'],
      ['income'],
      ['diet'],
      ['manglik'],
      ['hobbies'],
      ['familyDetails', 'family_details'],
      ['familyFinancialStatus', 'family_financial_status'],
    ];
    bool hasAny(List<String> keys) => keys.any(
      (key) => p[key] != null && p[key].toString().trim().isNotEmpty,
    );
    final filled = fieldGroups.where(hasAny).length;
    final hasPhoto = _photoUrls(p).isNotEmpty ? 1 : 0;
    return (((filled + hasPhoto) / (fieldGroups.length + 1)) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final profileForUi = _profile ?? widget.user;
    final name = profileForUi['name']?.toString().split(' ').first ?? 'User';
    final planRaw =
        _profile?['plan']?.toString() ??
        widget.user['plan']?.toString() ??
        'free';
    final plan =
        planRaw.substring(0, 1).toUpperCase() +
        planRaw.substring(1).toLowerCase();
    final count = (_connections?['count'] as num?)?.toInt() ?? 0;
    final max = (_connections?['max'] as num?)?.toInt() ?? 5;
    final receivedCount = List<dynamic>.from(
      _connections?['pendingReceived'] as List? ?? const <dynamic>[],
    ).length;
    final sentCount = List<dynamic>.from(
      _connections?['pendingSent'] as List? ?? const <dynamic>[],
    ).length;
    final progress = _progress(profileForUi);
    final totalInbox = _unreadChats + _unreadNotifications;
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final todaySubtitle =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Scaffold(
      backgroundColor: _postLoginBackground,
      body: VSPageShell(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  decoration: BoxDecoration(
                    gradient: VSGradients.matrimonialHero,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x249B1233),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -18,
                        top: -28,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -26,
                        bottom: -44,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$name!',
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      todaySubtitle,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final payload =
                                          await Navigator.of(
                                            context,
                                          ).push<String>(
                                            MaterialPageRoute<String>(
                                              builder: (_) => NotificationsPage(
                                                api: widget.api,
                                                token: widget.token,
                                              ),
                                            ),
                                          );
                                      if (payload != null &&
                                          payload.isNotEmpty) {
                                        widget.onNotificationPayload(payload);
                                      }
                                      unawaited(_load());
                                    },
                                    icon: const Icon(
                                      Icons.notifications_none_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                  if (totalInbox > 0)
                                    Positioned(
                                      right: 6,
                                      top: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _secondaryColor,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          totalInbox > 99
                                              ? '99+'
                                              : '$totalInbox',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF3A1F1D),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _CircularProfileAvatar(
                                profile: profileForUi,
                                size: 70,
                                borderColor: Colors.white24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: Text(
                                        'Current Plan: $plan',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Serious matchmaking, curated for you',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _openBrowse,
                                  icon: const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Browse Matches'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: _shaadiMaroon,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: _openEditProfile,
                                icon: const Icon(
                                  Icons.edit_note_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 420.ms).slideY(begin: -0.06, end: 0),
              const SizedBox(height: 16),
              if (progress < 100)
                GestureDetector(
                  onTap: _openEditProfile,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: _primaryColor,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Complete Your Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$progress% complete - add more details for better matches!',
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 8,
                            backgroundColor: _surfaceColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (progress < 100) const SizedBox(height: 16),
              const Text(
                'Your Matchmaking Snapshot',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _HomeMetricCard(
                    icon: Icons.people_alt_rounded,
                    value: '$count/$max',
                    label: 'Active Connections',
                    color: _primaryColor,
                    onTap: () => widget.onNavigate(1),
                  ),
                  _HomeMetricCard(
                    icon: Icons.mark_email_unread_outlined,
                    value: '$receivedCount',
                    label: 'Requests Received',
                    color: const Color(0xFF3566D6),
                    onTap: () => widget.onNavigate(1),
                  ),
                  _HomeMetricCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    value: '$_unreadChats',
                    label: 'Unread Chats',
                    color: const Color(0xFF2C9A65),
                    onTap: () => widget.onNavigate(2),
                  ),
                  _HomeMetricCard(
                    icon: Icons.notifications_active_outlined,
                    value: '$_unreadNotifications',
                    label: 'Unread Notifications',
                    color: const Color(0xFFB26A07),
                    onTap: () async {
                      final payload = await Navigator.of(context).push<String>(
                        MaterialPageRoute<String>(
                          builder: (_) => NotificationsPage(
                            api: widget.api,
                            token: widget.token,
                          ),
                        ),
                      );
                      if (payload != null && payload.isNotEmpty) {
                        widget.onNotificationPayload(payload);
                      }
                      unawaited(_load());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Handpicked Matches',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fresh profiles selected from your preferences',
                style: TextStyle(fontSize: 13, color: _textSecondaryColor),
              ),
              const SizedBox(height: 10),
              if (_previewMatches.isEmpty)
                const VSCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No recommendations yet. Complete preferences and try refresh.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondaryColor,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: _previewMatches.take(4).map((raw) {
                    final p = _asMap(raw);
                    final galleryProfile = _galleryProfileFor(
                      _profile ?? widget.user,
                      p,
                    );
                    return _HomeProfilePreviewCard(
                      profile: galleryProfile,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MatchProfilePage(
                              api: widget.api,
                              token: widget.token,
                              user: _profile ?? widget.user,
                              profileId: p['id']?.toString() ?? '',
                              initialProfile: p,
                            ),
                          ),
                        );
                      },
                      onAccept: () async {
                        final id = p['id']?.toString() ?? '';
                        if (id.isEmpty) return;
                        try {
                          final response = await widget.api.acceptRequest(
                            widget.token,
                            id,
                          );
                          if (!mounted) return;
                          setState(() {
                            _previewMatches = _previewMatches.map((item) {
                              final map = _asMap(item);
                              if (map['id']?.toString() == id) {
                                _applyRelationshipStatus(
                                  map,
                                  response['relationshipStatus']?.toString() ??
                                      'CONNECTED',
                                );
                              }
                              return map;
                            }).toList();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connection accepted'),
                            ),
                          );
                          await _load();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceFirst('Exception: ', ''),
                              ),
                            ),
                          );
                        }
                      },
                      onCancel: () async {
                        final id = p['id']?.toString() ?? '';
                        if (id.isEmpty) return;
                        try {
                          final response = await widget.api.cancelRequest(
                            widget.token,
                            id,
                          );
                          if (!mounted) return;
                          setState(() {
                            _previewMatches = _previewMatches.map((item) {
                              final map = _asMap(item);
                              if (map['id']?.toString() == id) {
                                _applyRelationshipStatus(
                                  map,
                                  response['relationshipStatus']?.toString() ??
                                      'NONE',
                                );
                              }
                              return map;
                            }).toList();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request cancelled')),
                          );
                          await _load();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceFirst('Exception: ', ''),
                              ),
                            ),
                          );
                        }
                      },
                      onConnect: () async {
                        final id = p['id']?.toString() ?? '';
                        if (id.isEmpty) return;
                        try {
                          final response = await widget.api.sendRequest(
                            widget.token,
                            id,
                          );
                          if (!mounted) return;
                          setState(() {
                            _previewMatches = _previewMatches.map((item) {
                              final map = _asMap(item);
                              if (map['id']?.toString() == id) {
                                _applyRelationshipStatus(
                                  map,
                                  response['relationshipStatus']?.toString() ??
                                      'REQUEST_SENT',
                                );
                              }
                              return map;
                            }).toList();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connection request sent'),
                            ),
                          );
                          await _load();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceFirst('Exception: ', ''),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _openBrowse,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Open Filters'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _openBrowse,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Show More Profiles'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReactSubscriptionPage(
                        api: widget.api,
                        token: widget.token,
                        currentPlan: planRaw,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: VSGradients.matrimonialHero,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x269B1233),
                        blurRadius: 22,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              sentCount > 0
                                  ? 'You have $sentCount request${sentCount > 1 ? 's' : ''} waiting for response'
                                  : 'Unlock chat, contacts, and more!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrowseTab extends StatefulWidget {
  const BrowseTab({
    super.key,
    required this.api,
    required this.token,
    required this.user,
    this.initialFilters,
    this.showBackButton = false,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? initialFilters;
  final bool showBackButton;

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  bool _loading = true;
  bool _showFilters = false;
  final _minAge = TextEditingController();
  final _maxAge = TextEditingController();
  final _city = TextEditingController();
  final _religion = TextEditingController();
  final _caste = TextEditingController();
  final _profession = TextEditingController();
  final _education = TextEditingController();
  final _maritalStatus = TextEditingController();
  final _motherTongue = TextEditingController();
  String? _selectedCity;
  String? _selectedReligion;
  String? _selectedCaste;
  String? _selectedProfession;
  String? _selectedEducation;
  String? _selectedMaritalStatus;
  String? _selectedMotherTongue;
  String? _selectedHeightMin;
  String? _selectedHeightMax;
  String? _selectedIncome;
  String? _selectedDiet;
  String? _selectedManglik;
  List<String> _availableCastes = const <String>[];
  List<dynamic> _matches = <dynamic>[];
  String _browseMode = 'matches';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _seedFiltersFromPreferences();
    unawaited(_load());
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _minAge.dispose();
    _maxAge.dispose();
    _city.dispose();
    _religion.dispose();
    _caste.dispose();
    _profession.dispose();
    _education.dispose();
    _maritalStatus.dispose();
    _motherTongue.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _seedFiltersFromPreferences() {
    final sourceFilters = <String, dynamic>{
      ..._partnerFiltersFromUser(widget.user),
      ...?widget.initialFilters,
    };
    final minAge = sourceFilters['age_min'] ?? sourceFilters['minAge'];
    final maxAge = sourceFilters['age_max'] ?? sourceFilters['maxAge'];
    final city = (sourceFilters['location'] ?? sourceFilters['city'] ?? '')
        .toString()
        .trim();
    final religion = (sourceFilters['religion'] ?? '').toString().trim();
    final caste = (sourceFilters['caste'] ?? '').toString().trim();
    final profession =
        (sourceFilters['profession'] ?? sourceFilters['occupation'] ?? '')
            .toString()
            .trim();
    if (minAge != null) _minAge.text = minAge.toString();
    if (maxAge != null) _maxAge.text = maxAge.toString();
    if (city.isNotEmpty) {
      _city.text = city;
      _selectedCity = city;
    }
    if (religion.isNotEmpty) {
      _religion.text = religion;
      _selectedReligion = religion;
    }
    if (caste.isNotEmpty) {
      _caste.text = caste;
      _selectedCaste = caste;
    }
    if (profession.isNotEmpty) {
      _profession.text = profession;
      _selectedProfession = profession;
    }
    if (_selectedReligion != null && _selectedReligion!.isNotEmpty) {
      unawaited(
        _loadCasteOptions(_selectedReligion!, selectedValue: _selectedCaste),
      );
    }
  }

  Map<String, dynamic> _partnerFiltersFromUser(Map<String, dynamic> user) {
    // Partner preferences are enforced by the shared backend. This screen only
    // sends explicit refinements, so "clear filters" keeps preference matching
    // intact without over-narrowing to a single saved option.
    return <String, dynamic>{};
  }

  Future<void> _loadCasteOptions(
    String religion, {
    String? selectedValue,
  }) async {
    if (religion.trim().isEmpty) {
      setState(() {
        _availableCastes = const <String>[];
        _selectedCaste = null;
        _caste.clear();
      });
      return;
    }
    final dynamicCastes = await widget.api.castes(religion);
    final staticCastes = _asList(
      _subCasteOptions.keys,
    ).map((item) => item.toString()).toList();
    final merged = <String>{
      ...dynamicCastes,
      ...staticCastes,
      if ((selectedValue ?? _selectedCaste ?? '').trim().isNotEmpty)
        (selectedValue ?? _selectedCaste!).trim(),
    }.toList()..sort();
    if (!mounted) return;
    setState(() {
      _availableCastes = merged;
      if (selectedValue != null && selectedValue.trim().isNotEmpty) {
        _selectedCaste = selectedValue.trim();
        _caste.text = selectedValue.trim();
      } else if (_selectedCaste != null &&
          !_availableCastes.contains(_selectedCaste)) {
        _selectedCaste = null;
        _caste.clear();
      }
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent || _matches.isEmpty) {
      setState(() => _loading = true);
    }
    try {
      final filters = <String, dynamic>{'page': 1, 'limit': 20};
      if (_minAge.text.trim().isNotEmpty)
        filters['age_min'] = int.tryParse(_minAge.text.trim());
      if (_maxAge.text.trim().isNotEmpty)
        filters['age_max'] = int.tryParse(_maxAge.text.trim());
      if (_selectedCity?.trim().isNotEmpty == true)
        filters['location'] = _selectedCity!.trim();
      if (_selectedReligion?.trim().isNotEmpty == true)
        filters['religion'] = _selectedReligion!.trim();
      if (_selectedCaste?.trim().isNotEmpty == true)
        filters['caste'] = _selectedCaste!.trim();
      if (_selectedProfession?.trim().isNotEmpty == true)
        filters['profession'] = _selectedProfession!.trim();
      if (_selectedEducation?.trim().isNotEmpty == true)
        filters['education'] = _selectedEducation!.trim();
      if (_selectedMaritalStatus?.trim().isNotEmpty == true)
        filters['marital_status'] = _selectedMaritalStatus!.trim();
      if (_selectedMotherTongue?.trim().isNotEmpty == true)
        filters['mother_tongue'] = _selectedMotherTongue!.trim();
      if (_selectedHeightMin?.trim().isNotEmpty == true)
        filters['height_min'] = _heightToInches(_selectedHeightMin);
      if (_selectedHeightMax?.trim().isNotEmpty == true)
        filters['height_max'] = _heightToInches(_selectedHeightMax);
      if (_selectedIncome?.trim().isNotEmpty == true)
        filters['income_min'] = int.tryParse(
          _selectedIncome!.replaceAll(RegExp(r'[^0-9]'), ''),
        );
      if (_selectedDiet?.trim().isNotEmpty == true)
        filters['diet'] = _selectedDiet!.trim();
      if (_selectedManglik?.trim().isNotEmpty == true)
        filters['manglik'] = _selectedManglik!.trim();
      final data = await widget.api.matches(widget.token, filters);
      var matches = List<dynamic>.from(data['matches'] as List? ?? <dynamic>[]);
      if (_browseMode == 'new') {
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        matches = matches.where((item) {
          final map = _asMap(item);
          final created = DateTime.tryParse(
            (map['created_at'] ?? map['createdAt'] ?? '').toString(),
          );
          return created == null || created.isAfter(cutoff);
        }).toList();
      }
      if (!mounted) return;
      setState(() => _matches = matches);
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connect(String id) async {
    try {
      final response = await widget.api.sendRequest(widget.token, id);
      if (mounted) {
        setState(() {
          _matches = _matches.map((item) {
            final map = _asMap(item);
            if (map['id']?.toString() == id) {
              _applyRelationshipStatus(
                map,
                response['relationshipStatus']?.toString() ?? 'REQUEST_SENT',
              );
            }
            return map;
          }).toList();
        });
      }
      _toast('Connection request sent');
      await _load();
    } catch (e) {
      _toast(e);
    }
  }

  Future<void> _cancel(String id) async {
    try {
      final response = await widget.api.cancelRequest(widget.token, id);
      if (mounted) {
        setState(() {
          _matches = _matches.map((item) {
            final map = _asMap(item);
            if (map['id']?.toString() == id) {
              _applyRelationshipStatus(
                map,
                response['relationshipStatus']?.toString() ?? 'NONE',
              );
            }
            return map;
          }).toList();
        });
      }
      _toast('Request cancelled');
      await _load(silent: true);
    } catch (e) {
      _toast(e);
    }
  }

  Future<void> _accept(String id) async {
    try {
      final response = await widget.api.acceptRequest(widget.token, id);
      if (mounted) {
        setState(() {
          _matches = _matches.map((item) {
            final map = _asMap(item);
            if (map['id']?.toString() == id) {
              _applyRelationshipStatus(
                map,
                response['relationshipStatus']?.toString() ?? 'CONNECTED',
              );
            }
            return map;
          }).toList();
        });
      }
      _toast('Connection accepted');
      await _load();
    } catch (e) {
      _toast(e);
    }
  }

  void _toast(Object message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  int? _connectionDaysLeft(Map<String, dynamic> profile) {
    final serverValue = profile['days_remaining'] ?? profile['daysRemaining'];
    if (serverValue is num) return serverValue.toInt().clamp(0, 30);
    final raw = (profile['expiresAt'] ?? profile['expires_at'])?.toString();
    if (raw == null || raw.trim().isEmpty) return null;
    final expiry = DateTime.tryParse(raw);
    if (expiry == null) return null;
    final seconds = expiry.difference(DateTime.now()).inSeconds;
    if (seconds <= 0) return 0;
    final days = (seconds / 86400).ceil();
    return days.clamp(0, 30);
  }

  bool _canRequestExtension({
    required int? daysLeft,
    required bool extensionPending,
    required bool extensionApproved,
    required bool requestedByMe,
  }) {
    if (daysLeft == null) return false;
    if (extensionPending || extensionApproved) return false;
    return daysLeft < 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SafeArea(
              bottom: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: VSGradients.matrimonialHero,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    if (widget.showBackButton)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Find Your Match',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_matches.length} profiles available',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _showFilters = !_showFilters),
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        _showFilters ? 'Hide' : 'Filters',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
                children: [
                  _BrowseSectionChip(
                    icon: Icons.tune_rounded,
                    label: 'Search',
                    value: 'Refine preferences',
                    selected: _showFilters || _browseMode == 'search',
                    onTap: () {
                      setState(() {
                        _browseMode = 'search';
                        _showFilters = true;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  _BrowseSectionChip(
                    icon: Icons.fiber_new_rounded,
                    label: 'New',
                    value: '${_matches.length} added',
                    selected: _browseMode == 'new',
                    onTap: () {
                      setState(() {
                        _browseMode = 'new';
                        _showFilters = false;
                      });
                      _load();
                    },
                  ),
                  const SizedBox(width: 10),
                  _BrowseSectionChip(
                    icon: Icons.favorite_rounded,
                    label: 'My Matches',
                    value: '${_matches.length} profiles',
                    selected: _browseMode == 'matches',
                    onTap: () {
                      setState(() {
                        _browseMode = 'matches';
                        _showFilters = false;
                      });
                      _load();
                    },
                  ),
                ],
              ),
            ),
            if (_showFilters)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FilterField(
                            label: 'Age Min',
                            controller: _minAge,
                            hint: '20',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FilterField(
                            label: 'Age Max',
                            controller: _maxAge,
                            hint: '35',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField(
                            label: 'City/State',
                            value: _selectedCity,
                            options: _mergeDropdownOptions(
                              _stateOptions,
                              _selectedCity,
                            ),
                            hint: 'Select state',
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                                _city.text = value ?? '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Religion',
                            value: _selectedReligion,
                            options: _mergeDropdownOptions(
                              _religionOptions,
                              _selectedReligion,
                            ),
                            hint: 'Select religion',
                            onChanged: (value) {
                              setState(() {
                                _selectedReligion = value;
                                _religion.text = value ?? '';
                                _selectedCaste = null;
                                _caste.clear();
                              });
                              unawaited(_loadCasteOptions(value ?? ''));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField(
                            label: 'Caste',
                            value: _selectedCaste,
                            options: _mergeDropdownOptions(
                              _availableCastes,
                              _selectedCaste,
                            ),
                            hint: _selectedReligion == null
                                ? 'Select religion first'
                                : 'Select caste',
                            onChanged: (value) {
                              setState(() {
                                _selectedCaste = value;
                                _caste.text = value ?? '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Profession',
                            value: _selectedProfession,
                            options: _mergeDropdownOptions(
                              _professionOptions,
                              _selectedProfession,
                            ),
                            hint: 'Profession',
                            onChanged: (value) {
                              setState(() {
                                _selectedProfession = value;
                                _profession.text = value ?? '';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField(
                            label: 'Education',
                            value: _selectedEducation,
                            options: _mergeDropdownOptions(
                              _educationOptions,
                              _selectedEducation,
                            ),
                            hint: 'Education',
                            onChanged: (value) {
                              setState(() {
                                _selectedEducation = value;
                                _education.text = value ?? '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Marital Status',
                            value: _selectedMaritalStatus,
                            options: _mergeDropdownOptions(
                              _maritalStatusOptions,
                              _selectedMaritalStatus,
                            ),
                            hint: 'Marital status',
                            onChanged: (value) {
                              setState(() {
                                _selectedMaritalStatus = value;
                                _maritalStatus.text = value ?? '';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField(
                            label: 'Mother Tongue',
                            value: _selectedMotherTongue,
                            options: _mergeDropdownOptions(
                              _motherTongueOptions,
                              _selectedMotherTongue,
                            ),
                            hint: 'Mother tongue',
                            onChanged: (value) {
                              setState(() {
                                _selectedMotherTongue = value;
                                _motherTongue.text = value ?? '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Income',
                            value: _selectedIncome,
                            options: _mergeDropdownOptions(
                              _incomeOptions,
                              _selectedIncome,
                            ),
                            hint: 'Income',
                            onChanged: (value) =>
                                setState(() => _selectedIncome = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField(
                            label: 'Min Height',
                            value: _selectedHeightMin,
                            options: _mergeDropdownOptions(
                              _heightOptions,
                              _selectedHeightMin,
                            ),
                            hint: 'Min height',
                            onChanged: (value) =>
                                setState(() => _selectedHeightMin = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Max Height',
                            value: _selectedHeightMax,
                            options: _mergeDropdownOptions(
                              _heightOptions,
                              _selectedHeightMax,
                            ),
                            hint: 'Max height',
                            onChanged: (value) =>
                                setState(() => _selectedHeightMax = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField(
                            label: 'Diet',
                            value: _selectedDiet,
                            options: _mergeDropdownOptions(
                              _dietOptions,
                              _selectedDiet,
                            ),
                            hint: 'Diet',
                            onChanged: (value) =>
                                setState(() => _selectedDiet = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DropdownField(
                            label: 'Manglik',
                            value: _selectedManglik,
                            options: _mergeDropdownOptions(
                              _manglikOptions,
                              _selectedManglik,
                            ),
                            hint: 'Manglik',
                            onChanged: (value) =>
                                setState(() => _selectedManglik = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _loading ? null : _load,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _minAge.clear();
                              _maxAge.clear();
                              _city.clear();
                              _religion.clear();
                              _caste.clear();
                              _profession.clear();
                              _education.clear();
                              _maritalStatus.clear();
                              _motherTongue.clear();
                              setState(() {
                                _selectedCity = null;
                                _selectedReligion = null;
                                _selectedCaste = null;
                                _selectedProfession = null;
                                _selectedEducation = null;
                                _selectedMaritalStatus = null;
                                _selectedMotherTongue = null;
                                _selectedHeightMin = null;
                                _selectedHeightMax = null;
                                _selectedIncome = null;
                                _selectedDiet = null;
                                _selectedManglik = null;
                                _availableCastes = const <String>[];
                                _browseMode = 'matches';
                              });
                              _load();
                              setState(() => _showFilters = false);
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFFE8DCC8)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _loading && _matches.isEmpty
                  ? const VSSkeletonLoader(count: 5)
                  : _matches.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 120),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: _textSecondaryColor,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'No matches found. Try adjusting your filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _matches.map((item) {
                        final p = Map<String, dynamic>.from(item as Map);
                        final galleryProfile = _galleryProfileFor(
                          widget.user,
                          p,
                        );
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MatchProfilePage(
                                  api: widget.api,
                                  token: widget.token,
                                  user: widget.user,
                                  profileId: p['id']?.toString() ?? '',
                                  initialProfile: p,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE8DCC8),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 260,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFF0F0),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: _PhotoCarousel(
                                        profile: galleryProfile,
                                        height: 260,
                                        radius: const BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    if (p['requestSent'] == true ||
                                        p['requestReceived'] == true ||
                                        p['alreadyConnected'] == true)
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: p['alreadyConnected'] == true
                                                ? Colors.green
                                                : const Color(0xFFFFD700),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            p['alreadyConnected'] == true
                                                ? 'Connected'
                                                : p['requestReceived'] == true
                                                ? 'Accept Request'
                                                : 'Request Sent',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p['name']?.toString() ?? 'User',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF4A2C0A),
                                              ),
                                            ),
                                          ),
                                          if (p['age'] != null)
                                            Text(
                                              '${p['age']} yrs',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: _textSecondaryColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _MiniDetail(
                                        icon: Icons.location_on_outlined,
                                        text:
                                            p['city']?.toString().isNotEmpty ==
                                                true
                                            ? p['city'].toString()
                                            : 'N/A',
                                      ),
                                      _MiniDetail(
                                        icon: Icons.work_outline,
                                        text:
                                            p['occupation']
                                                    ?.toString()
                                                    .isNotEmpty ==
                                                true
                                            ? p['occupation'].toString()
                                            : 'N/A',
                                      ),
                                      if ((p['religion']?.toString() ?? '')
                                          .isNotEmpty)
                                        _MiniDetail(
                                          icon: Icons.favorite_border,
                                          text: p['religion'].toString(),
                                        ),
                                      if (p['requestSent'] == true)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                          ),
                                          child: OutlinedButton.icon(
                                            onPressed: () => _cancel(
                                              p['id']?.toString() ?? '',
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              side: const BorderSide(
                                                color: Colors.redAccent,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              minimumSize:
                                                  const Size.fromHeight(42),
                                            ),
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                            ),
                                            label: const Text('Cancel Request'),
                                          ),
                                        )
                                      else if (p['alreadyConnected'] != true)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                          ),
                                          child: FilledButton.icon(
                                            onPressed: () =>
                                                p['requestReceived'] == true
                                                ? _accept(
                                                    p['id']?.toString() ?? '',
                                                  )
                                                : _connect(
                                                    p['id']?.toString() ?? '',
                                                  ),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF8B0000,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              minimumSize:
                                                  const Size.fromHeight(42),
                                            ),
                                            icon: const Icon(
                                              Icons.favorite,
                                              size: 18,
                                            ),
                                            label: Text(
                                              p['requestReceived'] == true
                                                  ? 'Accept Request'
                                                  : 'Connect',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

int? _connectionDaysLeft(Map<String, dynamic> profile) {
  final serverValue = profile['days_remaining'] ?? profile['daysRemaining'];
  if (serverValue is num) return serverValue.toInt().clamp(0, 30);
  final raw = (profile['expiresAt'] ?? profile['expires_at'])?.toString();
  if (raw == null || raw.trim().isEmpty) return null;
  final expiry = DateTime.tryParse(raw);
  if (expiry == null) return null;
  final seconds = expiry.difference(DateTime.now()).inSeconds;
  if (seconds <= 0) return 0;
  final days = (seconds / 86400).ceil();
  return days.clamp(0, 30);
}

bool _canRequestExtension({
  required int? daysLeft,
  required bool extensionPending,
  required bool extensionApproved,
  required bool requestedByMe,
}) {
  if (daysLeft == null) return false;
  if (extensionPending || extensionApproved) return false;
  return daysLeft < 15;
}

class ConnectionsTab extends StatefulWidget {
  const ConnectionsTab({
    super.key,
    required this.api,
    required this.token,
    required this.user,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> user;

  @override
  State<ConnectionsTab> createState() => _ConnectionsTabState();
}

class _ConnectionsTabState extends State<ConnectionsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  Map<String, dynamic> _data = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    final cachedConnections = List<dynamic>.from(
      widget.user['connections'] as List? ?? const <dynamic>[],
    );
    _data = {
      'connections': const <dynamic>[],
      'pendingReceived': List<dynamic>.from(
        widget.user['connectionRequestsReceived'] as List? ??
            widget.user['connection_requests_received'] as List? ??
            const <dynamic>[],
      ),
      'pendingSent': List<dynamic>.from(
        widget.user['connectionRequestsSent'] as List? ??
            widget.user['connection_requests_sent'] as List? ??
            const <dynamic>[],
      ),
      'count': cachedConnections.length,
      'max': 5,
    };
    _loading = true;
    _load();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent || _data.isEmpty) {
      setState(() => _loading = true);
    }
    try {
      final data = await widget.api
          .connections(widget.token)
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<void> Function() action, String message) async {
    try {
      await action();
      _toast(message);
      await _load();
    } catch (e) {
      _toast(e);
    }
  }

  Future<void> _runExtension(
    String connectionId,
    Future<Map<String, dynamic>> Function() action,
    String message, {
    required bool approving,
  }) async {
    try {
      final response = await action();
      if (mounted && approving) {
        final newExpiry = (response['expires_at'] ?? response['new_expires_at'])
            ?.toString();
        setState(() {
          final next = Map<String, dynamic>.from(_data);
          final active = List<dynamic>.from(
            next['connections'] as List? ?? const <dynamic>[],
          );
          next['connections'] = active.map((raw) {
            final item = _asMap(raw);
            final id = (item['connection_id'] ?? item['connectionId'] ?? '')
                .toString();
            if (id != connectionId) return raw;
            final currentExpiry =
                DateTime.tryParse(
                  (item['expiresAt'] ?? item['expires_at'] ?? '').toString(),
                ) ??
                DateTime.now();
            final expiry =
                DateTime.tryParse(newExpiry ?? '') ??
                currentExpiry.add(const Duration(days: 15));
            item['expiresAt'] = expiry.toIso8601String();
            item['expires_at'] = expiry.toIso8601String();
            item['extension_request'] = {
              'status': 'approved',
              'approved_at': DateTime.now().toUtc().toIso8601String(),
            };
            item['extensions'] =
                ((item['extensions'] as num?)?.toInt() ?? 0) + 1;
            return item;
          }).toList();
          _data = next;
        });
      }
      _toast(message);
      await _load(silent: true);
    } catch (e) {
      _toast(e);
    }
  }

  void _toast(Object message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final received = List<dynamic>.from(
      _data['pendingReceived'] as List? ?? <dynamic>[],
    );
    final active = List<dynamic>.from(
      _data['connections'] as List? ?? <dynamic>[],
    );
    final sent = List<dynamic>.from(
      _data['pendingSent'] as List? ?? <dynamic>[],
    );
    final max = (_data['max'] as num?)?.toInt() ?? 5;
    final count = (_data['count'] as num?)?.toInt() ?? active.length;
    return Scaffold(
      backgroundColor: _postLoginBackground,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: VSGradients.matrimonialHero,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your connections: $count/$max active',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelPadding: const EdgeInsets.symmetric(horizontal: 18),
              labelColor: _primaryColor,
              unselectedLabelColor: _textSecondaryColor,
              indicatorColor: _primaryColor,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: 'Active (${active.length})'),
                Tab(text: 'Received (${received.length})'),
                Tab(text: 'Sent (${sent.length})'),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ConnectionsPane(
                    loading: _loading,
                    items: active,
                    emptyLabel: 'No active connections',
                    builder: (item) {
                      final p = Map<String, dynamic>.from(item as Map);
                      if (_relationshipStatus(p).isEmpty) {
                        _applyRelationshipStatus(p, 'CONNECTED');
                      }
                      final daysLeft = _connectionDaysLeft(p);
                      final connectionId =
                          (p['connection_id'] ?? p['connectionId'] ?? '')
                              .toString();
                      final extensionRequest = _asMap(p['extension_request']);
                      final extensionPending =
                          extensionRequest['status']?.toString() == 'pending';
                      final extensionApproved =
                          extensionRequest['status']?.toString() == 'approved';
                      final requestedByMe =
                          extensionRequest['requested_by']?.toString() ==
                          (widget.user['id']?.toString() ?? '');
                      final canRequestExtension = _canRequestExtension(
                        daysLeft: daysLeft,
                        extensionPending: extensionPending,
                        extensionApproved: extensionApproved,
                        requestedByMe: requestedByMe,
                      );
                      final canApproveExtension =
                          extensionPending && !requestedByMe;
                      return _ConnectionCard(
                        profile: p,
                        allowAllPhotos: _isPaidUser(widget.user),
                        name: p['name']?.toString() ?? 'User',
                        detail1: p['age'] != null
                            ? '${p['age']} yrs ${p['city'] != null ? '| ${p['city']}' : ''}'
                            : (p['city']?.toString() ?? ''),
                        detail2: p['occupation']?.toString() ?? '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MatchProfilePage(
                                api: widget.api,
                                token: widget.token,
                                user: widget.user,
                                profileId: p['id']?.toString() ?? '',
                                initialProfile: p,
                              ),
                            ),
                          );
                        },
                        badge: daysLeft == null
                            ? null
                            : _TimerBadge(daysLeft: daysLeft),
                        trailing: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            _RoundIconButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              background: _primaryColor.withValues(alpha: 0.12),
                              iconColor: _primaryColor,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ChatPage(
                                      api: widget.api,
                                      token: widget.token,
                                      currentUser: widget.user,
                                      partner: p,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (connectionId.isNotEmpty) ...[
                              _RoundIconButton(
                                icon: extensionApproved
                                    ? Icons.verified_rounded
                                    : canApproveExtension
                                    ? Icons.check_circle_outline_rounded
                                    : extensionPending && requestedByMe
                                    ? Icons.hourglass_top_rounded
                                    : Icons.update_rounded,
                                background: extensionApproved
                                    ? const Color(0xFFEAF8EF)
                                    : extensionPending
                                    ? const Color(0xFFEFF4FF)
                                    : canRequestExtension
                                    ? const Color(0xFFFFF4DF)
                                    : const Color(0xFFF2F2F2),
                                onTap: extensionApproved
                                    ? null
                                    : extensionPending && requestedByMe
                                    ? null
                                    : !canApproveExtension &&
                                          !canRequestExtension
                                    ? null
                                    : () => _runExtension(
                                        connectionId,
                                        () => canApproveExtension
                                            ? widget.api
                                                  .approveConnectionExtension(
                                                    widget.token,
                                                    connectionId,
                                                  )
                                            : widget.api
                                                  .requestConnectionExtension(
                                                    widget.token,
                                                    connectionId,
                                                  ),
                                        canApproveExtension
                                            ? 'Connection extended by 15 days'
                                            : 'Extension request sent',
                                        approving: canApproveExtension,
                                      ),
                                iconColor: extensionApproved
                                    ? const Color(0xFF217A47)
                                    : extensionPending
                                    ? const Color(0xFF4169A8)
                                    : canRequestExtension
                                    ? const Color(0xFFB26A07)
                                    : _textSecondaryColor,
                              ),
                            ],
                            _RoundIconButton(
                              icon: Icons.delete_outline,
                              background: _surfaceColor,
                              onTap: () => _run(
                                () => widget.api.removeConnection(
                                  widget.token,
                                  p['id']?.toString() ?? '',
                                ),
                                'Connection removed',
                              ),
                              iconColor: Colors.red,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _ConnectionsPane(
                    loading: _loading,
                    items: received,
                    emptyLabel: 'No received connections',
                    builder: (item) {
                      final p = Map<String, dynamic>.from(item as Map);
                      if (_relationshipStatus(p).isEmpty) {
                        _applyRelationshipStatus(p, 'REQUEST_RECEIVED');
                      }
                      return _ConnectionCard(
                        profile: p,
                        allowAllPhotos: false,
                        name: p['name']?.toString() ?? 'User',
                        detail1: p['age'] != null
                            ? '${p['age']} yrs ${p['city'] != null ? '| ${p['city']}' : ''}'
                            : (p['city']?.toString() ?? ''),
                        detail2: p['occupation']?.toString() ?? '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MatchProfilePage(
                                api: widget.api,
                                token: widget.token,
                                user: widget.user,
                                profileId: p['id']?.toString() ?? '',
                                initialProfile: p,
                              ),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _RoundIconButton(
                              icon: Icons.check,
                              background: Colors.green,
                              onTap: () => _run(
                                () => widget.api.acceptRequest(
                                  widget.token,
                                  p['id']?.toString() ?? '',
                                ),
                                'Connection accepted',
                              ),
                            ),
                            const SizedBox(width: 8),
                            _RoundIconButton(
                              icon: Icons.close,
                              background: Colors.red,
                              onTap: () => _run(
                                () => widget.api.rejectRequest(
                                  widget.token,
                                  p['id']?.toString() ?? '',
                                ),
                                'Request rejected',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _ConnectionsPane(
                    loading: _loading,
                    items: sent,
                    emptyLabel: 'No sent connections',
                    builder: (item) {
                      final p = Map<String, dynamic>.from(item as Map);
                      if (_relationshipStatus(p).isEmpty) {
                        _applyRelationshipStatus(p, 'REQUEST_SENT');
                      }
                      return _ConnectionCard(
                        profile: p,
                        allowAllPhotos: false,
                        name: p['name']?.toString() ?? 'User',
                        detail1: p['age'] != null
                            ? '${p['age']} yrs ${p['city'] != null ? '| ${p['city']}' : ''}'
                            : (p['city']?.toString() ?? ''),
                        detail2: p['occupation']?.toString() ?? '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MatchProfilePage(
                                api: widget.api,
                                token: widget.token,
                                user: widget.user,
                                profileId: p['id']?.toString() ?? '',
                                initialProfile: p,
                              ),
                            ),
                          );
                        },
                        trailing: TextButton(
                          onPressed: () => _run(
                            () => widget.api.cancelRequest(
                              widget.token,
                              p['id']?.toString() ?? '',
                            ),
                            'Request cancelled',
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
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

class MessagesTab extends StatefulWidget {
  const MessagesTab({
    super.key,
    required this.api,
    required this.token,
    required this.user,
    this.initialPartnerId,
    this.onInitialPartnerConsumed,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> user;
  final String? initialPartnerId;
  final VoidCallback? onInitialPartnerConsumed;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  bool _loading = true;
  List<dynamic> _connections = <dynamic>[];
  Map<String, int> _unreadByPartner = <String, int>{};
  Map<String, ChatMessage> _lastMessageByPartner = <String, ChatMessage>{};
  bool _openedInitialPartner = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && _connections.isEmpty) setState(() => _loading = true);
    try {
      final data = await widget.api
          .connections(widget.token)
          .timeout(const Duration(seconds: 8));
      final connections = List<dynamic>.from(
        data['connections'] as List? ?? <dynamic>[],
      );
      final myId = widget.user['id']?.toString() ?? '';
      final unreadByPartner = <String, int>{};
      final lastByPartner = <String, ChatMessage>{};
      await Future.wait(
        connections.map((rawProfile) async {
          final profile = _asMap(rawProfile);
          final partnerId = profile['id']?.toString() ?? '';
          if (partnerId.isEmpty) return;
          try {
            final messages = await widget.api.messages(widget.token, partnerId);
            final normalized =
                messages
                    .map((item) => ChatMessage.fromMap(_asMap(item)))
                    .toList()
                  ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            if (normalized.isNotEmpty) {
              lastByPartner[partnerId] = normalized.last;
              unreadByPartner[partnerId] = normalized
                  .where(
                    (message) =>
                        message.senderId == partnerId &&
                        message.receiverId == myId &&
                        !message.read,
                  )
                  .length;
            }
          } catch (_) {
            // Keep list rendering even if one thread fetch fails.
          }
        }),
      );
      if (!mounted) return;
      setState(() {
        _connections = connections;
        _unreadByPartner = unreadByPartner;
        _lastMessageByPartner = lastByPartner;
      });
      _openInitialPartnerIfNeeded(connections);
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  void _openInitialPartnerIfNeeded(List<dynamic> connections) {
    final targetId = widget.initialPartnerId?.trim() ?? '';
    if (_openedInitialPartner || targetId.isEmpty) return;
    Map<String, dynamic>? match;
    for (final item in connections) {
      final profile = _asMap(item);
      if (profile['id']?.toString() == targetId) {
        match = profile;
        break;
      }
    }
    final partner = match;
    if (partner == null) return;
    _openedInitialPartner = true;
    widget.onInitialPartnerConsumed?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        Navigator.of(context)
            .push(
              MaterialPageRoute<void>(
                builder: (_) => ChatPage(
                  api: widget.api,
                  token: widget.token,
                  currentUser: widget.user,
                  partner: partner,
                ),
              ),
            )
            .then((_) {
              if (mounted) unawaited(_load(silent: true));
            }),
      );
    });
  }

  Future<void> _openChat(Map<String, dynamic> partner) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(
          api: widget.api,
          token: widget.token,
          currentUser: widget.user,
          partner: partner,
        ),
      ),
    );
    if (mounted) {
      await _load(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      body: RefreshIndicator(
        onRefresh: () => _load(),
        child: _loading && _connections.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _connections.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: _textSecondaryColor,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No messages yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Connect with someone to start chatting',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _connections.length,
                itemBuilder: (_, index) {
                  final p = Map<String, dynamic>.from(
                    _connections[index] as Map,
                  );
                  final partnerId = p['id']?.toString() ?? '';
                  final unread = _unreadByPartner[partnerId] ?? 0;
                  final lastMessage = _lastMessageByPartner[partnerId];
                  final myId = widget.user['id']?.toString() ?? '';
                  final preview = lastMessage == null
                      ? _personSummary(p)
                      : '${lastMessage.senderId == myId ? 'You: ' : ''}${lastMessage.content}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: unread > 0
                            ? _primaryColor.withValues(alpha: 0.35)
                            : _borderColor,
                      ),
                    ),
                    child: ListTile(
                      leading: _CircularProfileAvatar(profile: p, size: 54),
                      title: Text(p['name']?.toString() ?? 'User'),
                      subtitle: Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unread > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : unread.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          const Icon(
                            Icons.chevron_right,
                            color: _textSecondaryColor,
                          ),
                        ],
                      ),
                      onTap: () => unawaited(_openChat(p)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.api,
    required this.token,
    required this.user,
    required this.onUserChanged,
    required this.onLogout,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> user;
  final Future<void> Function(Map<String, dynamic>) onUserChanged;
  final Future<void> Function() onLogout;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _loading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await widget.api.me(widget.token);
      if (!mounted) return;
      setState(() => _profile = profile);
      await widget.onUserChanged(profile);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile ?? widget.user;
    return Scaffold(
      backgroundColor: _postLoginBackground,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: VSGradients.matrimonialHero,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _CircularProfileAvatar(
                      profile: profile,
                      size: 108,
                      borderColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile['name']?.toString() ?? 'User',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile['email']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        'Plan: ${(profile['plan']?.toString() ?? 'free').toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        final updated = await Navigator.of(context)
                            .push<Map<String, dynamic>>(
                              MaterialPageRoute<Map<String, dynamic>>(
                                builder: (_) => EditProfilePage(
                                  api: widget.api,
                                  token: widget.token,
                                  initialProfile: profile,
                                  onProfileSaved: widget.onUserChanged,
                                ),
                              ),
                            );
                        if (updated != null) {
                          setState(() => _profile = updated);
                          await widget.onUserChanged(updated);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(color: _shaadiMaroon),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ProfileMenuTile(
                    icon: Icons.credit_card,
                    label: 'Subscription',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReactSubscriptionPage(
                          api: widget.api,
                          token: widget.token,
                          currentPlan: profile['plan']?.toString() ?? 'free',
                        ),
                      ),
                    ),
                  ),
                  _ProfileMenuTile(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SettingsPage(api: widget.api, token: widget.token),
                      ),
                    ),
                  ),
                  _ProfileMenuTile(
                    icon: Icons.help,
                    label: 'Help & Support',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HelpSupportPage(),
                      ),
                    ),
                  ),
                  _ProfileMenuTile(
                    icon: Icons.notifications_active,
                    label: 'Notifications',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => NotificationsPage(
                          api: widget.api,
                          token: widget.token,
                        ),
                      ),
                    ),
                  ),
                  _ProfileMenuTile(
                    icon: Icons.info,
                    label: 'About',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutPage(),
                      ),
                    ),
                    showBorder: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: widget.onLogout,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class MatchProfilePage extends StatefulWidget {
  const MatchProfilePage({
    super.key,
    required this.api,
    required this.token,
    required this.user,
    required this.profileId,
    this.initialProfile,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> user;
  final String profileId;
  final Map<String, dynamic>? initialProfile;

  @override
  State<MatchProfilePage> createState() => _MatchProfilePageState();
}

class _MatchProfilePageState extends State<MatchProfilePage> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic> _subscription = <String, dynamic>{};
  bool _requestSentLocally = false;
  bool _requestAcceptedLocally = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _load();
  }

  Future<void> _load() async {
    if (widget.profileId.isEmpty) return;
    setState(() => _loading = true);
    try {
      final previousProfile = _profile == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(_profile!);
      final results = await Future.wait<dynamic>([
        widget.api.profile(widget.token, widget.profileId),
        widget.api
            .currentSubscription(widget.token)
            .catchError((_) => <String, dynamic>{}),
      ]);
      final profile = Map<String, dynamic>.from(results[0] as Map);
      final subscription = _asMap(results[1]);
      final refreshed = Map<String, dynamic>.from(profile);
      final refreshedStatus = _relationshipStatus(refreshed);
      final previousStatus = _relationshipStatus(previousProfile);
      if ((refreshedStatus.isEmpty || refreshedStatus == 'NONE') &&
          previousStatus.isNotEmpty &&
          previousStatus != 'NONE') {
        _applyRelationshipStatus(refreshed, previousStatus);
      }
      if (!mounted) return;
      setState(() {
        _profile = refreshed;
        _subscription = subscription;
      });
    } catch (_) {
      // Keep the passed profile visible if the detail refresh fails.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connect() async {
    try {
      final response = await widget.api.sendRequest(
        widget.token,
        widget.profileId,
      );
      if (!mounted) return;
      setState(() {
        _requestSentLocally = true;
        final profile = _profile ?? <String, dynamic>{};
        _applyRelationshipStatus(
          profile,
          response['relationshipStatus']?.toString() ?? 'REQUEST_SENT',
        );
        _profile = profile;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Connection request sent')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _cancelRequest() async {
    try {
      final response = await widget.api.cancelRequest(
        widget.token,
        widget.profileId,
      );
      if (!mounted) return;
      setState(() {
        _requestSentLocally = false;
        final profile = _profile ?? <String, dynamic>{};
        _applyRelationshipStatus(
          profile,
          response['relationshipStatus']?.toString() ?? 'NONE',
        );
        _profile = profile;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request cancelled')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _acceptRequest() async {
    try {
      final response = await widget.api.acceptRequest(
        widget.token,
        widget.profileId,
      );
      if (!mounted) return;
      setState(() {
        _requestAcceptedLocally = true;
        final profile = _profile ?? <String, dynamic>{};
        _applyRelationshipStatus(
          profile,
          response['relationshipStatus']?.toString() ?? 'CONNECTED',
        );
        _profile = profile;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Connection accepted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    final connectedIds = List<dynamic>.from(
      widget.user['connections'] as List? ?? const <dynamic>[],
    ).map((id) => id.toString()).toSet();
    final receivedIds = List<dynamic>.from(
      widget.user['connectionRequestsReceived'] as List? ??
          widget.user['connection_requests_received'] as List? ??
          const <dynamic>[],
    ).map((id) => id.toString()).toSet();
    final isConnected =
        _requestAcceptedLocally ||
        (p != null && _alreadyConnectedFlag(p)) ||
        connectedIds.contains(widget.profileId);
    final requestSent =
        _requestSentLocally || (p != null && _requestSentFlag(p));
    final requestReceived =
        (p != null && _requestReceivedFlag(p)) ||
        receivedIds.contains(widget.profileId);
    final subscriptionUser = Map<String, dynamic>.from(widget.user)
      ..['plan'] = _subscription['plan'] ?? widget.user['plan']
      ..['features'] = _subscription['features'] ?? widget.user['features'];
    final isPaid =
        (_subscription['subscriptionStatus']?.toString().toLowerCase() ==
            'active') ||
        (_subscription['subscription_status']?.toString().toLowerCase() ==
            'active') ||
        _isPaidUser(subscriptionUser);
    final canSeeContact = isPaid && isConnected;
    final allPhotos = p == null ? <String>[] : _photoUrls(p);
    final canSeeExtraPhotos = isConnected && isPaid;
    final visibleProfile = p == null
        ? <String, dynamic>{}
        : _galleryProfileFor(subscriptionUser, p, forceAll: canSeeExtraPhotos);
    final galleryPhotos = allPhotos.length > 1
        ? allPhotos.skip(1).toList()
        : <String>[];
    return Scaffold(
      backgroundColor: _postLoginBackground,
      body: _loading && _profile == null
          ? const VSSkeletonLoader(count: 3)
          : p == null
          ? const Center(child: Text('Profile not found'))
          : Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      height: 400,
                      color: const Color(0xFFFFF0F0),
                      child: _PhotoCarousel(
                        profile: visibleProfile,
                        height: 400,
                      ),
                    ),
                    if ((p['about']?.toString() ?? '').isNotEmpty)
                      _CreamCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A2C0A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              p['about'].toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: _textColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if ((p['familyDetails']?.toString() ?? '').isNotEmpty ||
                        (p['family_details']?.toString() ?? '').isNotEmpty)
                      _CreamCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Family',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A2C0A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              (p['familyDetails'] ?? p['family_details'])
                                  .toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: _textColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8DCC8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name']?.toString() ?? 'User',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A2C0A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${p['age'] != null ? '${p['age']} yrs' : ''}${(p['height']?.toString() ?? '').isNotEmpty ? ' | ${p['height']}' : ''}${(p['maritalStatus']?.toString() ?? '').isNotEmpty ? ' | ${p['maritalStatus']}' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ProfileDetailRow(
                            icon: Icons.location_on,
                            label: 'Location',
                            value:
                                '${p['city'] ?? ''} ${p['state'] ?? ''}'
                                    .trim()
                                    .isEmpty
                                ? 'N/A'
                                : '${p['city'] ?? ''} ${p['state'] ?? ''}'
                                      .trim(),
                          ),
                          _ProfileDetailRow(
                            icon: Icons.favorite,
                            label: 'Religion',
                            value:
                                '${p['religion'] ?? 'N/A'} ${(p['caste']?.toString() ?? '').isNotEmpty ? '- ${p['caste']}' : ''}'
                                    .trim(),
                          ),
                          _ProfileDetailRow(
                            icon: Icons.groups_rounded,
                            label: 'Sub-caste',
                            value:
                                p['subCaste']?.toString() ??
                                p['sub_caste']?.toString() ??
                                'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.cake_rounded,
                            label: 'Date of Birth',
                            value: canSeeContact
                                ? (p['dateOfBirth']?.toString() ??
                                      p['date_of_birth']?.toString() ??
                                      p['dob']?.toString() ??
                                      'N/A')
                                : 'Visible after paid mutual connection',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.school,
                            label: 'Education',
                            value: p['education']?.toString() ?? 'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.work,
                            label: 'Occupation',
                            value: p['occupation']?.toString() ?? 'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.payments,
                            label: 'Income',
                            value: p['income']?.toString() ?? 'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.language,
                            label: 'Mother Tongue',
                            value: p['motherTongue']?.toString() ?? 'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.restaurant_rounded,
                            label: 'Diet',
                            value: p['diet']?.toString() ?? 'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Manglik',
                            value: p['manglik']?.toString() ?? 'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Family Financial Status',
                            value:
                                p['familyFinancialStatus']?.toString() ??
                                p['family_financial_status']?.toString() ??
                                'N/A',
                          ),
                          _ProfileDetailRow(
                            icon: Icons.local_activity_rounded,
                            label: 'Hobbies',
                            value: p['hobbies']?.toString() ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                    if (galleryPhotos.isNotEmpty)
                      _CreamCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'More Photos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A2C0A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (canSeeExtraPhotos)
                              SizedBox(
                                height: 94,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: galleryPhotos.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (_, index) => GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).push<void>(
                                          MaterialPageRoute<void>(
                                            builder: (_) => _PhotoViewer(
                                              photos: allPhotos,
                                              initialIndex: index + 1,
                                            ),
                                          ),
                                        ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: _SmartImage(
                                        source: galleryPhotos[index],
                                        width: 94,
                                        height: 94,
                                        fit: BoxFit.cover,
                                        fallback: () => Container(
                                          width: 94,
                                          height: 94,
                                          color: const Color(0xFFFFF0F0),
                                          child: const Icon(
                                            Icons.person,
                                            color: _borderColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (galleryPhotos.isNotEmpty)
                                    SizedBox(
                                      height: 94,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: galleryPhotos.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (_, index) => ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ImageFiltered(
                                                imageFilter: ImageFilter.blur(
                                                  sigmaX: 8,
                                                  sigmaY: 8,
                                                ),
                                                child: _SmartImage(
                                                  source: galleryPhotos[index],
                                                  width: 94,
                                                  height: 94,
                                                  fit: BoxFit.cover,
                                                  fallback: () => Container(
                                                    width: 94,
                                                    height: 94,
                                                    color: const Color(
                                                      0xFFFFF0F0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.lock_rounded,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  VSGatedContentCard(
                                    title: isPaid
                                        ? 'Connect to see more photos'
                                        : 'Upgrade to see more photos',
                                    subtitle:
                                        'The profile photo is visible for free. Extra photos unlock only after subscription and mutual connection.',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    _CreamCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A2C0A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (canSeeContact) ...[
                            _ProfileDetailRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: p['email']?.toString() ?? 'N/A',
                            ),
                            _ProfileDetailRow(
                              icon: Icons.call,
                              label: 'Phone',
                              value: p['phone']?.toString() ?? 'N/A',
                            ),
                          ] else
                            VSGatedContentCard(
                              title: isPaid
                                  ? 'Make connection to see details'
                                  : 'Upgrade to see contact details',
                              subtitle: isPaid
                                  ? 'Once both sides are connected, email, phone, and date of birth become visible.'
                                  : 'Subscribe to Focus or Commit plan and connect with this match.',
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: requestSent
                          ? OutlinedButton.icon(
                              onPressed: _cancelRequest,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.redAccent),
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.close_rounded, size: 20),
                              label: const Text('Cancel Request'),
                            )
                          : FilledButton.icon(
                              onPressed: isConnected
                                  ? null
                                  : requestReceived
                                  ? _acceptRequest
                                  : _connect,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF8B0000),
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.favorite, size: 20),
                              label: Text(
                                isConnected
                                    ? 'Already Connected'
                                    : requestReceived
                                    ? 'Accept Request'
                                    : 'Send Connection Request',
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 4,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: _textColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.api,
    required this.token,
    required this.initialProfile,
    this.requireProfileCompletion = false,
    this.onProfileSaved,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> initialProfile;
  final bool requireProfileCompletion;
  final Future<void> Function(Map<String, dynamic> user)? onProfileSaved;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _dob;
  late final TextEditingController _city;
  late final TextEditingController _education;
  late final TextEditingController _occupation;
  late final TextEditingController _about;
  late final TextEditingController _familyDetails;
  late final TextEditingController _hobbies;
  late final TextEditingController _phone;
  late final TextEditingController _religion;
  late final TextEditingController _height;
  late final TextEditingController _income;
  late final TextEditingController _diet;
  late final TextEditingController _manglik;
  late final TextEditingController _familyFinancialStatus;
  late final TextEditingController _caste;
  late final TextEditingController _subCaste;
  late final TextEditingController _motherTongue;
  late final TextEditingController _maritalStatus;
  late final TextEditingController _prefAgeMin;
  late final TextEditingController _prefAgeMax;
  late final TextEditingController _prefLocation;
  late final TextEditingController _prefProfession;
  late final TextEditingController _prefReligion;
  late final TextEditingController _prefCaste;
  late final TextEditingController _prefHeightMin;
  late final TextEditingController _prefHeightMax;
  late final TextEditingController _prefIncome;
  late final TextEditingController _prefDiet;
  late final TextEditingController _prefManglik;
  String _gender = 'Male';
  bool _photoVisible = true;
  bool _saving = false;
  bool _uploadingPhoto = false;
  List<String> _photos = <String>[];
  String? _selectedCity;
  String? _selectedReligion;
  String? _selectedCaste;
  String? _selectedSubCaste;
  String? _selectedMotherTongue;
  String? _selectedMaritalStatus;
  String? _selectedEducation;
  String? _selectedProfession;
  String? _selectedHeight;
  String? _selectedIncome;
  String? _selectedDiet;
  String? _selectedManglik;
  String? _selectedFamilyFinancialStatus;
  String? _selectedHobby;
  String? _selectedPrefLocation;
  String? _selectedPrefReligion;
  String? _selectedPrefCaste;
  String? _selectedPrefProfession;
  String? _selectedPrefHeightMin;
  String? _selectedPrefHeightMax;
  String? _selectedPrefIncome;
  String? _selectedPrefDiet;
  String? _selectedPrefManglik;
  List<String> _availableCastes = const <String>[];
  List<String> _availableSubCastes = const <String>[];
  List<String> _availablePrefCastes = const <String>[];
  static const List<String> _genderOptions = <String>['Male', 'Female'];

  String _normalizeGender(dynamic raw) {
    final value = raw?.toString().trim().toLowerCase() ?? '';
    if (value == 'female') return 'Female';
    return 'Male';
  }

  String? _cleanSinglePreference(dynamic raw) {
    final values = _asList(raw)
        .map((item) => item.toString().trim())
        .where(
          (item) => item.isNotEmpty && item != '[]' && !_isAnyPreference(item),
        )
        .toList();
    if (values.isNotEmpty) return values.first;
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    if (text == '[]' || _isAnyPreference(text)) return null;
    if (text.contains(',')) {
      final first = text
          .split(',')
          .map((item) => item.trim())
          .firstWhere((item) => item.isNotEmpty, orElse: () => '');
      return first.isEmpty ? null : first;
    }
    return text;
  }

  String _cleanPreferenceText(dynamic raw, {String defaultValue = 'Any'}) {
    final values = _asList(raw)
        .map((item) => item.toString().trim())
        .where(
          (item) => item.isNotEmpty && item != '[]' && !_isAnyPreference(item),
        )
        .toList();
    if (values.isNotEmpty) return values.join(', ');
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty || text == '[]' || _isAnyPreference(text)) {
      return defaultValue;
    }
    return text;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _name = TextEditingController(text: p['name']?.toString() ?? '');
    _dob = TextEditingController(text: p['dob']?.toString() ?? '');
    _city = TextEditingController(text: p['city']?.toString() ?? '');
    _education = TextEditingController(text: p['education']?.toString() ?? '');
    _occupation = TextEditingController(
      text: p['occupation']?.toString() ?? '',
    );
    _about = TextEditingController(text: p['about']?.toString() ?? '');
    _familyDetails = TextEditingController(
      text: p['familyDetails']?.toString() ?? '',
    );
    _hobbies = TextEditingController(text: p['hobbies']?.toString() ?? '');
    _phone = TextEditingController(text: p['phone']?.toString() ?? '');
    _religion = TextEditingController(text: p['religion']?.toString() ?? '');
    _height = TextEditingController(text: p['height']?.toString() ?? '');
    _income = TextEditingController(text: p['income']?.toString() ?? '');
    _diet = TextEditingController(text: p['diet']?.toString() ?? '');
    _manglik = TextEditingController(text: p['manglik']?.toString() ?? '');
    _familyFinancialStatus = TextEditingController(
      text:
          p['familyFinancialStatus']?.toString() ??
          p['family_financial_status']?.toString() ??
          '',
    );
    _caste = TextEditingController(text: p['caste']?.toString() ?? '');
    _subCaste = TextEditingController(
      text:
          p['subCaste']?.toString() ??
          p['sub_caste']?.toString() ??
          p['subcast']?.toString() ??
          '',
    );
    _motherTongue = TextEditingController(
      text: p['motherTongue']?.toString() ?? '',
    );
    _maritalStatus = TextEditingController(
      text: p['maritalStatus']?.toString() ?? '',
    );
    final prefs = _asMap(p['partnerPreferences'] ?? p['partner_preferences']);
    _prefAgeMin = TextEditingController(
      text: prefs['age_min']?.toString() ?? '18',
    );
    _prefAgeMax = TextEditingController(
      text: prefs['age_max']?.toString() ?? '',
    );
    _prefLocation = TextEditingController(
      text: _cleanPreferenceText(prefs['location'], defaultValue: 'Any'),
    );
    _prefProfession = TextEditingController(
      text: _cleanPreferenceText(prefs['profession'], defaultValue: 'Any'),
    );
    _prefReligion = TextEditingController(
      text: _cleanSinglePreference(prefs['religion']) ?? '',
    );
    _prefCaste = TextEditingController(
      text: _cleanPreferenceText(prefs['caste'], defaultValue: 'Any'),
    );
    _prefHeightMin = TextEditingController(
      text:
          _cleanSinglePreference(prefs['height_min'] ?? prefs['minHeight']) ??
          'Any',
    );
    _prefHeightMax = TextEditingController(
      text:
          _cleanSinglePreference(prefs['height_max'] ?? prefs['maxHeight']) ??
          'Any',
    );
    _prefIncome = TextEditingController(
      text:
          _cleanSinglePreference(prefs['income'] ?? prefs['income_range']) ??
          'Any',
    );
    _prefDiet = TextEditingController(
      text: _cleanSinglePreference(prefs['diet']) ?? 'Any',
    );
    _prefManglik = TextEditingController(
      text: _cleanSinglePreference(prefs['manglik']) ?? 'Any',
    );
    _photos = _photoUrls(p);
    _gender = _normalizeGender(p['gender']);
    _photoVisible =
        (p['photoVisibility']?.toString().toLowerCase() ?? 'yes') != 'no';
    _selectedCity = _city.text.trim().isEmpty ? null : _city.text.trim();
    _selectedReligion = _religion.text.trim().isEmpty
        ? null
        : _religion.text.trim();
    _selectedCaste = _caste.text.trim().isEmpty ? null : _caste.text.trim();
    _selectedSubCaste = _subCaste.text.trim().isEmpty
        ? null
        : _subCaste.text.trim();
    _selectedMotherTongue = _motherTongue.text.trim().isEmpty
        ? null
        : _motherTongue.text.trim();
    _selectedMaritalStatus = _maritalStatus.text.trim().isEmpty
        ? null
        : _maritalStatus.text.trim();
    _selectedEducation = _education.text.trim().isEmpty
        ? null
        : _education.text.trim();
    _selectedProfession = _occupation.text.trim().isEmpty
        ? null
        : _occupation.text.trim();
    _selectedHeight = _height.text.trim().isEmpty ? null : _height.text.trim();
    _selectedIncome = _income.text.trim().isEmpty ? null : _income.text.trim();
    _selectedDiet = _diet.text.trim().isEmpty ? null : _diet.text.trim();
    _selectedManglik = _manglik.text.trim().isEmpty
        ? null
        : _manglik.text.trim();
    _selectedFamilyFinancialStatus = _familyFinancialStatus.text.trim().isEmpty
        ? null
        : _familyFinancialStatus.text.trim();
    _selectedHobby = _hobbies.text.trim().isEmpty ? null : _hobbies.text.trim();
    _selectedPrefLocation = _prefLocation.text.trim().isEmpty
        ? 'Any'
        : _prefLocation.text.trim();
    _selectedPrefReligion = _prefReligion.text.trim().isEmpty
        ? 'Any'
        : _prefReligion.text.trim();
    _selectedPrefCaste = _prefCaste.text.trim().isEmpty
        ? 'Any'
        : _prefCaste.text.trim();
    _selectedPrefProfession = _prefProfession.text.trim().isEmpty
        ? 'Any'
        : _prefProfession.text.trim();
    _selectedPrefHeightMin = _prefHeightMin.text.trim().isEmpty
        ? 'Any'
        : _prefHeightMin.text.trim();
    _selectedPrefHeightMax = _prefHeightMax.text.trim().isEmpty
        ? 'Any'
        : _prefHeightMax.text.trim();
    _selectedPrefIncome = _prefIncome.text.trim().isEmpty
        ? 'Any'
        : _prefIncome.text.trim();
    _selectedPrefDiet = _prefDiet.text.trim().isEmpty
        ? 'Any'
        : _prefDiet.text.trim();
    _selectedPrefManglik = _prefManglik.text.trim().isEmpty
        ? 'Any'
        : _prefManglik.text.trim();
    for (final controller in [
      _prefLocation,
      _prefReligion,
      _prefCaste,
      _prefProfession,
      _prefHeightMin,
      _prefHeightMax,
      _prefIncome,
      _prefDiet,
      _prefManglik,
    ]) {
      if (controller.text.trim().isEmpty) controller.text = 'Any';
    }
    if (_selectedReligion != null && _selectedReligion!.isNotEmpty) {
      unawaited(_loadCasteOptions(_selectedReligion!, pref: false));
    }
    if (_selectedPrefReligion != null && _selectedPrefReligion!.isNotEmpty) {
      unawaited(_loadCasteOptions(_selectedPrefReligion!, pref: true));
    }
    if (_selectedCaste != null && _selectedCaste!.isNotEmpty) {
      unawaited(_loadSubCasteOptions(_selectedCaste!));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    _city.dispose();
    _education.dispose();
    _occupation.dispose();
    _about.dispose();
    _familyDetails.dispose();
    _hobbies.dispose();
    _phone.dispose();
    _religion.dispose();
    _height.dispose();
    _income.dispose();
    _diet.dispose();
    _manglik.dispose();
    _familyFinancialStatus.dispose();
    _caste.dispose();
    _subCaste.dispose();
    _motherTongue.dispose();
    _maritalStatus.dispose();
    _prefAgeMin.dispose();
    _prefAgeMax.dispose();
    _prefLocation.dispose();
    _prefProfession.dispose();
    _prefReligion.dispose();
    _prefCaste.dispose();
    _prefHeightMin.dispose();
    _prefHeightMax.dispose();
    _prefIncome.dispose();
    _prefDiet.dispose();
    _prefManglik.dispose();
    super.dispose();
  }

  int? _age(String dob) {
    final parts = dob.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    final birth = DateTime(y, m, d);
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day))
      age--;
    return age > 0 ? age : null;
  }

  Future<void> _loadCasteOptions(String religion, {required bool pref}) async {
    if (religion.trim().isEmpty || _isAnyPreference(religion)) {
      if (!mounted) return;
      setState(() {
        if (pref) {
          _availablePrefCastes = const <String>[];
          _selectedPrefCaste = 'Any';
          _prefCaste.text = 'Any';
        } else {
          _availableCastes = const <String>[];
          _availableSubCastes = const <String>[];
          _selectedCaste = null;
          _selectedSubCaste = null;
          _caste.clear();
          _subCaste.clear();
        }
      });
      return;
    }
    final remoteCastes = await widget.api.castes(religion);
    final merged = _mergeDropdownOptions(
      remoteCastes,
      pref ? _selectedPrefCaste : _selectedCaste,
    );
    if (!mounted) return;
    setState(() {
      if (pref) {
        _availablePrefCastes = merged;
      } else {
        _availableCastes = merged;
      }
    });
  }

  Future<void> _loadSubCasteOptions(String caste) async {
    if (caste.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _availableSubCastes = const <String>[];
        _selectedSubCaste = null;
        _subCaste.clear();
      });
      return;
    }
    final remoteSubCastes = await widget.api.subCastes(caste);
    final merged = _mergeDropdownOptions(<String>[
      ..._subCasteChoices(caste, null),
      ...remoteSubCastes,
    ], _selectedSubCaste);
    if (!mounted) return;
    setState(() => _availableSubCastes = merged);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final dob = _dob.text.trim();
    final phone = _phone.text.trim();
    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    final age = _age(dob);
    if (widget.requireProfileCompletion) {
      final missing = <String>[];
      void requireText(String label, TextEditingController controller) {
        if (controller.text.trim().isEmpty) missing.add(label);
      }

      if (name.isEmpty) missing.add('Full name');
      if (dob.isEmpty || age == null) missing.add('Valid date of birth');
      if (phone.isEmpty) missing.add('Phone number');
      if (!_genderOptions.contains(_gender)) missing.add('Gender');
      requireText('City', _city);
      requireText('Religion', _religion);
      requireText('Caste', _caste);
      requireText('Sub-caste', _subCaste);
      requireText('Mother tongue', _motherTongue);
      requireText('Marital status', _maritalStatus);
      requireText('Education', _education);
      requireText('Profession', _occupation);
      requireText('Height', _height);
      requireText('Income', _income);
      requireText('Diet', _diet);
      requireText('Manglik status', _manglik);
      requireText('About you', _about);
      requireText('Hobbies', _hobbies);
      requireText('Family details', _familyDetails);
      requireText('Family financial status', _familyFinancialStatus);
      requireText('Preferred min age', _prefAgeMin);
      requireText('Preferred max age', _prefAgeMax);
      requireText('Preferred location', _prefLocation);
      requireText('Preferred religion', _prefReligion);
      requireText('Preferred caste', _prefCaste);
      if (_photos.isEmpty) missing.add('At least one photo');
      if (missing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please complete: ${missing.take(4).join(', ')}'),
          ),
        );
        return;
      }
    }
    if (phoneDigits.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10 digit mobile number'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final city = _city.text.trim();
      final preferredMinAge = int.tryParse(_prefAgeMin.text.trim()) ?? 18;
      if (preferredMinAge < 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferred min age cannot be below 18')),
        );
        setState(() => _saving = false);
        return;
      }
      final preferredMaxAge = int.tryParse(_prefAgeMax.text.trim());
      await widget.api.updateProfile(widget.token, {
        'name': name,
        'dob': dob,
        'date_of_birth': dob,
        'age': age,
        'gender': _gender.toLowerCase(),
        'city': city,
        'location': city,
        'education': _education.text.trim(),
        'occupation': _occupation.text.trim(),
        'profession': _occupation.text.trim(),
        'phone': phoneDigits,
        'religion': _religion.text.trim(),
        'height': _height.text.trim(),
        'income': _income.text.trim(),
        'diet': _diet.text.trim(),
        'manglik': _manglik.text.trim(),
        'caste': _caste.text.trim(),
        'sub_caste': _subCaste.text.trim(),
        'subCaste': _subCaste.text.trim(),
        'mother_tongue': _motherTongue.text.trim(),
        'marital_status': _maritalStatus.text.trim(),
        'about': _about.text.trim(),
        'hobbies': _hobbies.text.trim(),
        'familyDetails': _familyDetails.text.trim(),
        'family_details': _familyDetails.text.trim(),
        'familyFinancialStatus': _familyFinancialStatus.text.trim(),
        'family_financial_status': _familyFinancialStatus.text.trim(),
        'photoVisibility': _photoVisible ? 'yes' : 'no',
        'partner_preferences': {
          'age_min': preferredMinAge,
          'minAge': preferredMinAge,
          'age_max': preferredMaxAge,
          'maxAge': preferredMaxAge,
          'location': _preferenceList(_prefLocation),
          'city': _preferenceList(_prefLocation),
          'profession': _preferenceList(_prefProfession),
          'occupation': _preferenceList(_prefProfession),
          'religion': _preferenceList(_prefReligion),
          'caste': _preferenceList(_prefCaste),
          'height_min': _preferenceList(_prefHeightMin),
          'height_max': _preferenceList(_prefHeightMax),
          'income': _preferenceList(_prefIncome),
          'diet': _preferenceList(_prefDiet),
          'manglik': _preferenceList(_prefManglik),
        },
      });
      final updated = await widget.api.me(widget.token);
      if (!mounted) return;
      if (widget.onProfileSaved != null) {
        await widget.onProfileSaved!(updated);
      }
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
    );
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      await widget.api.uploadPhoto(widget.token, picked.path);
      final refreshedProfile = await widget.api.me(widget.token);
      if (!mounted) return;
      setState(() => _photos = _photoUrls(refreshedProfile));
      if (widget.onProfileSaved != null) {
        await widget.onProfileSaved!(refreshedProfile);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _deletePhoto(int index) async {
    if (index < 0 || index >= _photos.length) return;
    setState(() => _uploadingPhoto = true);
    try {
      await widget.api.deletePhoto(widget.token, index);
      final refreshedProfile = await widget.api.me(widget.token);
      if (!mounted) return;
      setState(() => _photos = _photoUrls(refreshedProfile));
      if (widget.onProfileSaved != null) {
        await widget.onProfileSaved!(refreshedProfile);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo removed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _setPrimaryPhoto(int index) async {
    if (index < 0 || index >= _photos.length) return;
    final selected = _photos[index];
    final reordered = <String>[
      selected,
      ..._photos.where((photo) => photo != selected),
    ];
    setState(() {
      _uploadingPhoto = true;
      _photos = reordered;
    });
    try {
      var ordered = <dynamic>[];
      Object? lastError;
      try {
        ordered = await widget.api.setPrimaryPhotoPath(widget.token, selected);
      } catch (e) {
        lastError = e;
      }
      if (ordered.isEmpty) {
        try {
          ordered = await widget.api.setPrimaryPhoto(widget.token, index);
        } catch (e) {
          lastError = e;
        }
      }
      if (ordered.isEmpty) {
        try {
          final fallbackProfile = await widget.api.updateProfile(widget.token, {
            'photos': reordered,
            'profile_photo': selected,
            'photoUrl': selected,
          });
          ordered = _photoUrls(fallbackProfile);
        } catch (e) {
          lastError = e;
        }
      }
      if (ordered.isEmpty && lastError != null) {
        throw lastError;
      }
      final refreshedProfile = await widget.api.me(widget.token);
      if (!mounted) return;
      final refreshedPhotos = _photoUrls(refreshedProfile);
      final visiblePhotos = refreshedPhotos.contains(selected)
          ? <String>[
              selected,
              ...refreshedPhotos.where((photo) => photo != selected),
            ]
          : (refreshedPhotos.isNotEmpty ? refreshedPhotos : reordered);
      final effectiveProfile = Map<String, dynamic>.from(refreshedProfile);
      final primaryPhoto = visiblePhotos.isNotEmpty
          ? visiblePhotos.first
          : selected;
      effectiveProfile['photos'] = visiblePhotos;
      effectiveProfile['profile_photo'] = primaryPhoto;
      effectiveProfile['photoUrl'] = primaryPhoto;
      effectiveProfile['profilePhoto'] = primaryPhoto;
      effectiveProfile['avatar'] = primaryPhoto;
      setState(() {
        _photos = ordered.isNotEmpty
            ? ordered.map((item) => item.toString()).toList()
            : reordered;
        _photos = visiblePhotos.isNotEmpty ? visiblePhotos : _photos;
      });
      if (widget.onProfileSaved != null) {
        await widget.onProfileSaved!(effectiveProfile);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.requireProfileCompletion,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E7),
        appBar: AppBar(
          automaticallyImplyLeading: !widget.requireProfileCompletion,
          title: Text(
            widget.requireProfileCompletion
                ? 'Complete Your Profile'
                : 'Edit Profile',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.requireProfileCompletion)
              _CreamCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Complete your profile to continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B0000),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please fill every profile field and upload at least one photo before entering the app.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondaryColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            _CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Photos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_photos.length}/5 uploaded. Choose one as your profile photo.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length >= 5
                          ? _photos.length
                          : _photos.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        if (index == _photos.length) {
                          return InkWell(
                            onTap: _uploadingPhoto ? null : _uploadPhoto,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 92,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE8DCC8),
                                ),
                              ),
                              child: Center(
                                child: _uploadingPhoto
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_a_photo_outlined,
                                        color: _primaryColor,
                                      ),
                              ),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _SmartImage(
                                source: _photos[index],
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                                fallback: () => Container(
                                  width: 92,
                                  height: 92,
                                  color: const Color(0xFFFFF0F0),
                                  child: const Icon(
                                    Icons.person,
                                    color: _borderColor,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              left: 4,
                              child: InkWell(
                                onTap: _uploadingPhoto
                                    ? null
                                    : () => _setPrimaryPhoto(index),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? const Color(0xFF8B0000)
                                        : Colors.black.withValues(alpha: 0.55),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    index == 0 ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 4,
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.62),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  index == 0
                                      ? 'Profile Photo'
                                      : 'Photo ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: _uploadingPhoto
                                    ? null
                                    : () => _deletePhoto(index),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeColor: _primaryColor,
                    title: const Text(
                      'Show photos to matched users',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    subtitle: Text(
                      _photoVisible ? 'Visible' : 'Hidden',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textSecondaryColor,
                      ),
                    ),
                    value: _photoVisible,
                    onChanged: (value) => setState(() => _photoVisible = value),
                  ),
                ],
              ),
            ),
            _CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(label: 'Full Name', controller: _name),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dob,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      hintText: '1995-06-15',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month_rounded),
                        onPressed: () async {
                          final now = DateTime.now();
                          final initial =
                              DateTime.tryParse(_dob.text.trim()) ??
                              DateTime(now.year - 25, now.month, now.day);
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initial,
                            firstDate: DateTime(1940),
                            lastDate: DateTime(
                              now.year - 18,
                              now.month,
                              now.day,
                            ),
                          );
                          if (picked == null) return;
                          setState(() {
                            _dob.text =
                                '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          });
                        },
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'Phone',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _genderOptions.contains(_gender)
                              ? _gender
                              : 'Male',
                          onChanged: (value) =>
                              setState(() => _gender = value ?? 'Male'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DisabledField(
                          label: 'Age (auto-calculated)',
                          value:
                              _age(_dob.text.trim())?.toString() ??
                              'Enter DOB above',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Professional Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'City/State',
                    value: _selectedCity,
                    options: _mergeDropdownOptions(
                      _stateOptions,
                      _selectedCity,
                    ),
                    hint: 'Select state',
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _city.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Religion',
                    value: _selectedReligion,
                    options: _mergeDropdownOptions(
                      _religionOptions,
                      _selectedReligion,
                    ),
                    hint: 'Select religion',
                    onChanged: (value) {
                      setState(() {
                        _selectedReligion = value;
                        _religion.text = value ?? '';
                        _selectedCaste = null;
                        _selectedSubCaste = null;
                        _availableSubCastes = const <String>[];
                        _caste.clear();
                        _subCaste.clear();
                      });
                      unawaited(_loadCasteOptions(value ?? '', pref: false));
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Caste',
                    value: _selectedCaste,
                    options: _mergeDropdownOptions(
                      _availableCastes,
                      _selectedCaste,
                    ),
                    hint: _selectedReligion == null
                        ? 'Select religion first'
                        : 'Select caste',
                    onChanged: (value) {
                      setState(() {
                        _selectedCaste = value;
                        _caste.text = value ?? '';
                        _selectedSubCaste = null;
                        _availableSubCastes = const <String>[];
                        _subCaste.clear();
                      });
                      unawaited(_loadSubCasteOptions(value ?? ''));
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Sub Caste',
                    value: _selectedSubCaste,
                    options: _mergeDropdownOptions(<String>[
                      ..._subCasteChoices(_selectedCaste, null),
                      ..._availableSubCastes,
                    ], _selectedSubCaste),
                    hint: _selectedCaste == null
                        ? 'Select caste first'
                        : 'Select sub caste',
                    onChanged: (value) {
                      setState(() {
                        _selectedSubCaste = value;
                        _subCaste.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Mother Tongue',
                    value: _selectedMotherTongue,
                    options: _mergeDropdownOptions(
                      _motherTongueOptions,
                      _selectedMotherTongue,
                    ),
                    hint: 'Select language',
                    onChanged: (value) {
                      setState(() {
                        _selectedMotherTongue = value;
                        _motherTongue.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Marital Status',
                    value: _selectedMaritalStatus,
                    options: _mergeDropdownOptions(
                      _maritalStatusOptions,
                      _selectedMaritalStatus,
                    ),
                    hint: 'Select status',
                    onChanged: (value) {
                      setState(() {
                        _selectedMaritalStatus = value;
                        _maritalStatus.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Education',
                    value: _selectedEducation,
                    options: _mergeDropdownOptions(
                      _educationOptions,
                      _selectedEducation,
                    ),
                    hint: 'Select education',
                    onChanged: (value) {
                      setState(() {
                        _selectedEducation = value;
                        _education.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Occupation',
                    value: _selectedProfession,
                    options: _mergeDropdownOptions(
                      _professionOptions,
                      _selectedProfession,
                    ),
                    hint: 'Select occupation',
                    onChanged: (value) {
                      setState(() {
                        _selectedProfession = value;
                        _occupation.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Height',
                    value: _selectedHeight,
                    options: _mergeDropdownOptions(
                      _heightOptions,
                      _selectedHeight,
                    ),
                    hint: 'Select height',
                    onChanged: (value) {
                      setState(() {
                        _selectedHeight = value;
                        _height.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Income',
                    value: _selectedIncome,
                    options: _mergeDropdownOptions(
                      _incomeOptions,
                      _selectedIncome,
                    ),
                    hint: 'Select income',
                    onChanged: (value) {
                      setState(() {
                        _selectedIncome = value;
                        _income.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Diet',
                    value: _selectedDiet,
                    options: _mergeDropdownOptions(_dietOptions, _selectedDiet),
                    hint: 'Select diet',
                    onChanged: (value) {
                      setState(() {
                        _selectedDiet = value;
                        _diet.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Manglik',
                    value: _selectedManglik,
                    options: _mergeDropdownOptions(
                      _manglikOptions,
                      _selectedManglik,
                    ),
                    hint: 'Select manglik status',
                    onChanged: (value) {
                      setState(() {
                        _selectedManglik = value;
                        _manglik.text = value ?? '';
                      });
                    },
                  ),
                ],
              ),
            ),
            _CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About You',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _about,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'About Yourself',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _familyDetails,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Family Details',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MultiSelectField(
                    label: 'Hobbies',
                    controller: _hobbies,
                    options: _mergeDropdownOptions(_hobbyOptions, null),
                    hint: 'Select hobbies',
                    onChanged: (values) {
                      setState(() {
                        _selectedHobby = values.isEmpty ? null : values.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Family Financial Status',
                    value: _selectedFamilyFinancialStatus,
                    options: _mergeDropdownOptions(
                      _familyFinancialStatusOptions,
                      _selectedFamilyFinancialStatus,
                    ),
                    hint: 'Select family financial status',
                    onChanged: (value) {
                      setState(() {
                        _selectedFamilyFinancialStatus = value;
                        _familyFinancialStatus.text = value ?? '';
                      });
                    },
                  ),
                ],
              ),
            ),
            _CreamCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Partner Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Preferred Min Age',
                          controller: _prefAgeMin,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _LabeledField(
                          label: 'Preferred Max Age',
                          controller: _prefAgeMax,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Preferred Religion',
                    value: _selectedPrefReligion,
                    options: _withAnyOptions(
                      _religionOptions,
                      _selectedPrefReligion,
                    ),
                    hint: 'Any religion',
                    onChanged: (value) {
                      setState(() {
                        _selectedPrefReligion = value;
                        _prefReligion.text = value ?? 'Any';
                        _selectedPrefCaste = 'Any';
                        _prefCaste.clear();
                      });
                      unawaited(_loadCasteOptions(value ?? '', pref: true));
                    },
                  ),
                  const SizedBox(height: 16),
                  _MultiSelectField(
                    label: 'Preferred Caste',
                    controller: _prefCaste,
                    allowAny: true,
                    options: _mergeDropdownOptions(
                      _availablePrefCastes,
                      _selectedPrefCaste,
                    ),
                    hint:
                        _selectedPrefReligion == null ||
                            _isAnyPreference(_selectedPrefReligion)
                        ? 'Select religion first'
                        : 'Select caste',
                    onChanged: (values) {
                      setState(() {
                        _selectedPrefCaste = values.isEmpty
                            ? 'Any'
                            : values.join(', ');
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _MultiSelectField(
                    label: 'Preferred Location',
                    controller: _prefLocation,
                    allowAny: true,
                    options: _mergeDropdownOptions(
                      _stateOptions,
                      _selectedPrefLocation,
                    ),
                    hint: 'Any location',
                    onChanged: (values) {
                      setState(() {
                        _selectedPrefLocation = values.isEmpty
                            ? 'Any'
                            : values.join(', ');
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _MultiSelectField(
                    label: 'Preferred Profession',
                    controller: _prefProfession,
                    allowAny: true,
                    options: _mergeDropdownOptions(
                      _professionOptions,
                      _selectedPrefProfession,
                    ),
                    hint: 'Any profession',
                    onChanged: (values) {
                      setState(() {
                        _selectedPrefProfession = values.isEmpty
                            ? 'Any'
                            : values.join(', ');
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DropdownField(
                          label: 'Preferred Min Height',
                          value: _selectedPrefHeightMin,
                          options: _withAnyOptions(
                            _heightOptions,
                            _selectedPrefHeightMin,
                          ),
                          hint: 'Any',
                          onChanged: (value) {
                            setState(() {
                              _selectedPrefHeightMin = value;
                              _prefHeightMin.text = value ?? 'Any';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DropdownField(
                          label: 'Preferred Max Height',
                          value: _selectedPrefHeightMax,
                          options: _withAnyOptions(
                            _heightOptions,
                            _selectedPrefHeightMax,
                          ),
                          hint: 'Any',
                          onChanged: (value) {
                            setState(() {
                              _selectedPrefHeightMax = value;
                              _prefHeightMax.text = value ?? 'Any';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Preferred Income',
                    value: _selectedPrefIncome,
                    options: _withAnyOptions(
                      _incomeOptions,
                      _selectedPrefIncome,
                    ),
                    hint: 'Any income',
                    onChanged: (value) {
                      setState(() {
                        _selectedPrefIncome = value;
                        _prefIncome.text = value ?? 'Any';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Preferred Diet',
                    value: _selectedPrefDiet,
                    options: _withAnyOptions(_dietOptions, _selectedPrefDiet),
                    hint: 'Any diet',
                    onChanged: (value) {
                      setState(() {
                        _selectedPrefDiet = value;
                        _prefDiet.text = value ?? 'Any';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownField(
                    label: 'Preferred Manglik',
                    value: _selectedPrefManglik,
                    options: _withAnyOptions(
                      _manglikOptions,
                      _selectedPrefManglik,
                    ),
                    hint: 'Any manglik status',
                    onChanged: (value) {
                      setState(() {
                        _selectedPrefManglik = value;
                        _prefManglik.text = value ?? 'Any';
                      });
                    },
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save, size: 20),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : (widget.requireProfileCompletion
                                ? 'Save & Continue'
                                : 'Save Profile'),
                    ),
                  ),
                ),
                if (!widget.requireProfileCompletion) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusPriceDisplay extends StatelessWidget {
  const _FocusPriceDisplay({
    required this.textColor,
    required this.mutedColor,
    this.center = false,
  });

  final Color textColor;
  final Color mutedColor;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'INR 4,990',
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: center ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: mutedColor,
            decoration: TextDecoration.lineThrough,
            decorationThickness: 2.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'INR 2,495',
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: center ? 42 : 30,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '50% off for 3 months Focus membership',
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: mutedColor, fontWeight: FontWeight.w800),
        ),
      ],
    );
    return center ? Center(child: column) : column;
  }
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({
    super.key,
    required this.api,
    required this.token,
    required this.currentPlan,
  });

  final ApiClient api;
  final String token;
  final String currentPlan;

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _loading = true;
  String? _processing;
  List<dynamic> _plans = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final plans = await widget.api.plans();
      if (!mounted) return;
      setState(() => _plans = plans);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buy(String planId) async {
    if (planId == 'free' || planId == widget.currentPlan) return;
    setState(() => _processing = planId);
    try {
      final order = await widget.api.createOrder(widget.token, planId);
      final payment = PaymentStatus.fromMap(order);
      final orderId = payment.orderId;
      final link = payment.paymentLink;
      if (!mounted) return;
      await _launchPaymentUrl(context, link);
      if (orderId.isNotEmpty) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final verified = PaymentStatus.fromMap(
          await widget.api.verifyOrder(widget.token, orderId),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment status: ${verified.status}. You can refresh this page to update your plan.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _processing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final plan = Map<String, dynamic>.from(_plans[index] as Map);
                final id = plan['id']?.toString() ?? '';
                final isFocus = id.toLowerCase() == 'focus';
                final current = id == widget.currentPlan;
                final available = plan['available'] == true;
                final features = List<dynamic>.from(
                  plan['features'] as List? ?? <dynamic>[],
                );
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['name']?.toString() ?? id,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(plan['tagline']?.toString() ?? ''),
                        const SizedBox(height: 8),
                        if (isFocus)
                          const _FocusPriceDisplay(
                            textColor: Color(0xFF8B0000),
                            mutedColor: _textSecondaryColor,
                          )
                        else
                          Text(
                            (plan['display_price']
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ==
                                    true)
                                ? plan['display_price'].toString()
                                : 'INR ${plan['discountedPrice'] ?? plan['price']}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                        if (!isFocus &&
                            (plan['promo_text']?.toString().trim() ?? '')
                                .isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            plan['promo_text'].toString(),
                            style: const TextStyle(
                              color: VSColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ...features.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• ${f.toString()}'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed:
                              (!available || current || _processing != null)
                              ? null
                              : () => _buy(id),
                          child: Text(
                            current
                                ? 'Current Plan'
                                : !available
                                ? 'Coming Soon'
                                : _processing == id
                                ? 'Processing...'
                                : 'Choose Plan',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ReactSubscriptionPage extends StatefulWidget {
  const ReactSubscriptionPage({
    super.key,
    required this.api,
    required this.token,
    required this.currentPlan,
  });

  final ApiClient api;
  final String token;
  final String currentPlan;

  @override
  State<ReactSubscriptionPage> createState() => _ReactSubscriptionPageState();
}

class _ReactSubscriptionPageState extends State<ReactSubscriptionPage> {
  bool _loading = true;
  String? _processing;
  List<dynamic> _plans = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final plans = await widget.api.plans();
      if (!mounted) return;
      setState(() => _plans = plans);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buy(String planId) async {
    if (planId == 'free' || planId == widget.currentPlan) return;
    setState(() => _processing = planId);
    try {
      final order = await widget.api.createOrder(widget.token, planId);
      final payment = PaymentStatus.fromMap(order);
      final orderId = payment.orderId;
      final link = payment.paymentLink;
      if (!mounted) return;
      await _launchPaymentUrl(context, link);
      if (orderId.isNotEmpty) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final verified = PaymentStatus.fromMap(
          await widget.api.verifyOrder(widget.token, orderId),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment status: ${verified.status}.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _processing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(title: const Text('Subscription')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Choose Your Plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start free and upgrade when ready',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                ),
                const SizedBox(height: 24),
                ..._plans.map((raw) {
                  final plan = Map<String, dynamic>.from(raw as Map);
                  final id = plan['id']?.toString() ?? '';
                  final current = id == widget.currentPlan;
                  final available = plan['available'] == true;
                  final features = List<dynamic>.from(
                    plan['features'] as List? ?? <dynamic>[],
                  );
                  final isFocus = id == 'focus';
                  final isCommit = id == 'commit';
                  final background = isFocus
                      ? const Color(0xFF8B0000)
                      : Colors.white;
                  final textColor = isFocus ? Colors.white : _textColor;
                  final subtitleColor = isFocus
                      ? Colors.white70
                      : _textSecondaryColor;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(
                        isFocus || isCommit ? 20 : 16,
                      ),
                      border: isFocus ? null : Border.all(color: _borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFocus)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'MOST POPULAR',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        if (isCommit)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'COMING SOON',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Center(
                          child: Icon(
                            isFocus
                                ? Icons.star
                                : isCommit
                                ? Icons.emoji_events
                                : Icons.check_circle,
                            size: 32,
                            color: isFocus
                                ? const Color(0xFFFFD700)
                                : isCommit
                                ? _textSecondaryColor
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            plan['name']?.toString() ?? id,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            plan['tagline']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                        if (!isFocus &&
                            (plan['promo_text']?.toString().trim() ?? '')
                                .isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              plan['promo_text'].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (isFocus)
                          _FocusPriceDisplay(
                            textColor: textColor,
                            mutedColor: subtitleColor,
                            center: true,
                          )
                        else
                          Center(
                            child: Text(
                              (plan['display_price']
                                          ?.toString()
                                          .trim()
                                          .isNotEmpty ==
                                      true)
                                  ? plan['display_price'].toString()
                                  : 'INR ${plan['discountedPrice'] ?? plan['price'] ?? ''}',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ...features.map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: isFocus
                                      ? const Color(0xFFFFD700)
                                      : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isFocus
                                          ? Colors.white70
                                          : _textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                (!available || current || _processing != null)
                                ? null
                                : () => _buy(id),
                            style: FilledButton.styleFrom(
                              backgroundColor: isFocus
                                  ? Colors.white24
                                  : _surfaceColor,
                              foregroundColor: isFocus
                                  ? Colors.white
                                  : _textSecondaryColor,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              current
                                  ? 'Current Plan'
                                  : !available
                                  ? 'Coming Soon'
                                  : _processing == id
                                  ? 'Processing...'
                                  : 'Subscribe Now',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.api,
    required this.token,
    required this.currentUser,
    required this.partner,
  });

  final ApiClient api;
  final String token;
  final Map<String, dynamic> currentUser;
  final Map<String, dynamic> partner;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _text = TextEditingController();
  final _scrollController = ScrollController();
  bool _loading = true;
  bool _sending = false;
  bool _socketConnected = false;
  bool _partnerTyping = false;
  String _loadError = '';
  bool _chatLockedFromServer = false;
  List<ChatMessage> _messages = <ChatMessage>[];
  Timer? _pollTimer;
  WebSocket? _socket;
  Timer? _reconnectTimer;
  Timer? _typingDebounce;
  Timer? _typingHideTimer;
  bool _shouldReconnect = true;
  int _reconnectAttempt = 0;
  bool _typingEnabled = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTypingPreference());
    _load();
    _connectSocket();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _load(silent: true),
    );
    _text.addListener(_onTypingChanged);
  }

  Future<void> _loadTypingPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () =>
          _typingEnabled = prefs.getBool('settings_typing_indicators') ?? true,
    );
  }

  @override
  void dispose() {
    _shouldReconnect = false;
    _pollTimer?.cancel();
    _reconnectTimer?.cancel();
    _typingDebounce?.cancel();
    _typingHideTimer?.cancel();
    _socket?.close(WebSocketStatus.normalClosure);
    _text.removeListener(_onTypingChanged);
    _scrollController.dispose();
    _text.dispose();
    super.dispose();
  }

  String get _partnerId => widget.partner['id']?.toString() ?? '';
  String get _myId => widget.currentUser['id']?.toString() ?? '';
  bool get _chatUnlocked =>
      (widget.currentUser['plan']?.toString().toLowerCase() ?? 'free') !=
      'free';

  void _openUpgrade() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReactSubscriptionPage(
          api: widget.api,
          token: widget.token,
          currentPlan:
              widget.currentUser['plan']?.toString().toLowerCase() ?? 'free',
        ),
      ),
    );
  }

  void _onTypingChanged() {
    if (!_typingEnabled) return;
    if (_text.text.trim().isEmpty) return;
    _typingDebounce?.cancel();
    _typingDebounce = Timer(
      const Duration(milliseconds: 650),
      _emitTypingEvent,
    );
  }

  void _emitTypingEvent() {
    if (!_socketConnected || _socket == null || _partnerId.isEmpty) return;
    try {
      _socket!.add(jsonEncode({'action': 'typing', 'receiverId': _partnerId}));
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final items = await widget.api.messages(widget.token, _partnerId);
      final serverMessages =
          items.map((item) => ChatMessage.fromMap(_asMap(item))).toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (!mounted) return;
      setState(() {
        _loadError = '';
        _chatLockedFromServer = false;
      });
      _mergeServerMessages(serverMessages);
      unawaited(_markThreadRead());
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      final locked =
          message.toLowerCase().contains('subscription') ||
          message.toLowerCase().contains('upgrade') ||
          message.toLowerCase().contains('active mutual connection') ||
          message.toLowerCase().contains('only chat');
      setState(() {
        _loadError = message;
        _chatLockedFromServer = locked;
      });
    } finally {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  void _mergeServerMessages(List<ChatMessage> serverMessages) {
    final pending = _messages
        .where((message) => message.status != ChatMessageStatus.sent)
        .toList();
    final merged = <ChatMessage>[...serverMessages];
    for (final local in pending) {
      final exists = serverMessages.any(
        (remote) => _messageEquivalent(remote, local),
      );
      if (!exists) {
        merged.add(local);
      }
    }
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    setState(() => _messages = merged);
    _scrollToBottom();
  }

  bool _messageEquivalent(ChatMessage remote, ChatMessage local) {
    if (remote.id == local.id) return true;
    if (remote.senderId != local.senderId) return false;
    if (remote.content.trim() != local.content.trim()) return false;
    final remoteTime = DateTime.tryParse(remote.createdAt);
    final localTime = DateTime.tryParse(local.createdAt);
    if (remoteTime == null || localTime == null) return false;
    final diff = remoteTime
        .toUtc()
        .difference(localTime.toUtc())
        .inSeconds
        .abs();
    return diff <= 30;
  }

  void _markMessageStatus(String id, ChatMessageStatus status) {
    final index = _messages.indexWhere((message) => message.id == id);
    if (index == -1) return;
    final updated = [..._messages];
    updated[index] = updated[index].copyWith(status: status);
    setState(() => _messages = updated);
  }

  void _appendServerMessage(ChatMessage message) {
    final updated = [..._messages];
    final byId = updated.indexWhere((item) => item.id == message.id);
    if (byId >= 0) {
      updated[byId] = message.copyWith(status: ChatMessageStatus.sent);
    } else {
      final pendingIndex = updated.indexWhere(
        (item) =>
            item.status != ChatMessageStatus.sent &&
            _messageEquivalent(message, item),
      );
      if (pendingIndex >= 0) {
        updated[pendingIndex] = message.copyWith(
          status: ChatMessageStatus.sent,
        );
      } else {
        updated.add(message.copyWith(status: ChatMessageStatus.sent));
      }
    }
    updated.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    setState(() => _messages = updated);
    _scrollToBottom();
  }

  void _sendMarkRead() {
    if (!_socketConnected || _socket == null || _partnerId.isEmpty) return;
    try {
      _socket!.add(
        jsonEncode({'action': 'mark_read', 'partnerId': _partnerId}),
      );
    } catch (_) {}
  }

  Future<void> _markThreadRead() async {
    _sendMarkRead();
    if (_partnerId.isEmpty) return;
    try {
      await widget.api.markChatRead(widget.token, _partnerId);
    } catch (_) {
      // The socket path still handles read state when REST is temporarily down.
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    _reconnectTimer?.cancel();
    final steps = <int>[2, 4, 6, 10, 15, 20];
    final waitSeconds =
        steps[_reconnectAttempt < steps.length
            ? _reconnectAttempt
            : steps.length - 1];
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: waitSeconds), () {
      if (!_shouldReconnect) return;
      unawaited(_connectSocket());
    });
  }

  void _handleSocketEvent(dynamic event) {
    dynamic decoded;
    try {
      decoded = jsonDecode(event.toString());
    } catch (_) {
      return;
    }
    if (decoded is! Map) return;
    final data = _asMap(decoded);
    final type = data['type']?.toString() ?? '';
    if (type == 'new_message' && data['message'] is Map) {
      final message = ChatMessage.fromMap(_asMap(data['message']));
      if (message.senderId == _partnerId || message.senderId == _myId) {
        _appendServerMessage(message);
      }
      if (message.senderId == _partnerId) {
        unawaited(_markThreadRead());
      }
      return;
    }
    if (type == 'typing') {
      if (!_typingEnabled) return;
      final senderId = data['senderId']?.toString() ?? '';
      if (senderId == _partnerId) {
        setState(() => _partnerTyping = true);
        _typingHideTimer?.cancel();
        _typingHideTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _partnerTyping = false);
        });
      }
    }
  }

  Future<void> _connectSocket() async {
    final backend = _baseUrl.replaceAll(RegExp(r'^http'), 'ws');
    final url = '$backend/ws/chat/${widget.token}';
    try {
      final socket = await WebSocket.connect(url);
      _socket = socket;
      if (!mounted) {
        await socket.close(WebSocketStatus.normalClosure);
        return;
      }
      _reconnectAttempt = 0;
      _reconnectTimer?.cancel();
      setState(() => _socketConnected = true);
      unawaited(_markThreadRead());
      socket.listen(
        _handleSocketEvent,
        onDone: () {
          if (!mounted) return;
          setState(() => _socketConnected = false);
          _scheduleReconnect();
        },
        onError: (_) {
          if (!mounted) return;
          setState(() => _socketConnected = false);
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (_) {
      if (mounted) setState(() => _socketConnected = false);
      _scheduleReconnect();
    }
  }

  Future<void> _sendViaRest(ChatMessage pending) async {
    await widget.api.sendMessage(widget.token, _partnerId, pending.content);
    await _load(silent: true);
  }

  Future<void> _retryFailed(ChatMessage message) async {
    _markMessageStatus(message.id, ChatMessageStatus.sending);
    try {
      await _sendViaRest(message);
    } catch (_) {
      _markMessageStatus(message.id, ChatMessageStatus.failed);
    }
  }

  Future<void> _send() async {
    if (!_chatUnlocked) {
      _openUpgrade();
      return;
    }
    if (_text.text.trim().isEmpty) return;
    final content = _text.text.trim();
    final localMessage = ChatMessage(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      senderId: _myId,
      receiverId: _partnerId,
      content: content,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      read: true,
      status: ChatMessageStatus.sending,
    );
    setState(() => _sending = true);
    setState(() => _messages = [..._messages, localMessage]);
    _scrollToBottom();
    _text.clear();
    try {
      if (_socketConnected && _socket != null && _partnerId.isNotEmpty) {
        _socket!.add(
          jsonEncode({
            'action': 'send_message',
            'receiverId': _partnerId,
            'content': content,
          }),
        );
        unawaited(
          Future<void>.delayed(const Duration(seconds: 10), () {
            if (!mounted) return;
            final stillPending = _messages.any(
              (message) =>
                  message.id == localMessage.id &&
                  message.status == ChatMessageStatus.sending,
            );
            if (stillPending) {
              _markMessageStatus(localMessage.id, ChatMessageStatus.failed);
            }
          }),
        );
        unawaited(
          Future<void>.delayed(
            const Duration(seconds: 2),
            () => _load(silent: true),
          ),
        );
      } else {
        await _sendViaRest(localMessage);
      }
    } catch (e) {
      _markMessageStatus(localMessage.id, ChatMessageStatus.failed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _insertEmoji(String emoji) {
    final selection = _text.selection;
    final current = _text.text;
    final start = selection.start < 0 ? current.length : selection.start;
    final end = selection.end < 0 ? current.length : selection.end;
    final next = current.replaceRange(start, end, emoji);
    _text.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  bool _isSameLocalDay(String? a, String? b) {
    final first = a == null ? null : DateTime.tryParse(a)?.toLocal();
    final second = b == null ? null : DateTime.tryParse(b)?.toLocal();
    if (first == null || second == null) return false;
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _partnerPresenceLabel() {
    if (_partnerTyping) return 'Typing...';
    final online =
        widget.partner['online'] == true || widget.partner['is_online'] == true;
    if (online) return 'Online';
    final lastSeen =
        widget.partner['lastSeen']?.toString() ??
        widget.partner['last_seen']?.toString() ??
        '';
    if (lastSeen.trim().isNotEmpty) {
      return 'Last seen ${_formatChatDate(lastSeen)} at ${_formatMessageTime(lastSeen)}';
    }
    return _socketConnected ? 'Connected securely' : 'Direct message';
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = _partnerPresenceLabel();
    final partnerName = widget.partner['name']?.toString() ?? 'Chat';
    return Scaffold(
      backgroundColor: const Color(0xFFF7EFE8),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _CircularProfileAvatar(profile: widget.partner, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    partnerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFFBF7), Color(0xFFF7EFE8)],
                      ),
                    ),
                    child: _messages.isEmpty && _loadError.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _loadError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _textSecondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(14, 40, 14, 18),
                            itemCount:
                                _messages.length + (_partnerTyping ? 1 : 0),
                            itemBuilder: (_, index) {
                              if (_partnerTyping && index == _messages.length) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFE8DCC8),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x0D000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'Typing',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _textSecondaryColor,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              final message = _messages[index];
                              final mine = message.senderId == _myId;
                              final bubbleTextColor = mine
                                  ? Colors.white
                                  : Colors.black87;
                              final failed =
                                  message.status == ChatMessageStatus.failed;
                              final sending =
                                  message.status == ChatMessageStatus.sending;
                              final showDate =
                                  index == 0 ||
                                  !_isSameLocalDay(
                                    _messages[index - 1].createdAt,
                                    message.createdAt,
                                  );
                              return Column(
                                children: [
                                  if (showDate)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF0F0),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE8DCC8),
                                        ),
                                      ),
                                      child: Text(
                                        _formatChatDate(message.createdAt),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _primaryColor,
                                        ),
                                      ),
                                    ),
                                  Align(
                                    alignment: mine
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: failed
                                          ? () => _retryFailed(message)
                                          : null,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.sizeOf(context).width *
                                              0.76,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            14,
                                            12,
                                            14,
                                            10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: mine
                                                ? const Color(0xFF8B0000)
                                                : Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(
                                                20,
                                              ),
                                              topRight: const Radius.circular(
                                                20,
                                              ),
                                              bottomLeft: Radius.circular(
                                                mine ? 20 : 6,
                                              ),
                                              bottomRight: Radius.circular(
                                                mine ? 6 : 20,
                                              ),
                                            ),
                                            border: mine
                                                ? null
                                                : Border.all(
                                                    color: const Color(
                                                      0xFFE8DCC8,
                                                    ),
                                                  ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x12000000),
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.content,
                                                style: TextStyle(
                                                  color: bubbleTextColor,
                                                  height: 1.35,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _formatMessageTime(
                                                      message.createdAt,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: mine
                                                          ? Colors.white70
                                                          : _textSecondaryColor,
                                                    ),
                                                  ),
                                                  if (sending) ...[
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Sending...',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: mine
                                                            ? Colors.white70
                                                            : _textSecondaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                  if (failed) ...[
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Failed. Tap to retry',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: mine
                                                            ? Colors.white70
                                                            : Colors
                                                                  .red
                                                                  .shade600,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              color: const Color(0xFFFFFBF7),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EmojiStrip(onEmoji: _insertEmoji),
                  if (false)
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: const [
                          '😊',
                          '❤️',
                          '🙏',
                          '👍',
                          '🌹',
                          '✨',
                        ].length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          const emojis = ['😊', '❤️', '🙏', '👍', '🌹', '✨'];
                          return InkWell(
                            onTap: () => _insertEmoji(emojis[index]),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFE8DCC8),
                                ),
                              ),
                              child: Text(
                                emojis[index],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (!_chatUnlocked || _chatLockedFromServer)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8DCC8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Subscribe or connect to chat',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _loadError.isNotEmpty
                                ? _loadError
                                : 'Upgrade to Focus and keep an active connection to message.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: _openUpgrade,
                            child: const Text('Upgrade now'),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE8DCC8),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _text,
                              decoration: const InputDecoration(
                                hintText: 'Write a message',
                                filled: false,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              minLines: 1,
                              maxLines: 4,
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: FilledButton(
                            onPressed: _sending ? null : _send,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: _sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.api, required this.token});

  final ApiClient api;
  final String token;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

String? _firstPreferenceValue(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    final values = value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return values.isEmpty ? null : values.first;
  }
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  if (text.contains(',')) {
    final parts = text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.first;
  }
  return text;
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _profileVisible = true;
  bool _showLastSeen = true;
  bool _typingIndicators = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> remote = <String, dynamic>{};
    try {
      remote = await widget.api.settings(widget.token);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _pushNotifications =
          (remote['pushNotifications'] as bool?) ??
          prefs.getBool('settings_push_notifications') ??
          true;
      _emailNotifications =
          (remote['emailNotifications'] as bool?) ??
          prefs.getBool('settings_email_notifications') ??
          true;
      _profileVisible =
          (remote['profileVisible'] as bool?) ??
          prefs.getBool('settings_profile_visible') ??
          true;
      _showLastSeen =
          (remote['showLastSeen'] as bool?) ??
          prefs.getBool('settings_show_last_seen') ??
          true;
      _typingIndicators =
          (remote['typingIndicators'] as bool?) ??
          prefs.getBool('settings_typing_indicators') ??
          true;
      _loading = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveRemote() async {
    try {
      await widget.api.updateSettings(widget.token, {
        'pushNotifications': _pushNotifications,
        'emailNotifications': _emailNotifications,
        'profileVisible': _profileVisible,
        'showLastSeen': _showLastSeen,
        'typingIndicators': _typingIndicators,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SettingsHeader('Notifications'),
                _SwitchSettingsTile(
                  icon: Icons.notifications_active,
                  label: 'Push Notifications',
                  subtitle: 'Connection requests, accepts, and reminders',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                    unawaited(_save('settings_push_notifications', value));
                    unawaited(_saveRemote());
                  },
                ),
                _SwitchSettingsTile(
                  icon: Icons.mail_outline,
                  label: 'Email Notifications',
                  subtitle: 'Weekly matches and platform updates',
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                    unawaited(_save('settings_email_notifications', value));
                    unawaited(_saveRemote());
                  },
                ),
                const SizedBox(height: 16),
                const _SettingsHeader('Privacy'),
                _SwitchSettingsTile(
                  icon: Icons.visibility_outlined,
                  label: 'Profile Visibility',
                  subtitle: 'Allow your profile in public match discovery',
                  value: _profileVisible,
                  onChanged: (value) {
                    setState(() => _profileVisible = value);
                    unawaited(_save('settings_profile_visible', value));
                    unawaited(_saveRemote());
                  },
                ),
                _SwitchSettingsTile(
                  icon: Icons.schedule,
                  label: 'Show Last Seen',
                  subtitle: 'Visible to your active connections only',
                  value: _showLastSeen,
                  onChanged: (value) {
                    setState(() => _showLastSeen = value);
                    unawaited(_save('settings_show_last_seen', value));
                    unawaited(_saveRemote());
                  },
                ),
                _SwitchSettingsTile(
                  icon: Icons.keyboard_rounded,
                  label: 'Typing Indicators',
                  subtitle: 'Show and send real-time typing status in chat',
                  value: _typingIndicators,
                  onChanged: (value) {
                    setState(() => _typingIndicators = value);
                    unawaited(_save('settings_typing_indicators', value));
                    unawaited(_saveRemote());
                  },
                ),
                const SizedBox(height: 16),
                const _SettingsHeader('Info'),
                _SettingsTile(
                  icon: Icons.shield,
                  label: 'Security & Safety Tips',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SecuritySafetyPage(),
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.description,
                  label: 'Terms & Privacy',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TermsPrivacyPage(),
                    ),
                  ),
                ),
                const _SettingsTile(
                  icon: Icons.info_outline,
                  label: 'App Version 1.0.2',
                ),
              ],
            ),
    );
  }
}

class _EmojiStrip extends StatelessWidget {
  const _EmojiStrip({required this.onEmoji});

  final ValueChanged<String> onEmoji;

  @override
  Widget build(BuildContext context) {
    const emojis = ['😊', '❤️', '🙏', '👍', '🌹', '✨'];
    const fixedEmojis = ['😊', '❤️', '🙏', '👍', '🌹', '✨'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fixedEmojis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) => InkWell(
          onTap: () => onEmoji(fixedEmojis[index]),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE8DCC8)),
            ),
            child: Text(
              fixedEmojis[index],
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.api, required this.token});

  final ApiClient api;
  final String token;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  List<dynamic> _items = <dynamic>[];
  final Set<String> _approvedExtensionIds = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        widget.api.notifications(widget.token),
        widget.api.unreadCount(widget.token),
      ]);
      final notifications = List<dynamic>.from(
        results[0] as List? ?? <dynamic>[],
      );
      final unreadChats = (results[1] as num?)?.toInt() ?? 0;
      final merged = <dynamic>[
        if (unreadChats > 0)
          {
            'id': 'chat_unread',
            'type': 'chat_unread',
            'message':
                'You have $unreadChats unread chat message${unreadChats > 1 ? 's' : ''}',
            'read': false,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        ...notifications,
      ];
      if (!mounted) return;
      setState(() => _items = merged);
      if (_items.isNotEmpty) {
        unawaited(_markVisibleNotificationsRead());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = <dynamic>[]);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markVisibleNotificationsRead() async {
    try {
      await widget.api.markNotificationsRead(widget.token);
      if (!mounted) return;
      setState(() {
        _items = _items.map((item) {
          final map = Map<String, dynamic>.from(_asMap(item));
          if (map['id'] != 'chat_unread') {
            map['read'] = true;
          }
          return map;
        }).toList();
      });
    } catch (_) {
      // Keep the fetched list visible even if the read-sync request fails.
    }
  }

  String _payloadFor(Map<String, dynamic> item) {
    final type = (item['type'] ?? '').toString().toLowerCase();
    final message = (item['message'] ?? '').toString().toLowerCase();
    final senderId =
        (item['sender_id'] ??
                item['senderId'] ??
                item['from_user_id'] ??
                item['fromUserId'] ??
                '')
            .toString()
            .trim();
    if (type.contains('chat') ||
        type.contains('message') ||
        message.contains('message')) {
      return 'chat:$senderId';
    }
    if (type.contains('match') ||
        type.contains('recommend') ||
        message.contains('match') ||
        message.contains('recommend')) {
      return 'matches';
    }
    if (type.contains('upgrade') ||
        type.contains('offer') ||
        type.contains('renewal') ||
        type.contains('plan') ||
        message.contains('upgrade') ||
        message.contains('renew') ||
        message.contains('50% off')) {
      return 'subscription';
    }
    if (type.contains('visitor') || message.contains('viewed your profile')) {
      return senderId.isEmpty ? 'notifications' : 'profile:$senderId';
    }
    if (type.contains('connection') ||
        type.contains('request') ||
        type.contains('extension') ||
        message.contains('request') ||
        message.contains('connected')) {
      return 'connections';
    }
    return 'notifications';
  }

  ({IconData icon, Color color, String title}) _visualFor(
    String type,
    String message,
  ) {
    final lowered = '$type $message'.toLowerCase();
    if (lowered.contains('match') || lowered.contains('recommend')) {
      return (
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE3526E),
        title: 'New match',
      );
    }
    if (lowered.contains('offer') ||
        lowered.contains('upgrade') ||
        lowered.contains('renewal') ||
        lowered.contains('plan')) {
      return (
        icon: Icons.local_offer_rounded,
        color: const Color(0xFFE6A93A),
        title: 'Premium offer',
      );
    }
    if (lowered.contains('extension') || lowered.contains('connection')) {
      return (
        icon: Icons.handshake_rounded,
        color: const Color(0xFF217A47),
        title: 'Connection update',
      );
    }
    if (lowered.contains('visitor')) {
      return (
        icon: Icons.visibility_rounded,
        color: const Color(0xFF7C4DFF),
        title: 'Profile visitor',
      );
    }
    if (lowered.contains('chat') || lowered.contains('message')) {
      return (
        icon: Icons.chat_bubble_rounded,
        color: const Color(0xFF4169A8),
        title: 'Chat message',
      );
    }
    return (
      icon: Icons.notifications_active_rounded,
      color: _primaryColor,
      title: 'VivaahSetu update',
    );
  }

  Future<void> _approveExtension(String connectionId) async {
    try {
      await widget.api.approveConnectionExtension(widget.token, connectionId);
      if (!mounted) return;
      setState(() => _approvedExtensionIds.add(connectionId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection extended by 15 days')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const VSSkeletonLoader(count: 5)
          : _items.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: _textSecondaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final item = _asMap(_items[index]);
                  final message = item['message']?.toString() ?? '';
                  final type = item['type']?.toString() ?? 'notification';
                  final visual = _visualFor(type, message);
                  final createdAt =
                      item['createdAt']?.toString() ??
                      item['created_at']?.toString();
                  final payload = _payloadFor(item);
                  final typeLower = type.toLowerCase();
                  final connectionId =
                      (item['connection_id'] ?? item['connectionId'] ?? '')
                          .toString()
                          .trim();
                  final notificationStatus =
                      (item['status'] ?? item['extension_status'] ?? '')
                          .toString()
                          .toLowerCase();
                  final extensionAccepted =
                      notificationStatus == 'accepted' ||
                      typeLower.contains('extension_accepted') ||
                      _approvedExtensionIds.contains(connectionId);
                  final canApproveExtension =
                      typeLower.contains('extension_request') &&
                      connectionId.isNotEmpty &&
                      !extensionAccepted;
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(payload),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFFFFBF4)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _borderColor),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F7C1838),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: visual.color.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(visual.icon, color: visual.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visual.title.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: visual.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: _textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (createdAt != null &&
                                      createdAt.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatMessageTime(createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                  if (canApproveExtension) ...[
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: FilledButton.icon(
                                        onPressed: () =>
                                            _approveExtension(connectionId),
                                        icon: const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Accept extension'),
                                      ),
                                    ),
                                  ],
                                  if (extensionAccepted) ...[
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Extension accepted',
                                      style: TextStyle(
                                        color: Color(0xFF217A47),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class SuccessStoriesPage extends StatefulWidget {
  const SuccessStoriesPage({super.key, required this.api});

  final ApiClient api;

  @override
  State<SuccessStoriesPage> createState() => _SuccessStoriesPageState();
}

class _SuccessStoriesPageState extends State<SuccessStoriesPage> {
  bool _loading = true;
  List<dynamic> _stories = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stories = await widget.api.successStories();
      if (!mounted) return;
      setState(() => _stories = stories);
    } catch (_) {
      if (!mounted) return;
      setState(() => _stories = <dynamic>[]);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      appBar: AppBar(title: const Text('Success Stories')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _stories.length,
                itemBuilder: (_, index) {
                  final story = _asMap(_stories[index]);
                  final image = _resolveMediaUrl(story['image']?.toString());
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _borderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (image != null)
                          _SmartImage(
                            source: image,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            fallback: () => Container(
                              height: 180,
                              color: _surfaceColor,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.favorite,
                                color: _primaryColor,
                                size: 40,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story['names']?.toString() ?? 'Couple',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _textColor,
                                ),
                              ),
                              if ((story['location']?.toString() ?? '')
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    story['location'].toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: _textSecondaryColor,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                story['story']?.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _textColor,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Support Channels',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Email: support@vivaahsetu.in',
                  style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                ),
                SizedBox(height: 6),
                Text(
                  'Phone: +91-00000-00000',
                  style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                ),
              ],
            ),
          ),
          _CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Safety',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Report suspicious profiles immediately.',
                  style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                ),
                SizedBox(height: 6),
                Text(
                  'Never share OTP, bank details, or passwords.',
                  style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                ),
              ],
            ),
          ),
          _CreamCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'FAQ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'How do connections work? You can keep up to 5 active connections for 15 days.',
                  style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                ),
                SizedBox(height: 6),
                Text(
                  'Why is chat locked? Chat requires Focus or Commit plan with active mutual connection.',
                  style: TextStyle(fontSize: 14, color: _textSecondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String _aboutVivaahSetuText = '''
VivaahSetu is a modern matchmaking platform designed to simplify and personalize the journey of finding the right life partner.

Built with a focus on trust, compatibility, and meaningful connections, VivaahSetu bridges traditional matchmaking values with today's digital expectations. The platform offers intelligent matching based on preferences, lifestyle, and long-term compatibility while emphasizing verified profiles, privacy controls, and a safe user experience.

VivaahSetu is committed to transparency, accountability, and user-centric data protection practices.
''';

const String _termsPrivacyText = '''
Privacy Policy

VivaahSetu acts as the data controller for personal data collected through the platform. We collect profile information, preferences, photographs, technical data, and voluntarily shared sensitive details such as religion or community to provide matchmaking and communication services.

Personal data is processed based on consent, contractual necessity, legitimate interest, and legal obligations. Data may be shared with other users according to privacy settings, service providers, and authorities when legally required. VivaahSetu does not sell personal data.

Users may access, correct, delete, withdraw consent, restrict processing, object to processing, and request data portability where applicable. Consent can be withdrawn at any time.

Terms & Conditions

Users must be legally eligible for marriage, provide truthful information, and use VivaahSetu only for genuine matrimonial purposes. Fake profiles, impersonation, harassment, financial scams, offensive content, scraping, or misuse are prohibited.

VivaahSetu acts as an intermediary and is not responsible for user-generated content, accuracy of user information, or outcomes of user interactions. Accounts may be suspended for terms violations, fraudulent activity, or regulatory requirements.

These terms are governed by the laws of India.
''';

const String _securitySafetyText = '''
VivaahSetu follows privacy-first design, minimal data collection, secure authentication, access controls, and monitoring to protect users.

Users should verify profile details through calls and family introductions, meet in public places, avoid sharing OTPs, bank details, passwords, or sensitive documents, and report suspicious activity immediately.

In case of a data breach, VivaahSetu will notify users and authorities where required by applicable law.
''';

class _LegalTextBlock extends StatelessWidget {
  const _LegalTextBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _CreamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body.trim(),
            style: const TextStyle(
              fontSize: 14,
              color: _textSecondaryColor,
              height: 1.48,
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      appBar: AppBar(title: const Text('About VivaahSetu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _LegalTextBlock(
            title: 'About VivaahSetu',
            body: _aboutVivaahSetuText,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Version: 1.0.2',
              style: TextStyle(fontSize: 13, color: _textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class SecuritySafetyPage extends StatelessWidget {
  const SecuritySafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      appBar: AppBar(title: const Text('Security & Safety Tips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _LegalTextBlock(
            title: 'Security & Safety',
            body: _securitySafetyText,
          ),
        ],
      ),
    );
  }
}

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _postLoginBackground,
      appBar: AppBar(title: const Text('Terms & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _LegalTextBlock(title: 'Terms & Privacy', body: _termsPrivacyText),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? VSGradients.goldAccent : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x22E6A93A),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? VSColors.wineDark : _textSecondaryColor,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _secondaryColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3A1F1D),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? VSColors.wineDark : _textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMetricCard extends StatelessWidget {
  const _HomeMetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 44) / 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, VSColors.ivory],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: VSColors.border.withValues(alpha: 0.8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F5F0924),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textColor,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.08, end: 0);
  }
}

class _HomeProfilePreviewCard extends StatelessWidget {
  const _HomeProfilePreviewCard({
    required this.profile,
    required this.onTap,
    required this.onConnect,
    required this.onAccept,
    required this.onCancel,
  });

  final Map<String, dynamic> profile;
  final VoidCallback? onTap;
  final VoidCallback onConnect;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final alreadyConnected = _alreadyConnectedFlag(profile);
    final requestSent = _requestSentFlag(profile);
    final requestReceived = _requestReceivedFlag(profile);
    final age = profile['age']?.toString();
    final city = profile['city']?.toString().trim() ?? '';
    final occupation = (profile['occupation'] ?? profile['profession'] ?? '')
        .toString();
    final religion = profile['religion']?.toString().trim() ?? '';
    final detailLine = [
      if (occupation.trim().isNotEmpty) occupation.trim(),
      if (religion.isNotEmpty) religion,
    ].join(' • ');
    final statusLabel = alreadyConnected
        ? 'Connected'
        : requestSent
        ? 'Request Sent'
        : requestReceived
        ? 'Accept Request'
        : 'New match';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, VSColors.ivory],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VSColors.border.withValues(alpha: 0.78)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x185F0924),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 116,
                  height: 148,
                  child: _PhotoCarousel(
                    profile: profile,
                    height: 148,
                    radius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VSStatusBadge(
                      label: statusLabel,
                      icon: alreadyConnected
                          ? Icons.verified_rounded
                          : requestSent
                          ? Icons.schedule_send_rounded
                          : requestReceived
                          ? Icons.mark_email_unread_rounded
                          : Icons.auto_awesome_rounded,
                      foreground: alreadyConnected
                          ? const Color(0xFF217A47)
                          : VSColors.primary,
                      background: alreadyConnected
                          ? const Color(0xFFEAF8EF)
                          : VSColors.roseMist,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profile['name']?.toString() ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      [
                        if (age != null && age.isNotEmpty) '$age yrs',
                        if (city.isNotEmpty) city,
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: VSColors.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      detailLine.isEmpty
                          ? 'Profile details available'
                          : detailLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: _textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(66, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('View'),
                        ),
                        const SizedBox(width: 8),
                        if (requestSent)
                          OutlinedButton.icon(
                            onPressed: onCancel,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(84, 32),
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            label: const Text('Cancel'),
                          )
                        else
                          FilledButton(
                            onPressed: alreadyConnected
                                ? null
                                : requestReceived
                                ? onAccept
                                : onConnect,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(80, 32),
                              backgroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              alreadyConnected
                                  ? 'Connected'
                                  : requestReceived
                                  ? 'Accept'
                                  : 'Connect Now',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 420.ms).slideX(begin: 0.08, end: 0);
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final validValue = options.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      value: validValue,
      onChanged: options.isEmpty ? null : onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        fillColor: const Color(0xFFFFFDF5),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
      ),
      items: options
          .map(
            (option) =>
                DropdownMenuItem<String>(value: option, child: Text(option)),
          )
          .toList(),
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
    this.allowAny = false,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;
  final bool allowAny;
  final String? hint;

  List<String> _values() {
    final raw = controller.text.trim();
    if (raw.isEmpty || _isAnyPreference(raw)) return allowAny ? ['Any'] : [];
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _values();
    final display = selected.isEmpty
        ? (hint ?? 'Select')
        : selected.contains('Any')
        ? 'Any'
        : selected.join(', ');
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final result = await showModalBottomSheet<List<String>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _MultiSelectSheet(
            title: label,
            options: allowAny ? _withAnyOptions(options, null) : options,
            selected: selected,
            allowAny: allowAny,
          ),
        );
        if (result == null) return;
        final normalized = allowAny && result.contains('Any')
            ? <String>['Any']
            : result.where((item) => !_isAnyPreference(item)).toList();
        controller.text = normalized.join(', ');
        onChanged(normalized);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          fillColor: const Color(0xFFFFFDF5),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
          ),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(
          display,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected.isEmpty ? _textSecondaryColor : _textColor,
          ),
        ),
      ),
    );
  }
}

class _MultiSelectSheet extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.allowAny,
  });

  final String title;
  final List<String> options;
  final List<String> selected;
  final bool allowAny;

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late final Set<String> _selected = widget.selected.toSet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.58,
              ),
              child: ListView(
                shrinkWrap: true,
                children: widget.options.map((option) {
                  final checked = _selected.contains(option);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(option),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: _primaryColor,
                    onChanged: (value) {
                      setState(() {
                        if (option == 'Any' && value == true) {
                          _selected
                            ..clear()
                            ..add('Any');
                          return;
                        }
                        _selected.remove('Any');
                        if (value == true) {
                          _selected.add(option);
                        } else {
                          _selected.remove(option);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_selected.toList()),
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                minimumSize: const Size.fromHeight(46),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: const Color(0xFFFFFDF5),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniDetail extends StatelessWidget {
  const _MiniDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _textSecondaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: _textSecondaryColor),
          ),
        ],
      ),
    );
  }
}

class VSSkeletonLoader extends StatelessWidget {
  const VSSkeletonLoader({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, index) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    Widget block(double width, double height, {double radius = 12}) {
      return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(radius),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fade(
            begin: 0.38,
            end: 1,
            duration: const Duration(milliseconds: 850),
          );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VSColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          block(82, 96, radius: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                block(double.infinity, 16),
                const SizedBox(height: 10),
                block(180, 12),
                const SizedBox(height: 10),
                block(120, 12),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: block(double.infinity, 36, radius: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: block(double.infinity, 36, radius: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionsPane extends StatelessWidget {
  const _ConnectionsPane({
    required this.loading,
    required this.items,
    required this.emptyLabel,
    required this.builder,
  });

  final bool loading;
  final List<dynamic> items;
  final String emptyLabel;
  final Widget Function(dynamic item) builder;

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) {
      return const VSSkeletonLoader(count: 4);
    }
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.people_outline,
            size: 64,
            color: _textSecondaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            emptyLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: builder(items[index]),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.profile,
    required this.allowAllPhotos,
    required this.name,
    required this.detail1,
    required this.detail2,
    required this.trailing,
    this.badge,
    this.onTap,
  });

  final Map<String, dynamic> profile;
  final bool allowAllPhotos;
  final String name;
  final String detail1;
  final String detail2;
  final Widget trailing;
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final galleryProfile = Map<String, dynamic>.from(profile);
    final photos = _photoUrls(galleryProfile);
    galleryProfile['photos'] = photos;
    galleryProfile['visiblePhotoCount'] = allowAllPhotos
        ? photos.length
        : (photos.isEmpty ? 0 : 1);
    galleryProfile['canViewAllPhotos'] = allowAllPhotos;
    return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFFFBF4)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VSColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F7C1838),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    height: 68,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _PhotoCarousel(
                        profile: galleryProfile,
                        height: 68,
                        radius: BorderRadius.circular(14),
                        showTapHint: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textColor,
                          ),
                        ),
                        if (detail1.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            detail1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                        if (detail2.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            detail2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                        if (badge != null) ...[
                          const SizedBox(height: 8),
                          badge!,
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 132),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: trailing,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 260))
        .slideY(
          begin: 0.035,
          end: 0,
          duration: const Duration(milliseconds: 260),
        );
  }
}

class _BrowseSectionChip extends StatelessWidget {
  const _BrowseSectionChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 154,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _primaryColor : _borderColor),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : _primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : _textColor,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: selected ? Colors.white70 : _textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.background,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final urgent = daysLeft <= 5;
    final displayDays = daysLeft.clamp(0, 30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFB42318) : const Color(0xFFFFF4DF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: urgent ? const Color(0xFFB42318) : const Color(0xFFE6A93A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: urgent ? Colors.white : _textColor,
          ),
          const SizedBox(width: 4),
          Text(
            displayDays > 0 ? '$displayDays days left' : 'Expired',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: urgent ? Colors.white : _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showBorder = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: showBorder
              ? const Border(bottom: BorderSide(color: _borderColor))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: _textColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: _textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _textSecondaryColor),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F0E5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _textSecondaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondaryColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreamCard extends StatelessWidget {
  const _CreamCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DCC8)),
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        fillColor: const Color(0xFFFFFDF5),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
      ),
    );
  }
}

class _DisabledField extends StatelessWidget {
  const _DisabledField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        fillColor: const Color(0xFFF0ECE4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8DCC8)),
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 14, color: _textSecondaryColor),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _textColor,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: _textColor),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: _textSecondaryColor),
      ),
    );
  }
}

class _SwitchSettingsTile extends StatelessWidget {
  const _SwitchSettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: _textColor),
        activeColor: _primaryColor,
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: _textSecondaryColor),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: _primaryColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: _textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SmartImage extends StatelessWidget {
  const _SmartImage({
    required this.source,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    required this.fallback,
  });

  final String source;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget Function() fallback;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screen = MediaQuery.sizeOf(context);
    final logicalWidth = width.isFinite ? width : screen.width;
    final logicalHeight = height.isFinite ? height : screen.height;
    final cacheWidth = (logicalWidth * dpr).clamp(1, 1600).round();
    final cacheHeight = (logicalHeight * dpr).clamp(1, 2200).round();
    final data = _decodeDataImage(source);
    if (data != null) {
      return Image.memory(
        data,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => fallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return fallback();
      },
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({
    required this.profile,
    required this.height,
    this.radius = BorderRadius.zero,
    this.showTapHint = true,
  });

  final Map<String, dynamic> profile;
  final double height;
  final BorderRadius radius;
  final bool showTapHint;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final photos = _photoUrls(widget.profile);
    if (photos.isEmpty) {
      return _CoverPhoto(
        profile: widget.profile,
        height: widget.height,
        radius: widget.radius,
      );
    }
    final rawVisibleCount = widget.profile['visiblePhotoCount'];
    final visibleCount = rawVisibleCount is num
        ? rawVisibleCount.toInt().clamp(0, photos.length)
        : photos.length;
    final canViewAll =
        widget.profile['canViewAllPhotos'] == true ||
        visibleCount >= photos.length;
    return ClipRRect(
      borderRadius: widget.radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: photos.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (_, index) {
              final locked = !canViewAll && index >= visibleCount;
              final containedImage = _SmartImage(
                source: photos[index],
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.contain,
                fallback: () => Container(
                  color: const Color(0xFFFFF0F0),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person,
                    size: 72,
                    color: _borderColor,
                  ),
                ),
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Subscribe and connect to view more photos',
                        ),
                      ),
                    );
                    return;
                  }
                  final viewerPhotos = canViewAll
                      ? photos
                      : photos.take(visibleCount).toList();
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => _PhotoViewer(
                        photos: viewerPhotos,
                        initialIndex: index.clamp(0, viewerPhotos.length - 1),
                      ),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Color(0xFFFFF4F6)),
                    if (locked)
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                        child: containedImage,
                      )
                    else
                      containedImage,
                    if (locked)
                      Container(
                        color: Colors.black.withValues(alpha: 0.30),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Locked photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          if (!canViewAll && photos.length > visibleCount)
            Positioned(
              top: 12,
              left: 12,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 5),
                      Text(
                        'More photos locked',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x33000000)],
                ),
              ),
            ),
          ),
          if (photos.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    photos.length,
                    (dot) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: dot == _index ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dot == _index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (widget.showTapHint && widget.height >= 120)
            const Positioned(
              right: 12,
              bottom: 12,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x8A000000),
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_out_map, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Tap to view',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.photos, required this.initialIndex});

  final List<String> photos;
  final int initialIndex;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1}/${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photos.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (_, index) => LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final height = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;
            return InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: _SmartImage(
                  source: widget.photos[index],
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  fallback: () => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CircularProfileAvatar extends StatelessWidget {
  const _CircularProfileAvatar({
    required this.profile,
    this.size = 60,
    this.borderColor,
  });

  final Map<String, dynamic> profile;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final photos = _photoUrls(profile);
    final child = photos.isNotEmpty
        ? ClipOval(
            child: _SmartImage(
              source: photos.first,
              width: size,
              height: size,
              fit: BoxFit.cover,
              fallback: _avatarFallback,
            ),
          )
        : _avatarFallback();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.transparent, width: 2),
      ),
      child: child,
    );
  }

  Widget _avatarFallback() => Container(
    decoration: const BoxDecoration(
      color: Color(0xFFF7EAE4),
      shape: BoxShape.circle,
    ),
    child: Icon(Icons.person, size: size * 0.48, color: _textSecondaryColor),
  );
}

class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({
    required this.profile,
    required this.height,
    this.radius = BorderRadius.zero,
  });

  final Map<String, dynamic> profile;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final photos = _photoUrls(profile);
    final child = photos.isNotEmpty
        ? _SmartImage(
            source: photos.first,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            fallback: _fallback,
          )
        : _fallback();
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x26000000)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFFFFF0F0),
    alignment: Alignment.center,
    child: const Icon(Icons.person, size: 72, color: _borderColor),
  );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _textSecondaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

String _personSummary(Map<String, dynamic> data) {
  final parts = <String>[];
  if (data['age'] != null && data['age'].toString().isNotEmpty)
    parts.add('${data['age']} yrs');
  if (data['city'] != null && data['city'].toString().isNotEmpty)
    parts.add(data['city'].toString());
  if (data['occupation'] != null && data['occupation'].toString().isNotEmpty)
    parts.add(data['occupation'].toString());
  return parts.isEmpty ? 'Profile available' : parts.join(' | ');
}

String _formatMessageTime(String? input) {
  final date = input == null ? null : DateTime.tryParse(input)?.toLocal();
  if (date == null) return '';
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String _formatChatDate(String? input) {
  final date = input == null ? null : DateTime.tryParse(input)?.toLocal();
  if (date == null) return 'Conversation';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final valueDay = DateTime(date.year, date.month, date.day);
  if (valueDay == today) return 'Today';
  if (valueDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
