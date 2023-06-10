import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'helping_classes/notifications.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FlutterDownloader.initialize(
    debug: true
  );

  Notifications().initialize();
  timezone.initializeTimeZones();

  runApp(RentApp());
}