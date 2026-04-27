import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/api/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/colors.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_layout.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(ApiClient())..checkAuth()),
        BlocProvider(create: (_) => SettingsCubit(ApiClient())),
      ],
      child: MaterialApp(
        title: 'Admin Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        ),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox(),
          );
        },
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const DashboardLayout();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
