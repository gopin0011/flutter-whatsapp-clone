import 'package:dio/dio.dart';

class EvolutionService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://domain-evolution-kamu.com',
    headers: {'apikey': 'API_KEY_KAMU'},
  ));

  // Fungsi untuk cek apakah instance sudah connect
  Future<bool> checkConnection(String instanceName) async {
    try {
      final response = await _dio.get('/instance/connectionState/$instanceName');
      return response.data['instance']['state'] == 'open';
    } catch (e) {
      return false;
    }
  }

  // Fungsi untuk kirim pesan (Pengganti Firestore.add)
  Future<void> sendMessage(String instanceName, String remoteJid, String text) async {
    await _dio.post('/message/sendText/$instanceName', data: {
      "number": remoteJid,
      "text": text,
    });
  }
}