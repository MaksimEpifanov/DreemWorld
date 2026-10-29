import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../wallet/wallet_controller.dart';

/// «Три в ряд»: меняйте соседние плитки местами, собирая линии из трёх и более.
///
/// Очки начисляются за каждую собранную плитку; действует дневной лимит.
/// В конце партии (после N ходов) очки конвертируются в монеты.
class MatchThreeGameScreen extends ConsumerStatefulWidget {
  const MatchThreeGameScreen({super.key});

  @override
  ConsumerState<MatchThreeGameScreen> createState() =>
      _MatchThreeGameScreenState();
}

class _MatchThreeGameScreenState extends ConsumerState<MatchThreeGameScreen> {
  static const int rows = 7;
  static const int cols = 7;
  static const int maxMoves = 15;
  static const List<Color> _tileColors = <Color>[
    Color(0xFF8A3FF2),
    Color(0xFFDA2E8C),
    Color(0xFF2E6BFF),
    Color(0xFF12C4B8),
    Color(0xFFF08A2E),
    Color(0xFF39FF88),
  ];

  late List<int> _board;
  int? _selected;
  int _score = 0;
  int _moves = 0;
  bool _busy = false;
  bool _finished = false;
  int _credited = 0;
  bool _limitReached = false;

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _board = List<int>.generate(rows * cols, (_) => _rnd.nextInt(_tileColors.length));
    // Убираем стартовые совпадения.
    while (_findMatches().isNotEmpty) {
      _board = List<int>.generate(
        rows * cols,
        (_) => _rnd.nextInt(_tileColors.length),
      );
    }
    _selected = null;
    _score = 0;
    _moves = 0;
    _busy = false;
    _finished = false;
    _credited = 0;
    _limitReached = false;
  }

  int _at(int r, int c) => _board[r * cols + c];

  void _set(int r, int c, int v) => _board[r * cols + c] = v;

  /// Индексы плиток, входящих в линии из 3+.
  Set<int> _findMatches() {
    final Set<int> matched = <int>{};

    for (int r = 0; r < rows; r++) {
      int run = 1;
      for (int c = 1; c <= cols; c++) {
        final bool same =
            c < cols && _at(r, c) == _at(r, c - 1);
        if (same) {
          run++;
        } else {
          if (run >= 3) {
            for (int k = c - run; k < c; k++) {
              matched.add(r * cols + k);
            }
          }
          run = 1;
        }
      }
    }

    for (int c = 0; c < cols; c++) {
      int run = 1;
      for (int r = 1; r <= rows; r++) {
        final bool same =
            r < rows && _at(r, c) == _at(r - 1, c);
        if (same) {
          run++;
        } else {
          if (run >= 3) {
            for (int k = r - run; k < r; k++) {
              matched.add(k * cols + c);
            }
          }
          run = 1;
        }
      }
    }

    return matched;
  }

  bool _wouldMatch(int a, int b) {
    final int ar = a ~/ cols, ac = a % cols;
    final int br = b ~/ cols, bc = b % cols;
    final int tmp = _at(ar, ac);
    _set(ar, ac, _at(br, bc));
    _set(br, bc, tmp);
    final bool ok = _findMatches().isNotEmpty;
    _set(br, bc, _at(ar, ac));
    _set(ar, ac, tmp);
    return ok;
  }

  bool _hasAnyMove() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final int idx = r * cols + c;
        if (c + 1 < cols && _wouldMatch(idx, idx + 1)) return true;
        if (r + 1 < rows && _wouldMatch(idx, idx + cols)) return true;
      }
    }
    return false;
  }

  Future<void> _tap(int index) async {
    if (_busy || _finished) return;
    if (_selected == null) {
      setState(() => _selected = index);
      return;
    }
    if (_selected == index) {
      setState(() => _selected = null);
      return;
    }

    final int a = _selected!;
    final int b = index;
    if (!_adjacent(a, b)) {
      setState(() => _selected = index);
      return;
    }

    if (!_wouldMatch(a, b)) {
      setState(() => _selected = null);
      return;
    }

    setState(() {
      _busy = true;
      _selected = null;
      _swap(a, b);
      _moves++;
    });

    await _resolveBoard();
  }

  Future<void> _dragSwap(int a, int b) async {
    if (_busy || _finished) return;
    if (a == b || !_adjacent(a, b)) return;
    if (!_wouldMatch(a, b)) return;
    setState(() {
      _busy = true;
      _selected = null;
      _swap(a, b);
      _moves++;
    });
    await _resolveBoard();
  }

  bool _adjacent(int a, int b) {
    final int ar = a ~/ cols, ac = a % cols;
    final int br = b ~/ cols, bc = b % cols;
    return (ar == br && (ac - bc).abs() == 1) ||
        (ac == bc && (ar - br).abs() == 1);
  }

  void _swap(int a, int b) {
    final int tmp = _board[a];
    _board[a] = _board[b];
    _board[b] = tmp;
  }

  Future<void> _resolveBoard() async {
    while (true) {
      final Set<int> matches = _findMatches();
      if (matches.isEmpty) break;
      setState(() {
        _score += matches.length;
        for (final int idx in matches) {
          _board[idx] = -1;
        }
      });
      await Future<void>.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      setState(_collapse);
      await Future<void>.delayed(const Duration(milliseconds: 160));
      if (!mounted) return;
    }

    // Если ходов больше нет — перемешиваем поле.
    if (!_hasAnyMove()) {
      setState(_reset);
    }

    if (_moves >= maxMoves) {
      await _finish();
    } else {
      setState(() => _busy = false);
    }
  }

  void _collapse() {
    for (int c = 0; c < cols; c++) {
      int writeRow = rows - 1;
      for (int r = rows - 1; r >= 0; r--) {
        if (_at(r, c) != -1) {
          _set(writeRow, c, _at(r, c));
          writeRow--;
        }
      }
      for (int r = writeRow; r >= 0; r--) {
        _set(r, c, _rnd.nextInt(_tileColors.length));
      }
    }
  }

  Future<void> _finish() async {
    final int reward = _score;
    final int credited = await ref
        .read(walletProvider.notifier)
        .rewardFromGame(reward);
    if (!mounted) return;
    setState(() {
      _finished = true;
      _busy = false;
      _credited = credited;
      _limitReached = credited < reward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeonAppBar(
        title: 'Три в ряд',
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
                    Text('Очки: $_score', style: AppTextStyles.bodyBold()),
                    const Spacer(),
                    Text(
                      'Ходы: $_moves / $maxMoves',
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _buildBoard()),
                if (_finished) _buildResult(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cell = min(
          constraints.maxWidth / cols,
          constraints.maxHeight / rows,
        );
        return Center(
          child: SizedBox(
            width: cell * cols,
            height: cell * rows,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: rows * cols,
              itemBuilder: (BuildContext context, int index) {
                final int v = _board[index];
                return Draggable<int>(
                  data: index,
                  feedback: SizedBox(
                    width: cell - 4,
                    height: cell - 4,
                    child: _Tile(
                      color: v >= 0 ? _tileColors[v] : Colors.transparent,
                      selected: true,
                      onTap: () {},
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.25,
                    child: _Tile(
                      color: v >= 0 ? _tileColors[v] : Colors.transparent,
                      selected: _selected == index,
                      onTap: () => _tap(index),
                    ),
                  ),
                  child: DragTarget<int>(
                    onWillAcceptWithDetails: (DragTargetDetails<int> details) {
                      return !_busy && !_finished && _adjacent(details.data, index);
                    },
                    onAcceptWithDetails: (DragTargetDetails<int> details) {
                      _dragSwap(details.data, index);
                    },
                    builder: (BuildContext context, List<int?> candidateData, List<dynamic> rejectedData) {
                      final bool over = candidateData.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: over
                              ? Border.all(color: AppColors.white.withValues(alpha: 0.8), width: 2)
                              : null,
                        ),
                        child: _Tile(
                          color: v >= 0 ? _tileColors[v] : Colors.transparent,
                          selected: _selected == index,
                          onTap: () => _tap(index),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Партия окончена', style: AppTextStyles.title()),
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

class _Tile extends StatefulWidget {
  const _Tile({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  late final AnimationController _disappearController;
  late final Animation<double> _scaleOut;
  late final Animation<double> _opacityOut;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _disappearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _disappearController, curve: Curves.easeInBack),
    );
    _opacityOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _disappearController, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(covariant _Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != Colors.transparent && widget.color == Colors.transparent) {
      _disappearController.forward(from: 0.0);
    } else if (widget.color != Colors.transparent) {
      _disappearController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _disappearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool empty = widget.color == Colors.transparent;
    final double scale = widget.selected ? 1.14 : 1.0;
    return AnimatedPress(
      onPressed: widget.onTap,
      scaleDown: 0.92,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_pulse, _disappearController]),
        builder: (BuildContext context, Widget? child) {
          if (empty) {
            return ScaleTransition(
              scale: _scaleOut,
              child: FadeTransition(
                opacity: _opacityOut,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          final double animScale = widget.selected ? scale : _pulse.value * 0.98;
          return AnimatedScale(
            scale: animScale,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutBack,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.3),
                  colors: <Color>[
                    widget.color.withValues(alpha: 1.0),
                    widget.color.withValues(alpha: 0.75),
                    widget.color.withValues(alpha: 0.55),
                  ],
                  stops: const <double>[0.0, 0.6, 1.0],
                ),
                border: Border.all(
                  color: widget.selected
                      ? AppColors.white.withValues(alpha: 0.98)
                      : widget.color.withValues(alpha: 0.85),
                  width: widget.selected ? 2.8 : 1.6,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: widget.color.withValues(alpha: widget.selected ? 1.0 : 0.6),
                    blurRadius: widget.selected ? 20 : 12,
                    spreadRadius: widget.selected ? 1 : 0,
                  ),
                  if (widget.selected)
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.28),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.32),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
