import 'package:flutter/material.dart';
import 'package:hybrid_storage/hybrid_storage.dart';
import 'package:hybrid_storage_example/models/task.dart';

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
  final HiveStorageImpl _hiveStorage = HiveStorageImpl();

  bool _isInitialized = false;
  bool _isLoading = false;

  // Values from storage
  String? _username;
  String? _authToken;
  bool _darkMode = false;
  int _loginCount = 0;
  double _appVersion = 0.0;

  // Hive storage - Tasks
  List<Task> _tasks = [];
  List<String> _notes = [];
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  Task? _editingTask;

  // Text controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _boxNameController = TextEditingController();

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

      // initialize HiveStorage
      await _hiveStorage.init();

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
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _noteController.dispose();
    _boxNameController.dispose();
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

      // Load tasks from Hive
      await _loadTasks();
      await _loadNotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _saveUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a username')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a token')));
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
    await _clearAllTasks();
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

  // Hive Storage - Task methods
  static const String _tasksBoxName = 'tasks';

  Future<void> _loadTasks() async {
    try {
      final tasksData = await _hiveStorage.getAll<Map>(boxName: _tasksBoxName);
      final tasks = tasksData
          .map((data) => Task.fromJson(Map<String, dynamic>.from(data)))
          .toList();

      setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tasks: $e')));
      }
    }
  }

  Future<void> _loadNotes() async {
    try {
      final allData = await _hiveStorage.getAll<dynamic>(
        boxName: _tasksBoxName,
      );
      final notes = allData.whereType<String>().toList();

      setState(() => _notes = notes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading notes: $e')));
      }
    }
  }

  Future<void> _addTask() async {
    // If editing, call update instead
    if (_editingTask != null) {
      await _updateTask();
      return;
    }

    final title = _taskTitleController.text.trim();
    final description = _taskDescriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    try {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
      );

      await _hiveStorage.put<Map>(
        boxName: _tasksBoxName,
        key: task.id,
        value: task.toJson(),
      );

      _taskTitleController.clear();
      _taskDescriptionController.clear();

      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added to HiveStorage'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding task: $e')));
      }
    }
  }

  void _startEditingTask({required Task task}) {
    setState(() {
      _editingTask = task;
      _taskTitleController.text = task.title;
      _taskDescriptionController.text = task.description;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingTask = null;
      _taskTitleController.clear();
      _taskDescriptionController.clear();
    });
  }

  Future<void> _updateTask() async {
    if (_editingTask == null) return;

    final title = _taskTitleController.text.trim();
    final description = _taskDescriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    try {
      final updatedTask = _editingTask!.copyWith(
        title: title,
        description: description,
      );

      await _hiveStorage.put<Map>(
        boxName: _tasksBoxName,
        key: updatedTask.id,
        value: updatedTask.toJson(),
      );

      _cancelEditing();
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
      }
    }
  }

  Future<void> _toggleTaskCompletion({required Task task}) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

      await _hiveStorage.put<Map>(
        boxName: _tasksBoxName,
        key: task.id,
        value: updatedTask.toJson(),
      );

      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
      }
    }
  }

  Future<void> _deleteTask({required String taskId}) async {
    try {
      await _hiveStorage.delete(boxName: _tasksBoxName, key: taskId);
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
      }
    }
  }

  Future<void> _clearAllTasks() async {
    try {
      await _hiveStorage.clear(boxName: _tasksBoxName);
      await _loadTasks();
      await _loadNotes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All tasks cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing tasks: $e')));
      }
    }
  }

  Future<void> _saveNote() async {
    if (_noteController.text.isEmpty) return;

    try {
      await _hiveStorage.put<String>(
        boxName: _tasksBoxName,
        key: 'note_${DateTime.now().millisecondsSinceEpoch}',
        value: _noteController.text,
      );
      _noteController.clear();

      await _loadNotes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    }
  }

  Future<void> _createBox() async {
    if (_boxNameController.text.isEmpty) return;

    try {
      final boxName = _boxNameController.text;
      await _hiveStorage.openBox(boxName: boxName);
      _boxNameController.clear();

      setState(() {}); // Refresh to show new box

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Box "$boxName" created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating box: $e')));
      }
    }
  }

  Future<void> _deleteBox({required String boxName}) async {
    try {
      await _hiveStorage.deleteBox(boxName: boxName);
      setState(() {}); // Refresh to update box list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Box "$boxName" deleted!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting box: $e')));
      }
    }
  }

  Future<void> _clearAllBoxes() async {
    try {
      await _hiveStorage.deleteAllBoxes();
      await _loadTasks();
      await _loadNotes();
      setState(() {}); // Refresh to update box list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All boxes cleared!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing boxes: $e')));
      }
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
                      '• HiveStorageImpl()\n'
                      'PreferencesStorage and HiveStorage require init() call!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // PreferencesStorage section
            _buildSectionHeader(
              'PreferencesStorage',
              Icons.settings,
              Colors.blue,
            ),
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

            const SizedBox(height: 32),

            // HiveStorage section
            _buildSectionHeader(
              'HiveStorage',
              Icons.storage_rounded,
              Colors.orange,
            ),
            const Text(
              'Local database for complex objects (Tasks with multiple fields)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Task input fields
            TextField(
              controller: _taskTitleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Task Description (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addTask,
                    icon: Icon(_editingTask == null ? Icons.add : Icons.save),
                    label: Text(
                      _editingTask == null ? 'Add Task' : 'Update Task',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (_editingTask != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _cancelEditing,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Simple string storage (primitive data)
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Quick Note (String)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                      hintText: 'Store a simple string value',
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade300,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks & Notes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: (_tasks.isEmpty && _notes.isEmpty)
                      ? null
                      : _clearAllTasks,
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Clear All Tasks Box'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),

            // Tasks list
            if (_tasks.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No tasks yet. Add one above!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Tasks (${_tasks.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._tasks.map(
                    (task) => Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => _toggleTaskCompletion(task: task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: task.description.isNotEmpty
                            ? Text(task.description)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _startEditingTask(task: task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(taskId: task.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            if (_notes.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Quick Notes (String primitives in same box)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ..._notes.map(
                (note) => Card(
                  color: Colors.orange.shade50,
                  child: ListTile(
                    leading: const Icon(
                      Icons.note,
                      color: Colors.orange,
                      size: 20,
                    ),
                    title: Text(note),
                    dense: true,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Box Management section
            _buildSectionHeader(
              'Box Management',
              Icons.folder,
              Colors.deepOrange,
            ),
            const Text(
              'Create, list, and delete Hive boxes',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Create box input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _boxNameController,
                    decoration: const InputDecoration(
                      labelText: 'Box Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.create_new_folder),
                      hintText: 'Enter box name to create',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _createBox,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Box'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // All boxes list
            FutureBuilder<List<String>>(
              future: _hiveStorage.getAllBoxes(),
              builder: (context, snapshot) {
                final boxes = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Boxes (${boxes.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: boxes.isEmpty ? null : _clearAllBoxes,
                          icon: const Icon(Icons.delete_forever, size: 18),
                          label: const Text('Clear All Boxes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (boxes.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No boxes yet. Create one above!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    else
                      ...boxes.map(
                        (boxName) => Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.folder,
                              color: Colors.deepOrange,
                            ),
                            title: Text(boxName),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBox(boxName: boxName),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Current values display
            const Divider(height: 32),
            _buildSectionHeader(
              'Current Stored Values',
              Icons.storage,
              Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildValueRow('Username', _username ?? 'Not set', Icons.person),
            _buildValueRow(
              'Token',
              _authToken != null ? '••••••••' : 'Not set',
              Icons.lock,
            ),
            _buildValueRow(
              'Dark Mode',
              _darkMode.toString(),
              Icons.brightness_6,
            ),
            _buildValueRow('Login Count', _loginCount.toString(), Icons.login),
            _buildValueRow(
              'App Version',
              _appVersion.toStringAsFixed(1),
              Icons.info,
            ),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
