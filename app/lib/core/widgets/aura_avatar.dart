import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/image_utils.dart';

class AuraAvatar extends StatelessWidget {
  const AuraAvatar({
    super.key,
    this.photoUrl,
    this.size = 64,
    this.borderWidth = 2,
    this.fallbackText,
    this.fallbackIcon,
  });

  final String? photoUrl;
  final double size;
  final double borderWidth;
  final String? fallbackText;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color secondary = Theme.of(context).colorScheme.secondary;

    Widget avatar = _buildAvatar();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primary.withValues(alpha: 0.6),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.05,
          ),
          BoxShadow(
            color: secondary.withValues(alpha: 0.3),
            blurRadius: size * 0.7,
            spreadRadius: size * 0.08,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            primary,
            secondary,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: borderWidth),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipOval(child: avatar),
    );
  }

  Widget _buildAvatar() {
    final Uint8List? bytes = decodeDataUri(photoUrl);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: size,
        height: size,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    if (photoUrl != null && photoUrl!.startsWith('http')) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if (fallbackIcon != null) {
      return Container(
        color: Colors.black.withValues(alpha: 0.3),
        alignment: Alignment.center,
        child: Icon(
          fallbackIcon,
          size: size * 0.4,
          color: Colors.white,
        ),
      );
    }
    final String text = fallbackText != null && fallbackText!.isNotEmpty
        ? fallbackText!.substring(0, 1).toUpperCase()
        : '?';
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
