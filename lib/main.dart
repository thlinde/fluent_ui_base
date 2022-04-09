import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/home.dart';
import 'pages/info.dart';
import 'pages/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async{
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setSize(const Size(800, 600));
    await windowManager.center();
    await windowManager.show();
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'com.thlinde.fluentui',
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      color: Colors.blue,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0,
        ),
      ),
      theme: ThemeData(
        accentColor: Colors.blue,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: NavigationPaneTheme(
            data: const NavigationPaneThemeData(
              backgroundColor: null,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WindowListener {
  bool value = false;

  int index = 0;

  // final settingsController = ScrollController();
  final viewKey = GlobalKey();

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    // settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        title: () {
          return const DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text('thlinde'),
              ),
            ),
          );
        }(),
        actions: DragToMoveArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [Spacer(), WindowButtons()],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        size: const NavigationPaneSize(
          openMinWidth: 200,
          openMaxWidth: 200,
        ),
        header: Container(
          height: kOneLineTileHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: const FlutterLogo(
            style: FlutterLogoStyle.horizontal,
            size: 100,
          ),
        ),
        displayMode: PaneDisplayMode.open,
        indicator: () {
          return const StickyNavigationIndicator();
        }(),
        items: [
          // It doesn't look good when resizing from compact to open
          // PaneItemHeader(header: const Text('User Interaction')),
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Home'),
          ),
          PaneItemSeparator(),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.info),
            title: const Text('Programminformation'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Einstellungen'),
          ),
        ],
      ),
      content: NavigationBody(index: index, children: const [
        HomePage(),
        InfoPage(),
        SettingsPage(),
      ]),
    );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('Bestätigung notwendig!'),
            content: const Text('Wollen Sie das Programm beenden?'),
            actions: [
              FilledButton(
                child: const Text('JA'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('ABBRECHEN'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
