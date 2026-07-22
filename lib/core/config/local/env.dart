// import 'package:envied/envied.dart';
//
// part 'env.g.dart';
//
// @Envied(path: '.env')
// abstract class Env {
//
//   //firebase
//   @EnviedField(varName: 'API_KEY',obfuscate: true)
//   static String apiKey = _Env.apiKey;
//   @EnviedField(varName: 'AUTH_DOMAIN', obfuscate: true)
//   static final String authDomain = _Env.authDomain;
//   @EnviedField(varName: 'PROJECT_ID', obfuscate: true)
//   static final String projectId = _Env.projectId;
//   @EnviedField(varName: 'STORAGE_BUCKET', obfuscate: true)
//   static final String storageBucket = _Env.storageBucket;
//   @EnviedField(varName: 'MESSAGING_SENDER_ID', obfuscate: true)
//   static final String messagingSenderId = _Env.messagingSenderId;
//   @EnviedField(varName: 'APP_ID', obfuscate: true)
//   static final String appId = _Env.appId;
//   @EnviedField(varName: 'MEASUREMENT_ID', obfuscate: true)
//   static final String measurementId = _Env.measurementId;
//   //supabase
//   @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
//   static String supabaseUrl = _Env.supabaseUrl;
//   @EnviedField(varName: 'SUPABASE_KEY', obfuscate: true)
//   static String supabaseKey = _Env.supabaseKey;
// }