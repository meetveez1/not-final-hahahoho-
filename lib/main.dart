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
  ThemeMode _themeMode = ThemeMode.dark;

  void _onThemeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Школьное приложение',
      themeMode: _themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: AppShell(
        themeMode: _themeMode,
        onThemeChanged: _onThemeChanged,
      ),
    );
  }
}

class AppTheme {
  static const Color midnight = Color(0xFF0B0B0E);
  static const Color darkHeader = Color(0xFF25272E);

  static const LinearGradient cyanGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF17C7E7), Color(0xFF09CB67)],
  );

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F5F9),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE4E6EB),
        foregroundColor: Color(0xFF10203F),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      extensions: const [
        AppPalette(
          background: Color(0xFFF4F5F9),
          title: Color(0xFF051737),
          body: Color(0xFF495B73),
          header: Color(0xFFE4E6EB),
          tile: Colors.white,
        ),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnight,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkHeader,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF141821),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      extensions: const [
        AppPalette(
          background: midnight,
          title: Colors.white,
          body: Color(0xFFD0D8E8),
          header: darkHeader,
          tile: Color(0xFF141821),
        ),
      ],
    );
  }
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.title,
    required this.body,
    required this.header,
    required this.tile,
  });

  final Color background;
  final Color title;
  final Color body;
  final Color header;
  final Color tile;

  @override
  AppPalette copyWith({
    Color? background,
    Color? title,
    Color? body,
    Color? header,
    Color? tile,
  }) {
    return AppPalette(
      background: background ?? this.background,
      title: title ?? this.title,
      body: body ?? this.body,
      header: header ?? this.header,
      tile: tile ?? this.tile,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      title: Color.lerp(title, other.title, t)!,
      body: Color.lerp(body, other.body, t)!,
      header: Color.lerp(header, other.header, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final PageController _controller = PageController();
  int _page = 0;

  void _changePage(int index) {
    Navigator.of(context).maybePop();
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _handleWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    if (event.scrollDelta.dy > 0 && _page < 3) {
      _changePage(_page + 1);
    } else if (event.scrollDelta.dy < 0 && _page > 0) {
      _changePage(_page - 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: const Text(
          'Школьное\nприложение',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.cyanGreen,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      drawer: SchoolMenu(currentPage: _page, onSelectPage: _changePage),
      body: Listener(
        onPointerSignal: _handleWheel,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: PageView(
            controller: _controller,
            onPageChanged: (value) {
              setState(() {
                _page = value;
              });
            },
            children: [
              const NewsScreen(),
              const ScheduleScreen(),
              const InfoScreen(),
              SettingsScreen(
                themeMode: widget.themeMode,
                onThemeChanged: widget.onThemeChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SchoolMenu extends StatelessWidget {
  const SchoolMenu({
    super.key,
    required this.currentPage,
    required this.onSelectPage,
  });

  final int currentPage;
  final ValueChanged<int> onSelectPage;

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
        decoration: const BoxDecoration(gradient: AppTheme.cyanGreen),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
                child: Row(
                  children: [
                    const Text(
                      'Меню',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white30),
              const SizedBox(height: 8),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: currentPage == i ? Colors.white : Colors.transparent,
                    leading: Icon(
                      items[i].$1,
                      color: currentPage == i ? const Color(0xFF019EC6) : Colors.white,
                    ),
                    title: Text(
                      items[i].$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: currentPage == i ? const Color(0xFF018CB3) : Colors.white,
                      ),
                    ),
                    onTap: () => onSelectPage(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Новости школы',
          style: TextStyle(
            color: palette.title,
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Все актуальные события и объявления',
          style: TextStyle(color: palette.body, fontSize: 20),
        ),
        const SizedBox(height: 10),
        const NewsCard(
          date: '1 сентября 2026',
          title: 'Начало нового учебного года',
          text:
              '1 сентября наша школа открыла двери для всех учеников. Торжественная линейка прошла успешно, все ученики получили учебные материалы.',
        ),
        const NewsCard(
          date: '14 февраля 2026',
          title: 'Спортивный турнир между классами',
          text:
              'Команды 8–11 классов приняли участие в школьном турнире. Финальные соревнования пройдут в эту пятницу.',
        ),
      ],
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.date,
    required this.title,
    required this.text,
  });

  final String date;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cyanGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(2),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.schedule, size: 16, color: palette.body),
                  const SizedBox(width: 4),
                  Text(date, style: TextStyle(color: palette.body)),
                ],
              ),
              const SizedBox(height: 96),
              Text(
                title,
                style: TextStyle(
                  color: palette.title,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.body, height: 1.35),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.favorite_border, color: palette.body),
                  const SizedBox(width: 6),
                  Text('124', style: TextStyle(color: palette.body)),
                  const SizedBox(width: 20),
                  Icon(Icons.chat_bubble_outline, color: palette.body),
                  const SizedBox(width: 6),
                  Text('18', style: TextStyle(color: palette.body)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Расписание уроков',
          style: TextStyle(
            color: palette.title,
            fontSize: 42,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text('Класс 9Б', style: TextStyle(color: palette.body, fontSize: 24)),
        const SizedBox(height: 14),
        const _DayChips(),
        const SizedBox(height: 14),
        const LessonTile(
          subject: 'Математика',
          teacher: 'Иванова А.П.',
          time: '08:30 - 09:15',
          room: 'Кабинет 204',
          number: 1,
        ),
        const LessonTile(
          subject: 'Русский язык',
          teacher: 'Петрова С.В.',
          time: '09:25 - 10:10',
          room: 'Кабинет 301',
          number: 2,
        ),
      ],
    );
  }
}

class _DayChips extends StatelessWidget {
  const _DayChips();

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
              decoration: BoxDecoration(
                gradient: i == 0 ? AppTheme.cyanGreen : null,
                color: i == 0 ? null : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: Text(
                days[i],
                style: TextStyle(
                  color: i == 0 ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  const LessonTile({
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
    final palette = Theme.of(context).extension<AppPalette>()!;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: palette.title,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0x2222C9E7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x5536D3EE)),
                  ),
                  child: Text(
                    'Урок $number',
                    style: const TextStyle(
                      color: Color(0xFF0EB7D9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(children: [Text(teacher, style: TextStyle(color: palette.body))]),
            const Divider(height: 22),
            Row(
              children: [
                Icon(Icons.schedule, size: 17, color: palette.body),
                const SizedBox(width: 6),
                Text(time, style: TextStyle(color: palette.body)),
                const Spacer(),
                Icon(Icons.location_pin, size: 17, color: palette.body),
                const SizedBox(width: 4),
                Text(room, style: TextStyle(color: palette.body)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Дополнительная информация',
          style: TextStyle(
            color: palette.title,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Здесь можно разместить контакты школы, правила посещения и важные объявления.',
              style: TextStyle(color: palette.body),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final isDark = themeMode == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Тема оформления',
          style: TextStyle(
            color: palette.title,
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Выберите внешний вид приложения',
          style: TextStyle(color: palette.body, fontSize: 20),
        ),
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x708EE2F1)),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF17C7E7).withOpacity(0.15),
                const Color(0xFF09CB67).withOpacity(0.15),
              ],
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Text(
            'Тёмная тема с полночным мраком (#0B0B0E) помогает снизить нагрузку на глаза при использовании приложения вечером и ночью.',
            style: TextStyle(color: palette.title, height: 1.4),
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
        gradient: selected ? AppTheme.cyanGreen : null,
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
              color: selected ? const Color(0x1916C7E7) : Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Icon(icon),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: selected
              ? Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.cyanGreen,
                  ),
                  child: const Icon(Icons.check, size: 17, color: Colors.white),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
