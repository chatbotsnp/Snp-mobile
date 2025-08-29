import 'package:flutter/material.dart';
import 'login_screen.dart';

import 'notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone cho zonedSchedule
  tz.initializeTimeZones();
  // Đặt múi giờ theo Việt Nam (có thể đổi thành máy người dùng nếu sau này thêm plugin lấy timezone hệ thống)
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

  // Khởi tạo Notifications
  await NotifService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: const Color(0xFF0D47A1),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SNP Chatbot',
      theme: theme,
      home: const LoginScreen(),
    );
  }
}
