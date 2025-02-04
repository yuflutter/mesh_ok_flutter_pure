import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import '/core/global.dart';
import '/core/logger.dart';
import '/entity/peer.dart';
import '/entity/p2p_info.dart';
import '/entity/p2p_group_info.dart';
import '/entity/socket_status.dart';
import '/data/p2p_info_repository.dart';
import 'p2p_connector_state.dart';
import 'socket_cubit.dart';
import 'dowl.dart';

class P2pConnectorCubit extends Cubit<P2pConnectorState> with WidgetsBindingObserver {
  final P2pInfoRepository repository;

  final _conn = FlutterP2pConnection();
  StreamSubscription? _peersSubscription;
  StreamSubscription? _p2pInfoSubscription;

  P2pConnectorCubit({required this.repository}) : super(P2pConnectorState.initial());

  Future<void> init() async {
    final logger = global<Logger>();
    try {
      // Нет способа получить из сети текущее состояние p2p, поэтому сохраняем его локально,
      // и восстанавливаем при старте приложения.
      await repository.init();
      emit(state.copyWith(p2pInfo: repository.restoreP2pInfo()));

      await dowl('Permission.location.request()', Permission.location.request);
      // Почему-то это не срабатывает, но как оказалось - и не нужно.
      // await dowl('Permission.nearbyWifiDevices.request()', Permission.nearbyWifiDevices.request);
      // await dowl('askConnectionPermissions()', _conn.askConnectionPermissions);

      if (!await _conn.checkWifiEnabled()) {
        await dowl('enableWifiServices()', _conn.enableWifiServices);
      }
      if (!await _conn.checkLocationEnabled()) {
        await dowl('enableLocationServices()', _conn.enableLocationServices);
      }

      // TODO: Вставить проверку, что всё разрешено и включено, или кинуть userError

      await dowl('initialize()', _conn.initialize);
      await dowl('register()', _conn.register);

      _peersSubscription = _conn.streamPeers().listen(_onPeersDetected);
      _p2pInfoSubscription = _conn.streamWifiP2PInfo().listen(_onP2pInfoChanged);

      await refreshAll();

      if (state.p2pInfo?.isConnected == true) {
        tryToOpenSocket();
      }

      WidgetsBinding.instance.addObserver(this);
    } catch (e, s) {
      logger.error('$runtimeType', e, s);
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      _discoverPeers(),
      _getGroupInfo(),
    ]);
  }

  Future<void> _discoverPeers() async {
    await dowl('discover()', _conn.discover);
  }

  Future<void> _getGroupInfo() async {
    final groupInfo = await _conn.groupInfo();
    global<Logger>().info('groupInfo() => ${groupInfo?.toJson()}');
    emit(state.copyWith(p2pGroupInfo: groupInfo));
  }

  Future<void> connectPeer(Peer peer) async {
    await dowl('connect(${peer.deviceName})', () => _conn.connect(peer.deviceAddress));
    _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  Future<void> disconnectFromGroup() async {
    await dowl('disconnect()', _conn.disconnect);
    _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  Future<void> removeGroup() async {
    await dowl('removeGroup()', _conn.removeGroup);
    _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
  }

  void _onPeersDetected(List<DiscoveredPeers> peers) {
    final logger = global<Logger>();
    try {
      logger.info('peers: ${peers.length}');
      emit(state.copyWith(
        peers: peers.map((p) => Peer.fromDiscoveredPeer(p)).toList(),
      ));
    } catch (e, s) {
      logger.error('$runtimeType', e, s);
    }
  }

  void _onP2pInfoChanged(WifiP2PInfo p2pInfo) async {
    final logger = global<Logger>();
    try {
      logger.info(p2pInfo.toJson());
      emit(state.copyWith(p2pInfo: p2pInfo));

      if (state.p2pInfo?.isConnected == true) {
        tryToOpenSocket();
      }

      await repository.saveP2pInfo(p2pInfo); // сохраняем для следующего запуска
      _discoverPeers(); // андроид прекратил поиск пиров, возобновляем
    } catch (e, s) {
      logger.error('$runtimeType', e, s);
    }
  }

  void tryToOpenSocket() async {
    if (state.p2pInfo?.isConnected != true) return;
    _conn.closeSocket(notify: false);
    final socketCubit = SocketCubit(p2pInfo: state.p2pInfo!);
    socketCubit
      ..init()
      ..socketStatusStream.listen((socketStatus) {
        emit(state.copyWith(
          socketStatus: socketStatus,
          justConnectedSocket: (socketStatus == SocketStatus.connected) ? socketCubit : null,
        ));
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final logger = global<Logger>();
    logger.info(state);
    if (state == AppLifecycleState.paused) {
      // await dowl('unregister()', _conn.unregister);
    } else if (state == AppLifecycleState.resumed) {
      await dowl('register()', _conn.register);
      await refreshAll();
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _peersSubscription?.cancel();
    _p2pInfoSubscription?.cancel();
    _conn.unregister();
    return super.close();
  }
}
