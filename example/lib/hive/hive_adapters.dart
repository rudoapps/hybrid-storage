import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/task.dart';

@GenerateAdapters([AdapterSpec<Task>()])
part 'hive_adapters.g.dart';
