import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/wallpaper_service.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildThemeModeCard(context),
          const SizedBox(height: 12),
          _buildThemeColorCard(context),
          const SizedBox(height: 12),
          _buildWallpaperCard(context),
        ],
      ),
    );
  }

  Widget _buildThemeModeCard(BuildContext context) {
    return _SettingsExpandableCard(
      leading: const Icon(Icons.brightness_6),
      title: const Text('深色模式'),
      subtitle: context.select((ThemeService service) =>
          Text(_getThemeModeText(service.themeMode))),
      children: [
        _buildThemeModeOption(
          context,
          ThemeMode.system,
          '跟随系统',
        ),
        _buildThemeModeOption(
          context,
          ThemeMode.light,
          '浅色',
        ),
        _buildThemeModeOption(
          context,
          ThemeMode.dark,
          '深色',
        ),
      ],
    );
  }

  Widget _buildThemeModeOption(BuildContext context, ThemeMode mode, String text) {
    final themeService = context.watch<ThemeService>();
    final isSelected = themeService.themeMode == mode;

    return InkWell(
      onTap: () => context.read<ThemeService>().setThemeMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            if (isSelected) const Icon(Icons.check),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeColorCard(BuildContext context) {
    return _SettingsExpandableCard(
      leading: const Icon(Icons.color_lens),
      title: const Text('主题颜色'),
      subtitle: context.select((ThemeService service) => Text(
        service.useDynamicColor
            ? '动态取色'
            : service.themeColorOptions
            .firstWhere(
              (option) => option.color == service.themeColor,
          orElse: () => service.themeColorOptions[1],
        )
            .name,
      )),
      children: context.watch<ThemeService>().themeColorOptions.map((option) {
        final themeService = context.watch<ThemeService>();
        bool isSelected;
        if (option.isDynamic) {
          isSelected = themeService.useDynamicColor;
        } else {
          isSelected = !themeService.useDynamicColor &&
              option.color.value == themeService.themeColor.value;
        }

        return InkWell(
          onTap: () async {
            await context.read<ThemeService>().setUseDynamicColor(option.isDynamic);
            if (!option.isDynamic) {
              await context.read<ThemeService>().setThemeColor(option.color);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
          ),
        );
      }).toList(),
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

  Widget _buildWallpaperCard(BuildContext context) {
    return _SettingsExpandableCard(
      leading: const Icon(Icons.wallpaper),
      title: const Text('聊天背景'),
      subtitle: const Text('自定义聊天界面背景'),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _buildWallpaperItems(context).length,
          itemBuilder: (context, index) => _buildWallpaperItems(context)[index],
        ),
      ],
    );
  }

  List<Widget> _buildWallpaperItems(BuildContext context) {
    final wallpaperService = context.watch<WallpaperService>();
    final selectedWallpaper = wallpaperService.selectedWallpaper;
    final List<Widget> items = [];

    // 默认无背景选项
    items.add(
      _WallpaperItem(
        isSelected: selectedWallpaper == null,
        onTap: () => wallpaperService.setWallpaper(null),
        child: const Icon(Icons.block),
      ),
    );

    // 默认背景选项
    final defaultWallpapers = ['bg1.png', 'bg2.png', 'bg3.png'];
    for (final wallpaper in defaultWallpapers) {
      items.add(
        _WallpaperItem(
          isSelected: selectedWallpaper == wallpaper,
          onTap: () async {
            await wallpaperService.setWallpaper(wallpaper);
            setState(() {});
          },
          child: Image.asset(
            'assets/wallpapers/$wallpaper',
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 自定义背景选项
    for (final wallpaper in wallpaperService.customWallpapers) {
      items.add(
        _WallpaperItem(
          isSelected: selectedWallpaper == wallpaper,
          onTap: () async {
            await wallpaperService.setWallpaper(wallpaper);
            setState(() {});
          },
          onLongPress: () => _showDeleteDialog(context, wallpaper),
          child: FutureBuilder<String>(
            future: wallpaperService.getWallpaperPath(wallpaper),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return Image.file(
                File(snapshot.data!),
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      );
    }

    // 添加按钮
    items.add(
      _WallpaperItem(
        onTap: () async {
          final wallpaper = await wallpaperService.addCustomWallpaper();
          if (wallpaper != null) {
            await wallpaperService.setWallpaper(wallpaper);
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );

    return items;
  }

  Future<void> _showDeleteDialog(BuildContext context, String wallpaper) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除壁纸'),
        content: const Text('确定要删除这张壁纸吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      await context.read<WallpaperService>().removeCustomWallpaper(wallpaper);
    }
  }
}

class _SettingsExpandableCard extends StatefulWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final List<Widget> children;

  const _SettingsExpandableCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  State<_SettingsExpandableCard> createState() => _SettingsExpandableCardState();
}

class _SettingsExpandableCardState extends State<_SettingsExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  widget.leading,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.title,
                        const SizedBox(height: 4),
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                          child: widget.subtitle,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            ...widget.children,
          ],
        ],
      ),
    );
  }
}

class _WallpaperItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  const _WallpaperItem({
    required this.onTap,
    this.onLongPress,
    required this.child,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}