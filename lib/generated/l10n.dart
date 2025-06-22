// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Hey there! Welcome To :`
  String get welcome_title {
    return Intl.message(
      'Hey there! Welcome To :',
      name: 'welcome_title',
      desc: '',
      args: [],
    );
  }

  /// `Your smart companion for campus life: schedules, events, campus services, and more!`
  String get welcome_description {
    return Intl.message(
      'Your smart companion for campus life: schedules, events, campus services, and more!',
      name: 'welcome_description',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get connection_status {
    return Intl.message(
      'No Internet Connection',
      name: 'connection_status',
      desc: '',
      args: [],
    );
  }

  /// `You are currently offline!`
  String get connection_status_1 {
    return Intl.message(
      'You are currently offline!',
      name: 'connection_status_1',
      desc: '',
      args: [],
    );
  }

  /// `You are connected with internet`
  String get connection_status_2 {
    return Intl.message(
      'You are connected with internet',
      name: 'connection_status_2',
      desc: '',
      args: [],
    );
  }

  /// `You are not connected with internet`
  String get connection_status_3 {
    return Intl.message(
      'You are not connected with internet',
      name: 'connection_status_3',
      desc: '',
      args: [],
    );
  }

  /// `Checking for connection ...`
  String get connection_status_4 {
    return Intl.message(
      'Checking for connection ...',
      name: 'connection_status_4',
      desc: '',
      args: [],
    );
  }

  /// `University Algerian Assistant`
  String get sign_in_title {
    return Intl.message(
      'University Algerian Assistant',
      name: 'sign_in_title',
      desc: '',
      args: [],
    );
  }

  /// `Sign In To Continue!`
  String get sign_in_subtitle {
    return Intl.message(
      'Sign In To Continue!',
      name: 'sign_in_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Registration Number`
  String get registration_nbr {
    return Intl.message(
      'Registration Number',
      name: 'registration_nbr',
      desc: '',
      args: [],
    );
  }

  /// `Registration Number must not be empty`
  String get registration_nbr_check_1 {
    return Intl.message(
      'Registration Number must not be empty',
      name: 'registration_nbr_check_1',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid 12-digit registration number. It should start with your Baccalaureate year followed by your matricule from your relevant Baccalaureate.`
  String get registration_nbr_check_2 {
    return Intl.message(
      'Enter a valid 12-digit registration number. It should start with your Baccalaureate year followed by your matricule from your relevant Baccalaureate.',
      name: 'registration_nbr_check_2',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Password must not be empty`
  String get password_check_1 {
    return Intl.message(
      'Password must not be empty',
      name: 'password_check_1',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters long.`
  String get password_check_2 {
    return Intl.message(
      'Password must be at least 8 characters long.',
      name: 'password_check_2',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in {
    return Intl.message('Sign In', name: 'sign_in', desc: '', args: []);
  }

  /// `Sign Out`
  String get sign_out {
    return Intl.message('Sign Out', name: 'sign_out', desc: '', args: []);
  }

  /// `Sign Out?`
  String get sign_out_qst {
    return Intl.message('Sign Out?', name: 'sign_out_qst', desc: '', args: []);
  }

  /// `Do you want to sign out?`
  String get sign_out_request {
    return Intl.message(
      'Do you want to sign out?',
      name: 'sign_out_request',
      desc: '',
      args: [],
    );
  }

  /// `Press back again to exit`
  String get exit {
    return Intl.message(
      'Press back again to exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `You have reached the maximum allowed input length!`
  String get input_length_check {
    return Intl.message(
      'You have reached the maximum allowed input length!',
      name: 'input_length_check',
      desc: '',
      args: [],
    );
  }

  /// `The model is in preview and may make mistakes.`
  String get model_status {
    return Intl.message(
      'The model is in preview and may make mistakes.',
      name: 'model_status',
      desc: '',
      args: [],
    );
  }

  /// `Good morning!`
  String get good_morning {
    return Intl.message(
      'Good morning!',
      name: 'good_morning',
      desc: '',
      args: [],
    );
  }

  /// `Good afternoon!`
  String get good_afternoon {
    return Intl.message(
      'Good afternoon!',
      name: 'good_afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good evening!`
  String get good_evening {
    return Intl.message(
      'Good evening!',
      name: 'good_evening',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Ask ...`
  String get ask {
    return Intl.message('Ask ...', name: 'ask', desc: '', args: []);
  }

  /// `New Chat`
  String get new_chat {
    return Intl.message('New Chat', name: 'new_chat', desc: '', args: []);
  }

  /// `There are no chats`
  String get no_chats {
    return Intl.message(
      'There are no chats',
      name: 'no_chats',
      desc: '',
      args: [],
    );
  }

  /// `Which language do you want to use`
  String get lang_request {
    return Intl.message(
      'Which language do you want to use',
      name: 'lang_request',
      desc: '',
      args: [],
    );
  }

  /// `Default is`
  String get default_lang {
    return Intl.message('Default is', name: 'default_lang', desc: '', args: []);
  }

  /// `English`
  String get lang_en {
    return Intl.message('English', name: 'lang_en', desc: '', args: []);
  }

  /// `Arabic`
  String get lang_ar {
    return Intl.message('Arabic', name: 'lang_ar', desc: '', args: []);
  }

  /// `French`
  String get lang_fr {
    return Intl.message('French', name: 'lang_fr', desc: '', args: []);
  }

  /// `Feedback`
  String get feedback {
    return Intl.message('Feedback', name: 'feedback', desc: '', args: []);
  }

  /// `Mic`
  String get mic {
    return Intl.message('Mic', name: 'mic', desc: '', args: []);
  }

  /// `Something went wrong. Please try again later.`
  String get error_message {
    return Intl.message(
      'Something went wrong. Please try again later.',
      name: 'error_message',
      desc: '',
      args: [],
    );
  }

  /// `Previous year`
  String get previous_year {
    return Intl.message(
      'Previous year',
      name: 'previous_year',
      desc: '',
      args: [],
    );
  }

  /// `Previous 30 days`
  String get previous_30_days {
    return Intl.message(
      'Previous 30 days',
      name: 'previous_30_days',
      desc: '',
      args: [],
    );
  }

  /// `Previous 15 days`
  String get previous_15_days {
    return Intl.message(
      'Previous 15 days',
      name: 'previous_15_days',
      desc: '',
      args: [],
    );
  }

  /// `Previous 7 days`
  String get previous_7_days {
    return Intl.message(
      'Previous 7 days',
      name: 'previous_7_days',
      desc: '',
      args: [],
    );
  }

  /// `Previous 3 days`
  String get previous_3_days {
    return Intl.message(
      'Previous 3 days',
      name: 'previous_3_days',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Loading ...`
  String get url_open {
    return Intl.message('Loading ...', name: 'url_open', desc: '', args: []);
  }

  /// `Rename`
  String get rename {
    return Intl.message('Rename', name: 'rename', desc: '', args: []);
  }

  /// `Rename Chat`
  String get rename_chat {
    return Intl.message('Rename Chat', name: 'rename_chat', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Delete Chat?`
  String get delete_chat {
    return Intl.message(
      'Delete Chat?',
      name: 'delete_chat',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete this chat?`
  String get delete_request {
    return Intl.message(
      'Do you want to delete this chat?',
      name: 'delete_request',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Chat name must not be empty`
  String get chat_name_check {
    return Intl.message(
      'Chat name must not be empty',
      name: 'chat_name_check',
      desc: '',
      args: [],
    );
  }

  /// `Name too large`
  String get chat_name_check_2 {
    return Intl.message(
      'Name too large',
      name: 'chat_name_check_2',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
