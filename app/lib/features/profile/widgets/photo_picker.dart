import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/index.dart';
import '../../../core/utils/image_utils.dart';

/// Выбор фото профиля: галерея или камера.
///
/// Фото кодируется в data URI ([encodeImageToDataUri]) и отдаётся наружу
/// через [onPicked]; родитель сохраняет его в `Profile.photoUrl`.
/// Работает на web: `image_picker` возвращает [XFile], а `readAsBytes`
/// доступен на всех платформах.
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.photoDataUri,
    required this.onPicked,
    this.height = 120,
  });

  /// Текущее фото (data URI) или `null`, если фото ещё нет.
  final String? photoDataUri;

  /// Вызывается с data URI выбранного изображения.
  final ValueChanged<String> onPicked;

  /// Высота области предпросмотра.
  final double height;

  Future<void> _pick(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final Uint8List bytes = await file.readAsBytes();
    onPicked(encodeImageToDataUri(bytes));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Uint8List? bytes = decodeDataUri(photoDataUri);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () => _pick(ImageSource.gallery),
          child: Container(
            height: height,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : const Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            TextButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Галерея'),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => _pick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text('Камера'),
            ),
          ],
        ),
      ],
    );
  }
}
