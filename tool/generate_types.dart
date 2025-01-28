import 'dart:io';
import 'generators/generate_supabase_types.dart';

void main() async {
  try {
    await generateSupabaseTypes();
    exit(0);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
