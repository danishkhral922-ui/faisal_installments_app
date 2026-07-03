# TODO_AUTO_MONTH

- [x] Confirmed: current app has no monthly auto-status logic. (Only manual recordPayment/markAsPaid/markAsPending changes status.)
- [ ] Implement monthly scheduler based on `CustomerModel.startDate`.
- [ ] On each month boundary update customer status from **Paid → Pending** (reset) as requested.
- [ ] Decide how to reset payment fields safely (isPaid, installmentAmount, completedInstallments, paidAmount, lastPaidMonth).
- [ ] Persist the computed state back to Hive (and Firestore if enabled).
- [ ] Hook the scheduler into app startup/resume (likely in CustomerProvider.initialize() or a new service called from main()).
- [ ] Add lightweight regression (at least run `flutter test`).


