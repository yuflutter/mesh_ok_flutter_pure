import '/core/global.dart';
import '/core/logger.dart';

/// Выполняет асинхронную функцию, и логирует её результат (do with log)
Future<T> dowl<T>(String msg, Future<T> Function() func) async {
  final res = await func();
  _log(msg, res);
  return res;
}

/// Выполняет синхронную функцию, и логирует её результат (do with log)
T dowls<T>(String msg, T Function() func) {
  final res = func();
  _log(msg, res);
  return res;
}

void _log(String msg, dynamic res) {
  final logger = global<Logger>();
  final ress = res.toString();
  // Неудача возвращается как false, это лишь особенность wifi-direct реализации
  if (res == false || ress.endsWith('denied') || ress.endsWith('null')) {
    logger.warn('$msg => $res');
  } else {
    logger.info('$msg => $res');
  }
}
