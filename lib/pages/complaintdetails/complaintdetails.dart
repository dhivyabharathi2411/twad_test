import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'package:twad/pages/dashboard/statuschip.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:twad/pages/home_screen.dart';
import '../../constants/app_constants.dart';
import '../../data/models/grievance_detail_model.dart';
import '../../data/models/grievance_status.dart';
import '../../presentation/providers/acknowledgement_provider.dart';
import '../../presentation/providers/feedback_provider.dart';
import '../../presentation/providers/grievance_provider.dart';
import '../../widgets/feedback_form.dart';
import '../../widgets/grievance_detail_row.dart';

class ComplaintDetailsPage extends StatefulWidget {
  final int grievanceId;

  const ComplaintDetailsPage({super.key, required this.grievanceId});

  @override
  State<ComplaintDetailsPage> createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends State<ComplaintDetailsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComplaintDetails();
    });
  }

  Future<void> _loadComplaintDetails() async {
    final provider = Provider.of<GrievanceProvider>(context, listen: false);
    await provider.fetchGrievanceDetail(widget.grievanceId);

    final detail = provider.grievanceDetail;
    if (detail != null) {
      if (detail.processHistory.isNotEmpty) {
        for (int i = 0; i < detail.processHistory.length; i++) {
          // final ph = detail.processHistory[i];
        }
      } else {}
      final showFeedback = detail.complaintStatus.toLowerCase() == 'closed';

      final hasAttachments = detail.fileLinks.isNotEmpty;
      int tabCount = 1;
      if (hasAttachments) tabCount++;
      if (showFeedback) tabCount++;

      _tabController?.dispose();

      _tabController = TabController(length: tabCount, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          _tabIndex.value = _tabController!.index;
        }
      });
      if (detail.isReopen == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final feedbackProvider = Provider.of<FeedbackProvider>(
            context,
            listen: false,
          );
          feedbackProvider.clearFeedbackForReopenedGrievance(detail.id);
        });
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _tabIndex.dispose();
    super.dispose();
  }

  Future<void> _downloadAcknowledgement(
    BuildContext context,
    int grievanceId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<AcknowledgementProvider>(
      context,
      listen: false,
    );

    provider.setDownloadProcessing(grievanceId, true);
    await provider.fetchAcknowledgementPdf(grievanceId);

    final pdfPath = provider.pdfUrl;
    final errorMessage = provider.errorMessage;
    final fileName = 'TWAD_Acknowledgement_$grievanceId.pdf';
    final baseUrl = 'https://api.tanneer.com/uploads';
    final fullUrl = '$baseUrl$pdfPath';

    if (pdfPath == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Unable to get acknowledgement file'),
          backgroundColor: Colors.red,
        ),
      );
      provider.setDownloadProcessing(grievanceId, false);
      return;
    }

    try {
      if (!mounted) return;
      
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text(context.tr.downloading),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      final response = await Dio().get<List<int>>(
        fullUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);

      const platform = MethodChannel('com.example.twad/download');
      final savedPath = await platform.invokeMethod('saveFile', {
        'bytes': bytes,
        'fileName': fileName,
      });

      if (!mounted) return;
      
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.tr.downloadComplete),

          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      
      if (savedPath != null && savedPath.isNotEmpty) {
        await OpenFilex.open(savedPath);
      }
    } catch (e) {
      if (!mounted) return;
      
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${context.tr.downloadFailed} ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 6),
        ),
      );
    } finally {
      provider.setDownloadProcessing(grievanceId, false);
    }
  }

  List<String> _buildPotentialFileUrls(String? fileUrl) {
    if (fileUrl == null || fileUrl.trim().isEmpty) {
      return <String>[];
    }

    final original = fileUrl.trim();
    String cleanFileUrl = original;
    if (cleanFileUrl.startsWith('/')) {
      cleanFileUrl = cleanFileUrl.substring(1);
    }
    if (cleanFileUrl.startsWith('http://') ||
        cleanFileUrl.startsWith('https://')) {
      return [cleanFileUrl];
    }

    final potentialUrls = <String>[
      "https://api.tanneer.com/uploads/$cleanFileUrl",
    ];
    for (int i = 0; i < potentialUrls.length; i++) {}

    return potentialUrls;
  }

  Future<void> _viewGrievanceFileWithFallback(
    BuildContext context,
    List<String> potentialUrls,
    String fileName,
  ) async {
    if (potentialUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr.fileNotAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final primaryUrl = potentialUrls.first;
    final fileCategory = _getFileTypeCategory(primaryUrl);
    switch (fileCategory) {
      case 'image':
        await _viewImageFileWithFallback(context, potentialUrls, fileName);
        break;
      case 'video':
        await _viewVideoFile(context, primaryUrl, fileName);
        break;
      case 'audio':
        await _viewAudioFile(context, primaryUrl, fileName);
        break;
      case 'pdf':
        await _viewPdfFileWithFallback(context, potentialUrls, fileName);
        break;
      case 'document':
      case 'spreadsheet':
      case 'presentation':
        await _viewDocumentFile(context, primaryUrl, fileName);
        break;
      case 'text':
        await _viewTextFile(context, primaryUrl, fileName);
        break;
      case 'archive':
        await _downloadArchiveFile(context, primaryUrl, fileName);
        break;
      default:
        await _viewGenericFile(context, primaryUrl, fileName);
        break;
    }
  }

  Future<void> _viewImageFileWithFallback(
    BuildContext context,
    List<String> potentialUrls,
    String fileName,
  ) async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: _buildImageWithFallback(potentialUrls, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithFallback(List<String> urls, BuildContext context) {
    return _ImageWithFallback(
      urls: urls,
      onAllFailed: () {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                context.tr.fileLoadFailed,
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tried ${urls.length} different URLs',
                style: TextStyle(color: Colors.red[400], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _viewPdfFileWithFallback(
    BuildContext context,
    List<String> potentialUrls,
    String fileName,
  ) async {
    for (int i = 0; i < potentialUrls.length; i++) {
      final currentUrl = potentialUrls[i];
      try {
        await _showPdfViewer(context, currentUrl, fileName);
        return;
      } catch (e) {
        if (i == potentialUrls.length - 1) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${context.tr.fileLoadFailed} - PDF not accessible from any source. Tried ${potentialUrls.length} URLs.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _showPdfViewer(
    BuildContext context,
    String pdfUrl,
    String fileName,
  ) async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () =>
                          _downloadPdfFile(context, pdfUrl, fileName),
                      tooltip: 'Download PDF',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: SfPdfViewer.network(
                    pdfUrl,
                    onDocumentLoadFailed:
                        (PdfDocumentLoadFailedDetails details) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to load PDF: ${details.description}',
                              ),
                              backgroundColor: Colors.red,
                              action: SnackBarAction(
                                label: 'Download',
                                onPressed: () =>
                                    _downloadPdfFile(context, pdfUrl, fileName),
                              ),
                            ),
                          );
                        },
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdfFile(
    BuildContext context,
    String pdfUrl,
    String fileName,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Downloading PDF...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 30),
        ),
      );

      final response = await Dio().get<List<int>>(
        pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      const platform = MethodChannel('com.example.twad/download');
      final savedPath = await platform.invokeMethod('saveFile', {
        'bytes': bytes,
        'fileName': fileName,
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF downloaded successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              if (savedPath != null && savedPath.isNotEmpty) {
                OpenFilex.open(savedPath);
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _viewVideoFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    await _downloadAndOpenFile(context, fileUrl, fileName, 'video');
  }

  Future<void> _viewAudioFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    await _downloadAndOpenFile(context, fileUrl, fileName, 'audio');
  }

  Future<void> _viewDocumentFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    await _downloadAndOpenFile(context, fileUrl, fileName, 'document');
  }

  Future<void> _viewTextFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    await _downloadAndOpenFile(context, fileUrl, fileName, 'text');
  }

  Future<void> _downloadArchiveFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    await _downloadAndOpenFile(context, fileUrl, fileName, 'archive');
  }

  Future<void> _viewGenericFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    await _downloadAndOpenFile(context, fileUrl, fileName, 'file');
  }

  Future<void> _downloadAndOpenFile(
    BuildContext context,
    String fileUrl,
    String fileName,
    String fileType,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final localFile = File('${directory.path}/$fileName');

    if (await localFile.exists()) {
      try {
        final result = await OpenFilex.open(localFile.path);
        if (!context.mounted) return;
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.tr.fileOpenFailed}: ${result.message}'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr.fileOpenFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text(_getLoadingMessage(context, fileType)),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      final response = await Dio().get<List<int>>(
        fileUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      await localFile.writeAsBytes(bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final fileSizeKB = (bytes.length / 1024).round();
      final fileSizeMB = (fileSizeKB / 1024).toStringAsFixed(1);
      final sizeText = fileSizeKB > 1024
          ? '${fileSizeMB}MB'
          : '${fileSizeKB}KB';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr.fileLoaded} ($sizeText)'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      try {
        final result = await OpenFilex.open(localFile.path);
        if (!context.mounted) return;
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File downloaded but could not open: ${result.message}',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => OpenFilex.open(localFile.path),
              ),
            ),
          );
        }
      } catch (openError) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File downloaded but could not open: $openError'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      String errorMessage;
      if (e.toString().contains('404')) {
        errorMessage = 'File not found on server';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied to file';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Download timeout - file too large or slow connection';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network connection error';
      } else {
        errorMessage = '${context.tr.fileLoadFailed}: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () =>
                _downloadAndOpenFile(context, fileUrl, fileName, fileType),
          ),
        ),
      );
    }
  }

  String _getLoadingMessage(BuildContext context, String fileType) {
    switch (fileType) {
      case 'image':
        return 'Loading image...';
      case 'video':
        return 'Loading video...';
      case 'audio':
        return 'Loading audio...';
      case 'pdf':
        return 'Loading PDF...';
      case 'document':
        return 'Loading document...';
      case 'spreadsheet':
        return 'Loading spreadsheet...';
      case 'presentation':
        return 'Loading presentation...';
      case 'text':
        return 'Loading text file...';
      case 'archive':
        return 'Loading archive...';
      default:
        return context.tr.loadingFile;
    }
  }

  IconData _getViewActionIcon(String? url) {
    final category = _getFileTypeCategory(url);
    switch (category) {
      case 'image':
        return Icons.zoom_in;
      case 'video':
        return Icons.play_arrow;
      case 'audio':
        return Icons.play_arrow;
      case 'pdf':
        return Icons.open_in_new;
      case 'document':
      case 'spreadsheet':
      case 'presentation':
      case 'text':
        return Icons.open_in_new;
      case 'archive':
        return Icons.download;
      default:
        return Icons.open_in_new;
    }
  }

  String _getFileExtension(String? url) {
    if (url == null || url.trim().isEmpty) return 'file';

    final uri = Uri.tryParse(url.trim());
    if (uri != null) {
      final path = uri.path;
      final lastDotIndex = path.lastIndexOf('.');
      if (lastDotIndex != -1 && lastDotIndex < path.length - 1) {
        final extension = path.substring(lastDotIndex + 1).toLowerCase();
        switch (extension) {
          case 'jpeg':
            return 'jpg';
          case 'mpeg':
          case 'mp4v':
            return 'mp4';
          case 'tiff':
            return 'tif';
          case 'docm':
          case 'dotx':
          case 'dotm':
            return 'doc';
          case 'xlsm':
          case 'xlsx':
            return 'xls';
          case 'pptm':
          case 'pptx':
            return 'ppt';
          default:
            return extension;
        }
      }
    }
    return 'file';
  }

  String _getFileTypeCategory(String? url) {
    final extension = _getFileExtension(url);
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
      case 'tif':
      case 'svg':
        return 'image';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
      case 'webm':
      case 'wmv':
      case 'flv':
      case '3gp':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
        return 'audio';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
      case 'rtf':
        return 'document';
      case 'xls':
      case 'xlsx':
      case 'csv':
        return 'spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'presentation';
      case 'txt':
      case 'log':
        return 'text';
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return 'archive';
      default:
        return 'file';
    }
  }

  IconData _getFileIcon(String? url) {
    final category = _getFileTypeCategory(url);
    switch (category) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.play_circle_filled;
      case 'audio':
        return Icons.audiotrack;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'presentation':
        return Icons.slideshow;
      case 'text':
        return Icons.text_snippet;
      case 'archive':
        return Icons.archive;
      default:
        return Icons.attach_file;
    }
  }

  Color _getFileIconColor(String? url) {
    final category = _getFileTypeCategory(url);
    switch (category) {
      case 'image':
        return Colors.green;
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'pdf':
        return Colors.orange;
      case 'document':
        return Colors.blue;
      case 'spreadsheet':
        return Colors.teal;
      case 'presentation':
        return Colors.amber;
      case 'text':
        return Colors.grey;
      case 'archive':
        return Colors.brown;
      default:
        return AppConstants.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GrievanceProvider>(context);
    final isLoading = provider.isLoadingDetail;
    final detail = provider.grievanceDetail;
    final error = provider.detailError;

    return SafeArea(
      child: isLoading
          ? _buildComplaintDetailsShimmer()
          : error != null
          ? Center(child: Text(error))
          : detail == null
          ? Center(child: Text(context.tr.complaintNotFound))
          : WillPopScope(
              onWillPop: () async {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false,
                );
                return false;
              },
              child: Scaffold(
                body: RefreshIndicator(
                  onRefresh: () async {
                    final provider = Provider.of<GrievanceProvider>(
                      context,
                      listen: false,
                    );
                    await provider.fetchGrievanceDetail(widget.grievanceId);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                        _buildBreadcrumb(),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0b5394), Color(0xFF187bcd)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: const [
                              Text(
                                "தமிழ்நாடு குடிநீர் வடிகால் வாரியம்",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "TamilNadu Water Supply and Drainage Board",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 70),
                        _buildComplaintCard(context, detail),
                        const SizedBox(height: 20),
                        _buildTabbedContent(context, detail),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            context.tr.grievance,
            style: AppConstants.bodyTextStyle.copyWith(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            context.tr.grievanceStatus,
            style: AppConstants.bodyTextStyle.copyWith(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            context.tr.detailsview,
            style: AppConstants.bodyTextStyle.copyWith(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, GrievanceDetail detail) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 50, 18, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: ShaderMask(
                              shaderCallback: (bounds) =>
                                  LinearGradient(
                                    colors: [
                                      Color(0xFF4F46E5),
                                      Color(0xFF3B82F6),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(
                                    Rect.fromLTWH(
                                      0,
                                      0,
                                      bounds.width,
                                      bounds.height,
                                    ),
                                  ),
                              child: Text(
                                detail.complaintNo,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          StatusChip(
                            status: parseGrievanceStatus(
                              detail.complaintStatus,
                            ),
                            grievanceId: detail.id,
                            showReopenOption: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        context.tr.translate(detail.complaintSubType),
                        style: AppConstants.bodyTextStyle.copyWith(
                          fontSize: 14,
                          color: AppConstants.textPrimaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      _buildActionButtons(context, detail),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -40,
          left: 20,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/twad_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, GrievanceDetail detail) {
    final bool showFeedback = detail.complaintStatus.toLowerCase() == 'closed';
    for (var i = 0; i < detail.documents.length; i++) {}

    return Consumer<AcknowledgementProvider>(
      builder: (context, provider, _) {
        final isProcessing = provider.isDownloadProcessing(detail.id);
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () => _downloadAcknowledgement(context, detail.id),
                icon: isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.download, color: Colors.white),
                label: Text(
                  context.tr.acknowledgement,
                  style: AppConstants.buttonTextStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.acknowledgementButtonBg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (showFeedback)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_tabController != null) {
                      final bool hasAttachments = detail.fileLinks.isNotEmpty;
                      final tabIndex = hasAttachments ? 2 : 1;
                      _tabController!.animateTo(tabIndex);
                      _tabIndex.value = tabIndex;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        try {
                          Element? targetElement;
                          void visitor(Element element) {
                            if (element.widget is TabBarView) {
                              targetElement = element;
                              return;
                            }
                            element.visitChildren(visitor);
                          }

                          (context as Element).visitChildren(visitor);

                          if (targetElement != null) {
                            Scrollable.ensureVisible(
                              targetElement!,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Scrollable.ensureVisible(
                              context,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        } catch (_) {}
                      });
                    }
                  },
                  icon: const Icon(Icons.feedback, color: Colors.white),
                  label: Text(
                    context.tr.feedback,
                    style: AppConstants.buttonTextStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.grievanceText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTabbedContent(BuildContext context, GrievanceDetail detail) {
    final bool showFeedback = detail.complaintStatus.toLowerCase() == 'closed';

    if (_tabController == null) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _tabIndex,
        builder: (context, tabIndex, _) {
          return Column(
            children: [
              _buildComplainantInformation(context, detail),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppConstants.primaryColor,
                  unselectedLabelColor: AppConstants.textSecondaryColor,
                  indicatorColor: AppConstants.primaryColor,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: context.tr.complaintdetails),
                    if (detail.fileLinks.isNotEmpty)
                      Tab(text: context.tr.attachment),
                    if (showFeedback) Tab(text: context.tr.feedback),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(AppConstants.cardPadding),
                child: ValueListenableBuilder<int>(
                  valueListenable: _tabIndex,
                  builder: (context, currentTab, _) {
                    final hasAttachments = detail.fileLinks.isNotEmpty;
                    if (currentTab == 0) {
                      return _buildComplaintDetailsTab(context, detail);
                    }
                    if (hasAttachments && currentTab == 1) {
                      return _buildAttachmentsTab(context, detail);
                    }
                    if (showFeedback) {
                      final feedbackTabIndex = hasAttachments ? 2 : 1;
                      if (currentTab == feedbackTabIndex) {
                        return FeedbackForm(
                          grievanceId: detail.id,
                          isReopened: detail.isReopen == 1,
                        );
                      }
                    }

                    return _buildComplaintDetailsTab(context, detail);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttachmentsTab(BuildContext context, GrievanceDetail detail) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.fileLinks.isNotEmpty) ...[
            Text(
              context.tr.attachment,
              style: AppConstants.headingLG.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...detail.fileLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final fileUrl = entry.value;
              final potentialUrls = _buildPotentialFileUrls(fileUrl);

              final fileName =
                  'Attachment ${index + 1}.${_getFileExtension(fileUrl)}';

              return Column(
                children: [
                  GestureDetector(
                    onTap: () => _viewGrievanceFileWithFallback(
                      context,
                      potentialUrls,
                      fileName,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getFileIcon(fileUrl),
                            color: _getFileIconColor(fileUrl),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: AppConstants.bodyTextStyle.copyWith(
                                    color: _getFileIconColor(fileUrl),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getFileIconColor(
                                          fileUrl,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getFileExtension(
                                          fileUrl,
                                        ).toUpperCase(),
                                        style: AppConstants.bodyTextStyle
                                            .copyWith(
                                              color: _getFileIconColor(fileUrl),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _getViewActionIcon(fileUrl),
                            color: _getFileIconColor(fileUrl),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
          ] else ...[
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.attach_file_outlined,
                    size: 64,
                    color: AppConstants.textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No attachments available',
                    style: AppConstants.bodyTextStyle.copyWith(
                      color: AppConstants.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplaintDetailsTab(
    BuildContext context,
    GrievanceDetail detail,
  ) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.assignedToName != null &&
              detail.assignedToName!.isNotEmpty)
            GrievanceDetailRow(
              label: context.tr.assignedTo,
              value: context.tr.translate(detail.assignedToName!),
            ),
          const SizedBox(height: 10),
          GrievanceDetailRow(
            label: context.tr.complaint,
            value: context.tr.translate(detail.description),
          ),
          const SizedBox(height: 16),
          GrievanceDetailRow(
            label: context.tr.grievanceCardStatus,
            value: context.tr.translate(detail.complaintStatus),
          ),
          const SizedBox(height: 16),

          ...(() {
            final hasFilesWithNames = detail.processHistory.any(
              (doc) => doc.fileName != null && doc.fileName!.trim().isNotEmpty,
            );

            if (hasFilesWithNames) {
              return [
                const SizedBox(height: 8),
                Text(
                  context.tr.documents,
                  style: AppConstants.headingLG.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
              ];
            } else {
              return <Widget>[];
            }
          })(),

          Builder(
            builder: (context) {
              final dynamic filelink = detail.twadEmployeeFileLink;
              String? origin;
              if (detail.resolutionOrganisationId == 5) {
                if (filelink == null) {
                  origin = detail.originImage;
                } else if (filelink is String) {
                  origin = filelink;
                } else {
                  origin = detail.originImage;
                }
              } else {
                origin = detail.originImage;
              }
              if (origin == null) return const SizedBox.shrink();

              final trimmed = origin.trim();
              if (trimmed.isEmpty) return const SizedBox.shrink();

              final rawPath = trimmed;
              final cleanedPath = rawPath.startsWith('/')
                  ? rawPath.substring(1)
                  : rawPath;

              final fullUrl = cleanedPath.isNotEmpty
                  ? 'https://api.tanneer.com/uploads/$cleanedPath'
                  : '';

              final displayName = cleanedPath.isNotEmpty
                  ? cleanedPath.split('/').last
                  : 'Documents';

              final ext = _getFileExtension(fullUrl);
              final potentialUrls = fullUrl.isNotEmpty
                  ? _buildPotentialFileUrls(fullUrl)
                  : <String>[];

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(fullUrl),
                          color: _getFileIconColor(fullUrl),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: AppConstants.bodyTextStyle.copyWith(
                                  color: _getFileIconColor(fullUrl),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getFileIconColor(
                                        fullUrl,
                                      ).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      ext.toUpperCase(),
                                      style: AppConstants.bodyTextStyle
                                          .copyWith(
                                            color: _getFileIconColor(fullUrl),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Uploaded File",
                                      style: AppConstants.bodyTextStyle
                                          .copyWith(
                                            color:
                                                AppConstants.textSecondaryColor,
                                            fontSize: 13,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            _getViewActionIcon(fullUrl),
                            color: _getFileIconColor(fullUrl),
                            size: 18,
                          ),
                          tooltip: 'Preview',
                          onPressed: () => _viewGrievanceFileWithFallback(
                            context,
                            potentialUrls,
                            displayName,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          if (detail.processHistory.isNotEmpty &&
              detail.processHistory.first.notes != null &&
              detail.processHistory.first.notes!.trim().isNotEmpty)
            GrievanceDetailRow(
              label: context.tr.notes,
              value: detail.processHistory.first.notes!,
            ),

          if (detail.processHistory.isNotEmpty &&
              detail.processHistory.first.notes != null &&
              detail.processHistory.first.notes!.trim().isNotEmpty)
            const SizedBox(height: 16),

          if (detail.closedDate != null &&
              !(detail.isReopen == 1 &&
                  detail.complaintStatus.toLowerCase() != 'reopen'))
            GrievanceDetailRow(
              label: context.tr.closeddate,
              value: DateFormat(
                'dd-MM-yyyy hh:mm a',
              ).format(detail.closedDate!),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildComplainantInformation(
    BuildContext context,
    GrievanceDetail detail,
  ) {
    bool hasValue(String? value) => value != null && value.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr.complaintinformation,
              style: AppConstants.titleStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 20),
            GrievanceDetailRow(
              label: context.tr.grievanceCardComplaintno,
              value: detail.complaintNo,
              isHighlighted: true,
            ),
            const SizedBox(height: 16),
            GrievanceDetailRow(
              label: context.tr.date,
              value: DateFormat(
                'dd-MM-yyyy - hh:mm a',
              ).format(detail.complaintDateTime),
            ),
            const SizedBox(height: 16),
            GrievanceDetailRow(
              label: context.tr.nameLabel,
              value: context.tr.translate(detail.publicName),
            ),
            const SizedBox(height: 16),
            GrievanceDetailRow(
              label: context.tr.phnoLable,
              value: detail.publicContactNo,
            ),
            const SizedBox(height: 16),
            GrievanceDetailRow(
              label: context.tr.mailIdLabel,
              value: detail.publicEmailId,
            ),
            const SizedBox(height: 16),
            GrievanceDetailRow(
              label: context.tr.addressLabel,
              value: context.tr.translate(detail.publicAddress ?? 'N/A'),
            ),
            const SizedBox(height: 16),
            GrievanceDetailRow(
              label: context.tr.organizationLabel,
              value: context.tr.translate(detail.organisationName),
            ),
            const SizedBox(height: 16),
            if (hasValue(detail.districtName))
              GrievanceDetailRow(
                label: context.tr.gistrictLabel,
                value: context.tr.translate(detail.districtName),
              ),
            const SizedBox(height: 16),
            if (detail.organisationName.toLowerCase() == 'corporation') ...[
              if (hasValue(detail.zoneName))
                GrievanceDetailRow(
                  label: context.tr.zoneLabel,
                  value: context.tr.translate(detail.zoneName),
                ),
              if (hasValue(detail.zoneWardName)) const SizedBox(height: 16),
              if (detail.zoneWardName.isNotEmpty)
                GrievanceDetailRow(
                  label: context.tr.wardLabel,
                  value: context.tr.translate(detail.zoneWardName),
                ),
            ] else if (detail.organisationName.toLowerCase() ==
                'panchayat') ...[
              if (hasValue(detail.blockName)) const SizedBox(height: 16),
              GrievanceDetailRow(
                label: context.tr.blockLabel,
                value: context.tr.translate(detail.blockName),
              ),
              if (hasValue(detail.villageName)) const SizedBox(height: 16),
              GrievanceDetailRow(
                label: context.tr.villageLabel,
                value: context.tr.translate(detail.villageName),
              ),
              if (hasValue(detail.habitationName)) const SizedBox(height: 16),
              GrievanceDetailRow(
                label: context.tr.habbinationLabel,
                value: context.tr.translate(detail.habitationName),
              ),
            ] else if (detail.organisationName.toLowerCase() ==
                'municipality') ...[
              if (hasValue(detail.municipalityName)) const SizedBox(height: 16),
              GrievanceDetailRow(
                label: context.tr.municipalityLabel,
                value: context.tr.translate(detail.municipalityName),
              ),
              if (hasValue(detail.municipalityWardName))
                const SizedBox(height: 16),
              GrievanceDetailRow(
                label: context.tr.wardLabel,
                value: context.tr.translate(detail.municipalityWardName),
              ),
            ] else if (detail.organisationName.toLowerCase() ==
                'town panchayat') ...[
              if (hasValue(detail.townPanchayatName))
                const SizedBox(height: 16),
              GrievanceDetailRow(
                label: context.tr.townpanchayatLabel,
                value: context.tr.translate(detail.townPanchayatName),
              ),
              if (hasValue(detail.townPanchayatWardName))
                const SizedBox(height: 16),
              GrievanceDetailRow(
                label: context.tr.wardLabel,
                value: context.tr.translate(detail.townPanchayatWardName),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintDetailsShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildBreadcrumbShimmer(),
          const SizedBox(height: 20),
          const SizedBox(height: 70),
          _buildComplaintCardShimmer(),
          const SizedBox(height: 20),
          _buildTabbedContentShimmer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 16,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 16, color: Colors.grey[300]),
          const SizedBox(width: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCardShimmer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 50, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 28,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: double.infinity * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -40,
          left: 20,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabbedContentShimmer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 16,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRowShimmer(),
                const SizedBox(height: 16),
                _buildDetailRowShimmer(),
                const SizedBox(height: 16),
                _buildDetailRowShimmer(),
                const SizedBox(height: 16),
                _buildDetailRowShimmer(),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildComplainantInformationShimmer(),
        ],
      ),
    );
  }

  Widget _buildDetailRowShimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplainantInformationShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 20,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRowShimmer(),
            const SizedBox(height: 16),
            _buildDetailRowShimmer(),
            const SizedBox(height: 16),
            _buildDetailRowShimmer(),
            const SizedBox(height: 16),
            _buildDetailRowShimmer(),
            const SizedBox(height: 16),
            _buildDetailRowShimmer(),
            const SizedBox(height: 16),
            _buildDetailRowShimmer(),
          ],
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(i * size.width / 5, 0);
      path.quadraticBezierTo(
        (i + 0.5) * size.width / 5,
        size.height * 0.3,
        (i + 1) * size.width / 5,
        size.height,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ImageWithFallback extends StatefulWidget {
  final List<String> urls;
  final Widget Function() onAllFailed;

  const _ImageWithFallback({required this.urls, required this.onAllFailed});

  @override
  State<_ImageWithFallback> createState() => _ImageWithFallbackState();
}

class _ImageWithFallbackState extends State<_ImageWithFallback> {
  int currentUrlIndex = 0;
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    if (currentUrlIndex >= widget.urls.length) {
      return widget.onAllFailed();
    }

    final currentUrl = widget.urls[currentUrlIndex];
    return Image.network(
      currentUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading image... (${currentUrlIndex + 1}/${widget.urls.length})',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              currentUrlIndex++;
            });
          }
        });
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppConstants.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Trying alternative URL... (${currentUrlIndex + 1}/${widget.urls.length})',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PdfWithFallback extends StatefulWidget {
  final List<String> urls;
  final String fileName;
  final VoidCallback onAllFailed;

  const _PdfWithFallback({
    required this.urls,
    required this.fileName,
    required this.onAllFailed,
  });

  @override
  State<_PdfWithFallback> createState() => _PdfWithFallbackState();
}

class _PdfWithFallbackState extends State<_PdfWithFallback> {
  int currentUrlIndex = 0;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (currentUrlIndex >= widget.urls.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAllFailed();
      });
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'PDF not accessible from any source',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final currentUrl = widget.urls[currentUrlIndex];
    return Stack(
      children: [
        SfPdfViewer.network(
          currentUrl,
          onDocumentLoaded: (details) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onDocumentLoadFailed: (details) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && currentUrlIndex < widget.urls.length - 1) {
                setState(() {
                  currentUrlIndex++;
                  isLoading = true;
                });
              } else if (mounted) {
                widget.onAllFailed();
              }
            });
          },
        ),
        if (isLoading)
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppConstants.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading PDF... (${currentUrlIndex + 1}/${widget.urls.length})',
                    style: TextStyle(color: AppConstants.textSecondaryColor),
                  ),
                  if (currentUrlIndex > 0)
                    Text(
                      'Trying alternative source...',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
