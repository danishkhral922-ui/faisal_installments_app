- [x] Create Firebase-only data layer plan: remove Hive usage from CustomerModel persistence and provider logic
- [ ] Update CustomerProvider: load customers from Firestore with Firestore cache for offline support; remove Box<CustomerModel> and Hive.openBox usage
- [ ] Remove Hive initialization/adapter registration from main.dart
- [ ] Update recordPayment/add/update/delete methods to read/modify/write Firestore (and keep local in-memory list)
- [ ] Keep existing monthly status reset logic but apply updates to Firestore
- [ ] Update dependencies in pubspec.yaml: remove hive, hive_flutter, hive_generator, build_runner/hive_generator if not needed
- [ ] Run flutter analyze + tests


