import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design_system/app_design_system.dart';
import '../../domain/models/client_document.dart';

class DocumentViewScreen extends StatelessWidget {
  final ClientDocument doc;

  const DocumentViewScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(doc.fileName,
            style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open externally',
            onPressed: () => launchUrl(Uri.parse(doc.fileUrl)),
          ),
        ],
      ),
      body: Center(
        child: doc.isImage
            ? InteractiveViewer(
                child: Image.network(
                  doc.fileUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, _, __) => _errorWidget(context, isDark),
                ),
              )
            : _filePreview(context, isDark),
      ),
    );
  }

  Widget _errorWidget(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.broken_image_rounded, size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        const SizedBox(height: 16),
        Text('Failed to load image',
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open in browser'),
          onPressed: () => launchUrl(Uri.parse(doc.fileUrl)),
        ),
      ],
    );
  }

  Widget _filePreview(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          doc.isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
          size: 80,
          color: doc.isPdf ? Colors.redAccent : Colors.blueAccent,
        ),
        const SizedBox(height: 16),
        Text(doc.fileName,
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(doc.fileSizeFormatted,
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open file'),
          onPressed: () => launchUrl(Uri.parse(doc.fileUrl)),
        ),
      ],
    );
  }
}
