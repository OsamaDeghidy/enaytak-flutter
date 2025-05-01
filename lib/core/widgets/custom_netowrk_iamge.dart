import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final double? borderRadius;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width ?? 75,
        height: height ?? 85,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => Center(
          child: LoadingAnimationWidget.twistingDots(
            rightDotColor: Constant.primaryColor,
            leftDotColor: Constant.secondaryColor,
            size: 30,
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: SvgPicture.asset(
            'assets/images/nt_found_iamge.svg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
