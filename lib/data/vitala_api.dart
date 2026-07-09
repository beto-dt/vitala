import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

const _baseUrl = 'https://us-central1-vitala-demo.cloudfunctions.net';

class RtcCredentials {
  final String appId;
  final String channel;
  final int uid;
  final String token;
  RtcCredentials({required this.appId, required this.channel, required this.uid, required this.token});
}

class RoomNotFoundException implements Exception {}

class VitalaApi {
  /// Creates a room and returns its code (VIT-XXXX).
  Future<String> createRoom() async {
    final res = await http.post(Uri.parse('$_baseUrl/createRoom'));
    if (res.statusCode != 200) throw Exception('createRoom ${res.statusCode}');
    return (jsonDecode(res.body) as Map<String, dynamic>)['code'] as String;
  }

  /// Fetches a signed RTC token for [code] with a random uid.
  Future<RtcCredentials> getToken(String code) async {
    final uid = Random().nextInt(999998) + 1;
    final res = await http.post(
      Uri.parse('$_baseUrl/getRtcToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code, 'uid': uid}),
    );
    if (res.statusCode == 404) throw RoomNotFoundException();
    if (res.statusCode != 200) throw Exception('getRtcToken ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return RtcCredentials(
      appId: data['appId'] as String,
      channel: data['channel'] as String,
      uid: data['uid'] as int,
      token: data['token'] as String,
    );
  }
}
