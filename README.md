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

4. Setup your preferred auth in Supabase.dart, as well as your keys
```dart
    String _kSupabaseUrl = 'XXXXXXXXXXXXXX';
    String _kSupabaseAnonKey = 'XXXXXXXXXXXXXX';

    ...

    if (session != null) {
      print('[Supabase] User ID: ${session.user.id}');
      // Create auth user wrapper and update app state
      // Initialize your auth here
      //final authUser = FlutterAppSupabaseUser(session.user);
      //AppStateNotifier.instance.update(authUser);
    }
```
You can optionally use the auth classes I've provided in lib/auth but it is not required.

5. Setup SQL functions in Supabase
   ```
   CREATE OR REPLACE FUNCTION public.get_schema_info()
RETURNS TABLE (
    table_name text,
    column_name text,
    data_type text,
    udt_name text,
    is_nullable text,
    column_default text,
    is_array boolean,
    element_type text
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.table_name::text,
        c.column_name::text,
        c.data_type::text,
        c.udt_name::text,
        c.is_nullable::text,
        c.column_default::text,
        (c.data_type = 'ARRAY') AS is_array,
        e.data_type::text as element_type
    FROM 
        information_schema.columns c
    LEFT JOIN 
        information_schema.element_types e 
    ON 
        ((c.table_catalog, c.table_schema, c.table_name, 'TABLE', c.dtd_identifier)
        = (e.object_catalog, e.object_schema, e.object_name, e.object_type, e.collection_type_identifier))
    WHERE 
        c.table_schema = 'public'
        AND c.table_name NOT LIKE 'pg_%'
        AND c.table_name NOT LIKE '_prisma_%'
    ORDER BY 
        c.table_name, 
        c.ordinal_position;
END;
$$;

-- Grant access to the function
GRANT EXECUTE ON FUNCTION public.get_schema_info() TO anon;
GRANT EXECUTE ON FUNCTION public.get_schema_info() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_schema_info() TO service_role;
   ```

```
CREATE OR REPLACE FUNCTION public.get_enum_types()
RETURNS TABLE (
    enum_name text,
    enum_value text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.typname::text as enum_name,
        e.enumlabel::text as enum_value
    FROM 
        pg_type t
        JOIN pg_enum e ON t.oid = e.enumtypid
        JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    WHERE 
        n.nspname = 'public'
    ORDER BY 
        t.typname,
        e.enumsortorder;
END;
$$;

-- Grant access to the function
GRANT EXECUTE ON FUNCTION public.get_enum_types() TO anon;
GRANT EXECUTE ON FUNCTION public.get_enum_types() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_enum_types() TO service_role;
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

// Fetch a single user
final users = await userAccountsTable.queryRows(
  queryFn: (q) => q.eq('id', 123),
  limit: 1,
);

if (users.isNotEmpty) {
  final user = users.first;
  // Access typed properties
  print(user.email);
  print(user.accName);
  print(user.phoneNumber);
  print(user.createdAt);
}

// Fetch multiple users
final activeUsers = await userAccountsTable.queryRows(
  queryFn: (q) => q
  .eq('is_active', true)
  .order('email'),
);

// Work with typed objects
for (final user in activeUsers) {
  print('User ${user.id}:');
  print('- Email: ${user.email}');
  print('- Name: ${user.accName ?? "No name set"}');
  print('- Phone: ${user.phoneNumber ?? "No phone set"}');
  print('- Created: ${user.createdAt}');
}

// Query with complex conditions
final recentUsers = await userAccountsTable.queryRows(
  queryFn: (q) => q
  .gte('created_at', DateTime.now().subtract(Duration(days: 7)))
  .ilike('email', '%@gmail.com')
  .order('created_at', ascending: false),
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
