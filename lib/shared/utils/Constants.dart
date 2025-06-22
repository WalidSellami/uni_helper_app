import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

String getOs() {
  if(kIsWeb) return 'web';
  return Platform.operatingSystem;
}

dynamic userId;

dynamic localeLanguage;

dynamic deviceLocaleLang;

const int maxInputLength = 4096;

const mobileBreakpoint = 785;

const String imageProfile = 'https://iili.io/30vILeS.png';

const String devMail = 'walid.sellami@univ-constantine2.dz';

final registrationNbrRegExp = RegExp(r'^(19|20)\d{2}\d{8}$');

// final rtlRegex = RegExp(r'[\u0600-\u06FF]'); // Arabic Unicode block

final rtlRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');

final RegExp urlRegex = RegExp(
    r"\b(?:https?|ftp)://[^\s/$.?#].\S*\b",
    caseSensitive: false);

final RegExp titleRegex = RegExp(
    r'\*\*(.*?)\*\*',
    caseSensitive: true);

final RegExp bulletRegex = RegExp(
    r'^\s*-\s*`(.+?)`',
    multiLine: true);

final RegExp codeRegex = RegExp(
    r'```([a-zA-Z]*)\n([\s\S]*?)\n```',
    dotAll: true);

final RegExp emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    caseSensitive: false);

final RegExp hashtagRegex = RegExp(
    r'\B#\w*[a-zA-Z]+\w*',
    caseSensitive: false);


Future<void> sendMailMsg({
  required String recipient,
  bool isFeedback = true,
}) async {

  localeLanguage ??= deviceLocaleLang;
  String subject = '...';
  String body = '';

  if(isFeedback) {

    if (localeLanguage == 'ar') {
      subject = 'ملاحظات حول التطبيق';
      body = 'ملاحظاتك هنا:\n\n';
    } else if (localeLanguage == 'fr') {
      subject = 'Commentaires sur l\'application';
      body = 'Vos commentaires ici:\n\n';
    } else {
      subject = 'Feedback on the app';
      body = 'Your feedback here:\n\n';
    }
  }

  if(kIsWeb) {

    final String emailUrl = 'mailto:$recipient?subject=$subject&body=$body';

    await lunchBaseUrl(emailUrl);

  } else {

    final Email email = Email(
      subject: subject,
      body: body,
      recipients: [recipient],
      attachmentPaths: [],
    );

    await FlutterEmailSender.send(email);

  }

}



Future<void> lunchBaseUrl(String url) async {
  final Uri baseUrl = Uri.parse(url);
  if (await canLaunchUrl(baseUrl)) {
    await launchUrl(baseUrl, mode: LaunchMode.externalApplication);
  }
}





