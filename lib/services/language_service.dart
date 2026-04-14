// lib/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple Tagalog ↔ English toggle.
/// Widgets that depend on the active language subscribe via [LanguageService.of]
/// and rebuild when [notifyListeners] fires.
class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _prefKey = 'app_language';
  static const String langEnglish = 'en';
  static const String langTagalog = 'tl';

  String _currentLanguage = langEnglish;

  String get currentLanguage => _currentLanguage;
  bool get isTagalog => _currentLanguage == langTagalog;
  bool get isEnglish => _currentLanguage == langEnglish;

  /// Call once at app startup to restore the saved preference.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_prefKey) ?? langEnglish;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (_currentLanguage == lang) return;
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, lang);
    notifyListeners();
  }

  Future<void> toggle() async {
    await setLanguage(isEnglish ? langTagalog : langEnglish);
  }

  // ─── Translation helper ───────────────────────────────────────────────────

  String t(String en, String tl) => isTagalog ? tl : en;

  // ─── Common UI strings ────────────────────────────────────────────────────

  // Auth
  String get signUp => t('Sign Up', 'Mag-sign Up');
  String get signIn => t('Sign In', 'Mag-sign In');
  String get logOut => t('Log Out', 'Mag-log Out');
  String get email => t('Email Address', 'Email Address');
  String get password => t('Password', 'Password');
  String get contactNumber => t('Contact Number', 'Numero ng Telepono');
  String get address => t('Address', 'Tirahan');
  String get dateOfBirth => t('Date of Birth', 'Petsa ng Kapanganakan');
  String get firstName => t('First Name', 'Pangalan');
  String get lastName => t('Last Name', 'Apelyido');
  String get middleInitial => t('Middle Initial', 'Gitnang Inisyal');

  // Notifications
  String get notifications => t('Notifications', 'Mga Abiso');
  String get noNewNotifications =>
      t('No new notifications', 'Walang bagong abiso');
  String get notificationsEmptyHint => t(
    "You'll see updates on your reports here when they are reviewed by admin.",
    'Makikita mo rito ang mga update sa iyong mga ulat kapag nasuri na ng admin.',
  );

  // Report status titles
  String notificationTitle(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return t('Report Accepted', 'Natanggap ang Ulat');
      case 'in_progress':
      case 'inprogress':
        return t('Work In Progress', 'Isinasagawa na');
      case 'resolved':
        return t('Issue Resolved', 'Naayos na ang Isyu');
      case 'invalid':
        return t('Report Invalid', 'Di-wastong Ulat');
      default:
        return t('Report Submitted', 'Naisumite ang Ulat');
    }
  }

  // Report status messages
  String notificationMessage(String status, String reportType) {
    final type = reportType.isNotEmpty ? reportType : t('road issue', 'isyu sa daan');
    switch (status.toLowerCase()) {
      case 'accepted':
        return t(
          'Your $type report has been accepted and is now being analyzed by the team.',
          'Ang iyong ulat tungkol sa $type ay natanggap na at sinusuri na ng pangkat.',
        );
      case 'in_progress':
      case 'inprogress':
        return t(
          'Our team is currently working on the $type you reported. A fix is underway.',
          'Ang aming pangkat ay kasalukuyang nag-aayos ng $type na iyong iniulat.',
        );
      case 'resolved':
        return t(
          'Great news! The $type you reported has been fixed and verified by our team.',
          'Magandang balita! Ang $type na iyong iniulat ay naayos na at na-verify ng aming pangkat.',
        );
      case 'invalid':
        return t(
          'Your $type report was reviewed but could not be verified. It has been archived.',
          'Ang iyong ulat tungkol sa $type ay nasuri ngunit hindi na-verify. Ito ay na-archive na.',
        );
      default:
        return t(
          'Your $type report has been submitted and is awaiting admin review.',
          'Ang iyong ulat tungkol sa $type ay naisumite na at naghihintay ng pagsusuri ng admin.',
        );
    }
  }

  // Status statement
  String statusStatement(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return t(
          'This report has been accepted and is currently being analyzed by the road maintenance team.',
          'Ang ulat na ito ay natanggap na at kasalukuyang sinusuri ng pangkat ng pagpapanatili ng kalsada.',
        );
      case 'in_progress':
      case 'inprogress':
        return t(
          'Your report is currently being worked on. Our team is actively addressing the road issue you reported.',
          'Ang iyong ulat ay kasalukuyang isinasagawa. Aktibo naming tinutugunan ang isyu sa kalsada na iyong iniulat.',
        );
      case 'resolved':
        return t(
          'This report has been resolved. The reported road issue has been fixed and verified by our team.',
          'Ang ulat na ito ay nalutas na. Ang iniulat na isyu sa kalsada ay naayos na at na-verify ng aming pangkat.',
        );
      case 'invalid':
        return t(
          'This report has been reviewed and marked as invalid. It is no longer active.',
          'Ang ulat na ito ay nasuri at minarkahan bilang hindi wasto. Hindi na ito aktibo.',
        );
      default:
        return t(
          'Your report is pending review. Our admin team will verify and process your submission soon.',
          'Ang iyong ulat ay naghihintay ng pagsusuri. Ang aming pangkat ng admin ay magbe-verify at magpoproseso ng iyong submission sa lalong madaling panahon.',
        );
    }
  }

  // Detection
  String detectionStatement(String className, int count) {
    final displayName = className.replaceAll('_', ' ').replaceAll('-', ' ');
    if (count == 1) {
      return t(
        'A $displayName has been detected.',
        'Isang $displayName ang natukoy.',
      );
    }
    return t(
      '$count ${displayName}s have been detected.',
      '$count na $displayName ang natukoy.',
    );
  }

  String get detectionResult => t('Detection Result', 'Resulta ng Pagtukoy');
  String get detectedStatus => t('Status: Detected', 'Katayuan: Natukoy');
  String get detectedLabel => t('Detected', 'Natukoy');
  String get detectionResults => t('Detection Results:', 'Mga Resulta ng Pagtukoy:');

  String noHazardDetected(String? category) => t(
        'No ${category?.toLowerCase() ?? 'road hazard'} detected in this image.',
        'Walang ${category?.toLowerCase() ?? 'panganib sa kalsada'} ang natukoy sa larawang ito.',
      );

  // Submit report
  String get submitReport => t('Submit Report', 'Isumite ang Ulat');
  String get submitAReport => t('Submit a Report', 'Mag-ulat');
  String get cancel => t('Cancel', 'Kanselahin');
  String get confirm => t('Confirm', 'Kumpirmahin');
  String get retry => t('Retry', 'Subukan Muli');

  // Profile
  String get languageToggleLabel =>
      t('Language / Wika', 'Language / Wika');
  String get currentLanguageLabel =>
      isEnglish ? 'English' : 'Filipino (Tagalog)';
}
