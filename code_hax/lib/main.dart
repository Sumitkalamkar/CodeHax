import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_constants.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/debugger_page.dart';
import 'screens/chat_with_sidebar.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final isLoggedIn = await authService.isLoggedIn();
  
  runApp(CodeHaxApp(initialRoute: isLoggedIn ? '/home' : '/login'));
}

class CodeHaxApp extends StatelessWidget {
  final String initialRoute;
  
  const CodeHaxApp({
    Key? key,
    this.initialRoute = '/login',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: AppConstants.primaryDark,
        primaryColor: AppConstants.accentGreen,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const CodeHaxScreen(),
      },
    );
  }
}

class CodeHaxScreen extends StatefulWidget {
  const CodeHaxScreen({Key? key}) : super(key: key);

  @override
  State<CodeHaxScreen> createState() => _CodeHaxScreenState();
}

class _CodeHaxScreenState extends State<CodeHaxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? username;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await authService.getUser();
      if (user != null) {
        setState(() {
          username = user['username'] ?? 'User';
          isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingUser = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.secondaryDark,
        title: Text(
          'Logout',
          style: GoogleFonts.robotoMono(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.robotoMono(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.robotoMono(color: AppConstants.accentGreen),
            ),
          ),
          TextButton(
            onPressed: () async {
              await authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: Text(
              'Logout',
              style: GoogleFonts.robotoMono(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryDark,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: GoogleFonts.robotoMono(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.accentGreen,
                letterSpacing: 2,
              ),
            ),
            if (!isLoadingUser)
              Text(
                '> Welcome, $username',
                style: GoogleFonts.robotoMono(
                  fontSize: 11,
                  color: AppConstants.accentGreen.withOpacity(0.6),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.accentGreen,
          labelColor: AppConstants.accentGreen,
          unselectedLabelColor: AppConstants.accentGreen.withOpacity(0.5),
          tabs: [
            Tab(
              child: Text(
                'Debugger',
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Neural Vault',
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DebuggerPage(),
          ChatWithSidebarScreen(),
        ],
      ),
    );
  }
}
