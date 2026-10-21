import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../wallet/wallet_controller.dart';

/// Мемори: найдите все пары карточек.
///
/// Награда зависит от числа ходов; действует дневной лимит заработка.
class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  static const List<String> _emojis = <String>[
    '🌙', '⭐', '🚀', '🪐', '☄️', '🌌', '👾', '🛸',
  ];

  late List<String> _cards;
  late List<bool> _matched;
  int? _firstIndex;
  int? _secondIndex;
  int _moves = 0;
  bool _busy = false;
  bool _finished = false;
  int _credited = 0;
  bool _limitReached = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    final List<String> pairs = <String>[..._emojis, ..._emojis]
      ..shuffle(Random());
    _cards = pairs;
    _matched = List<bool>.filled(_cards.length, false);
    _firstIndex = null;
    _secondIndex = null;
    _moves = 0;
    _busy = false;
    _finished = false;
    _credited = 0;
    _limitReached = false;
  }

  Future<void> _tap(int index) async {
    if (_busy || _finished || _matched[index] || index == _firstIndex) return;
    setState(() {
      if (_firstIndex == null) {
        _firstIndex = index;
      } else {
        _secondIndex = index;
        _moves++;
      }
    });

    if (_firstIndex != null && _secondIndex != null) {
      _busy = true;
      final int a = _firstIndex!;
      final int b = _secondIndex!;
      if (_cards[a] == _cards[b]) {
        setState(() {
          _matched[a] = true;
          _matched[b] = true;
          _firstIndex = null;
          _secondIndex = null;
          _busy = false;
        });
        if (_matched.every((bool m) => m)) {
          await _finish();
        }
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        setState(() {
          _firstIndex = null;
          _secondIndex = null;
          _busy = false;
        });
      }
    }
  }

  Future<void> _finish() async {
    // Чем меньше ходов, тем больше награда.
    final int base = 60 - (_moves - 8) * 3;
    final int reward = base < 10 ? 10 : base;
    final int credited = await ref
        .read(walletProvider.notifier)
        .rewardFromGame(reward);
    if (!mounted) return;
    setState(() {
      _finished = true;
      _credited = credited;
      _limitReached = credited < reward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeonAppBar(
        title: 'Мемори',
        leading: BackButton(onPressed: () => context.go('/minigames')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: AppSpacing.page,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Ходы: $_moves', style: AppTextStyles.bodyBold()),
                    const Spacer(),
                    Text(
                      'Пар найдено: ${_matched.where((bool m) => m).length ~/ 2} / ${_emojis.length}',
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _buildGrid()),
                if (_finished) _buildResult(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final int columns = _cards.length <= 12 ? 3 : 4;
    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      shrinkWrap: true,
      children: <Widget>[
        for (int i = 0; i < _cards.length; i++)
          _MemoryCard(
            emoji: _cards[i],
            faceUp: _matched[i] || i == _firstIndex || i == _secondIndex,
            matched: _matched[i],
            onTap: () => _tap(i),
          ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Все пары найдены!', style: AppTextStyles.title()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Начислено: +$_credited монет',
            style: AppTextStyles.bodyBold(color: scheme.tertiary),
          ),
          if (_limitReached) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Дневной лимит заработка достигнут',
              style: AppTextStyles.caption(color: AppColors.warning),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: NeonButton(
                  label: 'Ещё раз',
                  icon: Icons.replay_rounded,
                  onPressed: () => setState(_reset),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: NeonButton(
                  label: 'К играм',
                  variant: NeonButtonVariant.outlined,
                  onPressed: () => context.go('/minigames'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.emoji,
    required this.faceUp,
    required this.matched,
    required this.onTap,
  });

  final String emoji;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AnimatedPress(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: faceUp
              ? (matched
                  ? scheme.primary.withValues(alpha: 0.22)
                  : AppColors.surfaceElevated)
              : AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: matched
                ? scheme.primary
                : scheme.primary.withValues(alpha: faceUp ? 0.6 : 0.25),
            width: matched ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: faceUp
            ? Text(emoji, style: const TextStyle(fontSize: 34))
            : Icon(
                Icons.question_mark_rounded,
                color: scheme.primary.withValues(alpha: 0.6),
                size: 26,
              ),
      ),
    );
  }
}
