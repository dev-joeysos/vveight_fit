import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/provider/isUpdated.dart';
import 'package:flutter_project/provider/regression_data.dart';
import 'package:flutter_project/provider/regression_provider.dart';
import 'package:flutter_project/provider/routine_state.dart';
import 'package:flutter_project/provider/speed_values.dart';
import 'package:flutter_project/provider/workout_manager.dart';
import 'package:flutter_project/provider/workout_save_success.dart';
import 'package:flutter_project/screens/intro_screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'components/timer_service.dart';
import 'provider/workout_data.dart';
import 'package:intl/date_symbol_data_local.dart';
import './screens/workout_screens/testing_result.dart';

void main() async {
  await initializeDateFormatting();
  runApp(MyApp());

  // 상태 표시줄 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark, // 상태 표시줄 아이콘을 밝게 설정
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerService()),
        ChangeNotifierProvider(create: (context) => WorkoutData()),
        ChangeNotifierProvider(create: (context) => WorkoutManager()),
        ChangeNotifierProvider(create: (context) => RoutineState()),
        ChangeNotifierProvider(create: (context) => SpeedValuesProvider()),
        ChangeNotifierProvider(create: (context) => RDP()),
        ChangeNotifierProvider(create: (_) => IsUpdated()),
        ChangeNotifierProvider(create: (_) => RegressionProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutSaveProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "vveight.fit app",
        theme: ThemeData(
          fontFamily: 'Pretendard',
        ),
        home: SplashScreen(),
      ),
    );
  }
}
