import 'dart:async';

import 'realtime_service.dart';

/// Заглушка Supabase Realtime.
///
/// Компилируется и работает как локальная шина; интеграция с каналами
/// Supabase выполняется по задаче подключения бэкенда.
class SupabaseRealtimeService implements RealtimeService {
  SupabaseRealtimeService()
      : _controller = StreamController<RealtimeEvent>.broadcast();

  final StreamController<RealtimeEvent> _controller;
  final Set<String> _subscriptions = <String>{};

  @override
  Stream<RealtimeEvent> get events => _controller.stream;

  @override
  Set<String> get topics => Set<String>.unmodifiable(_subscriptions);

  @override
  void subscribe(String topic) {
    // TODO(A7): realtime.channel(topic).onBroadcast(...) -> emit(event).
    _subscriptions.add(topic);
  }

  @override
  void unsubscribe(String topic) {
    // TODO(A7): realtime.removeChannel(channel).
    _subscriptions.remove(topic);
  }

  @override
  void emit(RealtimeEvent event) {
    // TODO(A7): отправка через Supabase-канал; локально пробрасываем в шину.
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  @override
  Future<void> dispose() async {
    // TODO(A7): отключить все Supabase-каналы.
    await _controller.close();
  }
}
