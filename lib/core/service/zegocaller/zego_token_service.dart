// OPTIONAL: Only needed if your ZegoCloud project uses "Token authentication".
// With AppSign auth (the default in ZegoCallProviderService) you do NOT need this.
// Mirrors AgoraTokenService: calls a Supabase Edge Function that signs a Zego token.
import 'package:supabase_flutter/supabase_flutter.dart';

class ZegoTokenService {
  Future<String> generateToken({
    required String userId,
    int effectiveTimeInSeconds = 3600,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'zego-token',
      body: {
        'userId': userId,
        'effectiveTimeInSeconds': effectiveTimeInSeconds,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to generate Zego token: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return data['token'] as String;
  }
}
