import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SchoolApp());
}

class SchoolApp extends StatefulWidget {
  const SchoolApp({super.key});

  @override
  State<SchoolApp> createState() => _SchoolAppState();
}

class _SchoolAppState extends State<SchoolApp> {
  ThemeMode _mode = ThemeMode.dark;

  void _setMode(ThemeMode mode) {
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Школьное приложение',
      theme: AppStyles.light,
      darkTheme: AppStyles.dark,
      themeMode: _mode,
      home: ShellPage(
        themeMode: _mode,
        onThemeChanged: _setMode,
      ),
    );
  }
}

class AppStyles {
  static const bgDark = Color(0xFF0B0B0E);
  static const headerDark = Color(0xFF24262C);
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12C9EA), Color(0xFF08CC66)],
  );

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE4E6EB),
        foregroundColor: Color(0xFF0F213E),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      extensions: const [
        Palette(
          title: Color(0xFF051636),
          text: Color(0xFF495A72),
          tile: Colors.white,
        ),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: headerDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF141720),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      extensions: const [
        Palette(
          title: Colors.white,
          text: Color(0xFFD2D9E7),
          tile: Color(0xFF141720),
        ),
      ],
    );
  }
}

@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({required this.title, required this.text, required this.tile});

  final Color title;
  final Color text;
  final Color tile;

  @override
  Palette copyWith({Color? title, Color? text, Color? tile}) {
    return Palette(
      title: title ?? this.title,
      text: text ?? this.text,
      tile: tile ?? this.tile,
    );
  }

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    return Palette(
      title: Color.lerp(title, other.title, t)!,
      text: Color.lerp(text, other.text, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  final PageController _pageController = PageController();
  int _index = 0;

  void _jump(int page) {
    Navigator.of(context).maybePop();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _onWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (event.scrollDelta.dy > 0 && _index < 3) {
      _jump(_index + 1);
    } else if (event.scrollDelta.dy < 0 && _index > 0) {
      _jump(_index - 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: const Text('Школьное\nприложение', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: DecoratedBox(
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppStyles.accentGradient),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(index: _index, onSelect: _jump),
      body: Listener(
        onPointerSignal: _onWheel,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: const {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
          ),
          child: PageView(
            controller: _pageController,
            onPageChanged: (v) => setState(() => _index = v),
            children: [
              const NewsPage(),
              const SchedulePage(),
              const InfoPage(),
              ThemeSettingsPage(themeMode: widget.themeMode, onThemeChanged: widget.onThemeChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.home_outlined, 'Главное'),
      (Icons.calendar_month_outlined, 'Расписание'),
      (Icons.info_outline_rounded, 'Доп информация'),
      (Icons.settings_outlined, 'Настройки'),
    ];

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppStyles.accentGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  children: [
                    const Text('Меню', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white30),
              const SizedBox(height: 8),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: ListTile(
                    tileColor: i == index ? Colors.white : Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Icon(items[i].$1, color: i == index ? const Color(0xFF009AC4) : Colors.white),
                    title: Text(
                      items[i].$2,
                      style: TextStyle(fontWeight: FontWeight.w700, color: i == index ? const Color(0xFF008EB8) : Colors.white),
                    ),
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Palette>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Новости школы', style: TextStyle(color: colors.title, fontSize: 40, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Все актуальные события и объявления', style: TextStyle(color: colors.text, fontSize: 20)),
        const SizedBox(height: 10),
        const NewsCard(
          date: '1 сентября 2026',
          title: 'Начало нового учебного года',
          body: '1 сентября наша школа открыла двери для всех учеников. Торжественная линейка прошла успешно, все ученики получили учебные материалы.',
        ),
        const NewsCard(
          date: '14 февраля 2026',
          title: 'Спортивный турнир между классами',
          body: 'Команды 8–11 классов приняли участие в школьном турнире. Финальные соревнования пройдут в эту пятницу.',
        ),
      ],
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.date, required this.title, required this.body});

  final String date;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Palette>()!;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(gradient: AppStyles.accentGradient, borderRadius: BorderRadius.circular(18)),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Icon(Icons.schedule, size: 16, color: colors.text), const SizedBox(width: 4), Text(date, style: TextStyle(color: colors.text))],
            ),
            const SizedBox(height: 98),
            Text(title, style: TextStyle(color: colors.title, fontSize: 34, fontWeight: FontWeight.w800, height: 1.08)),
            const SizedBox(height: 10),
            Text(body, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.text, height: 1.35)),
            const Divider(height: 24),
            Row(children: [
              Icon(Icons.favorite_border, color: colors.text),
              const SizedBox(width: 6),
              Text('124', style: TextStyle(color: colors.text)),
              const SizedBox(width: 20),
              Icon(Icons.chat_bubble_outline, color: colors.text),
              const SizedBox(width: 6),
              Text('18', style: TextStyle(color: colors.text)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Palette>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Расписание уроков', style: TextStyle(color: colors.title, fontSize: 42, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Класс 9Б', style: TextStyle(color: colors.text, fontSize: 24)),
        const SizedBox(height: 14),
        const DaysRow(),
        const SizedBox(height: 14),
        const LessonCard(subject: 'Математика', teacher: 'Иванова А.П.', time: '08:30 - 09:15', room: 'Кабинет 204', number: 1),
        const LessonCard(subject: 'Русский язык', teacher: 'Петрова С.В.', time: '09:25 - 10:10', room: 'Кабинет 301', number: 2),
      ],
    );
  }
}

class DaysRow extends StatelessWidget {
  const DaysRow({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Понедельник', 'Вторник', 'Среда'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                gradient: i == 0 ? AppStyles.accentGradient : null,
                color: i == 0 ? null : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                days[i],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: i == 0 ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.time,
    required this.room,
    required this.number,
  });

  final String subject;
  final String teacher;
  final String time;
  final String room;
  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Palette>()!;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text(subject, style: TextStyle(color: colors.title, fontSize: 36, fontWeight: FontWeight.w800))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0x2222C9E7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x5536D3EE)),
              ),
              child: Text('Урок $number', style: const TextStyle(color: Color(0xFF0EB7D9), fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [Text(teacher, style: TextStyle(color: colors.text))]),
          const Divider(height: 22),
          Row(children: [
            Icon(Icons.schedule, size: 17, color: colors.text),
            const SizedBox(width: 6),
            Text(time, style: TextStyle(color: colors.text)),
            const Spacer(),
            Icon(Icons.location_pin, size: 17, color: colors.text),
            const SizedBox(width: 4),
            Text(room, style: TextStyle(color: colors.text)),
          ]),
        ]),
      ),
    );
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Palette>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Дополнительная информация', style: TextStyle(color: colors.title, fontSize: 34, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Здесь можно разместить контакты школы, правила посещения и важные объявления.', style: TextStyle(color: colors.text)),
          ),
        ),
      ],
    );
  }
}

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key, required this.themeMode, required this.onThemeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Palette>()!;
    final isDark = themeMode == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Тема оформления', style: TextStyle(color: colors.title, fontSize: 40, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Выберите внешний вид приложения', style: TextStyle(color: colors.text, fontSize: 20)),
        const SizedBox(height: 16),
        ThemeOption(
          icon: Icons.light_mode_outlined,
          title: 'Светлая тема',
          subtitle: 'Классический светлый дизайн',
          selected: !isDark,
          onTap: () => onThemeChanged(ThemeMode.light),
        ),
        ThemeOption(
          icon: Icons.nightlight_round,
          title: 'Тёмная тема',
          subtitle: 'Полночный мрак для комфорта',
          selected: isDark,
          onTap: () => onThemeChanged(ThemeMode.dark),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x708EE2F1)),
            gradient: LinearGradient(
              colors: [const Color(0xFF12C9EA).withOpacity(0.15), const Color(0xFF08CC66).withOpacity(0.15)],
            ),
          ),
          child: Text(
            'Тёмная тема с полночным мраком (#0B0B0E) помогает снизить нагрузку на глаза при использовании приложения вечером и ночью.',
            style: TextStyle(color: colors.title, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class ThemeOption extends StatelessWidget {
  const ThemeOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: selected ? AppStyles.accentGradient : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? Colors.transparent : Colors.white24),
      ),
      child: Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected ? const Color(0x1912C9EA) : Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Icon(icon),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: selected
              ? Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppStyles.accentGradient),
                  child: const Icon(Icons.check, size: 17, color: Colors.white),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
