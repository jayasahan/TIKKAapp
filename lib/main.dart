import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/app/app.dart';
import 'package:tikka/core/config/supabase_config.dart';
import 'package:tikka/features/auth/data/supabase_auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/bookings/data/supabase_bookings_repository.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/services/data/supabase_services_repository.dart';
import 'package:tikka/features/services/domain/services_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const config = SupabaseConfig.fromEnvironment;
  var configurationMessage = config.errorMessage;
  AuthRepository? authRepository;
  ServicesRepository? servicesRepository;
  BookingsRepository? bookingsRepository;

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
      servicesRepository = SupabaseServicesRepository(
        client: Supabase.instance.client,
      );
      bookingsRepository = SupabaseBookingsRepository(
        client: Supabase.instance.client,
      );
    } on Object {
      configurationMessage = 'Supabase could not be initialized. Check the local URL and public anon key.';
    }
  }

  // If Supabase was not initialized, repositories default to in-memory/seed data fallback
  servicesRepository ??= SupabaseServicesRepository();
  bookingsRepository ??= SupabaseBookingsRepository();

  runApp(
    MyApp(
      authenticationEnabled: true,
      authRepository: authRepository,
      servicesRepository: servicesRepository,
      bookingsRepository: bookingsRepository,
      configurationMessage: configurationMessage,
    ),
  );
}
