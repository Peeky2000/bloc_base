import 'package:mOrder/domain/entities/auth/token_auth.dart';

abstract class TokenWrapper {
  TokenAuth? get access;

  TokenAuth? get refresh;
}
