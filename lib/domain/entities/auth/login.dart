import 'package:mOrder/domain/entities/auth/token_wrapper.dart';
import 'package:mOrder/domain/entities/profile/account.dart';

abstract class Login {
  Account? get account;

  TokenWrapper? get token;
}
