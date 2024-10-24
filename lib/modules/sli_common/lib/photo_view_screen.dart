import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewScreen extends StatefulWidget {
  final List<String> arrUrlImg;
  final int indexSelected;
  final String title;
  final bool showAppbar;
  final Color? backgroundColor;
  final Color? backButtonColor;
  final Color? appbarBackgroundColor;
  final Function(String)? onTapDownload;

  const PhotoViewScreen({
    Key? key,
    required this.arrUrlImg,
    this.indexSelected = 0,
    this.title = '',
    this.showAppbar = true,
    this.backgroundColor,
    this.backButtonColor,
    this.appbarBackgroundColor,
    this.onTapDownload,
  }) : super(key: key);

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late PageController _pageController;
  late PhotoViewController photoViewController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.indexSelected);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      appBar: widget.showAppbar
          ? AppBar(
        elevation: 0,
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: widget.appbarBackgroundColor ?? Colors.transparent,
        actions: [
          if (widget.onTapDownload != null)
            IconButton(
              onPressed: () {
                if (widget.onTapDownload != null) {
                  String url = widget.arrUrlImg[currentIndex];
                  widget.onTapDownload!(url);
                }
              },
              icon: const Icon(Icons.download),
              splashRadius: 20.r,
            )
        ],
      )
          : null,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.arrUrlImg.length,
            onPageChanged: (index) => currentIndex = index,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  widget.arrUrlImg[index],
                ),
                minScale: PhotoViewComputedScale.contained * 1,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
            ),
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                value:
                event == null ? 0 : event.cumulativeBytesLoaded / event.cumulativeBytesLoaded,
              ),
            ),
          ),
          if (!widget.showAppbar)
            Positioned(
                top: MediaQuery.of(context).padding.top + 12.h,
                left: 12.w,
                child: BackButton(
                  color: widget.backButtonColor ?? Colors.black,
                )),
          if (!widget.showAppbar && widget.onTapDownload != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12.h,
              right: 12.w,
              child: IconButton(
                onPressed: () {
                  if (widget.onTapDownload != null) {
                    String url = widget.arrUrlImg[currentIndex];
                    widget.onTapDownload!(url);
                  }
                },
                icon: const Icon(Icons.download),
                color: widget.backButtonColor ?? Colors.black,
                splashRadius: 20.r,
              ),
            )
        ],
      ),
    );
  }
}
