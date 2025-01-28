# 🚀 Supabase Dart Model Generator

Generate type-safe Dart models from your Supabase tables automatically! This tool helps you port projects to Flutter (from FlutterFlow) or create new Flutter projects with full type safety and Supabase integration.

## ✨ Features

- Automatically generates Dart classes from Supabase tables
- Creates type-safe models with full IDE support
- Supports complex relationships and nested structures
- Compatible with Flutter and Flutter Flow paradigms
- Generates getters and setters for all fields

## 📋 Prerequisites

- Supabase project with tables
- Dart/Flutter development environment
- Environment configuration file (`env.dart`)

## 🛠️ Setup

1. Add the generator to your project's root directory
2. Create an `env.dart` file with your Supabase credentials:

```dart
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

3. Run the generation script:
```bash
# On Unix-like systems
./generate_models.sh

# On Windows
generate_models.bat
```

## 📦 Generated Types

The generator will create strongly-typed models like this:

```dart
class UsersTable extends SupabaseTable<UsersRow> {
  @override
  String get tableName => 'users';
  
  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  UsersRow(super.data);
  
  @override
  SupabaseTable get table => UsersTable();
  
  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);
  
  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);
  
  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
```

## 🚀 Usage Examples

### Reading Data
```dart
// Fetch a single record
final userResponse = await supabase
    .from('USERS')
    .select()
    .eq('id', userId)
    .single();
if (userResponse != null) {
    final user = UsersRow(userResponse);
    // Now you can access typed properties
    print(user.name);
}

// Fetch multiple records
final usersResponse = await supabase
    .from('USERS')
    .select()
    .eq('role', 'admin');
if (usersResponse != null) {
    final users = usersResponse.map((json) => UsersRow(json)).toList();
}
```

### Creating Records
```dart
final newUser = UsersRow({
  'name': 'John Doe',
  'email': 'john@example.com',
});
await supabase.from('USERS').insert(newUser.toJson());
```

### Updating Records
```dart
// First fetch the user
final userResponse = await supabase
    .from('USERS')
    .select()
    .eq('id', userId)
    .single();
if (userResponse != null) {
    final user = UsersRow(userResponse);
    // Update properties
    user.name = 'Jane Doe';
    // Save changes
    await supabase
        .from('USERS')
        .update(user.toJson())
        .eq('id', user.id);
}

## 📝 Notes

- Ensure your Supabase tables have proper primary keys defined
- All generated models are null-safe
- Custom column types are supported through type converters

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
