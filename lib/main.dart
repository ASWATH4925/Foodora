import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/cart_provider.dart';
import 'models/address_provider.dart';
import 'models/order_provider.dart';
import 'models/favourite_provider.dart';
import 'shared/app_theme.dart';
import 'views/mobile/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
      ],
      child: MaterialApp(
        title: 'FoodoraUI',
        debugShowCheckedModeBanner: false,
        theme: appPrimaryTheme(),
        home: const LoginScreen(),
      ),
    );
  }
}
