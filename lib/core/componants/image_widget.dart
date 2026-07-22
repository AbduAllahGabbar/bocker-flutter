import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:boker/core/componants/shimmer_placeholder.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget.network(
    this.imageUrl, {
    super.key,
    this.fit,
    this.borderRadius = 0,
    this.width,
    this.height,
  });

  final String imageUrl;
  final BoxFit? fit;
  final double borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => ShimmerPlaceholder(
        width: double.infinity,
        height: double.infinity,
        borderRadius: borderRadius,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
    );
  }
}
