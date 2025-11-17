import 'package:file_picker/file_picker.dart';

class UploadedFileInfo {
  final PlatformFile file;
  final String relativePath;
  final String fullLink;

  UploadedFileInfo({
    required this.file,
    required this.relativePath,
    required this.fullLink,
  });
}
