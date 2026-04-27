import 'package:fitness_pj_3/services/db_init_io.dart'
    if (dart.library.html) 'package:fitness_pj_3/services/db_init_web.dart' as impl;

void initializeDatabaseFactory() {
  impl.initializeDatabaseFactory();
}

