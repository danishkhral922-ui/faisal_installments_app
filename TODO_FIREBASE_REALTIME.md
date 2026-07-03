# Firebase realtime + Hive sync (per admin email)

- [ ] CustomerModel me `adminUid` (string) field add karna (HiveType adapter update).
- [ ] addCustomer(): Firestore document set/update me `adminUid` (logged-in user.uid) aur (optional) `adminEmail` save karna.
- [ ] CustomerProvider.initialize()/loadCustomers(): logged-in admin ke hisaab se Firestore query: `customers.where('adminUid' == currentUid)`.
- [ ] CustomerProvider me Firestore `snapshots()` listener setup karna:
  - add/modify par Hive me upsert
  - delete par Hive delete
- [ ] UI Hive se same provider `customers` list show karti rahe (instant local updates + realtime listener).
- [ ] recordPayment/markAsPaid/updateCustomer/deleteCustomer me Firestore update bhi ensure (adminUid filter ke sath inconsistencies avoid).
- [ ] MonthlyStatusScheduler updates Firestore me update karte rahein (adminUid field preserved).
- [ ] test/build run karna: `flutter analyze` aur aap ki platform (android) par app run.

