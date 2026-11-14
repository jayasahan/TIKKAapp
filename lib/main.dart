import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/app/app.dart';
import 'package:tikka/core/config/supabase_config.dart';
import 'package:tikka/features/auth/data/supabase_auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const config = SupabaseConfig.fromEnvironment;
  var configurationMessage = config.errorMessage;
  AuthRepository? authRepository;

  if (configurationMessage == null) {
    try {
      await Supabase.initialize(
        url: config.url.trim(),
        publishableKey: config.anonKey.trim(),
      );
      authRepository = SupabaseAuthRepository(
        Supabase.instance.client,
        authRedirectUrl: config.authRedirectUrl,
      );
    } on Object {
      configurationMessage = 'Supabase could not be initialized. Check the local URL and public anon key.';
    }
  }

  runApp(
    MyApp(
      authenticationEnabled: true,
      authRepository: authRepository,
      configurationMessage: configurationMessage,
    ),
  );
}
