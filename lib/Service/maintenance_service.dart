import '../model/vehicle.dart';
import '../model/maintenance_schedule.dart';
import '../model/maintenance_record.dart';
import '../model/expense.dart';

// MaintenanceService contains the app's maintenance and reminder operations.
class MaintenanceService {
  static const int dueSoonKm = 200;

  static const int dueSoonDays = 14;

  // Add a maintenance schedule to a vehicle.
  void addSchedule(Vehicle v, MaintenanceSchedule s) {
    // Check whether a schedule with this task name already exists.
    if (v.schedules.any((e) => e.taskName == s.taskName)) {
      throw StateError('Schedule "${s.taskName}" already exists');
    }

    // Add the schedule if no duplicate name was found.
    v.schedules.add(s);
  }

  // Update the vehicle's odometer reading.
  void updateOdometer(Vehicle v, int newKm) {
    if (newKm < 0) {
      throw ArgumentError('Distance cannot be negative');
    }

    if (newKm < v.odometerKm) {
      throw ArgumentError('Distance cannot be lower than the current value');
    }

    // Store the valid odometer reading.
    v.odometerKm = newKm;
  }

  MaintenanceRecord recordMaintenance(
    Vehicle v,
    String taskName,
    DateTime date, {
    Expense? expense,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    // The task must have an existing schedule.
    if (!v.schedules.any((s) => s.taskName == taskName)) {
      throw ArgumentError('No schedule for task "$taskName"');
    }

    if (date.isAfter(today)) {
      throw ArgumentError('Maintenance date cannot be in the future');
    }

    // Create the maintenance record with the current odometer value.
    final record = MaintenanceRecord(
      taskName: taskName,
      date: date,
      odometerKm: v.odometerKm,
      expense: expense,
    );

    // Add the record to the vehicle's maintenance history.
    v.records.add(record);

    // Return the newly created record.
    return record;
  }

  MaintenanceStatus getStatus(Vehicle v, MaintenanceSchedule s, DateTime now) {
    // Find the most recent record for this maintenance task.
    final last = v.lastRecordFor(s.taskName);

    // Start distance from the last record, or zero for a new vehicle.
    final baseKm = last?.odometerKm ?? 0;

    // Start date from the last record, or vehicle registration date.
    final baseDate = last?.date ?? v.registeredAt;

    // Calculate how many kilometres remain before the next service.
    final kmLeft = s.intervalKm == null
        ? null
        : baseKm + s.intervalKm! - v.odometerKm;

    // Calculate the date when service becomes due
    final dueDate = s.intervalMonths == null
        ? null
        : DateTime(
            baseDate.year,
            baseDate.month + s.intervalMonths!,
            baseDate.day,
          );

    // overdue: distance has reached/passed today's date.
    if ((kmLeft != null && kmLeft <= 0) ||
        (dueDate != null && !now.isBefore(dueDate))) {
      return MaintenanceStatus.overdue;
    }

    // dueSoon: 200 km or fewer remain(14day).
    if ((kmLeft != null && kmLeft <= dueSoonKm) ||
        (dueDate != null && dueDate.difference(now).inDays <= dueSoonDays)) {
      return MaintenanceStatus.dueSoon;
    }

    // Otherwise, maintenance is not due soon.
    return MaintenanceStatus.ok;
  }

  // Return all schedules that are due soon or overdue.
  List<MaintenanceSchedule> getDueReminders(Vehicle v, DateTime now) {
    return v.schedules
        .where((s) => getStatus(v, s, now) != MaintenanceStatus.ok)
        .toList();
  }

  // Calculate the total of every maintenance expense.
  double calculateTotalExpenses(Vehicle v) {
    // If a record has no expense, use zero instead.
    return v.records.fold(0.0, (sum, r) => sum + (r.expense?.amount ?? 0));
  }
}
