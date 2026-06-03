// REUSABLE SERVICE: Works in any project.
// REQUIRES: flutter_dotenv package in pubspec.yaml
// CHANGE: Update the fields below to match your project's .env keys.
// CHANGE: Add/remove env fields as needed for your project.
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum EnvTypeEnum { dev, prod }

class EnvVariable {
  EnvVariable._();
  factory EnvVariable() => instance;
  static final EnvVariable instance = EnvVariable._();

  String _envType = '';

  // CHANGE: Add your project-specific env variables here
  String _notifcationBaseUrl = '';
  final String _firebaseKey = '';
  final String _buildDeveloper = '';

  Future<void> init({required EnvTypeEnum envType}) async {
    switch (envType) {
      // CHANGE: Update .env file names if different
      case EnvTypeEnum.dev:
        await dotenv.load(fileName: '.env.dev');

      case EnvTypeEnum.prod:
        await dotenv.load(fileName: '.env.prod');
    }

    _envType = dotenv.get('ENV_TYPE');
    // CHANGE: Load your project-specific keys here
    _notifcationBaseUrl = dotenv.get('NOTFICATION_BASEURL');
  }

  bool get debugMode => _envType == 'dev';
  // CHANGE: Add getters for your project-specific env variables
  String get notifcationBaseUrl => _notifcationBaseUrl;
  String get firebaseKey => _firebaseKey;
  String get buildDeveloper => _buildDeveloper;
}
