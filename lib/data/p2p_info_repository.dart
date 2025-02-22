import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/p2p_info.dart';

class P2pInfoRepository {
  late final SharedPreferences _db;

  Future<void> init() async {
    _db = await SharedPreferences.getInstance();
  }

  Future<void> saveP2pInfo(WifiP2PInfo data) async {
    await _db.setString('$runtimeType', jsonEncode(data.toJson()));
  }

  WifiP2PInfo? restoreP2pInfo() {
    final res = _db.getString('$runtimeType');
    global<Logger>().info('restore WifiP2PInfo => $res');
    return (res != null) ? P2pInfoEx.fromJson(jsonDecode(res)) : null;
  }
}
