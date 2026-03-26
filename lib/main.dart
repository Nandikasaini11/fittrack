import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.init();
  
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    const ProviderScope(
      child: FitTrackApp(),
    ),
  );
}
