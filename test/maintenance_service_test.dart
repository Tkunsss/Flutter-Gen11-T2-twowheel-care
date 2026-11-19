// Import Flutter's testing tools and the application's classes used in these tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:two_wheel_care/model/vehicle.dart';
import 'package:two_wheel_care/model/vehicle_type.dart';
import 'package:two_wheel_care/model/expense.dart';
import 'package:two_wheel_care/model/maintenance_schedule.dart';
import 'package:two_wheel_care/service/maintenance_service.dart';

void main() {
  // These variables are declared with late because they are initialized
  late MaintenanceService service;
  late Vehicle bike;

  final now = DateTime(2026, 2, 1);

  setUp(() {
    // Create a new MaintenanceService for each test.
    service = MaintenanceService();

    // Create a motorcycle object with an initial registration date.
    bike = Vehicle(
      id: 'v1',
      name: 'Honda Xr230',
      type: VehicleType.motorcycle,
      registeredAt: DateTime(2026, 1, 1),
    );

    // Add an oil change schedule after every 3000 km or 6 months.
    service.addSchedule(
      bike,
      MaintenanceSchedule('Oil change', intervalKm: 3000, intervalMonths: 6),
    );

    // Add a brake check schedule after every 10000 km.
    service.addSchedule(
      bike,
      MaintenanceSchedule('Brake check', intervalKm: 10000),
    );
  });

  //Normal 

  test('records maintenance with expense and sums total', () {
    service.updateOdometer(bike, 1000);

    // Record an oil change with a $15 expense.
    service.recordMaintenance(
      bike,
      'Oil change',
      DateTime(2026, 1, 20),
      expense: Expense(15),
      now: now,
    );

    // Confirm that one maintenance record was created.
    expect(bike.records.length, 1);

    // Confirm that the total expense is calculated as 15.
    expect(service.calculateTotalExpenses(bike), 15);
  });

  test('status is ok when far from interval', () {
    service.updateOdometer(bike, 1000);

    expect(
      service.getStatus(bike, bike.schedules[0], now),
      MaintenanceStatus.ok,
    );
  });

  test('due reminders contain only due or overdue tasks', () {
    service.updateOdometer(bike, 3100);

    final due = service.getDueReminders(bike, now);

    // Only "Oil change" should be returned because the brake task
    expect(due.map((s) => s.taskName), ['Oil change']);
  });

  // Invalid

  test('rejects record for a task without schedule', () {
    // "Tire change" does not have a maintenance schedule.
    expect(
      () => service.recordMaintenance(
        bike,
        'Tire change',
        DateTime(2026, 1, 20),
        now: now,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects record dated in the future', () {
    // March 1 is later than the fixed current date, February 1.
    expect(
      () => service.recordMaintenance(
        bike,
        'Oil change',
        DateTime(2026, 3, 1),
        now: now,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects odometer lower than current value', () {
    service.updateOdometer(bike, 2000);

    // Attempting to lower the odometer should be rejected.
    expect(
      () => service.updateOdometer(bike, 1500),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects duplicate schedule name', () {
    // Adding another schedule with the same name should be rejected.
    expect(
      () => service.addSchedule(
        bike,
        MaintenanceSchedule('Oil change', intervalKm: 1000),
      ),
      throwsA(isA<StateError>()),
    );
  });

  //Boundary 

  test('status is dueSoon at 100 km before interval', () {
    // This is exactly 100 km below the 3000 km oil interval.
    service.updateOdometer(bike, 2900);

    expect(
      service.getStatus(bike, bike.schedules[0], now),
      MaintenanceStatus.dueSoon,
    );
  });

  test('status is overdue exactly at the interval (3100 km)', () {
    service.updateOdometer(bike, 3100);

    // the schedule is overdue.
    expect(
      service.getStatus(bike, bike.schedules[0], now),
      MaintenanceStatus.overdue,
    );
  });
}
