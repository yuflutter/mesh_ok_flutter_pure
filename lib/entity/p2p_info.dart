import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import 'device_role.dart';
export 'device_role.dart';

extension P2pInfoEx on WifiP2PInfo {
  Map<String, dynamic> toJson() => {
        'deviceRole': deviceRole.name,
        'groupOwnerAddress': groupOwnerAddress,
        'groupFormed': groupFormed,
        'isGroupOwner': isGroupOwner,
        'isConnected': isConnected,
        'clients': clients.map((e) => e.deviceName).toList(),
      };

  DeviceRole get deviceRole => (isGroupOwner) ? DeviceRole.host : DeviceRole.client;
}
