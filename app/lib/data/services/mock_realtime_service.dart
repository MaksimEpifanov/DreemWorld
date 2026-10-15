import 'dart:async';

import 'realtime_service.dart';

/// Мок-реалтайм: broadcast-контроллер в памяти.
///
/// Эмулирует мгновенную синхронизацию между экранами без сети.
class MockRealtimeService implements RealtimeService {
  MockRealtimeService()
    : _controller = StreamController<RealtimeEvent>.broadcast();

  final StreamController<RealtimeEvent> _controller;
  final Set<String> _subscriptions = <String>{};

  @override
  Stream<RealtimeEvent> get events => _controller.stream;

  @override
  Set<String> get topics => Set<String>.unmodifiable(_subscriptions);

  @override
  void subscribe(String topic) {
    _subscriptions.add(topic);
  }

  @override
  void unsubscribe(String topic) {
    _subscriptions.remove(topic);
  }

  @override
  void emit(RealtimeEvent event) {
    if (_controller.isClosed) return;
    if (_subscriptions.isNotEmpty && !_subscriptions.contains(event.topic)) {
      return;
    }
    _controller.add(event);
  }

  @override
  Future<void> dispose() => _controller.close();
}
