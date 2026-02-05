import 'package:hive_ce/hive_ce.dart';
import '../models/task.dart';

@GenerateAdapters([
  AdapterSpec<Task>(),
])
part 'hive_adapters.g.dart';
