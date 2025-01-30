import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class P2pInfoRepository {
  late SharedPreferences _db;

  Future<void> init() async {
    _db = await SharedPreferences.getInstance();
  }

  Future<void> setP2pInfo(WifiP2PInfo data) async {
    await _db.setString('$runtimeType', jsonEncode(data));
  }

  WifiP2PInfo? getP2pInfo() {
    final res = _db.getString('$runtimeType');
    return (res != null) ? jsonDecode(res) : null;
  }
}
