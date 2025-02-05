import 'package:flutter/material.dart';
import 'package:mOrder/core/common/enum.dart';
import 'package:mOrder/domain/repositories/app_repo.dart';

class AppUseCase {
  final AppRepo _appRepo;

  AppUseCase(this._appRepo);

  Locale getSavedLocale() {
    return _appRepo.getSavedLocale();
  }

  AppLanguage getSavedAppLanguage() {
    return _appRepo.getSavedLanguage();
  }

  Future<void> saveLanguage({required AppLanguage language}) {
    return _appRepo.saveLanguage(language: language);
  }
}
