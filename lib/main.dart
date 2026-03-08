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

  void _changeTheme(ThemeMode mode) {
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
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      home: HomeScreen(
        themeMode: _themeMode,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}

class AppThemes {
  static const LinearGradient cyanGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF13C8E8), Color(0xFF09CC63)],
  );

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F5F8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0BCF63),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFFE5E7EC),
        foregroundColor: Color(0xFF11213D),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      extensions: const [
        AppPalette(
          background: Color(0xFFF4F5F8),
          topBar: Color(0xFFE5E7EC),
          headline: Color(0xFF0A1F3D),
          body: Color(0xFF3C4E68),
        ),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0B0E),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0BCF63),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF23252A),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF151820),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      extensions: const [
        AppPalette(
          background: Color(0xFF0B0B0E),
          topBar: Color(0xFF23252A),
          headline: Colors.white,
          body: Color(0xFFCBD3E4),
        ),
      ],
    );
  }
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.topBar,
    required this.headline,
    required this.body,
  });

  final Color background;
  final Color topBar;
  final Color headline;
  final Color body;

  @override
  ThemeExtension<AppPalette> copyWith({
    Color? background,
    Color? topBar,
    Color? headline,
    Color? body,
  }) {
    return AppPalette(
      background: background ?? this.background,
      topBar: topBar ?? this.topBar,
      headline: headline ?? this.headline,
      body: body ?? this.body,
    );
  }

  @override
  ThemeExtension<AppPalette> lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      topBar: Color.lerp(topBar, other.topBar, t)!,
      headline: Color.lerp(headline, other.headline, t)!,
      body: Color.lerp(body, other.body, t)!,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    Navigator.of(context).maybePop();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    final delta = event.scrollDelta.dy;
    if (delta > 0 && _currentPage < 3) {
      _goToPage(_currentPage + 1);
    } else if (delta < 0 && _currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: const Text(
          'Школьное\nприложение',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppThemes.cyanGreenGradient,
              ),
              child: IconButton(
                icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      drawer: SideMenu(
        selectedIndex: _currentPage,
        onTapItem: _goToPage,
      ),
      body: Listener(
        onPointerSignal: _onPointerSignal,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
            },
          ),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              const NewsPage(),
              const SchedulePage(),
              const InfoPage(),
              SettingsPage(
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

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onTapItem,
  });

  final int selectedIndex;
  final ValueChanged<int> onTapItem;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.home_outlined, 'Главное'),
      (Icons.calendar_today_outlined, 'Расписание'),
      (Icons.info_outline_rounded, 'Доп информация'),
      (Icons.settings_outlined, 'Настройки'),
    ];

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppThemes.cyanGreenGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  children: [
                    const Text(
                      'Меню',
                      style: TextStyle(
                        fontSize: 34,
                        color: Colors.white,
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
              const Divider(color: Colors.white30, height: 1),
              const SizedBox(height: 8),
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: ListTile(
                    onTap: () => onTapItem(i),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: selectedIndex == i ? Colors.white : Colors.transparent,
                    leading: Icon(
                      items[i].$1,
                      color: selectedIndex == i ? const Color(0xFF039CCB) : Colors.white,
                    ),
                    title: Text(
                      items[i].$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selectedIndex == i ? const Color(0xFF0595C2) : Colors.white,
                      ),
                    ),
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
    final palette = Theme.of(context).extension<AppPalette>()!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Новости школы',
          style: TextStyle(
            color: palette.headline,
            fontSize: 38,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Все актуальные события и объявления',
          style: TextStyle(
            color: palette.body,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        const NewsItemCard(
          date: '1 сентября 2026',
          title: 'Начало нового учебного года',
          body:
              '1 сентября наша школа открыла двери для всех учеников. Торжественная линейка прошла успешно, все ученики получили учебные материалы.',
        ),
        const NewsItemCard(
          date: '14 февраля 2026',
          title: 'Спортивный турнир между классами',
          body:
              'Команды 8-11 классов приняли участие в школьном турнире. Финальные соревнования пройдут в эту пятницу.',
        ),
      ],
    );
  }
}

class NewsItemCard extends StatelessWidget {
  const NewsItemCard({
    super.key,
    required this.date,
    required this.title,
    required this.body,
  });

  final String date;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        gradient: AppThemes.cyanGreenGradient,
        borderRadius: BorderRadius.circular(16),
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
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(date, style: TextStyle(color: palette.body)),
                ],
              ),
              const SizedBox(height: 100),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: palette.headline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: TextStyle(color: palette.body, height: 1.35),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 22),
              Row(
                children: [
                  Icon(Icons.favorite_border, color: palette.body),
                  const SizedBox(width: 6),
                  Text('124', style: TextStyle(color: palette.body)),
                  const SizedBox(width: 22),
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

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Расписание уроков',
          style: TextStyle(
            color: palette.headline,
            fontSize: 42,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text('Класс 9Б', style: TextStyle(color: palette.body, fontSize: 25)),
        const SizedBox(height: 16),
        const _DayTabs(),
        const SizedBox(height: 14),
        const LessonCard(
          subject: 'Математика',
          teacher: 'Иванова А.П.',
          time: '08:30 - 09:15',
          room: 'Кабинет 204',
          lessonNumber: 1,
        ),
        const LessonCard(
          subject: 'Русский язык',
          teacher: 'Петрова С.В.',
          time: '09:25 - 10:10',
          room: 'Кабинет 301',
          lessonNumber: 2,
        ),
      ],
    );
  }
}

class _DayTabs extends StatelessWidget {
  const _DayTabs();

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
                gradient: i == 0 ? AppThemes.cyanGreenGradient : null,
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

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.time,
    required this.room,
    required this.lessonNumber,
  });

  final String subject;
  final String teacher;
  final String time;
  final String room;
  final int lessonNumber;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return Card(
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
                      color: palette.headline,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x2622C9E8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x4436D2EF)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Text(
                    'Урок $lessonNumber',
                    style: const TextStyle(
                      color: Color(0xFF0EB7D9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(teacher, style: TextStyle(color: palette.body)),
              ],
            ),
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

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Дополнительная информация',
          style: TextStyle(
            color: palette.headline,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Здесь можно разместить объявления школы, контакты и правила для учеников.',
              style: TextStyle(color: palette.body),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
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
            color: palette.headline,
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
        ThemeTile(
          title: 'Светлая тема',
          subtitle: 'Классический светлый дизайн',
          icon: Icons.light_mode_outlined,
          selected: !isDark,
          onTap: () => onThemeChanged(ThemeMode.light),
        ),
        ThemeTile(
          title: 'Тёмная тема',
          subtitle: 'Полночный мрак для комфорта',
          icon: Icons.nightlight_round,
          selected: isDark,
          onTap: () => onThemeChanged(ThemeMode.dark),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x604FDDED)),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF13C8E8).withOpacity(0.15),
                const Color(0xFF09CC63).withOpacity(0.15),
              ],
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Text(
            'Тёмная тема с полночным мраком (#0B0B0E) помогает снизить нагрузку на глаза при использовании приложения в тёмное время суток.',
            style: TextStyle(color: palette.headline, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class ThemeTile extends StatelessWidget {
  const ThemeTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: selected ? AppThemes.cyanGreenGradient : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.transparent : Colors.white24,
        ),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x4413C8E8),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
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
              color: selected
                  ? const Color(0x1913C8E8)
                  : Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Icon(icon),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          trailing: selected
              ? Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppThemes.cyanGreenGradient,
                  ),
                  child: const Icon(Icons.check, size: 17, color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }
}
