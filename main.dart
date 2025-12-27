import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const IslamicApp());
}

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(fontFamily: 'Amiri', primarySwatch: Colors.green),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E8449), Color(0xFF27AE60)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'أدعوا الله لنا بالقبول',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  String _currentTheme = 'green';
  List<String> _bookmarks = [];
  bool _showBookmarks = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _currentTheme = prefs.getString('theme') ?? 'green';
      _bookmarks = prefs.getStringList('bookmarks') ?? [];
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setString('theme', _currentTheme);
    await prefs.setStringList('bookmarks', _bookmarks);
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _savePreferences();
  }

  void _addBookmark(String bookmark) {
    if (!_bookmarks.contains(bookmark)) {
      setState(() {
        _bookmarks.add(bookmark);
      });
      _savePreferences();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⭐ تمت إضافة إشارة: $bookmark'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleBookmarks() {
    setState(() {
      _showBookmarks = !_showBookmarks;
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        currentTheme: _currentTheme,
        isDarkMode: _isDarkMode,
        onThemeChanged: (theme) {
          setState(() {
            _currentTheme = theme;
          });
          _savePreferences();
        },
        onDarkModeChanged: (value) {
          setState(() {
            _isDarkMode = value;
          });
          _savePreferences();
        },
      ),
    );
  }

  void _showDonationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ساعد في نشر التطبيق ❤️',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E8449),
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'ساعدنا في نشر هذا التطبيق الخير ليكون في ميزان حسناتك',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f6f0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFd4b896), width: 1),
                ),
                child: Column(
                  children: [
                    const Text(
                      'للتبرع ودعم التطوير:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E8449),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _copyDonationNumber,
                      child: const Text(
                        '01067364304',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E8449),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(فودافون كاش)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ملاحظة: جزء من التبرع سيذهب للمطور',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'شكراً لك',
                style: TextStyle(
                  color: Color(0xFF1E8449),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _copyDonationNumber() async {
    const number = '01067364304';

    try {
      await Clipboard.setData(const ClipboardData(text: number));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ رقم التبرع: 01067364304'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في نسخ الرقم: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _getThemeData(),
      child: Scaffold(
        backgroundColor:
            _isDarkMode ? const Color(0xFF0d1b2a) : Colors.grey[100],
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildNavigationBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      QuranSection(
                        addBookmark: _addBookmark,
                        isDarkMode: _isDarkMode,
                      ),
                      const TasbihSection(),
                      const HadithSection(),
                      const DuasSection(),
                      AdhkarSection(
                        addBookmark: _addBookmark,
                        isDarkMode: _isDarkMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showBookmarks) _buildBookmarksPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E8449), Color(0xFF27AE60)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // Settings button
              Positioned(
                right: 120,
                child: IconButton(
                  onPressed: _showSettings,
                  icon: const Icon(Icons.settings, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              // Donation button (هدية)
              Positioned(
                right: 60,
                child: IconButton(
                  onPressed: _showDonationDialog,
                  icon: const Icon(Icons.card_giftcard, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              // Bookmarks button
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: _toggleBookmarks,
                  icon: const Icon(Icons.star, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              // Center title
              Center(
                child: Column(
                  children: [
                    const Text(
                      'الطريق الي اللة',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ألا بذكر الله تطمئن القلوب',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final items = [
      'القرآن الكريم',
      'التسبيح',
      'الأحاديث',
      'الأدعية',
      'الأذكار',
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: items.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            bool isActive = _selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive
                      ? const Color(0xFF27AE60)
                      : const Color(0xFF1E8449),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  elevation: isActive ? 8 : 4,
                ),
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookmarksPanel() {
    return Positioned(
      top: 120,
      right: 20,
      child: Container(
        width: 250,
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1b263b) : Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                '⭐ إشاراتي المرجعية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _bookmarks.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد إشارات مرجعية',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _bookmarks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _bookmarks[index],
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم فتح ${_bookmarks[index]}'),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _bookmarks.removeAt(index);
                              });
                              _savePreferences();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData _getThemeData() {
    Color primaryColor;
    switch (_currentTheme) {
      case 'turquoise':
        primaryColor = Colors.teal;
        break;
      case 'dark':
        primaryColor = Colors.blueGrey;
        break;
      default:
        primaryColor = const Color(0xFF1E8449);
    }

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      fontFamily: 'Amiri',
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// Settings Dialog
class SettingsDialog extends StatefulWidget {
  final String currentTheme;
  final bool isDarkMode;
  final Function(String) onThemeChanged;
  final Function(bool) onDarkModeChanged;

  const SettingsDialog({
    super.key,
    required this.currentTheme,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onDarkModeChanged,
  });
  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String _selectedTheme = 'green';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'الإعدادات',
        style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark Mode Switch
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SwitchListTile(
              title: const Text(
                'الوضع الليلي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _isDarkMode ? 'مفعّل' : 'غير مفعّل',
                style: const TextStyle(fontSize: 14),
              ),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                widget.onDarkModeChanged(value);
              },
              activeThumbColor: const Color(0xFF1E8449),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'اختر الثيم:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildThemeOption('green', 'أخضر (افتراضي)'),
          _buildThemeOption('turquoise', 'تركوازي أزرق'),
          _buildThemeOption('dark', 'أسود داكن'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _launchURL(
              'https://abdulmalik39.blogspot.com/2025/12/blog-post.html',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '🚫 اترك الإباحية/الإدمان',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _launchURL('https://wa.me/201559285943'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'التواصل مع المطور',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Widget _buildThemeOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedTheme,
      onChanged: (String? newValue) {
        setState(() {
          _selectedTheme = newValue!;
        });
        widget.onThemeChanged(newValue!);
        Navigator.of(context).pop();
      },
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// قائمة الأذكار الثابتة - تُعرَّف مرة واحدة على مستوى الملف
final Map<String, List<Map<String, dynamic>>> adhkarCategoriesData = {
  'morning': [
    {
      'id': 1,
      'title': 'آية الكرسي',
      'arabic':
          'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ\nاللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ.',
      'count': 1,
      'benefit': 'من قالها حين يصبح أجير من الجن حتى يمسي',
    },
    {
      'id': 2,
      'title': 'سيد الاستغفار',
      'arabic':
          'اللّهـمَّ أَنْتَ رَبِّـي لا إلهَ إلاّ أَنْتَ ، خَلَقْتَنـي وَأَنا عَبْـدُك ، وَأَنا عَلـى عَهْـدِكَ وَوَعْـدِكَ ما اسْتَـطَعْـت ، أَعـوذُبِكَ مِنْ شَـرِّ ما صَنَـعْت ، أَبـوءُ لَـكَ بِنِعْـمَتِـكَ عَلَـيَّ وَأَبـوءُ بِذَنْـبي فَاغْفـِرْ لي فَإِنَّـهُ لا يَغْـفِرُ الذُّنـوبَ إِلاّ أَنْتَ .',
      'count': 1,
      'benefit': 'من قالها موقنا بها حين يصبح ومات من يومه دخل الجنة',
    },
    {
      'id': 3,
      'title': 'أذكار الصباح',
      'arabic':
          'أَصْبَحْنَا وَأَصْبَحَ المـلكُ لله وَالحَمدُ لله ، لا إلهَ إلاّ اللّهُ وَحدَهُ لا شَريكَ لهُ، لهُ المُـلكُ ولهُ الحَمْـد، وهُوَ على كلّ شَيءٍ قدير ، رَبِّ أسْـأَلُـكَ خَـيرَ ما في هـذا اليوم وَخَـيرَ ما بَعْـدَه ، وَأَعـوذُ بِكَ مِنْ شَـرِّ ما في هـذا اليوم وَشَرِّ ما بَعْـدَه ، رَبِّ أَعـوذُبِكَ مِنَ الْكَسَـلِ وَسـوءِ الْكِـبَر ، رَبِّ أَعـوذُ بِكَ مِنْ عَـذابٍ في النّـارِ وَعَـذابٍ في القَـبْر.',
      'count': 1,
      'benefit': 'رواه أبو داود',
    },
    {
      'id': 4,
      'title': 'رضيت بالله ربا',
      'arabic':
          'رَضيـتُ بِاللهِ رَبَّـاً وَبِالإسْلامِ ديـناً وَبِمُحَـمَّدٍ صلى الله عليه وسلم نَبِيّـاً.',
      'count': 3,
      'benefit': 'من قالها حين يصبح كان حقا على الله أن يرضيه يوم القيامة.',
    },
    {
      'id': 5,
      'title': 'اللهم إني أصبحت أشهدك',
      'arabic':
          'اللّهُـمَّ إِنِّـي أَصبحتُ أُشْـهِدُك ، وَأُشْـهِدُ حَمَلَـةَ عَـرْشِـك ، وَمَلَائِكَتَكَ ، وَجَمـيعَ خَلْـقِك ، أَنَّـكَ أَنْـتَ اللهُ لا إلهَ إلاّ أَنْـتَ وَحْـدَكَ لا شَريكَ لَـك ، وَأَنَّ ُ مُحَمّـداً عَبْـدُكَ وَرَسـولُـك.',
      'count': 4,
      'benefit': 'من قالها أعتقه الله من النار.',
    },
    {
      'id': 6,
      'title': 'اللهم ما أصبح بي من نعمة',
      'arabic':
          'اللّهُـمَّ ما أَصبحَ بي مِـنْ نِعْـمَةٍ أَو بِأَحَـدٍ مِـنْ خَلْـقِك ، فَمِـنْكَ وَحْـدَكَ لا شريكَ لَـك ، فَلَـكَ الْحَمْـدُ وَلَـكَ الشُّكْـر.',
      'count': 1,
      'benefit': 'من قالها حين يصبح أدى شكر يومه.',
    },
    {
      'id': 7,
      'title': 'حسبي الله',
      'arabic':
          'حَسْبِـيَ اللّهُ لا إلهَ إلاّ هُوَ عَلَـيهِ تَوَكَّـلتُ وَهُوَ رَبُّ العَرْشِ العَظـيم.',
      'count': 7,
      'benefit': 'من قالها كفاه الله ما أهمه من أمر الدنيا والأخرة.',
    },
    {
      'id': 8,
      'title': 'بسم الله الذي لا يضر مع اسمه شيء',
      'arabic':
          'بِسـمِ اللهِ الذي لا يَضُـرُّ مَعَ اسمِـهِ شَيءٌ في الأرْضِ وَلا في السّمـاءِ وَهـوَ السّمـيعُ العَلـيم.',
      'count': 3,
      'benefit': 'لم يضره من الله شيء.',
    },
    {
      'id': 9,
      'title': 'اللهم بك أصبحنا',
      'arabic':
          'اللّهُـمَّ بِكَ أَصْـبَحْنا وَبِكَ أَمْسَـينا، وَبِكَ نَحْـيا وَبِكَ نَمُـوتُ وَإِلَـيْكَ الْمَصِيرُ.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 10,
      'title': 'أصبحنا على فطرة الإسلام',
      'arabic':
          'أَصْبَحْنَا عَلَى فِطْرَةِ الإسْلاَمِ، وَعَلَى كَلِمَةِ الإِخْلاَصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إبْرَاهِيمَ حَنِيفاً مُسْلِماً وَمَا كَانَ مِنَ المُشْرِكِينَ.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 11,
      'title': 'سبحان الله وبحمده',
      'arabic':
          'سُبْحـانَ اللهِ وَبِحَمْـدِهِ عَدَدَ خَلْـقِه ، وَرِضـا نَفْسِـه ، وَزِنَـةَ عَـرْشِـه ، وَمِـدادَ كَلِمـاتِـه.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 12,
      'title': 'اللهم عافني في بدني',
      'arabic':
          'اللّهُـمَّ عافِـني في بَدَنـي ، اللّهُـمَّ عافِـني في سَمْـعي ، اللّهُـمَّ عافِـني في بَصَـري ، لا إلهَ إلاّ أَنْـتَ.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 13,
      'title': 'اللهم إني أعوذ بك من الكفر والفقر',
      'arabic':
          'اللّهُـمَّ إِنّـي أَعـوذُ بِكَ مِنَ الْكُـفر ، وَالفَـقْر ، وَأَعـوذُ بِكَ مِنْ عَذابِ القَـبْر ، لا إلهَ إلاّ أَنْـتَ.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 14,
      'title': 'اللهم إني أسألك العفو والعافية',
      'arabic':
          'اللّهُـمَّ إِنِّـي أسْـأَلُـكَ العَـفْوَ وَالعـافِـيةَ في الدُّنْـيا وَالآخِـرَة ، اللّهُـمَّ إِنِّـي أسْـأَلُـكَ العَـفْوَ وَالعـافِـيةَ في ديني وَدُنْـيايَ وَأهْـلي وَمالـي ، اللّهُـمَّ اسْتُـرْ عـوْراتي وَآمِـنْ رَوْعاتـي ، اللّهُـمَّ احْفَظْـني مِن بَـينِ يَدَيَّ وَمِن خَلْفـي وَعَن يَمـيني وَعَن شِمـالي ، وَمِن فَوْقـي ، وَأَعـوذُ بِعَظَمَـتِكَ أَن أُغْـتالَ مِن تَحْتـي.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 15,
      'title': 'يا حي يا قيوم',
      'arabic':
          'يَا حَيُّ يَا قيُّومُ بِرَحْمَتِكَ أسْتَغِيثُ أصْلِحْ لِي شَأنِي كُلَّهُ وَلاَ تَكِلْنِي إلَى نَفْسِي طَـرْفَةَ عَيْنٍ.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 16,
      'title': 'أصبحنا وأصبح الملك لله رب العالمين',
      'arabic':
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ للهِ رَبِّ الْعَالَمَيْنِ، اللَّهُمَّ إِنَّي أسْأَلُكَ خَيْرَ هَذَا اليومِ فَتْحَهَا ونَصْرَهَا، ونُوْرَهَا وبَرَكَتهَا، وَهُدَاهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فيهِ وَشَرَّ مَا بَعْدَهَ.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 17,
      'title': 'اللهم عالم الغيب والشهادة',
      'arabic':
          'اللّهُـمَّ عالِـمَ الغَـيْبِ وَالشّـهادَةِ فاطِـرَ السّماواتِ وَالأرْضِ رَبَّ كـلِّ شَـيءٍ وَمَليـكَه ، أَشْهَـدُ أَنْ لا إِلـهَ إِلاّ أَنْت ، أَعـوذُ بِكَ مِن شَـرِّ نَفْسـي وَمِن شَـرِّ الشَّيْـطانِ وَشِرْكِهِ ، وَأَنْ أَقْتَـرِفَ عَلـى نَفْسـي سوءاً أَوْ أَجُـرَّهُ إِلـى مُسْـلِم.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 18,
      'title': 'أعوذ بكلمات الله التامات',
      'arabic':
          'أَعـوذُ بِكَلِمـاتِ اللّهِ التّـامّـاتِ مِنْ شَـرِّ ما خَلَـق.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 19,
      'title': 'الصلاة على النبي',
      'arabic': 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ على نَبِيِّنَا مُحمَّد.',
      'count': 10,
      'benefit': 'من صلى على حين يصبح ادركته شفاعتى يوم القيامة.',
    },
    {
      'id': 20,
      'title': 'اللهم إنا نعوذ بك أن نشرك بك شيئا',
      'arabic':
          'اللَّهُمَّ إِنَّا نَعُوذُ بِكَ مِنْ أَنْ نُشْرِكَ بِكَ شَيْئًا نَعْلَمُهُ ، وَنَسْتَغْفِرُكَ لِمَا لَا نَعْلَمُهُ.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 21,
      'title': 'اللهم إني أعوذ بك من الهم والحزن',
      'arabic':
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنْ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنْ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ، وَقَهْرِ الرِّجَالِ.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 22,
      'title': 'أستغفر الله العظيم',
      'arabic':
          'أسْتَغْفِرُ اللهَ العَظِيمَ الَّذِي لاَ إلَهَ إلاَّ هُوَ، الحَيُّ القَيُّومُ، وَأتُوبُ إلَيهِ.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 23,
      'title': 'يا رب لك الحمد',
      'arabic':
          'يَا رَبِّ , لَكَ الْحَمْدُ كَمَا يَنْبَغِي لِجَلَالِ وَجْهِكَ , وَلِعَظِيمِ سُلْطَانِكَ.',
      'count': 3,
      'benefit': '',
    },
    {
      'id': 24,
      'title': 'لا إله إلا الله وحده لا شريك له',
      'arabic':
          'لَا إلَه إلّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءِ قَدِيرِ.',
      'count': 100,
      'benefit':
          'كانت له عدل عشر رقاب، وكتبت له مئة حسنة، ومحيت عنه مئة سيئة، وكانت له حرزا من الشيطان.',
    },
    {
      'id': 25,
      'title': 'اللهم أنت ربي لا إله إلا أنت',
      'arabic':
          'اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلا أَنْتَ ، عَلَيْكَ تَوَكَّلْتُ ، وَأَنْتَ رَبُّ الْعَرْشِ الْعَظِيمِ , مَا شَاءَ اللَّهُ كَانَ ، وَمَا لَمْ يَشَأْ لَمْ يَكُنْ ، وَلا حَوْلَ وَلا قُوَّةَ إِلا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ , أَعْلَمُ أَنَّ اللَّهَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ ، وَأَنَّ اللَّهَ قَدْ أَحَاطَ بِكُلِّ شَيْءٍ عِلْمًا , اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي ، وَمِنْ شَرِّ كُلِّ دَابَّةٍ أَنْتَ آخِذٌ بِنَاصِيَتِهَا ، إِنَّ رَبِّي عَلَى صِرَاطٍ مُسْتَقِيمٍ.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 26,
      'title': 'سورة الإخلاص',
      'arabic':
          'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ هُوَ ٱللَّهُ أَحَدٌ، ٱللَّهُ ٱلصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ.',
      'count': 3,
      'benefit': 'من قالها حين يصبح وحين يمسى كفته من كل شىء.',
    },
    {
      'id': 27,
      'title': 'سورة الفلق',
      'arabic':
          'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ، مِن شَرِّ مَا خَلَقَ، وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلْعُقَدِ، وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ.',
      'count': 3,
      'benefit': 'من قالها حين يصبح وحين يمسى كفته من كل شىء.',
    },
    {
      'id': 28,
      'title': 'سورة الناس',
      'arabic':
          'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ، مَلِكِ ٱلنَّاسِ، إِلَٰهِ ٱلنَّاسِ، مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ، ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ، مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ.',
      'count': 3,
      'benefit': 'من قالها حين يصبح وحين يمسى كفته من كل شىء.',
    },
  ],
  'evening': [
    {
      'id': 29,
      'title': 'آية الكرسي',
      'arabic':
          'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ\nاللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ.',
      'count': 1,
      'benefit': 'من قالها حين يمسى أجير من الجن حتى يصبح.',
    },
    {
      'id': 30,
      'title': 'آخر آيتين من سورة البقرة',
      'arabic':
          'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ\nآمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ. لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَّسِينَآ أَوْ أَخْطَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ.',
      'count': 1,
      'benefit': 'من قرأ آيتين من آخر سورة البقرة في ليلة كفتاه.',
    },
    {
      'id': 31,
      'title': 'سيد الاستغفار',
      'arabic':
          'اللّهـمَّ أَنْتَ رَبِّـي لا إلهَ إلاّ أَنْتَ ، خَلَقْتَنـي وَأَنا عَبْـدُك ، وَأَنا عَلـى عَهْـدِكَ وَوَعْـدِكَ ما اسْتَـطَعْـت ، أَعـوذُبِكَ مِنْ شَـرِّ ما صَنَـعْت ، أَبـوءُ لَـكَ بِنِعْـمَتِـكَ عَلَـيَّ وَأَبـوءُ بِذَنْـبي فَاغْفـِرْ لي فَإِنَّـهُ لا يَغْـفِرُ الذُّنـوبَ إِلاّ أَنْتَ .',
      'count': 1,
      'benefit': 'من قالها موقنا بها حين يمسى ومات من ليلته دخل الجنة.',
    },
    {
      'id': 32,
      'title': 'أذكار المساء',
      'arabic':
          'أَمْسَيْـنا وَأَمْسـى المـلكُ لله وَالحَمدُ لله ، لا إلهَ إلاّ اللّهُ وَحدَهُ لا شَريكَ لهُ، لهُ المُـلكُ ولهُ الحَمْـد، وهُوَ على كلّ شَيءٍ قدير ، رَبِّ أسْـأَلُـكَ خَـيرَ ما في هـذهِ اللَّـيْلَةِ وَخَـيرَ ما بَعْـدَهـا ، وَأَعـوذُ بِكَ مِنْ شَـرِّ ما في هـذهِ اللَّـيْلةِ وَشَرِّ ما بَعْـدَهـا ، رَبِّ أَعـوذُبِكَ مِنَ الْكَسَـلِ وَسـوءِ الْكِـبَر ، رَبِّ أَعـوذُ بِكَ مِنْ عَـذابٍ في النّـارِ وَعَـذابٍ في القَـبْر.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 33,
      'title': 'رضيت بالله ربا',
      'arabic':
          'رَضيـتُ بِاللهِ رَبَّـاً وَبِالإسْلامِ ديـناً وَبِمُحَـمَّدٍ صلى الله عليه وسلم نَبِيّـاً.',
      'count': 3,
      'benefit': 'من قالها حين يمسى كان حقا على الله أن يرضيه يوم القيامة.',
    },
    {
      'id': 34,
      'title': 'اللهم إني أمسيت أشهدك',
      'arabic':
          'اللّهُـمَّ إِنِّـي أَمسيتُ أُشْـهِدُك ، وَأُشْـهِدُ حَمَلَـةَ عَـرْشِـك ، وَمَلَائِكَتَكَ ، وَجَمـيعَ خَلْـقِك ، أَنَّـكَ أَنْـتَ اللهُ لا إلهَ إلاّ أَنْـتَ وَحْـدَكَ لا شَريكَ لَـك ، وَأَنَّ ُ مُحَمّـداً عَبْـدُكَ وَرَسـولُـك.',
      'count': 4,
      'benefit': 'من قالها أعتقه الله من النار.',
    },
    {
      'id': 35,
      'title': 'اللهم ما أمسى بي من نعمة',
      'arabic':
          'اللّهُـمَّ ما أَمسى بي مِـنْ نِعْـمَةٍ أَو بِأَحَـدٍ مِـنْ خَلْـقِك ، فَمِـنْكَ وَحْـدَكَ لا شريكَ لَـك ، فَلَـكَ الْحَمْـدُ وَلَـكَ الشُّكْـر.',
      'count': 1,
      'benefit': 'من قالها حين يمسى أدى شكر يومه.',
    },
    {
      'id': 36,
      'title': 'حسبي الله',
      'arabic':
          'حَسْبِـيَ اللّهُ لا إلهَ إلاّ هُوَ عَلَـيهِ تَوَكَّـلتُ وَهُوَ رَبُّ العَرْشِ العَظـيم.',
      'count': 7,
      'benefit': 'من قالها كفاه الله ما أهمه من أمر الدنيا والأخرة.',
    },
    {
      'id': 37,
      'title': 'بسم الله الذي لا يضر مع اسمه شيء',
      'arabic':
          'بِسـمِ اللهِ الذي لا يَضُـرُّ مَعَ اسمِـهِ شَيءٌ في الأرْضِ وَلا في السّمـاءِ وَهـوَ السّمـيعُ العَلـيم.',
      'count': 3,
      'benefit': 'لم يضره من الله شيء.',
    },
    {
      'id': 38,
      'title': 'اللهم بك أمسينا',
      'arabic':
          'اللّهُـمَّ بِكَ أَمْسَـينا وَبِكَ أَصْـبَحْنا، وَبِكَ نَحْـيا وَبِكَ نَمُـوتُ وَإِلَـيْكَ الْمَصِيرُ.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 39,
      'title': 'أمسينا على فطرة الإسلام',
      'arabic':
          'أَمْسَيْنَا عَلَى فِطْرَةِ الإسْلاَمِ، وَعَلَى كَلِمَةِ الإِخْلاَصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إبْرَاهِيمَ حَنِيفاً مُسْلِماً وَمَا كَانَ مِنَ المُشْرِكِينَ.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 40,
      'title': 'أمسينا وأمسى الملك لله رب العالمين',
      'arabic':
          'أَمْسَيْنا وَأَمْسَى الْمُلْكُ للهِ رَبِّ الْعَالَمَيْنِ، اللَّهُمَّ إِنَّي أسْأَلُكَ خَيْرَ هَذَه اللَّيْلَةِ فَتْحَهَا ونَصْرَهَا، ونُوْرَهَا وبَرَكَتهَا، وَهُدَاهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فيهِا وَشَرَّ مَا بَعْدَهَا.',
      'count': 1,
      'benefit': '',
    },
    {
      'id': 41,
      'title': 'سورة الإخلاص',
      'arabic':
          'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ هُوَ ٱللَّهُ أَحَدٌ، ٱللَّهُ ٱلصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ.',
      'count': 3,
      'benefit': 'من قالها حين يمسى كفته من كل شىء.',
    },
    {
      'id': 42,
      'title': 'سورة الفلق',
      'arabic':
          'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ، مِن شَرِّ مَا خَلَقَ، وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلْعُقَدِ، وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ.',
      'count': 3,
      'benefit': 'من قالها حين يمسى كفته من كل شىء.',
    },
    {
      'id': 43,
      'title': 'سورة الناس',
      'arabic':
          'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ، مَلِكِ ٱلنَّاسِ، إِلَٰهِ ٱلنَّاسِ، مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ، ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ، مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ.',
      'count': 3,
      'benefit': 'من قالها حين يمسى كفته من كل شىء.',
    },
  ],
  'afterPrayer': [
    {
      'id': 44,
      'title': 'سبحان الله',
      'arabic': 'سُبْحَانَ اللَّهِ',
      'count': 33,
      'benefit': 'بعد كل صلاة',
    },
    {
      'id': 45,
      'title': 'الحمد لله',
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'count': 33,
      'benefit': 'بعد كل صلاة',
    },
    {
      'id': 46,
      'title': 'الله أكبر',
      'arabic': 'اللَّهُ أَكْبَرُ',
      'count': 33,
      'benefit': 'بعد كل صلاة',
    },
    {
      'id': 47,
      'title': 'لا إله إلا الله وحده لا شريك له',
      'arabic':
          'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      'count': 10,
      'benefit': 'بعد كل صلاة',
    },
    {
      'id': 48,
      'title': 'الاستغفار',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'count': 3,
      'benefit': 'بعد كل صلاة',
    },
    {
      'id': 49,
      'title': 'لا حول ولا قوة إلا بالله',
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'count': 10,
      'benefit': 'بعد كل صلاة',
    },
    {
      'id': 50,
      'title': 'آية الكرسي',
      'arabic': 'آية الكرسي',
      'count': 1,
      'benefit': 'بعد صلاة الفجر والمغرب',
    },
    {
      'id': 51,
      'title': 'الصلاة على النبي',
      'arabic': 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ على نَبِيِّنَا مُحمَّد.',
      'count': 10,
      'benefit': 'بعد الصلاة',
    },
    {
      'id': 52,
      'title': 'سورة الإخلاص والمعوذتين',
      'arabic': 'قراءة سورة الإخلاص والمعوذتين',
      'count': 3,
      'benefit': 'بعد صلاة الفجر والمغرب',
    },
  ],
  'wakeup': [
    {
      'id': 53,
      'title': 'الحمد لله الذي أحيانا بعد ما أماتنا',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'count': 1,
      'benefit': 'عند الاستيقاظ',
    },
    {
      'id': 54,
      'title': 'لا إله إلا الله',
      'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'count': 10,
      'benefit': 'عند الاستيقاظ',
    },
    {
      'id': 55,
      'title': 'اللهم إني أسألك خير هذا اليوم',
      'arabic':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هٰذَا الْيَوْمِ فَتْحَهُ وَنَصْرَهُ وَنُورَهُ وَبَرَكَتَهُ وَهُدَاهُ',
      'count': 1,
      'benefit': 'عند الاستيقاظ',
    },
    {
      'id': 56,
      'title': 'أعوذ بكلمات الله التامات',
      'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ شَرِّ مَا خَلَقَ',
      'count': 3,
      'benefit': 'عند الاستيقاظ للحماية من الشر',
    },
    {
      'id': 57,
      'title': 'بسم الله الرحمن الرحيم',
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'count': 1,
      'benefit': 'عند الاستيقاظ',
    },
  ],
  'sleep': [
    {
      'id': 58,
      'title': 'بسم الله أموت وأحيا',
      'arabic': 'بِسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'count': 1,
      'benefit': 'قبل النوم',
    },
    {
      'id': 59,
      'title': 'اللهم أسلمت نفسي إليك',
      'arabic':
          'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ',
      'count': 1,
      'benefit': 'قبل النوم',
    },
    {
      'id': 60,
      'title': 'الحمد لله الذي أطعمنا وسقانا وكفانا وآوانا',
      'arabic':
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا',
      'count': 1,
      'benefit': 'قبل النوم',
    },
    {
      'id': 61,
      'title': 'أعوذ بكلمات الله التامات',
      'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ شَرِّ مَا خَلَقَ',
      'count': 3,
      'benefit': 'قبل النوم للحماية من الشر',
    },
    {
      'id': 62,
      'title': 'سورة الإخلاص والمعوذتين',
      'arabic': 'قراءة سورة الإخلاص والمعوذتين ثلاث مرات',
      'count': 1,
      'benefit': 'قبل النوم للحماية من الشر',
    },
    {
      'id': 63,
      'title': 'آية الكرسي',
      'arabic': 'آية الكرسي',
      'count': 1,
      'benefit': 'قبل النوم للحماية',
    },
    {
      'id': 64,
      'title': 'اللهم باسمك أحيا وأموت',
      'arabic': 'اللَّهُمَّ بِاسْمِكَ أَحْيَا وَبِاسْمِكَ أَمُوتُ',
      'count': 1,
      'benefit': 'قبل النوم',
    },
  ],
};

// أذكار بتصميم جديد مع شريط التقدم والعداد
class AdhkarSection extends StatefulWidget {
  final Function(String) addBookmark;
  final bool isDarkMode;

  const AdhkarSection({
    super.key,
    required this.addBookmark,
    required this.isDarkMode,
  });

  @override
  _AdhkarSectionState createState() => _AdhkarSectionState();
}

class _AdhkarSectionState extends State<AdhkarSection> {
  int currentAdhkarIndex = 0;
  int currentCount = 0;
  int targetCount = 3;
  bool isCompleted = false;
  String currentCategory = 'morning';

  // قائمة آيات السجدة من الملف الثاني
  final List<Map<String, int>> sajdahAyahs = [
    {'surah': 7, 'ayah': 206}, // الأعراف
    {'surah': 13, 'ayah': 15}, // الرعد
    {'surah': 16, 'ayah': 49}, // النحل
    {'surah': 17, 'ayah': 107}, // الإسراء
    {'surah': 19, 'ayah': 58}, // مريم
    {'surah': 22, 'ayah': 18}, // الحج
    {'surah': 22, 'ayah': 77}, // الحج
    {'surah': 25, 'ayah': 60}, // الفرقان
    {'surah': 27, 'ayah': 25}, // النمل
    {'surah': 32, 'ayah': 15}, // السجدة
    {'surah': 38, 'ayah': 24}, // ص
    {'surah': 41, 'ayah': 37}, // فصلت
    {'surah': 53, 'ayah': 62}, // النجم
    {'surah': 84, 'ayah': 21}, // الانشقاق
    {'surah': 96, 'ayah': 19}, // العلق
  ];

  // قائمة الأذكار - تستخدم المتغير الثابت الخارجي
  Map<String, List<Map<String, dynamic>>> get adhkarCategories =>
      adhkarCategoriesData;
  @override
  void initState() {
    super.initState();
    // تحميل الأذكار عند بدء القسم
    Future.delayed(Duration.zero, () {
      _loadCurrentAdhkar();
    });
  }

  void _loadCurrentAdhkar() {
    // التحقق من وجود الفئة
    if (!adhkarCategoriesData.containsKey(currentCategory)) {
      currentCategory = 'morning';
    }

    final categoryData = adhkarCategoriesData[currentCategory];

    // التحقق من صحة الفهرس
    if (categoryData == null ||
        categoryData.isEmpty ||
        currentAdhkarIndex >= categoryData.length) {
      currentAdhkarIndex = 0;
    }

    // تحديث القيم
    if (categoryData != null &&
        categoryData.isNotEmpty &&
        currentAdhkarIndex < categoryData.length) {
      final currentAdhkar = categoryData[currentAdhkarIndex];
      targetCount = currentAdhkar['count'] ?? 3;
    } else {
      targetCount = 3;
    }

    currentCount = 0;
    isCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFf0f8f0), Color(0xFFe8f5e8)],
          ),
        ),
        child: Column(
          children: [
            _buildCategoryButtons(),
            _buildProgressBar(),
            Expanded(
              child: _buildAdhkarContent(),
            ),
            _buildBottomControls(),
            // زر إعادة تشغيل سريع
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    currentCategory = 'morning';
                    currentAdhkarIndex = 0;
                    currentCount = 0;
                    isCompleted = false;
                  });
                  _loadCurrentAdhkar();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('إعادة تشغيل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCategoryButton('morning', 'أذكار الصباح'),
          _buildCategoryButton('evening', 'أذكار المساء'),
          _buildCategoryButton('sleep', 'أذكار النوم'),
          _buildCategoryButton('wakeup', 'أذكار الاستيقاظ'),
          _buildCategoryButton('afterPrayer', 'بعد الصلاة'),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category, String title) {
    bool isActive = currentCategory == category;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () {
            if (adhkarCategoriesData.containsKey(category)) {
              setState(() {
                currentCategory = category;
                currentAdhkarIndex = 0;
              });
              _loadCurrentAdhkar();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? const Color(0xFF1E8449) : Colors.white,
            foregroundColor: isActive ? Colors.white : const Color(0xFF1E8449),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF1E8449), width: 1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final categoryData = adhkarCategoriesData[currentCategory];
    final totalItems = categoryData?.length ?? 1;
    final progress = (currentAdhkarIndex + 1) / totalItems;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // رقم السورة
          Text(
            '${currentAdhkarIndex + 1}/$totalItems',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E8449),
            ),
          ),
          const SizedBox(width: 12),
          // شريط التقدم
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF27AE60),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdhkarContent() {
    final categoryData = adhkarCategoriesData[currentCategory];

    // التحقق من وجود البيانات
    if (categoryData == null ||
        categoryData.isEmpty ||
        currentAdhkarIndex >= categoryData.length) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'لا توجد أذكار متاحة في هذه الفئة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final currentAdhkar = categoryData[currentAdhkarIndex];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // رقم السورة مع نقطة الإنجاز
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: currentAdhkarIndex == 0 && currentCount == 0
                      ? const Color(0xFF1E8449)
                      : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${currentAdhkarIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '● ${currentAdhkar['title']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E8449),
                  ),
                ),
              ),
              Text(
                currentCount >= targetCount ? '✓' : '○',
                style: TextStyle(
                  fontSize: 20,
                  color:
                      currentCount >= targetCount ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // نص الأذكار
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f6f0),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFd4b896), width: 1),
              ),
              child: Text(
                currentAdhkar['arabic'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Amiri',
                  color: Color(0xFF2c3e50),
                  height: 2,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // عداد المرات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                targetCount == 1 ? 'مرة واحدة' : '$targetCount مرات',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E8449),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '[ ${targetCount - currentCount} ]',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          // زر العد
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: currentCount < targetCount ? _incrementCount : null,
              icon: const Icon(Icons.touch_app, size: 20),
              label: Text(
                currentCount < targetCount
                    ? 'العد (${targetCount - currentCount})'
                    : 'مكتمل',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentCount < targetCount
                    ? const Color(0xFF27AE60)
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // زر التالي
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: _nextAdhkar,
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: const Text('التالي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8449),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _incrementCount() {
    if (currentCount < targetCount) {
      setState(() {
        currentCount++;
        if (currentCount >= targetCount) {
          isCompleted = true;
          // الانتقال التلقائي للذكر التالي
          Future.delayed(const Duration(milliseconds: 500), () {
            _nextAdhkar();
          });
        }
      });
    }
  }

  void _nextAdhkar() {
    final categoryData = adhkarCategoriesData[currentCategory];
    if (categoryData == null || categoryData.isEmpty) {
      return;
    }

    if (currentAdhkarIndex < categoryData.length - 1) {
      setState(() {
        currentAdhkarIndex++;
        _loadCurrentAdhkar();
      });
    } else {
      // إذا كان آخر ذكر
      _showCompletionDialog();
    }
  }

  void _previousAdhkar() {
    if (currentAdhkarIndex > 0) {
      setState(() {
        currentAdhkarIndex--;
        _loadCurrentAdhkar();
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 مبروك!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E8449),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'تم الانتهاء من جميع الأذكار',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF27AE60),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartAdhkar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('إعادة البدء'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _restartAdhkar() {
    setState(() {
      currentAdhkarIndex = 0;
      _loadCurrentAdhkar();
    });
  }
}

// Quran Section
class QuranSection extends StatefulWidget {
  final Function(String) addBookmark;
  final bool isDarkMode;

  const QuranSection({
    super.key,
    required this.addBookmark,
    required this.isDarkMode,
  });

  @override
  _QuranSectionState createState() => _QuranSectionState();
}

class _QuranSectionState extends State<QuranSection> {
  List<Map<String, dynamic>> surahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      // قراءة ملف JSON من assets
      final String response = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/Quran.json');

      // تحويل JSON إلى List مباشرة (لأن الجذر هو مصفوفة)
      final List<dynamic> surahsData = json.decode(response);

      // تحويل البيانات إلى تنسيق متوافق مع الكود الموجود
      surahs = surahsData.map((surahData) {
        final surah = Map<String, dynamic>.from(surahData);

        // تحويل البنية إلى التنسيق المتوقع
        return {
          'number': surah['id'],
          'name': surah['name'],
          'englishName': surah['name_translation'] ?? surah['name_en'] ?? '',
          'numberOfAyahs': surah['array'].length,
          'revelationType': surah['type_en'] == 'meccan' ? 'Meccan' : 'Medinan',
          'ayahs': (surah['array'] as List).map((ayahData) {
            final ayah = Map<String, dynamic>.from(ayahData);
            return {
              'number': ayah['id'],
              'numberInSurah': ayah['id'], // إضافة numberInSurah للتوافق
              'text': ayah['ar'],
              'text_en': ayah['en'],
            };
          }).toList(),
        };
      }).toList();

      setState(() {
        isLoading = false;
      });

      print('تم تحميل ${surahs.length} سورة بنجاح');
    } catch (e) {
      print('خطأ في قراءة ملف القرآن: $e');

      // في حالة وجود خطأ، استخدم البيانات الاحتياطية
      _loadSurahsBackup();
    }
  }

  void _loadSurahsBackup() {
    // بيانات احتياطية في حالة فشل قراءة الملف
    surahs = [
      {
        'number': 1,
        'name': 'الفاتحة',
        'englishName': 'Al-Fatihah',
        'numberOfAyahs': 7,
        'revelationType': 'Meccan',
        'ayahs': [
          {'number': 1, 'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'},
          {'number': 2, 'text': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
          {'number': 3, 'text': 'الرَّحْمَٰنِ الرَّحِيمِ'},
          {'number': 4, 'text': 'مَالِكِ يَوْمِ الدِّينِ'},
          {'number': 5, 'text': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'},
          {'number': 6, 'text': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ'},
          {
            'number': 7,
            'name': 'حديث الدين النصيحة',
            'text':
                'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          },
        ],
      },
      {
        'number': 112,
        'name': 'الإخلاص',
        'englishName': 'Al-Ikhlas',
        'numberOfAyahs': 4,
        'revelationType': 'Meccan',
        'ayahs': [
          {'number': 1, 'text': 'قُلْ هُوَ اللَّهُ أَحَدٌ'},
          {'number': 2, 'text': 'اللَّهُ الصَّمَدُ'},
          {'number': 3, 'text': 'لَمْ يَلِدْ وَلَمْ يُولَدْ'},
          {'number': 4, 'text': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'},
        ],
      },
      {
        'number': 113,
        'name': 'الفلق',
        'englishName': 'Al-Falaq',
        'numberOfAyahs': 5,
        'revelationType': 'Meccan',
        'ayahs': [
          {'number': 1, 'text': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ'},
          {'number': 2, 'text': 'مِن شَرِّ مَا خَلَقَ'},
          {'number': 3, 'text': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ'},
          {'number': 4, 'text': 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ'},
          {'number': 5, 'text': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ'},
        ],
      },
      {
        'number': 114,
        'name': 'الناس',
        'englishName': 'An-Nas',
        'numberOfAyahs': 6,
        'revelationType': 'Meccan',
        'ayahs': [
          {'number': 1, 'text': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ'},
          {'number': 2, 'text': 'مَلِكِ النَّاسِ'},
          {'number': 3, 'text': 'إِلَٰهِ النَّاسِ'},
          {'number': 4, 'text': 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ'},
          {'number': 5, 'text': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ'},
          {'number': 6, 'text': 'مِنَ الْجِنَّةِ وَالنَّاسِ'},
        ],
      },
    ];

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E8449)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return _buildSurahCard(surah);
      },
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> surah) {
    String icon = surah['revelationType'] == 'Meccan' ? '🕋' : '🕌';
    String typeText = surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showSurahDetail(surah),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Surah number
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E8449),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${surah['number']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Icon and info
              Expanded(
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2c3e50),
                              fontFamily: 'Amiri',
                            ),
                          ),
                          Text(
                            '$typeText - ${surah['numberOfAyahs']} آية',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7f8c8d),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bookmark button
              IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () => widget.addBookmark('سورة ${surah['name']}'),
                color: const Color(0xFF1E8449),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSurahDetail(Map<String, dynamic> surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(
          surah: surah,
          addBookmark: widget.addBookmark,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }
}

// Surah Detail Screen
class SurahDetailScreen extends StatefulWidget {
  final Map<String, dynamic> surah;
  final Function(String) addBookmark;
  final bool isDarkMode;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.addBookmark,
    required this.isDarkMode,
  });

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double fontSize = 28.0;

  // قائمة آيات السجدة من الملف الثاني
  final List<Map<String, int>> sajdahAyahs = [
    {'surah': 7, 'ayah': 206}, // الأعراف
    {'surah': 13, 'ayah': 15}, // الرعد
    {'surah': 16, 'ayah': 49}, // النحل
    {'surah': 17, 'ayah': 107}, // الإسراء
    {'surah': 19, 'ayah': 58}, // مريم
    {'surah': 22, 'ayah': 18}, // الحج
    {'surah': 22, 'ayah': 77}, // الحج
    {'surah': 25, 'ayah': 60}, // الفرقان
    {'surah': 27, 'ayah': 25}, // النمل
    {'surah': 32, 'ayah': 15}, // السجدة
    {'surah': 38, 'ayah': 24}, // ص
    {'surah': 41, 'ayah': 37}, // فصلت
    {'surah': 53, 'ayah': 62}, // النجم
    {'surah': 84, 'ayah': 21}, // الانشقاق
    {'surah': 96, 'ayah': 19}, // العلق
  ];

  // دالة للتحقق إذا كانت الآية تحتوي على سجدة
  bool _isSajdahAyah(int ayahNumberInSurah) {
    final surahNumber = widget.surah['number'];
    return sajdahAyahs.any(
      (sajdah) =>
          sajdah['surah'] == surahNumber && sajdah['ayah'] == ayahNumberInSurah,
    );
  }

  void _adjustFontSize(double change) {
    setState(() {
      fontSize = (fontSize + change).clamp(16.0, 40.0);
    });
  }

  Future<void> _playAudio() async {
    // رقم السورة (بتنسيق 3 أرقام، مثل 001، 002، ...، 114)
    final surahNumber = widget.surah['number'].toString().padLeft(3, '0');

    // رابط الصوت من mp3quran.net (قارئ السديس)
    final audioUrl = 'https://server.mp3quran.net/sudais/$surahNumber.mp3';

    // محاولة فتح رابط الصوت
    try {
      final Uri url = Uri.parse(audioUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('لا يمكن تشغيل الصوت')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ في تشغيل الصوت')));
      }
    }
  }

  // قائمة المفسرين المتاحة
  final List<Map<String, dynamic>> tafsirs = [
    {'id': 1, 'name': 'تفسير السعدي'},
    {'id': 2, 'name': 'تفسير الجلالين'},
    {'id': 3, 'name': 'تفسير ابن كثير'},
    {'id': 4, 'name': 'تفسير الطبري'},
    {'id': 86, 'name': 'التفسير الميسر'},
  ];

  // دالة لعرض قائمة المفسرين
  void _showTafsirOptions(int ayahNumberInSurah) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFf8f6f0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'اختر المفسر',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E8449),
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tafsirs.length,
              itemBuilder: (context, index) {
                final tafsir = tafsirs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      tafsir['name'],
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color: Color(0xFF2c3e50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _fetchAndShowTafsir(tafsir['id'], ayahNumberInSurah);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: Color(0xFF1E8449),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // دالة لجلب وعرض التفسير
  Future<void> _fetchAndShowTafsir(int tafsirId, int ayahNumberInSurah) async {
    // عرض رسالة تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF1E8449)),
        );
      },
    );

    try {
      final surahNumber = widget.surah['number'];
      final ayahKey = '$surahNumber:$ayahNumberInSurah';
      final url =
          'https://api.quran.com/api/v4/tafsirs/$tafsirId/by_ayah/$ayahKey';

      final response = await http.get(Uri.parse(url));

      // إغلاق رسالة التحميل
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tafsirText = data['tafsir']['text'] ?? 'لا يوجد تفسير متاح';

        // عرض التفسير
        if (mounted) {
          _showTafsirDialog(tafsirText, ayahNumberInSurah);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ في تحميل التفسير')),
          );
        }
      }
    } catch (e) {
      // إغلاق رسالة التحميل
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  // دالة لعرض التفسير
  void _showTafsirDialog(String tafsirText, int ayahNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFf8f6f0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'تفسير الآية $ayahNumber',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E8449),
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Text(
              tafsirText,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: Color(0xFF2c3e50),
                height: 1.8,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: Color(0xFF1E8449),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isDarkMode ? const Color(0xFF1a1a1a) : const Color(0xFFf8f6f0),
      appBar: AppBar(
        title: Text('سورة ${widget.surah['name']}'),
        backgroundColor: const Color(0xFF1E8449),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _playAudio(),
            tooltip: 'استماع للسورة',
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () => widget.addBookmark('سورة ${widget.surah['name']}'),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFf8f6f0),
          border: Border.all(color: const Color(0xFFd4b896), width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFd4b896)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: _buildSurahContent(),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            onPressed: () => _adjustFontSize(2),
            backgroundColor: const Color(0xFF1E8449),
            mini: true,
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            onPressed: () => _adjustFontSize(-2),
            backgroundColor: const Color(0xFF1E8449),
            mini: true,
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahContent() {
    final ayahs = widget.surah['ayahs'] as List;
    List<Widget> content = [];

    // Add Bismillah (except for Surah 9 and 1)
    if (widget.surah['number'] != 9 && widget.surah['number'] != 1) {
      content.add(
        Container(
          margin: const EdgeInsets.only(bottom: 25),
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E8449),
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Add all verses with continuous scroll
    List<InlineSpan> spans = [];
    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      final ayahNumberInSurah = ayah['numberInSurah'] ?? (i + 1);
      final isSajdah = _isSajdahAyah(ayahNumberInSurah);

      spans.add(
        TextSpan(
          text: '${ayah['text']} ',
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'Amiri',
            color: const Color(0xFF2c3e50),
            height: 2.2,
          ),
        ),
      );

      // رقم الآية
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () {
              _showTafsirOptions(ayahNumberInSurah);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1E8449),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$ayahNumberInSurah',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // علامة السجدة إذا كانت آية سجدة
      if (isSajdah) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.only(right: 4, left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD35400),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '۩',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }

      spans.add(const TextSpan(text: ' '));
    }

    content.add(
      RichText(
        text: TextSpan(children: spans),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: content,
    );
  }
}

// Tasbih Section (مطابق للكود الأصلي)
class TasbihSection extends StatefulWidget {
  const TasbihSection({super.key});

  @override
  _TasbihSectionState createState() => _TasbihSectionState();
}

class _TasbihSectionState extends State<TasbihSection> {
  int counter = 0;
  bool soundEnabled = true;
  String currentDhikr = 'سبحان الله';
  String selectedDhikr = 'سبحان الله';
  TextEditingController customDhikrController = TextEditingController();
  bool showCustomInput = false;

  // قائمة الأذكار المخصصة
  final List<String> customDhikrs = [
    'سبحان الله',
    'الحمد لله',
    'اللهم صلي وسلم وبارك على سيدنا محمد',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'سبحان الله وبحمده',
    'لا حول ولا قوة إلا بالله',
  ];

  final List<String> dhikrOptions = [
    'سبحان الله',
    'الحمد لله',
    'اللهم صلي وسلم وبارك على سيدنا محمد',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'سبحان الله وبحمده',
    'لا حول ولا قوة إلا بالله',
  ];

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void resetCounter() {
    setState(() {
      counter = 0;
    });
  }

  void toggleSound() {
    setState(() {
      soundEnabled = !soundEnabled;
    });
  }

  void setCustomDhikr() {
    if (customDhikrController.text.trim().isNotEmpty) {
      setState(() {
        final newDhikr = customDhikrController.text.trim();

        // إضافة الذكر إلى قائمة الأذكار المخصصة إذا لم يكن موجوداً
        if (!customDhikrs.contains(newDhikr)) {
          customDhikrs.add(newDhikr);
        }

        // إضافة الذكر إلى قائمة الخيارات إذا لم يكن موجوداً
        if (!dhikrOptions.contains(newDhikr)) {
          dhikrOptions.add(newDhikr);
        }

        currentDhikr = newDhikr;
        selectedDhikr = newDhikr;
        showCustomInput = false;

        // مسح النص من الحقل
        customDhikrController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text(
            'التسبيح الإلكتروني',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Dhikr Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1E8449), width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: DropdownButton<String>(
              value: selectedDhikr,
              isExpanded: true,
              underline: const SizedBox(),
              items: [...customDhikrs, 'إضافة ذكر مخصص'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontFamily: 'Amiri'),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue == 'إضافة ذكر مخصص') {
                    showCustomInput = true;
                  } else {
                    selectedDhikr = newValue!;
                    currentDhikr = newValue;
                    showCustomInput = false;
                  }
                });
              },
            ),
          ),

          // Custom Dhikr Input
          if (showCustomInput) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: customDhikrController,
                    decoration: InputDecoration(
                      hintText: 'أدخل الذكر المخصص',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF1E8449)),
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: setCustomDhikr,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8449),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'تعيين',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),

          // Tasbih Counter
          GestureDetector(
            onTap: incrementCounter,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E8449), Color(0xFF27AE60)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E8449).withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$counter',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentDhikr,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: resetCounter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8449),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'إعادة تعيين',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: toggleSound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8449),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'الصوت: ${soundEnabled ? 'مفعل' : 'معطل'}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Hadith Section (حديث اليوم)
class HadithSection extends StatefulWidget {
  const HadithSection({super.key});

  @override
  _HadithSectionState createState() => _HadithSectionState();
}

class _HadithSectionState extends State<HadithSection> {
  int currentHadithIndex = 0;

  static final List<Map<String, dynamic>> hadithData = [
    {
      'number': 1,
      'name': 'حديث النية',
      'text':
          'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى، فمن كانت هجرته إلى الله ورسوله فهجرته إلى الله ورسوله، ومن كانت هجرته لدنيا يصيبها أو امرأة ينكحها فهجرته إلى ما هاجر إليه',
      'explanation':
          'هذا الحديث أصل عظيم في الإسلام، فجميع الأعمال تتوقف على النية. فمن هاجر لله ورسوله فله أجر الهجرة، ومن هاجر للدنيا أو امرأة فليس له إلا ما نوى. وهذا يدل على عظم مكانة النية في الإسلام',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 2,
      'name': 'حديث جبريل',
      'text':
          'بينما نحن جلوس عند رسول الله ذات يوم، إذ طلع علينا رجل شديد بياض الثياب، شديد سواد الشعر، لا يرى عليه أثر السفر، ولا يعرفه منا أحد. حتى جلس إلى النبي. فأسند ركبتيه إلى ركبتيه، ووضع كفيه على فخذيه، وقال: يا محمد أخبرني عن الإسلام. فقال رسول الله: الإسلام أن تشهد أن لا إله إلا الله وأن محمدا رسول الله، وتقيم الصلاة، وتؤتي الزكاة، وتصوم رمضان، وتحج البيت إن استطعت إليه سبيلا. قال: صدقت. فعجبنا له يسأله ويصدقه! قال: فأخبرني عن الإيمان. قال: أن تؤمن بالله وملائكته وكتبه ورسله واليوم الآخر، وتؤمن بالقدر خيره وشره. قال: صدقت. قال: فأخبرني عن الإحسان. قال: أن تعبد الله كأنك تراه، فإن لم تكن تراه فإنه يراك. قال: فأخبرني عن الساعة. قال: ما المسئول عنها بأعلم من السائل. قال: فأخبرني عن أماراتها؟ قال: أن تلد الأمة ربتها، وأن ترى الحفاة العراة العالة رعاء الشاء يتطاولون في البنيان. ثم انطلق، فلبثنا مليا، ثم قال: يا عمر أتدري من السائل؟. قلت: الله ورسوله أعلم. قال: فإنه جبريل أتاكم يعلمكم دينكم',
      'explanation':
          'هذا الحديث يبين أركان الإسلام والإيمان والإحسان. فهو جامع لأصول الدين، حيث بين الإسلام بشهادة أن لا إله إلا الله وإقام الصلاة وإيتاء الزكاة وصوم رمضان وحج البيت، والإيمان بالإيمان بالله وملائكته وكتبه ورسله واليوم الآخر والقدر خيره وشره، والإحسان بأن تعبد الله كأنك تراه',
      'reference': 'رواه مسلم',
    },
    {
      'number': 3,
      'name': 'حديث أركان الإسلام',
      'text':
          'بني الإسلام على خمس: شهادة أن لا إله إلا الله وأن محمدا رسول الله، وإقام الصلاة، وإيتاء الزكاة، وحج البيت، وصوم رمضان',
      'explanation':
          'هذا الحديث يبين الأركان الخمسة التي بني عليها الإسلام، وهي الأساس الذي يقوم عليه الدين، وتشمل الشهادتين وإقام الصلاة وإيتاء الزكاة وصوم رمضان وحج البيت لمن استطاع إليه سبيلا',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 4,
      'name': 'حديث الخلق والأقدار',
      'text':
          'إن أحدكم يجمع خلقه في بطن أمه أربعين يوما نطفة، ثم يكون علقة مثل ذلك، ثم يكون مضغة مثل ذلك، ثم يرسل إليه الملك فينفخ فيه الروح، ويؤمر بأربع كلمات: بكتب رزقه، وأجله، وعمله، وشقي أم سعيد؛ فوالله الذي لا إله غيره إن أحدكم ليعمل بعمل أهل الجنة حتى ما يكون بينه وبينها إلا ذراع فيسبق عليه الكتاب فيعمل بعمل أهل النار فيدخلها. وإن أحدكم ليعمل بعمل أهل النار حتى ما يكون بينه وبينها إلا ذراع فيسبق عليه الكتاب فيعمل بعمل أهل الجنة فيدخلها',
      'explanation':
          'هذا الحديث يبين مراحل خلق الإنسان في بطن أمه، وأن الله تعالى يقدر أرزاق العباد وآجالهم وأعمالهم وهم في الأرحام. كما يؤكد على أن الخاتمة هي التي تحدد مصير الإنسان، فقد يعمل الإنسان بعمل أهل الجنة ثم تختم له بخاتمة سوء فيدخل النار، والعكس صحيح',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 5,
      'name': 'حديث البدع',
      'text': 'من أحدث في أمرنا هذا ما ليس فيه فهو رد',
      'explanation':
          'هذا الحديث أصل من أصول الإسلام، ويبين أن كل بدعة في الدين مردودة على صاحبها، وأن الإسلام كامل لا يحتاج إلى زيادة ولا نقصان. فمن اخترع في الدين ما ليس منه فهو مبتدع وبدعته مردودة',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 6,
      'name': 'حديث الحلال والحرام',
      'text':
          'إن الحلال بين وإن الحرام بين، وبينهما أمور مشتبهات لا يعلمهن كثير من الناس، فمن اتقى الشبهات فقد استبرأ لدينه وعرضه، ومن وقع في الشبهات وقع في الحرام، كالراعي يرعى حول الحمى يوشك أن يرتع فيه، ألا وإن لكل ملك حمى، ألا وإن حمى الله محارمه، ألا وإن في الجسد مضغة إذا صلحت صلح الجسد كله، وإذا فسدت فسد الجسد كله، ألا وهي القلب',
      'explanation':
          'هذا الحديث يبين أن الحلال واضح والحرام واضح، وبينهما أمور مشتبهات. فمن ترك الشبهات فقد حصن دينه وعرضه، ومن تعاطى الشبهات فقد تعرض للحرام. كما بين الحديث أن القلب هو أساس صلاح الجسد كله أو فساده',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 7,
      'name': 'حديث الدين النصيحة',
      'text':
          'الدين النصيحة. قلنا: لمن؟ قال لله، ولكتابه، ولرسوله، ولأئمة المسلمين وعامتهم',
      'explanation':
          'هذا الحديث يبين أن الدين كله قائم على النصيحة، وهي الإخلاص في القول والعمل. والنصيحة تكون لله ولرسوله ولكتاب الله ولأئمة المسلمين وعامتهم. فالنصيحة لله بالإيمان به وعبادته، ولرسوله بطاعته، وللكتاب بتعلمه وتعليمه، وللأئمة بطاعتهم في المعروف، ولعامة المسلمين بمحبة الخير لهم',
      'reference': 'رواه مسلم',
    },
    {
      'number': 8,
      'name': 'حديث حرمة المسلم',
      'text':
          'أمرت أن أقاتل الناس حتى يشهدوا أن لا إله إلا الله وأن محمدا رسول الله، ويقيموا الصلاة، ويؤتوا الزكاة؛ فإذا فعلوا ذلك عصموا مني دماءهم وأموالهم إلا بحق الإسلام، وحسابهم على الله تعالى',
      'explanation':
          'هذا الحديث يبين أن الإسلام يحمي الدماء والأموال بالشهادتين وإقامة الصلاة وإيتاء الزكاة. فمن أتى بهذه الأمور فقد عصم دمه وماله، إلا إذا ارتكب ما يبيح دمه أو ماله بحق الإسلام',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 9,
      'name': 'حديث الابتعاد عن الشبهات',
      'text':
          'ما نهيتكم عنه فاجتنبوه، وما أمرتكم به فأتوا منه ما استطعتم، فإنما أهلك الذين من قبلكم كثرة مسائلهم واختلافهم على أنبيائهم',
      'explanation':
          'هذا الحديث يأمر باجتناب المنهيات وفعل المأمورات حسب الاستطاعة. ويحذر من كثرة السؤال والاختلاف، كما فعلت الأمم السابقة، مما كان سببا في هلاكهم',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 10,
      'name': 'حديث الطيبات',
      'text':
          'إن الله طيب لا يقبل إلا طيبا، وإن الله أمر المؤمنين بما أمر به المرسلين فقال تعالى: "يا أيها الرسل كلوا من الطيبات واعملوا صالحا"، وقال تعالى: "يا أيها الذين آمنوا كلوا من طيبات ما رزقناكم" ثم ذكر الرجل يطيل السفر أشعث أغبر يمد يديه إلى السماء: يا رب! يا رب! ومطعمه حرام، ومشربه حرام، وملبسه حرام، وغذي بالحرام، فأنى يستجاب له؟',
      'explanation':
          'هذا الحديث يبين أن الله تعالى طيب لا يقبل إلا الطيب من الأقوال والأعمال. ويحذر من أكل الحرام، فإنه مانع من إجابة الدعاء، كما في مثال الرجل الذي يأكل الحرام ويدعو الله، فلا يستجاب له',
      'reference': 'رواه مسلم',
    },
    {
      'number': 11,
      'name': 'حديث ترك الشبهات',
      'text': 'دع ما يريبك إلى ما لا يريبك',
      'explanation':
          'هذا الحديث يأمر بترك الأمور المشبوهة والتزام الأمور الواضحة التي لا شبهة فيها. فما اشتبه عليك حله من حرامه فاتركه إلى ما لا تشك في حله',
      'reference': 'رواه الترمذي والنسائي',
    },
    {
      'number': 12,
      'name': 'حديث ترك ما لا يعني',
      'text': 'من حسن إسلام المرء تركه ما لا يعنيه',
      'explanation':
          'هذا الحديث يبين أن من علامات كمال الإسلام ترك ما لا يعني الإنسان من الأقوال والأعمال. فالمسلم الحقيقي يشغل نفسه بما يفيده في دينه ودنياه، ويترك ما لا يعنيه',
      'reference': 'رواه الترمذي وابن ماجة',
    },
    {
      'number': 13,
      'name': 'حديث كمال الإيمان',
      'text': 'لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه',
      'explanation':
          'هذا الحديث يبين أن الإيمان الكامل يتطلب محبة الخير للآخرين كما يحبه الإنسان لنفسه. فالمؤمن الحق يفرح لفرح أخيه ويحزن لحزنه، ويتمنى له ما يتمنى لنفسه',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 14,
      'name': 'حديث حرمة الدماء',
      'text':
          'لا يحل دم امريء مسلم إلا بإحدى ثلاث: الثيب الزاني، والنفس بالنفس، والتارك لدينه المفارق للجماعة',
      'explanation':
          'هذا الحديث يبين الأسباب التي تجيز إزهاق روح المسلم، وهي: الزنا بعد الإحصان، والقتل العمد، والردة عن الإسلام. فدم المسلم مصون لا يحل إلا بهذه الأمور الثلاثة',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 15,
      'name': 'حديث آداب الإسلام',
      'text':
          'من كان يؤمن بالله واليوم الآخر فليقل خيرا أو ليصمت، ومن كان يؤمن بالله واليوم الآخر فليكرم جاره، ومن كان يؤمن بالله واليوم الآخر فليكرم ضيفه',
      'explanation':
          'هذا الحديث يجمع ثلاث وصايا عظيمة: الأولى في آداب الكلام، والثانية في حقوق الجوار، والثالثة في إكرام الضيف. وهذه من مقتضيات الإيمان بالله واليوم الآخر',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 16,
      'name': 'حديث الغضب',
      'text': 'لا تغضب',
      'explanation':
          'هذا الحديث وصية عظيمة بالتحكم في الغضب وكبحه، لأن الغضب قد يؤدي إلى أفعال وأقوال يندم عليها الإنسان. فالمؤمن الحكيم هو الذي يسيطر على غضبه ولا يسيطر الغضب عليه',
      'reference': 'رواه البخاري',
    },
    {
      'number': 17,
      'name': 'حديث الإحسان',
      'text':
          'إن الله كتب الإحسان على كل شيء، فإذا قتلتم فأحسنوا القتلة، وإذا ذبحتم فأحسنوا الذبحة، وليحد أحدكم شفرته، ويرح ذبيحته',
      'explanation':
          'هذا الحديث يبين وجوب الإحسان في كل شيء، حتى في الأمور التي يظن أنها قاسية مثل القتل والذبح. فالإسلام يأمر بالإحسان حتى مع الحيوان عند ذبحه',
      'reference': 'رواه مسلم',
    },
    {
      'number': 18,
      'name': 'حديث التقوى',
      'text':
          'اتق الله حيثما كنت، وأتبع السيئة الحسنة تمحها، وخالق الناس بخلق حسن',
      'explanation':
          'هذا الحديث يجمع ثلاث وصايا: التقوى في كل مكان، ومقابلة السيئة بالحسنة، وحسن الخلق مع الناس. فالتقوى هي خشية الله في السر والعلن، ومقابلة السيئة بالحسنة تمحو أثرها، وحسن الخلق يجلب محبة الناس',
      'reference': 'رواه الترمذي',
    },
    {
      'number': 19,
      'name': 'حديث حفظ الله للعبد',
      'text':
          'احفظ الله يحفظك، احفظ الله تجده تجاهك، إذا سألت فاسأل الله، وإذا استعنت فاستعن بالله، واعلم أن الأمة لو اجتمعت على أن ينفعوك بشيء لم ينفعوك إلا بشيء قد كتبه الله لك، وإن اجتمعوا على أن يضروك بشيء لم يضروك إلا بشيء قد كتبه الله عليك؛ رفعت الأقلام، وجفت الصحف',
      'explanation':
          'هذا الحديث يبين أن من يحفظ الله بطاعته يحفظه الله في دينه ودنياه. ويأمر بالتوكل على الله في السؤال والاستعانة، ويؤكد أن الأقدار لا تتغير، فما كتب للعبد من نفع أو ضر لا بد أن يصيبه',
      'reference': 'رواه الترمذي',
    },
    {
      'number': 20,
      'name': 'حديث الحياء',
      'text':
          'إن مما أدرك الناس من كلام النبوة الأولى: إذا لم تستح فاصنع ما شئت',
      'explanation':
          'هذا الحديث يبين أن الحياء من الإيمان، وهو مانع من المعاصي. فمن فقد الحياء فقد فعل ما شاء من القبائح، والحياء خلق كريم يمنع صاحبه من ارتكاب المحرمات',
      'reference': 'رواه البخاري',
    },
    {
      'number': 21,
      'name': 'حديث الاستقامة',
      'text': 'قل آمنت بالله ثم استقم',
      'explanation':
          'هذا الحديث يوجز طريق السعادة في كلمتين: الإيمان ثم الاستقامة. فالإيمان هو الأساس، والاستقامة هي الثبات على طاعة الله واجتناب معصيته',
      'reference': 'رواه مسلم',
    },
    {
      'number': 22,
      'name': 'حديث طرق الخير',
      'text':
          'أرأيت إذا صليت المكتوبات، وصمت رمضان، وأحللت الحلال، وحرمت الحرام، ولم أزد على ذلك شيئا؛ أأدخل الجنة؟ قال: نعم',
      'explanation':
          'هذا الحديث يبين أن من أدى الفرائض واجتنب المحرمات دخل الجنة. فهو يبشر بأن الجنة لمن التزم بأركان الإسلام وابتعد عن المحرمات',
      'reference': 'رواه مسلم',
    },
    {
      'number': 23,
      'name': 'حديث التيسير',
      'text':
          'الطهور شطر الإيمان، والحمد لله تملأ الميزان، وسبحان الله والحمد لله تملآن -أو: تملأ- ما بين السماء والأرض، والصلاة نور، والصدقة برهان، والصبر ضياء، والقرآن حجة لك أو عليك، كل الناس يغدو، فبائع نفسه فمعتقها أو موبقها',
      'explanation':
          'هذا الحديث يبين فضائل عدة من أعمال البر: الطهارة، والتسبيح، والتحميد، والصلاة، والصدقة، والصبر، وتلاوة القرآن. ويختم بأن الإنسان إما أن يعتق نفسه بطاعة الله أو يوبقها بمعصيته',
      'reference': 'رواه مسلم',
    },
    {
      'number': 24,
      'name': 'حديث فضل الصدقة',
      'text':
          'يا عبادي: إني حرمت الظلم على نفسي، وجعلته بينكم محرما؛ فلا تظالموا. يا عبادي! كلكم ضال إلا من هديته، فاستهدوني أهدكم. يا عبادي! كلكم جائع إلا من أطعمته، فاستطعموني أطعمكم. يا عبادي! كلكم عار إلا من كسوته، فاستكسوني أكسكم. يا عبادي! إنكم تخطئون بالليل والنهار، وأنا أغفر الذنوب جميعا؛ فاستغفروني أغفر لكم. يا عبادي! إنكم لن تبلغوا ضري فتضروني، ولن تبلغوا نفعي فتنفعوني. يا عبادي! لو أن أولكم وآخركم وإنسكم وجنكم كانوا على أتقى قلب رجل واحد منكم، ما زاد ذلك في ملكي شيئا. يا عبادي! لو أن أولكم وآخركم وإنسكم وجنكم كانوا على أفجر قلب رجل واحد منكم، ما نقص ذلك من ملكي شيئا. يا عبادي! لو أن أولكم وآخركم وإنسكم وجنكم قاموا في صعيد واحد، فسألوني، فأعطيت كل واحد مسألته، ما نقص ذلك مما عندي إلا كما ينقص المخيط إذا أدخل البحر. يا عبادي! إنما هي أعمالكم أحصيها لكم، ثم أوفيكم إياها؛ فمن وجد خيرا فليحمد الله، ومن وجد غير ذلك فلا يلومن إلا نفسه',
      'explanation':
          'هذا الحديث القدسي يبين عدل الله ورحمته وغناه عن خلقه. فيه تحريم الظلم، وبيان أن الهداية والرزق والكسوة من الله، وسعة مغفرته، وأنه الغني عن العالمين، وأن الجزاء على الأعمال',
      'reference': 'رواه مسلم',
    },
    {
      'number': 25,
      'name': 'حديث أعمال القلوب',
      'text':
          'ذهب أهل الدثور بالأجور؛ يصلون كما نصلي، ويصومون كما نصوم، ويتصدقون بفضول أموالهم. قال: أوليس قد جعل الله لكم ما تصدقون؟ إن بكل تسبيحة صدقة، وكل تكبيرة صدقة، وكل تحميدة صدقة، وكل تهليلة صدقة، وأمر بمعروف صدقة، ونهي عن منكر صدقة، وفي بضع أحدكم صدقة. قالوا: يا رسول الله أيأتي أحدنا شهوته ويكون له فيها أجر؟ قال: أرأيتم لو وضعها في حرام أكان عليه وزر؟ فكذلك إذا وضعها في الحلال، كان له أجر',
      'explanation':
          'هذا الحديث يبين أن أبواب الخير كثيرة وليست مقصورة على الأموال فقط. فكل تسبيحة وتكبيرة وتحمدية وتهليلة صدقة، والأمر بالمعروف والنهي عن المنكر صدقة، حتى الجماع الحلال يكون فيه أجر',
      'reference': 'رواه مسلم',
    },
    {
      'number': 26,
      'name': 'حديث كثرة طرق الخير',
      'text':
          'كل سلامى من الناس عليه صدقة، كل يوم تطلع فيه الشمس تعدل بين اثنين صدقة، وتعين الرجل في دابته فتحمله عليها أو ترفع له عليها متاعه صدقة، والكلمة الطيبة صدقة، وبكل خطوة تمشيها إلى الصلاة صدقة، وتميط الأذى عن الطريق صدقة',
      'explanation':
          'هذا الحديث يبين أنواع الصدقات المتعددة التي يمكن للمسلم أن يؤديها، فليس الصدقة مقصورة على المال فقط، بل كل معروف صدقة، والإصلاح بين الناس صدقة، والكلمة الطيبة صدقة، وإماطة الأذى صدقة',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 27,
      'name': 'حديث البر والإثم',
      'text': 'البر حسن الخلق، والإثم ما حاك في صدرك، وكرهت أن يطلع عليه الناس',
      'explanation':
          'هذا الحديث يبين أن البر هو حسن الخلق، والإثم ما حاك في النفس وكره الإنسان أن يطلع عليه الناس. فالفطرة السليمة تميز بين الخير والشر، والقلب يأنس للبر وينكر الإثم',
      'reference': 'رواه مسلم',
    },
    {
      'number': 28,
      'name': 'حديث الاستماتة في الأمر',
      'text':
          'أوصيكم بتقوى الله، والسمع والطاعة وإن تأمر عليكم عبد، فإنه من يعش منكم فسيرى اختلافا كثيرا، فعليكم بسنتي وسنة الخلفاء الراشدين المهديين، عضوا عليها بالنواجذ، وإياكم ومحدثات الأمور؛ فإن كل بدعة ضلالة',
      'explanation':
          'هذا الحديث وصية بالتمسك بتقوى الله وطاعة ولي الأمر، والتمسك بالسنة النبوية وسنة الخلفاء الراشدين، والتحذير من البدع والمحدثات في الدين، فإن كل بدعة ضلالة',
      'reference': 'رواه أبو داود والترمذي',
    },
    {
      'number': 29,
      'name': 'حديث الجد في الأمور',
      'text':
          'تعبد الله لا تشرك به شيئا، وتقيم الصلاة، وتؤتي الزكاة، وتصوم رمضان، وتحج البيت، ثم قال: ألا أدلك على أبواب الخير؟ الصوم جنة، والصدقة تطفئ الخطيئة كما يطفئ الماء النار، وصلاة الرجل في جوف الليل، ثم تلا: "تتجافى جنوبهم عن المضاجع" حتى بلغ "يعملون"، ثم قال: ألا أخبرك برأس الأمر وعموده وذروة سنامه؟ قلت: بلى يا رسول الله. قال: رأس الأمر الإسلام، وعموده الصلاة، وذروة سنامه الجهاد، ثم قال: ألا أخبرك بمالك ذلك كله؟ فقلت: بلى يا رسول الله! فأخذ بلسانه وقال: كف عليك هذا. قلت: يا نبي الله وإنا لمؤاخذون بما نتكلم به؟ فقال: ثكلتك أمك وهل يكب الناس على وجوههم -أو قال على مناخرهم- إلا حصائد ألسنتهم؟!',
      'explanation':
          'هذا الحديث يبين أركان الإسلام وفضائل الصوم والصدقة والصلاة، ثم يبين أن رأس الأمر الإسلام، وعموده الصلاة، وذروة سنامه الجهاد. ثم يحذر من خطر اللسان، فإن كثيرا من الناس يهلكون بسبب أقوالهم',
      'reference': 'رواه الترمذي',
    },
    {
      'number': 30,
      'name': 'حديث حدود الله',
      'text':
          'إن الله تعالى فرض فرائض فلا تضيعوها، وحد حدودا فلا تعتدوها، وحرم أشياء فلا تنتهكوها، وسكت عن أشياء رحمة لكم غير نسيان فلا تبحثوا عنها',
      'explanation':
          'هذا الحديث يبين أصول التعامل مع الشرع: المحافظة على الفرائض، وعدم تجاوز الحدود، واجتناب المحرمات، وترك البحث عما سكت عنه الشرع رحمة بالأمة',
      'reference': 'رواه الدارقطني',
    },
    {
      'number': 31,
      'name': 'حديث الزهد',
      'text': 'ازهد في الدنيا يحبك الله، وازهد فيما عند الناس يحبك الناس',
      'explanation':
          'هذا الحديث يبين أن الزهد في الدنيا وفيما عند الناس طريق إلى محبة الله ومحبة الناس. فمن لم يهتم بالدنيا ولم يحسد الناس على ما عندهم أحبه الله وأحبه الناس',
      'reference': 'رواه ابن ماجة',
    },
    {
      'number': 32,
      'name': 'حديث لا ضرر',
      'text': 'لا ضرر ولا ضرار',
      'explanation':
          'هذا الحديث قاعدة عظيمة من قواعد الإسلام، تحرم الضرر والضرار. فليس للإنسان أن يضر نفسه ولا أن يضر غيره، وهذا من كمال العدل في الإسلام',
      'reference': 'رواه ابن ماجة والدارقطني',
    },
    {
      'number': 33,
      'name': 'حديث البينة على المدعي',
      'text':
          'لو يعطى الناس بدعواهم لادعى رجال أموال قوم ودماءهم، ولكن البينة على المدعي، واليمين على من أنكر',
      'explanation':
          'هذا الحديث يبين أصول الإثبات في القضاء، فليس مجرد الدعوى كافيا، بل لا بد من البينة (الشهود أو الإقرار). فالبينة على المدعي، وإذا أنكر المدعى عليه يحلف',
      'reference': 'رواه البيهقي',
    },
    {
      'number': 34,
      'name': 'حديث تغيير المنكر',
      'text':
          'من رأى منكم منكرا فليغيره بيده، فإن لم يستطع فبلسانه، فإن لم يستطع فبقلبه، وذلك أضعف الإيمان',
      'explanation':
          'هذا الحديث يبين مراتب تغيير المنكر حسب الاستطاعة: التغيير باليد لمن له سلطة، ثم باللسان بالنصيحة، ثم بالقلب (بكراهية المنكر). والتغيير بالقلب هو أضعف الإيمان',
      'reference': 'رواه مسلم',
    },
    {
      'number': 35,
      'name': 'حديث أخوة الإسلام',
      'text':
          'لا تحاسدوا، ولا تناجشوا، ولا تباغضوا، ولا تدابروا، ولا يبع بعضكم على بيع بعض، وكونوا عباد الله إخوانا، المسلم أخو المسلم، لا يظلمه، ولا يخذله، ولا يكذبه، ولا يحقره، التقوى هاهنا، ويشير إلى صدره ثلاث مرات، بحسب امرئ من الشر أن يحقر أخاه المسلم، كل المسلم على المسلم حرام: دمه وماله وعرضه',
      'explanation':
          'هذا الحديث يجمع آداب التعامل بين المسلمين، فينهى عن الحسد والنجش (الغش في البيع) والبغضاء والهجران، ويأمر بالإخاء الإسلامي. ويبين حرمة دم المسلم وماله وعرضه',
      'reference': 'رواه مسلم',
    },
    {
      'number': 36,
      'name': 'حديث مساعدة المسلم',
      'text':
          'من نفس عن مؤمن كربة من كرب الدنيا نفس الله عنه كربة من كرب يوم القيامة، ومن يسر على معسر، يسر الله عليه في الدنيا والآخرة، ومن ستر مسلما ستره الله في الدنيا والآخرة، والله في عون العبد ما كان العبد في عون أخيه، ومن سلك طريقا يلتمس فيه علما سهل الله له به طريقا إلى الجنة، وما اجتمع قوم في بيت من بيوت الله يتلون كتاب الله، ويدرسونه فيما بينهم؛ إلا نزلت عليهم السكينة، وغشيتهم الرحمة، وذكرهم الله فيمن عنده، ومن أبطأ به عمله لم يسرع به نسبه',
      'explanation':
          'هذا الحديث يبين فضائل إزالة الكرب والتيسير على المعسرين والستر وطلب العلم. فمن helped أخاه helpedه الله، ومن ستر مسلما ستره الله، ومن طلب العلم سهل الله له طريق الجنة',
      'reference': 'رواه مسلم',
    },
    {
      'number': 37,
      'name': 'حديث الكرامة الحسنة',
      'text':
          'إن الله كتب الحسنات والسيئات، ثم بين ذلك، فمن هم بحسنة فلم يعملها كتبها الله عنده حسنة كاملة، وإن هم بها فعملها كتبها الله عنده عشر حسنات إلى سبعمائة ضعف إلى أضعاف كثيرة، وإن هم بسيئة فلم يعملها كتبها الله عنده حسنة كاملة، وإن هم بها فعملها كتبها الله سيئة واحدة',
      'explanation':
          'هذا الحديث يبين كرم الله تعالى في كتابة الحسنات والسيئات. فمن هم بحسنة كتبت له حسنة كاملة وإن لم يعملها، وإذا عملها كتبت له عشر حسنات إلى سبعمائة ضعف. ومن هم بسيئة لم تكتب عليه إذا تركها، بل تكتب له حسنة، وإذا عملها تكتب سيئة واحدة',
      'reference': 'رواه البخاري ومسلم',
    },
    {
      'number': 38,
      'name': 'حديث الستر على المسلم',
      'text':
          'من عادى لي وليا فقد آذنته بالحرب، وما تقرب إلي عبدي بشيء أحب إلي مما افترضته عليه، ولا يزال عبدي يتقرب إلي بالنوافل حتى أحبه، فإذا أحببته كنت سمعه الذي يسمع به، وبصره الذي يبصر به، ويده التي يبطش بها، ورجله التي يمشي بها، ولئن سألني لأعطينه، ولئن استعاذني لأعيذنه',
      'explanation':
          'هذا الحديث يبين مكانة أولياء الله وثمرات التقرب إليه بالفرائض والنوافل. فمن عادى وليا لله فقد declared الحرب على الله. ومن تقرب إلى الله بالفرائض ثم النوافل أحبه الله وكان معه في جميع أحواله',
      'reference': 'رواه البخاري',
    },
    {
      'number': 39,
      'name': 'حديث شفاعة الله',
      'text': 'إن الله تجاوز لي عن أمتي الخطأ والنسيان وما استكرهوا عليه',
      'explanation':
          'هذا الحديث يبين رحمة الله تعالى بأمته، حيث رفع المؤاخذة عن الخطأ والنسيان والإكراه. فليس على الإنسان إثم في ما أخطأ أو نسي أو أكره عليه',
      'reference': 'رواه ابن ماجة والبيهقي',
    },
    {
      'number': 40,
      'name': 'حديث التوقي من النار',
      'text':
          'كن في الدنيا كأنك غريب أو عابر سبيل. وكان ابن عمر يقول: إذا أمسيت فلا تنتظر الصباح، وإذا أصبحت فلا تنتظر المساء، وخذ من صحتك لمرضك، ومن حياتك لموتك',
      'explanation':
          'هذا الحديث يأمر بالزهد في الدنيا وعدم التعلق بها، وأن يعامل الإنسان الدنيا معاملة الغريب أو المسافر. ويوصي بالاستعداد للآخرة بالأعمال الصالحة',
      'reference': 'رواه البخاري',
    },
    {
      'number': 41,
      'name': 'حديث الإيمان بالقدر',
      'text': 'لا يؤمن أحدكم حتى يكون هواه تبعا لما جئت به',
      'explanation':
          'هذا الحديث يبين أن الإيمان الكامل يتطلب انقياد الهوى لشرع الله. فالمؤمن الحقيقي هو الذي يخضع هواه لما جاء به النبي صلى الله عليه وسلم',
      'reference': 'حديث حسن صحيح',
    },
    {
      'number': 42,
      'name': 'حديث سعة مغفرة الله',
      'text':
          'يا ابن آدم! إنك ما دعوتني ورجوتني غفرت لك على ما كان منك ولا أبالي، يا ابن آدم! لو بلغت ذنوبك عنان السماء ثم استغفرتني غفرت لك، يا ابن آدم! إنك لو أتيتني بقُراب الأرض خطايا ثم لقيتني لا تشرك بي شيئا لأتيتك بقُرابها مغفرة',
      'explanation':
          'هذا الحديث يبين سعة مغفرة الله تعالى لمن دعاه ورجاه ولم يشرك به. فمهما عظمت ذنوب العبد فإن مغفرة الله أعظم، إذا تاب وأناب ولم يشرك بالله',
      'reference': 'رواه الترمذي',
    },
  ];

  void _nextHadith() {
    if (currentHadithIndex < hadithData.length - 1) {
      setState(() {
        currentHadithIndex++;
      });
    } else {
      setState(() {
        currentHadithIndex = 0;
      });
    }
  }

  void _previousHadith() {
    if (currentHadithIndex > 0) {
      setState(() {
        currentHadithIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHadith = hadithData[currentHadithIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFf8f6f0),
      body: Column(
        children: [
          // العنوان
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E8449),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${currentHadith['number']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '● ${currentHadith['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E8449),
                      fontFamily: 'Amiri',
                    ),
                  ),
                ),
                Text(
                  currentHadithIndex == hadithData.length - 1 ? '○' : '○',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // نص الحديث
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f6f0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFd4b896), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'عَنْ عُمَرَ بْنِ الْخَطَّابِ رَضِيَ اللَّهُ عَنْهُ قَالَ:',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6c757d),
                        fontFamily: 'Amiri',
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentHadith['text'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Amiri',
                        color: Color(0xFF2c3e50),
                        height: 2,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // المصدر
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFd4b896), width: 1),
            ),
            child: Text(
              currentHadith['reference'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF95a5a6),
                fontStyle: FontStyle.italic,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 15),

          // أزرار التنقل
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: currentHadithIndex > 0 ? _previousHadith : null,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('السابق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentHadithIndex > 0
                          ? Colors.grey[600]
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextHadith,
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: const Text('التالي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8449),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Duas Section (مطابق للكود الأصلي)
class DuasSection extends StatelessWidget {
  const DuasSection({super.key});

  static final List<Map<String, dynamic>> duasData = [
    {
      'title': 'دعاء الكرب والهم',
      'arabic':
          'لا إِلَهَ إِلا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'translation': 'لا إله إلا أنت سبحانك إني كنت من الظالمين',
      'occasion': 'يقال عند الكرب والهم والضيق',
    },
    {
      'title': 'دعاء دخول المسجد',
      'arabic': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      'translation': 'اللهم افتح لي أبواب رحمتك',
      'occasion': 'عند دخول المسجد'
    },
    {
      'title': 'دعاء الخروج من المسجد',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ وَرَحْمَتِكَ',
      'translation': 'اللهم إني أسألك من فضلك ورحمتك',
      'occasion': 'عند الخروج من المسجد'
    },
    {
      'title': 'دعاء الرزق',
      'arabic':
          'اللَّهُمَّ اكْفِنِي بِحَلالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      'translation': 'اللهم اكفني بحلالك عن حرامك، وأغنني بفضلك عمن سواك',
      'occasion': 'لطلب الرزق الحلال والغنى عن الناس'
    },
    {
      'title': 'دعاء الهم والحزن',
      'arabic':
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْجُبْنِ وَالْبُخْلِ، وَضَلَعِ الدَّيْنِ، وَقهر الرِّجَالِ',
      'translation':
          'اللهم إني أعوذ بك من الهم والحزن، والعجز والكسل، والجبن والبخل، وضلع الدين، وقهر الرجال',
      'occasion': 'عند الشعور بالهم والحزن والضيق'
    },
    {
      'title': 'دعاء الاستعاذة من النار',
      'arabic':
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ، وَأَعُوذُ بِكَ مِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ',
      'translation':
          'اللهم إني أعوذ بك من عذاب جهنم، وأعوذ بك من عذاب القبر، وأعوذ بك من فتنة المسيح الدجال، وأعوذ بك من فتنة المحيا والممات',
      'occasion':
          'للتحصين من عذاب النار وفتن الدنيا ويقال بعد التشهد وقبل التسليم'
    },
    {
      'title': 'دعاء لقضاء الدين',
      'arabic':
          'اللَّهُمَّ اكْفِنِي بِحَلالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      'translation': 'اللهم اكفني بحلالك عن حرامك، وأغنني بفضلك عمن سواك',
      'occasion': 'لقضاء الدين والغنى عن سؤال الناس'
    },
    {
      'title': 'دعاء السفر',
      'arabic':
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ، اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ mَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا، وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ، وَالْخَلِيفَةُ فِي الأَهْلِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرِ، وَكَآبَةِ الْمَنْظَرِ، وَسُوءِ الْمُنْقَلَبِ فِي الْمَالِ وَالأَهْلِ',
      'translation':
          'سبحان الذي سخر لنا هذا وما كنا له مقرنين، وإنا إلى ربنا لمنقلبون، اللهم إنا نسألك في سفرنا هذا البر والتقوى، ومن العمل ما ترضى، اللهم هون علينا سفرنا هذا، واطو عنا بعده، اللهم أنت الصاحب في السفر، والخليفة في الأهل، اللهم إني أعوذ بك من وعثاء السفر، وكآبة المنظر، وسوء المنقلب في المال والأهل',
      'occasion': 'عند البدء في السفر'
    },
    {
      'title': 'دعاء دخول المنزل',
      'arabic':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ، بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
      'translation':
          'اللهم إني أسألك خير المولج وخير المخرج، بسم الله ولجنا، وبسم الله خرجنا، وعلى الله ربنا توكلنا',
      'occasion': 'عند دخول المنزل'
    },
    {
      'title': 'دعاء الخروج من المنزل',
      'arabic':
          'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'translation': 'بسم الله، توكلت على الله، ولا حول ولا قوة إلا بالله',
      'occasion': 'عند الخروج من المنزل'
    },
    {
      'title': 'دعاء لبس الثوب الجديد',
      'arabic':
          'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ، أَسْأَلُكَ خَيْرَهُ وَخَيْرَ mَا صُنِعَ لَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ mَا صُنِعَ لَهُ',
      'translation':
          'اللهم لك الحمد أنت كسوتنيه، أسألك خيره وخير ما صنع له، وأعوذ بك من شره وشر ما صنع له',
      'occasion': 'عند لبس الثوب الجديد'
    },
    {
      'title': 'دعاء النظر في المرآة',
      'arabic': 'اللَّهُمَّ كَمَا حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي',
      'translation': 'اللهم كما حسنت خلقي فحسن خلقي',
      'occasion': 'عند النظر في المرآة'
    },
    {
      'title': 'دعاء الريح',
      'arabic':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا، وَخَيْرَ mَا فِيهَا، وَخَيْرَ mَا أُرْسِلَتْ بِهِ، وَأَعُوذُ بِكَ مِنْ شَرِّهَا، وَشَرِّ mَا فِيهَا، وَشَرِّ mَا أُرْسِلَتْ بِهِ',
      'translation':
          'اللهم إني أسألك خيرها، وخير ما فيها، وخير ما أرسلت به، وأعوذ بك من شرها، وشر ما فيها، وشر ما أرسلت به',
      'occasion': 'عند هبوب الريح'
    },
    {
      'title': 'دعاء المطر',
      'arabic': 'اللَّهُمَّ صَيِّباً نَافِعاً',
      'translation': 'اللهم صيباً نافعاً',
      'occasion': 'عند نزول المطر'
    },
    {
      'title': 'دعاء بعد الانتهاء من المطر',
      'arabic': 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ',
      'translation': 'مطرنا بفضل الله ورحمته',
      'occasion': 'بعد انتهاء المطر'
    },
    {
      'title': 'دعاء رؤية الهلال',
      'arabic':
          'اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالْيُمْنِ وَالإِيمَانِ، وَالسَّلامَةِ وَالإِسْلامِ، رَبِّي وَرَبُّكَ اللَّهُ',
      'translation':
          'اللهم أهله علينا باليمن والإيمان، والسلامة والإسلام، ربي وربك الله',
      'occasion': 'عند رؤية هلال الشهر الجديد'
    },
    {
      'title': 'دعاء عيادة المريض',
      'arabic': 'لا بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ',
      'translation': 'لا بأس طهور إن شاء الله',
      'occasion': 'عند زيارة المريض'
    },
    {
      'title': 'دعاء الاستغفار',
      'arabic':
          'اللَّهُمَّ إنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، ولَا يَغْفِرُ الذُّنُوبَ إلَّا أنْتَ، فَاغْفِرْ لي مَغْفِرَةً مِن عِندِكَ، وارْحَمْنِي، إنَّكَ أنْتَ الغَفُورُ الرَّحِيمُ.',
      'translation':
          'اللَّهُمَّ إنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، ولَا يَغْفِرُ الذُّنُوبَ إلَّا أنْتَ، فَاغْفِرْ لي مَغْفِرَةً مِن عِندِكَ، وارْحَمْنِي، إنَّكَ أنْتَ الغَفُورُ الرَّحِيمُ.',
      'occasion': 'مرة واحدة',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: duasData.length,
      itemBuilder: (context, index) {
        final dua = duasData[index];
        return _buildDuaCard(dua, context);
      },
    );
  }

  Widget _buildDuaCard(Map<String, dynamic> dua, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dua['title'] ?? 'دعاء',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Amiri',
                color: Color(0xFF1E8449),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f6f0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFd4b896)),
              ),
              child: Text(
                dua['arabic'],
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Amiri',
                  color: Color(0xFF2c3e50),
                  height: 2,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 10),
            if (dua['translation'].isNotEmpty) ...[
              Text(
                dua['translation'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6c757d),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
            if (dua['occasion'].isNotEmpty)
              Text(
                dua['occasion'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF95a5a6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
