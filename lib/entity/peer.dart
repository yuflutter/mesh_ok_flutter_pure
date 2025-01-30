import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import 'peer_status.dart';
export 'peer_status.dart';

class Peer {
  String deviceName;
  String deviceAddress;
  PeerStatus status;
  String? primaryDeviceType;
  String? secondaryDeviceType;
  bool? isGroupOwner;

  Peer.fromDiscoveredPeer(DiscoveredPeers p)
      : deviceName = p.deviceName,
        deviceAddress = p.deviceAddress,
        status = PeerStatus.fromId(p.status),
        primaryDeviceType = p.primaryDeviceType,
        secondaryDeviceType = p.secondaryDeviceType,
        isGroupOwner = p.isGroupOwner;

  // Почему-то в пакете P2P пир и клиент - разные типы, хотя поля одинаковые.
  Peer.fromClient(Client p)
      : deviceName = p.deviceName,
        deviceAddress = p.deviceAddress,
        status = PeerStatus.fromId(p.status),
        primaryDeviceType = p.primaryDeviceType,
        secondaryDeviceType = p.secondaryDeviceType,
        isGroupOwner = p.isGroupOwner;
}
