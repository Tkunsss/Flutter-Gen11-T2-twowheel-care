import 'expense.dart';

class MaintenanceRecord {
  final String taskName;
  final DateTime date;
  final int odometerKm;
  final Expense? expense;

  MaintenanceRecord({
    required this.taskName,
    required this.date,
    required this.odometerKm,
    this.expense,
  });
}
