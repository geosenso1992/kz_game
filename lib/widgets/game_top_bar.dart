import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/hunt_game_state.dart';
import '../screens/navigation_helpers.dart';
import 'responsive.dart';

class GameTopBar extends StatelessWidget {
  final GameTopTab currentTab;
  final ValueChanged<GameTopTab> onTabSelected;

  const GameTopBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.watch<HuntGameState>();
    if (game.shouldAutoOpenFinalWord && currentTab != GameTopTab.finalWord) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.read<HuntGameState>().markFinalWordAutoOpened();
        onTabSelected(GameTopTab.finalWord);
      });
    }
    if (currentTab == GameTopTab.collection && game.hasNewFaunaUnlock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.read<HuntGameState>().clearFaunaUnlockBadge();
      });
    }
    if (currentTab == GameTopTab.finalWord && game.hasNewFinalWordUnlock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.read<HuntGameState>().clearFinalWordUnlockBadge();
      });
    }

    final scale = responsiveScale(context);

    return Container(
      margin: EdgeInsets.fromLTRB(10 * scale, 8 * scale, 10 * scale, 0),
      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
      height: 54 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFF8EED8).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0xFFD7C29A), width: 1.0 * scale),
      ),
      child: Row(
        children: [
          _item(icon: Icons.home, tab: GameTopTab.home, scale: scale),
          SizedBox(width: 8 * scale),
          _item(icon: Icons.public, tab: GameTopTab.map, scale: scale),
          SizedBox(width: 8 * scale),
          _item(
            icon: Icons.pets,
            tab: GameTopTab.collection,
            showBadge: game.hasNewFaunaUnlock,
            scale: scale,
          ),
          SizedBox(width: 8 * scale),
          _item(
            icon: Icons.emoji_events,
            tab: GameTopTab.finalWord,
            showBadge: game.hasNewFinalWordUnlock,
            scale: scale,
          ),
          const Spacer(),
          _timerPill(game, scale),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required GameTopTab tab,
    required double scale,
    bool showBadge = false,
  }) {
    final selected = currentTab == tab;
    return IconButton(
      onPressed: () {
        onTabSelected(tab);
      },
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 36 * scale, minHeight: 36 * scale),
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: selected ? const Color(0xFF4D331D) : const Color(0xFF8D6A4A),
            size: 28 * scale,
          ),
          if (showBadge)
            Positioned(
              right: -2 * scale,
              top: -3 * scale,
              child: _TopBarBadge(scale: scale),
            ),
        ],
      ),
    );
  }

  Widget _timerPill(HuntGameState game, double scale) {
    final color = game.remainingSeconds <= 600
        ? const Color(0xFFC62828)
        : game.remainingSeconds <= 1800
            ? const Color(0xFFEF6C00)
            : const Color(0xFF0B5D1E);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: Colors.white70, width: 0.8 * scale),
      ),
      child: Text(
        game.remainingTimeLabel,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12 * scale,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TopBarBadge extends StatelessWidget {
  final double scale;

  const _TopBarBadge({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14 * scale,
      height: 14 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.white, width: 1 * scale),
      ),
      child: Text(
        '!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10 * scale,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

