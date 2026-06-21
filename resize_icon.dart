import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final fileBytes = File('img/space-game.png').readAsBytesSync();
  final image = img.decodeImage(fileBytes)!;
  
  // Create a new image that is 25% larger to effectively scale down the icon (add padding)
  int newWidth = (image.width * 1.35).toInt();
  int newHeight = (image.height * 1.35).toInt();
  
  final padded = img.Image(width: newWidth, height: newHeight);
  // Transparent background is default.
  
  int dstX = ((newWidth - image.width) / 2).toInt();
  int dstY = ((newHeight - image.height) / 2).toInt();
  
  img.compositeImage(padded, image, dstX: dstX, dstY: dstY);
  
  File('img/space-game-icon.png').writeAsBytesSync(img.encodePng(padded));
  print('Resized and saved');
}
