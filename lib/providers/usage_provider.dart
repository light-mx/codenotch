import '../model/usage_model.dart';
import 'provider_glyph.dart';

abstract class UsageProvider {
  String get id;
  String get displayName;
  ProviderGlyph get glyph;

  Future<ProviderSnapshot> fetchSnapshot();
  ProviderAccount? account();
  Future<void> signOut() async {}
  void presentSignIn() {}
  void forgetCachedCredential() {}
}
