# TODO - Statement (Installment-wise) Feature

- [ ] Step 1: Extend `CustomerModel` with `paymentHistory` and `PaymentEntry`.
- [ ] Step 2: Update `CustomerProvider.recordPayment()` to append installment-wise ledger entries with dates and per-installment amounts.
- [ ] Step 3: Update Firestore serialization/deserialization in `CustomerProvider` (`addCustomer`, `_fromDoc`, `updateCustomer`).
- [ ] Step 4: Implement statement generator in `lib/utils/record_export.dart`:
  - [ ] Build statement text (bank-statement style table)
  - [ ] Generate PDF with installment rows
  - [ ] Save to Downloads (TXT)
- [ ] Step 5: Update `CustomerDetailScreen` popup menu to use Statement actions (Save/Print/Share) rather than summary.
- [ ] Step 6: Quick sanity test: add customer, record installments, verify statement output includes installment number, paid date, amount.

