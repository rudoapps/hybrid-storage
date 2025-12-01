import 'package:flutter/material.dart';
import 'package:hybrid_storage/hybrid_storage.dart';

/// Example screen demonstrating hybrid_storage usage WITHOUT dependency injection.
/// This is the simplest way to use the library - direct instantiation.
///
/// Note: PreferencesStorage requires initialization before use.
/// Call init() before using any methods.
class WithoutDIScreen extends StatefulWidget {
  const WithoutDIScreen({super.key});

  @override
  State<WithoutDIScreen> createState() => _WithoutDIScreenState();
}

class _WithoutDIScreenState extends State<WithoutDIScreen> {
  // Direct instantiation - no DI needed
  final PreferencesStorageImpl _prefsStorage = PreferencesStorageImpl();
  final SecureStorageImpl _secureStorage = SecureStorageImpl();

  bool _isInitialized = false;
  bool _isLoading = false;

  // Values from storage
  String? _username;
  String? _authToken;
  bool _darkMode = false;
  int _loginCount = 0;
  double _appVersion = 0.0;

  // Text controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    try {
      // Initialize PreferencesStorage
      await _prefsStorage.init();

      setState(() => _isInitialized = true);

      // Load data after successful initialization
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing storage: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Read from PreferencesStorage
      final username = await _prefsStorage.read(key: 'username');
      final darkMode = await _prefsStorage.readBool(key: 'dark_mode');
      final loginCount = await _prefsStorage.readInt(key: 'login_count');
      final appVersion = await _prefsStorage.readDouble(key: 'app_version');

      // Read from SecureStorage
      final token = await _secureStorage.read(key: 'auth_token');

      setState(() {
        _username = username;
        _authToken = token;
        _darkMode = darkMode;
        _loginCount = loginCount ?? 0;
        _appVersion = appVersion ?? 1.0;

        _usernameController.text = username ?? '';
        _tokenController.text = token ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _saveUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    await _prefsStorage.write(key: 'username', value: username);
    setState(() => _username = username);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username saved to PreferencesStorage'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a token')),
      );
      return;
    }

    await _secureStorage.write(key: 'auth_token', value: token);
    setState(() => _authToken = token);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token saved to SecureStorage (encrypted)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleDarkMode() async {
    final newValue = !_darkMode;
    await _prefsStorage.writeBool(key: 'dark_mode', value: newValue);
    setState(() => _darkMode = newValue);
  }

  Future<void> _incrementLoginCount() async {
    final newCount = _loginCount + 1;
    await _prefsStorage.writeInt(key: 'login_count', value: newCount);
    setState(() => _loginCount = newCount);
  }

  Future<void> _updateVersion() async {
    final newVersion = _appVersion + 0.1;
    await _prefsStorage.writeDouble(key: 'app_version', value: newVersion);
    setState(() => _appVersion = newVersion);
  }

  Future<void> _clearAllData() async {
    await _prefsStorage.clear();
    await _secureStorage.clear();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing storage...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Without DI Example'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearAllData,
            tooltip: 'Clear all data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            const Card(
              color: Colors.green,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Direct Usage (No DI)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Storages instantiated directly:\n'
                      '• PreferencesStorageImpl()\n'
                      '• SecureStorageImpl()\n'
                      'PreferencesStorage requires init() call!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // PreferencesStorage section
            _buildSectionHeader('PreferencesStorage', Icons.settings, Colors.blue),
            const Text(
              'Fast, unencrypted storage for app preferences',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Username input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username (String)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveUsername,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dark mode toggle
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode (Boolean)'),
                subtitle: Text('Current: $_darkMode'),
                value: _darkMode,
                onChanged: (value) => _toggleDarkMode(),
              ),
            ),
            const SizedBox(height: 16),

            // Login count
            Card(
              child: ListTile(
                title: const Text('Login Count (Integer)'),
                subtitle: Text('Count: $_loginCount'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _incrementLoginCount,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App version
            Card(
              child: ListTile(
                title: const Text('App Version (Double)'),
                subtitle: Text('Version: ${_appVersion.toStringAsFixed(1)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.upgrade),
                  onPressed: _updateVersion,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // SecureStorage section
            _buildSectionHeader('SecureStorage', Icons.lock, Colors.red),
            const Text(
              'Encrypted storage for sensitive data (tokens, passwords)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Token input
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Auth Token (Encrypted)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.security),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveToken,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Current values display
            const Divider(height: 32),
            _buildSectionHeader('Current Stored Values', Icons.storage, Colors.purple),
            const SizedBox(height: 8),
            _buildValueRow('Username', _username ?? 'Not set', Icons.person),
            _buildValueRow('Token', _authToken != null ? '••••••••' : 'Not set', Icons.lock),
            _buildValueRow('Dark Mode', _darkMode.toString(), Icons.brightness_6),
            _buildValueRow('Login Count', _loginCount.toString(), Icons.login),
            _buildValueRow('App Version', _appVersion.toStringAsFixed(1), Icons.info),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
