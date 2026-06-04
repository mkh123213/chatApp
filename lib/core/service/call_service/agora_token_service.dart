import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class AgoraTokenService {
  Future<String> generateToken({
    required String channelName,
    required int uid,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'agora-token',
      body: {
        'channelName': channelName,
        'uid': uid,
        'role': 'publisher',
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to generate Agora token: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return data['token'] as String;
  }
}
