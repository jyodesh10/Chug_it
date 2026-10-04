import 'package:flutter/material.dart';
import 'package:jhyapp/app/app_router.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yoxdxwopfrkcqrcoqzxl.supabase.co',
    publishableKey: 'sb_publishable_UwwglX_lFaQhG4SFvSWOBg_caUxz8ou',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          title: 'JHYAPP App',
          theme: ThemeData(
            fontFamily: 'Montserrat',
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}
