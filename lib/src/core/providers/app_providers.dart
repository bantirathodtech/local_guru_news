import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:local_guru_all/src/features/auth/viewmodel/auth_provider.dart';
import 'package:local_guru_all/src/features/location/viewmodel/location_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<LocationProvider>(create: (_) => LocationProvider()),
      ],
      child: child,
    );
  }
}
