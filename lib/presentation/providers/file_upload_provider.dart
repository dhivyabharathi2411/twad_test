import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/file_upload_service.dart';

class UploadProvider extends ChangeNotifier {
  final UploadService _uploadService = UploadService();

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  String? _message;
  String? get message => _message;

  final List<PlatformFile> _uploadedFiles = [];
  List<PlatformFile> get uploadedFiles => _uploadedFiles;

  final List<String> _fileLinks = [];
  List<String> get fileLinks => _fileLinks;

  final List<String> _relativePaths = [];
  List<String> get relativePaths => _relativePaths;

  Future<void> uploadFiles(List<PlatformFile> files) async {
    _isUploading = true;
    _message = null;
    _uploadedFiles.clear();
    _fileLinks.clear();
    _relativePaths.clear();
    notifyListeners();

    for (var file in files) {
      try {
        final ext = file.extension?.toLowerCase();
        if (!(["jpg", "jpeg", "png", "pdf", "mp4"].contains(ext))) {
          _message = "Unsupported file type: ${file.name}";
          continue;
        }

        final sizeInMB = file.size / (1024 * 1024);
        if (sizeInMB > 5) {
          _message = "File ${file.name} is larger than 5 MB";
          continue;
        }

        final result = await _uploadService.uploadFile(
          filePath: file.path!,
          type: "public",
        );

        if (result['success'] == true) {
          _uploadedFiles.add(file);

          final relativePath = result['data'];
          if (relativePath != null && relativePath is String) {
            final fullLink = '$relativePath';
            _fileLinks.add(fullLink);
            _relativePaths.add(relativePath);
          }
        } else {
          _message = result['message'];
        }
      } catch (e) {
        _message = e.toString();
      }
    }

    _isUploading = false;
    notifyListeners();
  }

  Future<void> deleteFile(String relativePath) async {
    _isDeleting = true;
    _message = null;
    notifyListeners();

    try {
      final result = await _uploadService.deleteFile(fileName: relativePath);

      if (result['success'] == true) {
        final index = _relativePaths.indexOf(relativePath);
        if (index != -1) {
          _relativePaths.removeAt(index);
          _fileLinks.removeAt(index);
          _uploadedFiles.removeAt(index);
        }
        _message = 'File deleted successfully';
      } else {
        _message = result['message'] ?? 'Delete failed';
      }
    } catch (e) {
      _message = e.toString();
    }

    _isDeleting = false;
    notifyListeners();
  }

  /// NEW METHOD: View a file
  void viewFile(BuildContext context, PlatformFile file) async {
    final ext = file.extension?.toLowerCase();

    if (ext == 'pdf') {
      // Open PDF viewer
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: file.path != null
                ? SfPdfViewer.file(File(file.path!))
                : const Center(child: Text('PDF path not available')),
          ),
        ),
      );
      return;
    }

    if (ext == 'mp4' || ext == 'mov' || ext == 'mkv' || ext == 'webm') {
      VideoPlayerController? controller;
      File? tmpFile;

      try {
        if (file.path != null && file.path!.isNotEmpty) {
          controller = VideoPlayerController.file(File(file.path!));
        } else if (file.bytes != null) {
          // write bytes to a temporary file
          final dir = await getTemporaryDirectory();
          tmpFile = File('${dir.path}/${file.name}');
          await tmpFile.writeAsBytes(file.bytes!);
          controller = VideoPlayerController.file(tmpFile);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video path/bytes not available')),
          );
          return;
        }

        await controller.initialize();
        controller.setLooping(false);
        controller.play();

        await showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(controller),
                  _videoControls(controller: controller),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening video: $e')));
      } finally {
        try {
          await controller?.pause();
          await controller?.dispose();
        } catch (_) {}
        if (tmpFile != null && await tmpFile.exists()) {
          try {
            await tmpFile.delete();
          } catch (_) {}
        }
      }
      return;
    }

    if (file.bytes != null) {
      // Preview images from memory
      showDialog(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: SizedBox(
          width: size.width,
          height: size.height * 0.9,
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 1.0,
            maxScale: 5.0,
            child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(file.bytes!, fit: BoxFit.contain),
            ),
          ),
        ),
          );
        },
      );
        } else if (file.path != null && file.path!.isNotEmpty) {
      // Preview images from path with zoom
      showDialog(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: SizedBox(
          width: size.width,
          height: size.height * 0.9,
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 1.0,
            maxScale: 5.0,
            child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(file.path!), fit: BoxFit.contain),
            ),
          ),
        ),
          );
        },
      );
        } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview not available for this file')),
      );
    }
  }

  // Small helper widget for video controls used above
  // Place inside the same class (UploadProvider) as a private StatelessWidget-like method
  Widget _videoControls({required VideoPlayerController controller}) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                  setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: () {
                  controller.pause();
                  controller.seekTo(Duration.zero);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
