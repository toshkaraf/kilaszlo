import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  bool get isGerman => language == AppLanguage.german;

  // Home Page
  String get appTitle => 'KI-LASZLO';
  String get appSubtitle => isGerman 
      ? 'Intelligenter Chat-Service' 
      : 'Интеллектуальный чат-сервис';
  String get selectTheme => isGerman ? 'THEMA WÄHLEN' : 'ВЫБРАТЬ ТЕМУ';
  String get chatHistory => isGerman ? 'CHAT-VERLAUF' : 'ИСТОРИЯ ЧАТОВ';
  String get homeInfo => isGerman
      ? 'Wählen Sie ein interessantes Thema und beginnen Sie ein fesselndes Gespräch mit KI. Die Informationen umfassen Geschichte, Wissenschaft, Technologie, Philosophie, Literatur und vieles mehr.'
      : 'Выберите интересующую вас тему и начните увлекательный разговор с ИИ. Информация охватывает историю, науку, технологию, философию, литературу и многое другое.';
  String get switchLanguage => isGerman ? 'Sprache wechseln (DE/RU)' : 'Переключить язык (RU/DE)';

  // Chat Page
  String get chat => isGerman ? 'Chat' : 'Чат';
  String get speak => isGerman ? 'VORLESEN' : 'ОЗВУЧИТЬ';
  String get stop => isGerman ? 'STOPP' : 'СТОП';
  String get continueChat => isGerman ? 'GESPRÄCH FORTSETZEN' : 'ПРОДОЛЖИТЬ РАЗГОВОР';
  String get autoPlay => isGerman ? 'Automatisches Vorlesen' : 'Автовоспроизведение';
  String get repeatLast => isGerman ? 'Letzte Nachricht wiederholen' : 'Повторить последнее';
  String get speechSpeed => isGerman ? 'Sprechtempo' : 'Скорость озвучки';

  // Errors
  String get errorCreatingChat => isGerman 
      ? 'Fehler beim Erstellen des Chats' 
      : 'Ошибка при создании чата';
  String get errorSendingMessage => isGerman 
      ? 'Fehler beim Senden der Nachricht' 
      : 'Ошибка при отправке сообщения';
  String get apiKeyNotFound => isGerman 
      ? 'Fehler: API-Schlüssel nicht in .env-Datei gefunden' 
      : 'Ошибка: API ключ не найден в .env файле';
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return AppLocalizations(languageProvider.currentLanguage);
  }
}
