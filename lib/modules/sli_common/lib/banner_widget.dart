import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sli_common/sli_common.dart';

class BannerWidget extends StatefulWidget {
  final List<String> urls;
  final double? height;
  final Color? activeColor;
  final Color? unActiveColor;
  final PageController? pageController;
  final double viewportFraction;
  final ScrollPhysics? physics;
  final ValueChanged<int>? onChange;
  final Duration? duration;
  final double? radius;
  final bool keepPage;
  final Function(int)? onTap;
  final Widget? errorWidget;
  final BoxFit? fit;

  const BannerWidget({
    Key? key,
    required this.urls,
    this.height,
    this.activeColor,
    this.unActiveColor,
    this.pageController,
    this.viewportFraction = 1,
    this.physics,
    this.onChange,
    this.duration,
    this.radius,
    this.keepPage = true,
    this.onTap,
    this.errorWidget,
    this.fit,
  }) : super(key: key);

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  PageController? pageController;
  Timer? timer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = widget.pageController ??
        PageController(viewportFraction: widget.viewportFraction, keepPage: widget.keepPage);
    timer = widget.duration != null
        ? Timer.periodic(widget.duration!, (timer) {
            if (widget.urls.isNotEmpty) {
              setState(() {
                if (currentIndex == widget.urls.length - 1) {
                  currentIndex = 0;
                } else {
                  currentIndex++;
                }
              });
              pageController?.animateToPage(currentIndex.toInt(),
                  duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            }
          })
        : null;
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 110.0.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          InkWell(
            onTap: widget.onTap == null
                ? null
                : () {
                    if (widget.onTap != null) {
                      widget.onTap!(currentIndex);
                    }
                  },
            child: PageView.builder(
              controller: pageController,
              physics: widget.physics,
              onPageChanged: (index) {
                if (widget.onChange != null) {
                  widget.onChange!(index);
                }
                setState(() {
                  currentIndex = index;
                });
              },
              scrollDirection: Axis.horizontal,
              itemCount: widget.urls.length,
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius ?? 8.0.r),
                child: CachedNetworkImage(
                  imageUrl: widget.urls[index],
                  placeholder: (context, url) => const ImageLoading(),
                  fit: widget.fit ?? BoxFit.cover,
                  errorWidget: (context, url, error) => widget.errorWidget ?? const SizedBox(),
                ),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            Padding(
              padding: EdgeInsets.all(8.0.w),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DotsIndicator(
                    dotsCount: widget.urls.length,
                    position: currentIndex.toDouble(),
                    onTap: (index) => pageController?.animateToPage(index.toInt(),
                        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                    decorator: DotsDecorator(
                      animationDuration: const Duration(milliseconds: 400),
                      color: widget.unActiveColor ?? Colors.white.withOpacity(0.5),
                      activeColor: widget.activeColor ?? const Color(0xFFF35A49),
                      size: Size.square(9.0.w),
                      activeSize: Size(18.0.w, 9.0.h),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0.r),
                      ),
                    )),
              ),
            )
        ],
      ),
    );
  }
}
