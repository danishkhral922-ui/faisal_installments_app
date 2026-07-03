import '../data/models/customer_model.dart';

class MonthlyStatusScheduler {
  /// Resets status each month boundary.
  ///
  /// Requested rule from user:
  /// - once per month, status should flip **Paid -> Pending** (reset).
  /// - monthly schedule is driven by each customer's `startDate`.
  ///
  /// NOTE:
  /// - We compute the number of months that have passed since startDate
  ///   up to `now`.
  /// - We then derive what the customer *should* be at that month boundary.
  /// - Since the app currently doesn't track "monthly events" separately,
  ///   we only reset `isPaid`/`installmentAmount` when a new month boundary is reached
  ///   compared to `lastPaidMonth`.
  ///
  /// Returns whether any customer was changed.
  static bool resetPaidToPendingIfMonthAdvanced({
    required CustomerModel customer,
    required DateTime now,
  }) {
    if (customer.totalMonths <= 0) return false;

    final start = DateTime(customer.startDate.year, customer.startDate.month);
    final current = DateTime(now.year, now.month);

    final monthsDiff = _monthsBetween(
      start,
      current,
    ); // >= 0 means at/after start

    if (monthsDiff <= 0) {
      return false;
    }

    // lastPaidMonth is used by current code as a "how many installments were recorded" counter.
    // For this scheduler, we interpret it as "the last month boundary we processed".
    // We reset only when we cross a new month boundary.
    final processedMonths = customer.lastPaidMonth;

    // If we've already processed this boundary or beyond, nothing to do.
    if (monthsDiff <= processedMonths) return false;

    // At a new month boundary, flip Paid -> Pending (reset).
    // To keep Remaining/Next Installment calculations consistent across:
    // - CustomerDetailScreen
    // - Print/PDF/Share (record_export.dart)
    // we must also reset the progress counters used by `currentMonthlyInstallment`.
    if (customer.isPaid) {
      customer.isPaid = false;
      customer.completedInstallments = 0;
      customer.paidAmount = 0;
      customer.lastPaidMonth = 0;

      customer.installmentAmount = customer.currentMonthlyInstallment;
    }

    // Also update lastPaidMonth to avoid repeatedly applying the reset.
    // We set it to the latest boundary month index.
    customer.lastPaidMonth = monthsDiff;

    return true;
  }

  static int _monthsBetween(DateTime fromMonth, DateTime toMonth) {
    // Both inputs are normalized to year+month.
    return (toMonth.year - fromMonth.year) * 12 +
        (toMonth.month - fromMonth.month);
  }

  /// Applies the scheduler over a list and returns the count of updates.
  static int runOnCustomers({
    required List<CustomerModel> customers,
    required DateTime now,
    required void Function(CustomerModel customer) onChanged,
  }) {
    var changed = 0;
    for (final c in customers) {
      final didChange = resetPaidToPendingIfMonthAdvanced(
        customer: c,
        now: now,
      );
      if (didChange) {
        changed++;
        onChanged(c);
      }
    }
    return changed;
  }
}
