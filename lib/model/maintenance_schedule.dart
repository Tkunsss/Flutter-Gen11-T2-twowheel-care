enum MaintenanceStatus { ok, dueSoon, overdue }

class MaintenanceSchedule {
  final String taskName;
  final int? intervalKm;
  final int? intervalMonths;

  MaintenanceSchedule(this.taskName, {this.intervalKm, this.intervalMonths}) {
    if (taskName.trim().isEmpty) throw ArgumentError('Task name is required');
    if ((intervalKm ?? 0) <= 0 && (intervalMonths ?? 0) <= 0) {
      throw ArgumentError('Set a positive interval in km or months');
    }
  }
}
