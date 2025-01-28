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
final userAccountsTable = UserAccountsTable();

// Query single record
final users = await userAccountsTable.queryRows(
  queryFn: (q) => q.eq('id', 123),
  limit: 1,
);
final user = users.firstOrNull;

// Query multiple records with conditions
final activeUsers = await userAccountsTable.queryRows(
  queryFn: (q) => q
  .eq('is_active', true)
  .order('created_at'),
);

// Query with joins
final usersWithProfiles = await userAccountsTable.queryRows(
queryFn: (q) => q.select(', pilots()'),
);
```

### Creating Records
```dart
final userAccountsTable = UserAccountsTable();

// Create new record
final newUser = await userAccountsTable.insert({
  'email': 'john@example.com',
  'acc_name': 'John Doe',
  'phone_number': '+1234567890',
});

// The returned object is already typed
print(newUser.email);
print(newUser.accName);
```

### Updating Records
```dart
final userAccountsTable = UserAccountsTable();

// Update by query
await userAccountsTable.update(
  data: {'acc_name': 'Jane Doe'},
  matchingRows: (q) => q.eq('id', 123),
);

// Update with return value
final updatedUsers = await userAccountsTable.update(
  data: {'is_active': true},
  matchingRows: (q) => q.in_('id', [1, 2, 3]),
  returnRows: true,
);
```

### Deleting Records
```dart
final userAccountsTable = UserAccountsTable();

// Delete single record
  await userAccountsTable.delete(
  matchingRows: (q) => q.eq('id', 123),
);

// Delete with return value
final deletedUsers = await userAccountsTable.delete(
  matchingRows: (q) => q.eq('is_active', false),
  returnRows: true,
);
```

### Working with Related Data
```dart
// Get a pilot and their documents
final pilotsTable = PilotsTable();
final documentsTable = DocumentsTable();

// Get pilot
final pilots = await pilotsTable.queryRows(
  queryFn: (q) => q.eq('id', pilotId),
);
final pilot = pilots.firstOrNull;

// Get related documents
if (pilot != null) {
  final documents = await documentsTable.queryRows(
    queryFn: (q) => q.eq('pilot_id', pilot.id),
  );
}
```

## 📝 Notes

- Ensure your Supabase tables have proper primary keys defined
- All generated models are null-safe
- Custom column types are supported through type converters

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
