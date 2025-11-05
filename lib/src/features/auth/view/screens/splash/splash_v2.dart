import 'package:flutter/material.dart';
// import '../../signin/signin_v2.dart';
import 'package:local_guru_all/src/src.dart';
import 'package:provider/provider.dart';

class SplashScreenV2 extends StatefulWidget {
  const SplashScreenV2({Key? key}) : super(key: key);

  @override
  State<SplashScreenV2> createState() => _SplashScreenV2State();
}

class _SplashScreenV2State extends State<SplashScreenV2> {
  @override
  void initState() {
    super.initState();
    _decideNavigation();
  }

  Future<void> _decideNavigation() async {
    final auth = context.read<AuthProvider>();
    final loggedIn = await auth.isLoggedInPersistent();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashBoardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreenV2()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
