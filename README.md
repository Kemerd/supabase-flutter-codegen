A codegen script that grabs and generates classes and functions from Supabase tables, structs, enums, and utils, in Dart.

I initially used this to port my project over from FlutterFlow to Flutter (it matches their paradigm), but can be used with any project.

Place into your project's root directory and run the .sh or .bat script

You will need to have an env.dart file, with these set:
const supabaseUrl = Environment.supabaseUrl;
const supabaseAnonKey = Environment.supabaseAnonKey;
