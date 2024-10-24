import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sli_common/l10n/l10n.dart';
import 'package:sli_common/sli_common.dart';

class PermissionUtil {
  final BuildContext context;
  final PermissionType permission;
  final String titleDialogDined;
  final String descDialogDined;
  final Function() onGranted;

  static const Map<PermissionType, Permission> _mapPermissionAndroid = {
    PermissionType.photo: Permission.photos,
    PermissionType.camera: Permission.camera,
    PermissionType.location: Permission.location,
    PermissionType.call: Permission.phone,
    PermissionType.storage: Permission.storage,
    PermissionType.videos: Permission.videos,
  };

  static const Map<PermissionType, Permission> _mapPermissionIOS = {
    PermissionType.photo: Permission.photos,
    PermissionType.camera: Permission.camera,
    PermissionType.location: Permission.location,
    PermissionType.call: Permission.phone,
    PermissionType.storage: Permission.storage,
    PermissionType.videos: Permission.videos,
  };

  PermissionUtil(this.context,
      {required this.permission,
      this.titleDialogDined = '',
      this.descDialogDined = '',
      required this.onGranted});

  Future<void> checkPermission() async {
    Permission? androidPermission = _mapPermissionAndroid[permission];
    Permission? iosPermission = _mapPermissionIOS[permission];
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      int? androidVersion = int.tryParse(androidInfo.version.release);
      if (androidVersion != null && androidVersion < 13 && permission == PermissionType.photo) {
        androidPermission = _mapPermissionAndroid[PermissionType.storage];
      }
    }
    final status = Platform.isIOS
        ? await iosPermission?.request()
        : await androidPermission?.request();
    if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
      onGranted();
    } else if (status == PermissionStatus.denied) {
      Fluttertoast.showToast(msg: context.l10n.permissionDenied, toastLength: Toast.LENGTH_LONG);
    } else if (status == PermissionStatus.permanentlyDenied) {
      DialogUtil.confirm(context,
          title: titleDialogDined,
          content: descDialogDined,
          onTapSubmit: () => openAppSettings(),
          cancelText: context.l10n.cancel,
          submitText: context.l10n.setting);
    }
  }
}

enum PermissionType { photo, camera, location, call, storage, videos }
