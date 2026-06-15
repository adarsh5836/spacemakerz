import 'dart:io';
import 'package:flutter/material.dart';
import '../../../app/models/task_photo_model.dart';
import '../../../core/storage/local_storage.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';
import '../../../core/enums/app_enums.dart';

/// 2-column grid of uploaded task photos with delete & full-screen support.
class UploadedPhotoGrid extends StatelessWidget {
  final List<TaskPhotoModel> photos;
  final LocalStorage session;
  final TaskStatus taskStatus;
  final VoidCallback? onAddPhoto; // null → hide add button
  final Future<void> Function(String photoId)? onDelete;

  const UploadedPhotoGrid({
    super.key,
    required this.photos,
    required this.session,
    required this.taskStatus,
    this.onAddPhoto,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final items = [...photos];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: onAddPhoto != null ? items.length + 1 : items.length,
      itemBuilder: (context, i) {
        if (onAddPhoto != null && i == items.length) {
          return _addPhotoTile();
        }
        return _photoTile(context, items[i]);
      },
    );
  }

  Widget _photoTile(BuildContext context, TaskPhotoModel photo) {
    final file = File(photo.localPath);
    final canDelete = _canDelete(photo);

    return GestureDetector(
      onTap: () => _showFullScreen(context, photo.localPath),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: file.existsSync()
                ? Image.file(file, fit: BoxFit.cover)
                : Container(
                    color: AppColors.backgroundLight,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          // Gradient overlay + info
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 10,
            right: 10,
            child: Text(
              photo.uploadedByRole.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Delete or Share button (role-gated)
          if (canDelete)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _confirmDelete(context, photo.id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            )
          else if (session.currentRole == UserRole.manager ||
              session.currentRole == UserRole.superAdmin)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon!'),
                    ),
                  );
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _addPhotoTile() {
    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo,
              color: AppColors.textSecondary,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(
              'Add Photo',
              style: AppTextStyle.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canDelete(TaskPhotoModel photo) {
    if (onDelete == null) return false;

    // Status check: if rejected or completed, cannot delete
    if (taskStatus == TaskStatus.rejected ||
        taskStatus == TaskStatus.completed) {
      return false;
    }

    final id = session.currentUserId ?? '';
    final role = session.currentRole;

    // Manager and SuperAdmin can only view/share, not delete
    if (role == UserRole.superAdmin) {
      return false;
    }

    // Uploader can delete their own photo (dealer or user)
    return photo.uploadedById == id;
  }

  void _confirmDelete(BuildContext context, String photoId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This photo will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call(photoId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImage(path: path),
        fullscreenDialog: true,
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String path;
  const _FullScreenImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.white, size: 60),
          ),
        ),
      ),
    );
  }
}
