import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/oauth_config.dart';
import '../../presentation/providers/oauth_providers.dart';

/// Service to handle OAuth flow initiation and URL launching.
class OAuthLauncherService {
  final Ref ref;

  OAuthLauncherService(this.ref);

  /// Initiates OAuth flow for a server and launches the authorization URL.
  Future<bool> initiateOAuth(OAuthConfig config, String serverId) async {
    try {
      // Add server_id to the redirect URI for callback handling
      final updatedConfig = config.copyWith(
        redirectUri: '${config.redirectUri}?server_id=$serverId',
      );

      // Initiate OAuth flow and get authorization URL
      final authUrl = await ref.read(oauthProvider.notifier).initiateOAuth(updatedConfig);

      // Launch the authorization URL
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch authorization URL');
      }
    } catch (e) {
      ref.read(oauthProvider.notifier).setError(e.toString());
      return false;
    }
  }
}

final oauthLauncherServiceProvider = Provider<OAuthLauncherService>((ref) {
  return OAuthLauncherService(ref);
});
