import 'package:flutter/material.dart';
import 'without_di/without_di_screen.dart';
import 'with_di/core/di/injection.dart';
import 'with_di/presentation/with_di_screen.dart';

/// Main entry point.
/// Initializes dependency injection ONCE at app startup.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI once here (for the "With DI" example)
  // This includes initializing PreferencesStorage
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hybrid Storage Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hybrid Storage Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storage,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Choose an example to see hybrid_storage in action',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WithoutDIScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.code),
                  label: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Without DI (Simple)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WithDIScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.architecture),
                  label: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'With DI (get_it + injectable)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features demonstrated:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• SecureStorage (encrypted)'),
                      Text('• PreferencesStorage (fast)'),
                      Text('• String, bool, int, double types'),
                      Text('• Read, write, delete operations'),
                      SizedBox(height: 12),
                      Text(
                        'Note: DI is initialized once at app startup',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
