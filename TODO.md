# TODO

## Customer sync between devices (same email/password)
- [x] Identify issue: app loads from local Hive box `customers` (not per-user) while Firebase is only written on add.
- [ ] Change CustomerProvider to make Hive box per authenticated user (e.g. `customers_<uid>`).
- [ ] Implement Firebase real-time listener (or periodic fetch) so that when customer changes on one device, other device updates.
- [ ] On login/initialize: load initial Firebase customers for that user and keep Hive in sync.
- [ ] Update add/update/delete/payment methods to write to both Hive (user box) and Firestore, and handle incoming snapshot updates.
- [ ] Run Flutter unit/widget tests and (if available) add a basic sanity check.

