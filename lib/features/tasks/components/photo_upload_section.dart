import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_style.dart';

/// Section header + camera/gallery buttons. Hidden when [canUpload] is false.
class PhotoUploadSection extends StatelessWidget {
  final bool canUpload;
  final Future<void> Function(ImageSource source) onUpload;

  const PhotoUploadSection({
    super.key,
    required this.canUpload,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Task Evidence',
            style: AppTextStyle.subheading.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (canUpload) ...[
          const SizedBox(width: 8),
          _btn(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            outlined: true,
            onTap: () => onUpload(ImageSource.gallery),
          ),
          const SizedBox(width: 8),
          _btn(
            icon: Icons.photo_camera_outlined,
            label: 'Camera',
            outlined: false,
            onTap: () => onUpload(ImageSource.camera),
          ),
        ],
      ],
    );
  }

  Widget _btn({
    required IconData icon,
    required String label,
    required bool outlined,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:        outlined ? Colors.transparent : AppColors.primaryBlue,
          border:       Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size:  16,
                color: outlined ? AppColors.primaryBlue : Colors.white),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: outlined ? AppColors.primaryBlue : Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}
