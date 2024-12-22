import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class ColorSelection {
  final Color color;
  final bool isDynamic;

  ColorSelection(this.color, this.isDynamic);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildThemeModeSection(context),
          _buildThemeColorSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('深色模式'),
      subtitle: Text(_getThemeModeText(themeService.themeMode)),
      onTap: () async {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box == null) return;

        final Offset offset = box.localToGlobal(Offset.zero);

        final ThemeMode? selectedMode = await showMenu<ThemeMode>(
          context: context,
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 280,
          ),
          position: RelativeRect.fromLTRB(
            offset.dx + box.size.width - 200,
            offset.dy + box.size.height,
            offset.dx + box.size.width,
            offset.dy + box.size.height + 200,
          ),
          items: [
            _buildThemeModeMenuItem(
              context,
              ThemeMode.system,
              '跟随系统',
              themeService.themeMode == ThemeMode.system,
            ),
            _buildThemeModeMenuItem(
              context,
              ThemeMode.light,
              '浅色',
              themeService.themeMode == ThemeMode.light,
            ),
            _buildThemeModeMenuItem(
              context,
              ThemeMode.dark,
              '深色',
              themeService.themeMode == ThemeMode.dark,
            ),
          ],
        );

        if (selectedMode != null) {
          // ignore: use_build_context_synchronously
          await context.read<ThemeService>().setThemeMode(selectedMode);
        }
      },
    );
  }

  PopupMenuItem<ThemeMode> _buildThemeModeMenuItem(
      BuildContext context,
      ThemeMode mode,
      String text,
      bool isSelected,
      ) {
    return PopupMenuItem<ThemeMode>(
      value: mode,
      onTap: () {
        context.read<ThemeService>().setThemeMode(mode);
      },
      child: Row(
        children: [
          Expanded(child: Text(text)),
          if (isSelected) const Icon(Icons.check),
        ],
      ),
    );
  }

  Widget _buildThemeColorSection(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: const Text('主题颜色'),
      subtitle: Text(
        themeService.useDynamicColor
            ? '动态取色'
            : themeService.themeColorOptions
            .firstWhere(
              (option) => option.color == themeService.themeColor,
          orElse: () => themeService.themeColorOptions[1],
        )
            .name,
      ),
      onTap: () async {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box == null) return;

        final Offset offset = box.localToGlobal(Offset.zero);

        final ColorSelection? selectedColor = await showMenu<ColorSelection>(
          context: context,
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 280,
          ),
          position: RelativeRect.fromLTRB(
            offset.dx + box.size.width - 200,
            offset.dy + box.size.height,
            offset.dx + box.size.width,
            offset.dy + box.size.height + 200,
          ),
          items: themeService.themeColorOptions.map((option) {
            bool isSelected;
            if (option.isDynamic) {
              isSelected = themeService.useDynamicColor;
            } else {
              isSelected = !themeService.useDynamicColor &&
                  option.color.value == themeService.themeColor.value;
            }

            return PopupMenuItem<ColorSelection>(
              value: ColorSelection(option.color, option.isDynamic),
              child: Row(
                children: [
                  if (!option.isDynamic)
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.green,
                            Colors.yellow,
                            Colors.orange,
                            Colors.red,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(child: Text(option.name)),
                  if (isSelected)
                    const Icon(Icons.check, size: 20),
                ],
              ),
            );
          }).toList(),
        );

        if (selectedColor != null) {
          // ignore: use_build_context_synchronously
          await context.read<ThemeService>().setUseDynamicColor(selectedColor.isDynamic);
          if (!selectedColor.isDynamic) {
            // ignore: use_build_context_synchronously
            await context.read<ThemeService>().setThemeColor(selectedColor.color);
          }
        }
      },
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
    }
  }
}