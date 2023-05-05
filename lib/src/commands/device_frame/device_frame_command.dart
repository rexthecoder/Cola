import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class DeviceFrameCommand extends Command<int> {
  DeviceFrameCommand({
    required Logger logger,
  }) : _logger = logger {
    // argParser
  }
  @override
  String get description => 'Screenshot your screen and frame the images';

  @override
  String get name => 'DeviceFrame';

  final Logger _logger;

  @override
  Future<int> run() async {
    var output = 'Which unicorn has a cold? The Achoo-nicorn!';
    if (argResults?['cyan'] == true) {
      output = lightCyan.wrap(output)!;
    }
    _logger.info(output);
    return ExitCode.success.code;
  }
}
