// Fake data and constants for Hive storage tests
// Mock classes are defined inline in test files, NOT here

/// Test constants
const String testBoxName = 'test_box';
const String testKey = 'test_key';
const String testStringValue = 'test_value';
const int testIntValue = 42;

/// Factory function to create fake Map data
Map<String, dynamic> createFakeMapData({
  String id = '1',
  String name = 'Test User',
  String email = 'test@example.com',
}) {
  return {
    'id': id,
    'name': name,
    'email': email,
  };
}

/// Factory function to create a list of fake Map data
List<Map<String, dynamic>> createFakeMapList({
  int count = 3,
}) {
  return List.generate(
    count,
    (index) => createFakeMapData(
      id: '${index + 1}',
      name: 'Test User ${index + 1}',
      email: 'test${index + 1}@example.com',
    ),
  );
}

/// Factory function to create mixed type values for testing type filtering
List<dynamic> createMixedTypeValues() {
  return [
    createFakeMapData(id: '1', name: 'Test1'),
    'string_value',
    createFakeMapData(id: '2', name: 'Test2'),
    42,
    true,
    createFakeMapData(id: '3', name: 'Test3'),
  ];
}

/// Test box names for multiple box scenarios
const String testBox1 = 'box1';
const String testBox2 = 'box2';
const String testBox3 = 'box3';

/// Error messages for testing
const String errorMessagePutFailed = 'Put failed';
const String errorMessageGetFailed = 'Get failed';
const String errorMessageDeleteFailed = 'Delete failed';
const String errorMessageClearFailed = 'Clear failed';
const String errorMessageOpenFailed = 'Open failed';
const String errorMessageCloseFailed = 'Close failed';
