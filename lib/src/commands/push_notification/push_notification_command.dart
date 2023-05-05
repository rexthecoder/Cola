import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cola/src/commands/push_notification/push_notification_model.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:process_run/shell_run.dart';

/// {@template push_notification_command}
///
/// `cola sample`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class PushNotificationCommand extends Command<int> {
  /// {@macro sample_command}
  PushNotificationCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'bundle-identifier',
        help: 'The bundle identifier of the app to push to',
        abbr: 'b',
        mandatory: true,
      )
      ..addOption(
        'title',
        help: 'The title of the Push notification',
        abbr: 't',
        defaultsTo: 'Cola',
      )
      ..addOption(
        'body',
        help: 'The body of the Push notification',
        defaultsTo: 'Cola is an amazing tool 🤑',
      )
      ..addOption(
        'badge',
        help: "The number to display in a badge on your app's icon",
        defaultsTo: '1',
      );
  }

  final Logger _logger;

  @override
  Future<int> run() async {
    /// Get all the passed agrument
    final bundleIdentifier = argResults?['bundle-identifier'] as String;
    final title = argResults?['title'] as String;
    final body = argResults?['body'] as String;
    final badge = argResults?['badge'] as String;

    final shell = Shell(
      commandVerbose: false,
      commentVerbose: false,
      verbose: false,
    );
    const encoder = JsonEncoder();

    /// Creatinf payload object out of the args
    final payload = Payload(
      title: title,
      body: body,
      badge: badge,
    );

    _logger.info(lightCyan.wrap('Starting cola ...'));
    // Show a progress message while performing an asynchronous operation.
    final progress = _logger.progress('Sending push notification...');
    await Future<void>.delayed(const Duration(seconds: 1));

    progress.update('Generating payload ...');
    await Future<void>.delayed(const Duration(seconds: 1));

    final payloadFile = File('payload.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        encoder.convert(payload),
      );

    await shell.run(
      'xcrun simctl push booted $bundleIdentifier ${payloadFile.path}',
    );

    // Show a completion message when the asynchronous operation has completed.
    progress.complete('Push notification sent successfully');

    payloadFile.deleteSync();

    return ExitCode.success.code;
  }

  @override
  String get description => 'Send a push notification test to your simulator';

  @override
  String get name => 'push';
}
