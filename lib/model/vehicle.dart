import 'vehicle_type.dart';
import 'maintenance_schedule.dart';
import 'maintenance_record.dart';

class Vehicle {
  final String id;
  String name;
  final VehicleType type;
  final DateTime registeredAt;
  int odometerKm;
  final List<MaintenanceSchedule> schedules = [];
  final List<MaintenanceRecord> records = [];

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.registeredAt,
    this.odometerKm = 0,
  });

  MaintenanceRecord? lastRecordFor(String taskName) {
    final list = records.where((r) => r.taskName == taskName).toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.first;
  }
}
