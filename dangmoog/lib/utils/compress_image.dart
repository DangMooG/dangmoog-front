import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<File> compressImage(File imageFile) async {
  await checkFileSize(imageFile);

  var tmpDir = await path_provider.getTemporaryDirectory();
  var targetName = DateTime.now().millisecondsSinceEpoch;

  var compressFile = await FlutterImageCompress.compressAndGetFile(
    imageFile.absolute.path,
    "${tmpDir.absolute.path}/$targetName.jpg",
    quality: 50,
  );

  return getImageFileFromXFile(compressFile!);
}

Future<File> getImageFileFromXFile(XFile xFile) async {
  await checkFileSize(File(xFile.path));

  return File(xFile.path);
}

Future<void> checkFileSize(File file) async {
  int fileSize = await file.length(); // 파일의 크기를 바이트 단위로 가져옵니다.
  print("File size: $fileSize bytes");
}


// Future<File> testCompressAndGetFile(File file, String targetPath) async {
//     var result = await FlutterImageCompress.compressAndGetFile(
//         file.absolute.path, targetPath,
//         quality: 88,
//         rotate: 180,
//       );

//     print(file.lengthSync());
//     print(result.lengthSync());

//     return result;
//   }