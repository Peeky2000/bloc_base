import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sli_common/sli_common.dart';

enum MultiImageType { image, video, common }

class MultiImagePicker {
  void selectImage(
    BuildContext context, {
    List<File> imagesSelected = const [],
    int? limit,
    required Function(List<File>) onSelected,
    MultiImageType type = MultiImageType.image,
  }) {
    Map<MultiImageType, RequestType> map = {
      MultiImageType.image: RequestType.image,
      MultiImageType.video: RequestType.video,
      MultiImageType.common: RequestType.common,
    };
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => _MultiImagePickerScreen(
              imagesSelected: imagesSelected,
              limit: limit,
              onSelected: onSelected,
              type: map[type] ?? RequestType.image,
            )));
  }
}

class _MultiImagePickerScreen extends StatefulWidget {
  final List<File> imagesSelected;
  final int? limit;
  final Function(List<File>) onSelected;
  final RequestType type;

  const _MultiImagePickerScreen({
    Key? key,
    this.imagesSelected = const [],
    this.limit,
    required this.onSelected,
    this.type = RequestType.image,
  }) : super(key: key);

  @override
  State<_MultiImagePickerScreen> createState() => _MultiImagePickerScreenState();
}

class _MultiImagePickerScreenState extends State<_MultiImagePickerScreen> {
  List<File> imagesSelected = [];
  List<AssetEntity> assets = [];
  List<File> assetsFile = [];
  StreamController numberSelected = StreamController<int>();

  Stream get numberSelectedStream => numberSelected.stream;

  @override
  void initState() {
    super.initState();
    imagesSelected.addAll(widget.imagesSelected);
    numberSelected.sink.add(widget.imagesSelected.length);
    _getAllImage();
  }

  @override
  void dispose() {
    numberSelected.close();
    super.dispose();
  }

  Future<void> _getAllImage() async {
    final albums = await PhotoManager.getAssetPathList(onlyAll: true, type: widget.type);
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000000,
    );
    for (int i = 0; i < recentAssets.length; i++) {
      File? file = await recentAssets[i].file;
      if (file != null) {
        assetsFile.add(File(file.path));
      }
    }
    setState(() {
      assets = recentAssets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: StreamBuilder(
        stream: numberSelectedStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int number = (snapshot.data as int?) ?? 0;
            return number > 0
                ? Stack(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          widget.onSelected(imagesSelected);
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.add,
                          size: 32.0,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 22.0,
                          width: 22.0,
                          decoration:
                              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '$number',
                              style: const TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            bool isSelected = imagesSelected
                .where((element) => assetsFile[index].path == element.path)
                .isNotEmpty;
            return GestureDetector(
              onTap: () {
                if ((widget.limit != null &&
                        imagesSelected.length < widget.limit! &&
                        !isSelected) ||
                    (widget.limit == null && !isSelected)) {
                  setState(() {
                    imagesSelected.add(assetsFile[index]);
                  });
                  numberSelected.sink.add(imagesSelected.length);
                } else if (isSelected) {
                  setState(() {
                    imagesSelected.removeWhere((element) => element.path == assetsFile[index].path);
                  });
                  numberSelected.sink.add(imagesSelected.length);
                }
              },
              child: Stack(
                children: [
                  AssetThumbnail(
                    multiModel: assets[index],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.only(top: 5.0, right: 5.0),
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2.2)),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key? key,
    required this.multiModel,
  }) : super(key: key);

  final AssetEntity multiModel;

  String printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: multiModel.thumbnailData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const ImageLoading();
        }
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover)),
          child: multiModel.type == AssetType.video ? Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0, bottom: 5.0),
              child: Text(
                printDuration(multiModel.videoDuration),
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ) : null,
        );
      },
    );
  }
}
