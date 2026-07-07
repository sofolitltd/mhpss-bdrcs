import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '/core/design_system/app_design_system.dart';
import '/core/services/cloudinary_service.dart';
import '/core/widgets/card_action_button.dart';
import '../../../data/document_repository.dart';
import '../../../domain/models/client_document.dart';
import '../../../domain/models/client.dart';
import '../../providers/document_providers.dart';

class DocsTab extends ConsumerStatefulWidget {
  final Client client;

  const DocsTab({super.key, required this.client});

  @override
  ConsumerState<DocsTab> createState() => _DocsTabState();
}

class _DocsTabState extends ConsumerState<DocsTab> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    if (_uploading) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final fileBytes = file.bytes;

      if (fileBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not read file')),
          );
        }
        return;
      }

      final cloudinary = CloudinaryService();
      final ext = file.name.split('.').last.toLowerCase();
      final mimeType = _mimeFromExtension(ext);

      setState(() => _uploading = true);

      final uploadResult = await cloudinary.uploadFile(fileBytes: fileBytes, fileName: file.name);

      final doc = ClientDocument(
        id: '',
        clientId: widget.client.id,
        sessionId: null,
        fileName: file.name,
        fileUrl: uploadResult.url,
        fileType: mimeType,
        fileSize: fileBytes.length,
        publicId: uploadResult.publicId,
        uploadedAt: DateTime.now(),
      );

      await ref.read(documentRepositoryProvider).addDocument(doc);
      ref.invalidate(clientDocumentsProvider(widget.client.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload complete'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.accent),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _mimeFromExtension(String ext) {
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'bmp' => 'image/bmp',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      _ => 'application/octet-stream',
    };
  }

  void _openDocument(ClientDocument doc) {
    context.push('/clients/${widget.client.id}/docs/view', extra: doc);
  }

  Future<void> _confirmDelete(ClientDocument doc) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : null,
        title: Text('Delete Document',
          style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        content: Text('Delete "${doc.fileName}"?',
          style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(documentRepositoryProvider).deleteDocument(doc.id, doc.publicId);
      ref.invalidate(clientDocumentsProvider(widget.client.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        ref.watch(clientDocumentsProvider(widget.client.id)).when(
          data: (docs) {
            if (docs.isEmpty) {
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 64,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        const SizedBox(height: AppSpacing.md),
                        Text('No documents yet',
                          style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Tap + to upload', style: TextStyle(fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: FloatingActionButton.extended(
                      onPressed: _pickAndUpload,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text('Upload'),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: _responsiveColumns(context),
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final ext = doc.fileName.split('.').last.toLowerCase();
                          final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
                          Color iconColor;
                          IconData iconData;
                          if (doc.fileType.startsWith('image/') || isImage) {
                            iconColor = AppColors.primary;
                            iconData = Icons.image_rounded;
                          } else if (doc.fileType == 'application/pdf') {
                            iconColor = Colors.redAccent;
                            iconData = Icons.picture_as_pdf_rounded;
                          } else if (doc.fileType.contains('document')) {
                            iconColor = Colors.blueAccent;
                            iconData = Icons.description_rounded;
                          } else {
                            iconColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
                            iconData = Icons.insert_drive_file_rounded;
                          }
                          return InkWell(
                            onTap: (doc.isImage || doc.isPdf) ? () => _openDocument(doc) : null,
                            borderRadius: AppRadius.roundedMd,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                                borderRadius: AppRadius.roundedMd,
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.border,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.cardShadow,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(iconData, size: 40, color: iconColor),
                                      const Spacer(),
                                      if (doc.sessionId != null)
                                        Icon(Icons.link_rounded, size: 14,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    doc.fileName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    doc.fileSizeFormatted,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    spacing: 4,
                                    children: [
                                      const Spacer(),
                                      if (doc.isImage || doc.isPdf)
                                        CardActionButton(
                                          icon: Icons.visibility_outlined,
                                          onTap: () => _openDocument(doc),
                                        ),
                                      CardActionButton(
                                        icon: Icons.delete_outline,
                                        color: Colors.red,
                                        onTap: () => _confirmDelete(doc),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: FloatingActionButton.extended(
                    onPressed: _pickAndUpload,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text('Upload'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.accent))),
        ),
        if (_uploading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  int _responsiveColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= AppBreakpoints.lg) return 4;
    if (w >= AppBreakpoints.sm) return 3;
    return 2;
  }
}
