import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImagesCarousel extends StatefulWidget {
  const ImagesCarousel({
    required this.allImages,
    required this.imageBuilder,
    this.height = 200.0,
    super.key,
  });

  final List<String> allImages;
  final double height;
  final Widget Function(String url) imageBuilder;

  @override
  State<ImagesCarousel> createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<ImagesCarousel> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final res = MyRes.of(context);

    if (widget.allImages.isEmpty) {
      return const SizedBox.shrink(); // or placeholder
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CarouselSlider.builder(
            itemCount: widget.allImages.length,
            itemBuilder: (context, index, realIndex) {
              final imageUrl = widget.allImages[index];
              return Hero(tag: imageUrl, child: widget.imageBuilder(imageUrl));
            },
            options: CarouselOptions(
              height: widget.height,
              viewportFraction: 1,
              enableInfiniteScroll: true,
              enlargeCenterPage: false,
              scrollPhysics: const BouncingScrollPhysics(),
              onPageChanged: (index, reason) {
                setState(() {
                  currentPage = index;
                });
              },
            ),
          ),
        ),
        Center(
          child: AnimatedSmoothIndicator(
            activeIndex: currentPage,
            count: widget.allImages.length,
            effect: ExpandingDotsEffect(
              expansionFactor: res.h(4),
              dotWidth: 8.h,
              dotHeight: 8.h,
              spacing: res.h(5),
              activeDotColor: theme.primaryColor,
              dotColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
