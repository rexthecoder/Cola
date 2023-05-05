import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart';

import 'package:path/path.dart' as path;

void main() async {
  final framePath = path.join(
    Directory.current.path,
    'deviceframe',
  );

  // await readFrames(framePath).then((frames) {
  //   print('reading files');
  //   final content = json.encode(frames);
  //   File('${Directory.current.path}/data/frames.json').writeAsStringSync(
  //     content,
  //   );
  // });

  createImage();
  print('added file');
}

void createImage() {
  final imageFrame = File('${Directory.current.path}/data/Apple iPhone 7 Gold');



  // Load JSON file
  final jsonString = File(
    '${Directory.current.path}/data/frames.json',
  ).readAsStringSync();
  final List framesData = json.decode(jsonString);

  // Loop through frames
  for (final frame in framesData) {
    // Get image path and frame info
    final imagePath = frame['relPath'];
    final frameData = frame['frame'];

    // Load image
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      print('Image file "$imagePath" could not be opened.');
      continue;
    }
    final imageData = imageFile.readAsBytesSync();
    final originalImage = decodeImage(imageData);

    // Create new image with frame dimensions
    final newImage = Image(
      width: frameData['width'] ?? 100,
      height: frameData['height'] ?? 100,
    );

    // // Crop original image using frame info
    final int x = frameData['left'] - (frameData['right'] - frameData['width']);
    final int y =
        frameData['top'] - (frameData['bottom'] - frameData['height']);

    // Scale cropped image to fit new image using frame info
    final croppedImage = copyCrop(
      originalImage!,
      x: x,
      y: y,
      width: 100,
      height: 100,
    );

// Check for invalid image size
    if (croppedImage.width == 0 || croppedImage.height == 0) {
      print('Error: Invalid image size');
      return;
    }

// Calculate scaling factor
    final scaleFactor = min(
      newImage.width / croppedImage.width,
      newImage.height / croppedImage.height,
    );

// Scale cropped image to fit new image
    final scaledImage = copyResize(
      croppedImage,
      width: (croppedImage.width * scaleFactor).toInt(),
      height: (croppedImage.height * scaleFactor).toInt(),
    );

    // Add scaled image to new image
    for (int y = 0; y < scaledImage.height; y++) {
      for (int x = 0; x < scaledImage.width; x++) {
        newImage.setPixel(x, y, scaledImage.getPixel(x, y));
      }
    }

    // Save new image
    final newName = '${frame['name'].replaceAll('%20', ' ')}-framed.png';
    File(newName).writeAsBytesSync(encodePng(newImage));
  }
}

Future<List<String>> readDirRecursive(String dirPath) async {
  final files = <String>[];
  await for (final entity in Directory(dirPath).list(recursive: true)) {
    if (entity is File) {
      files.add(entity.path);
    }
  }
  return files;
}

Future<List<Map<String, dynamic>>> readFrames(String framePath) async {
  final files = await readDirRecursive(framePath);
  files.sort();

  return Future.wait(
    files.where((path) => path.endsWith('.png')).map(getFrameDetails).toList(),
  );
}

Future<Map<String, dynamic>> getFrameDetails(String framePath) async {
  final px = json.decode(
    await File(
      '${Directory.current.path}/data/pixel-ratios.json',
    ).readAsString(),
  );

  print(px);
  final relPath = framePath.replaceFirst(RegExp('.+?deviceframe-frames/'), '');
  print("relPath: $relPath");
  final path = Uri.parse(relPath).path;
  final parts = path.split('/').where((part) => part.isNotEmpty).toList();

  final category = parts[0];
  final device = parts[1];
  final name = parts.last;
  final shadow = RegExp('shadow', caseSensitive: false).hasMatch(relPath);

  final frame = await pathToFrame(framePath);
  print([category, device, name, if (shadow) 'Shadow' else 'No Shadow']
      .join(' | '));

  var pixelRatio;
  final p = px.firstWhere(
    (element) => element['name'] == device,
    orElse: () => null,
  );

  if (p != null) {
    pixelRatio = p['pixelRatio'];
  }

  return {
    'relPath': relPath,
    'category': category,
    'device': device,
    'name': name,
    'frame': frame,
    'pixelRatio': pixelRatio,
    'shadow': shadow,
    'tags': name.split(RegExp(r'\s+')).map((tag) => tag.toLowerCase()).toList(),
  };
}

Future<Map<String, dynamic>> pathToFrame(String framePath) async {
  final image = decodeImage(await File(framePath).readAsBytes());
  return findFrame(image!);
}

num getAlpha(Pixel pixel) {
  return pixel.a;
}

Map<String, dynamic> findFrame(Image image) {
  final middleX = image.width ~/ 2;
  final middleY = image.height ~/ 2;

  var left = 0;
  var right = 0;
  var top = 0;
  var bottom = 0;

  // Scan left
  for (var i = middleX; i >= 0; i--) {
    final alpha = getAlpha(image.getPixel(i, middleY));
    if (alpha == 255) {
      left = i;
      break;
    }
  }

  // Scan right
  for (var i = middleX; i <= image.width; i++) {
    final alpha = getAlpha(image.getPixel(i, middleY));
    if (alpha == 255) {
      right = i;
      break;
    }
  }

  // Scan top
  for (var i = middleY; i >= 0; i--) {
    final alpha = getAlpha(image.getPixel(middleX, i));
    if (alpha == 255) {
      top = i;
      break;
    }
  }

  // Scan bottom
  for (var i = middleY; i <= image.height; i++) {
    final alpha = getAlpha(image.getPixel(middleX, i));
    if (alpha == 255) {
      bottom = i;
      break;
    }
  }

  return {
    'top': top,
    'left': left,
    'bottom': bottom,
    'right': right,
    'width': right - left,
    'height': bottom - top,
  };
}

class FrameData {
  final String relPath;
  final String category;
  final String device;
  final String name;
  final Map<String, int> frame;
  final double? pixelRatio;
  final bool shadow;
  final List<String> tags;

  FrameData({
    required this.relPath,
    required this.category,
    required this.device,
    required this.name,
    required this.frame,
    required this.shadow,
    required this.tags,
    this.pixelRatio,
  });

  factory FrameData.fromJson(Map<String, dynamic> json) {
    return FrameData(
      relPath: json['relPath'],
      category: json['category'] as String,
      device: json['device'],
      name: json['name'] as String,
      frame: Map.from(json['frame']),
      pixelRatio: json['pixelRatio']?.toDouble() as double,
      shadow: json['shadow'] as bool,
      tags: List<String>.from(json['tags']),
    );
  }
}
