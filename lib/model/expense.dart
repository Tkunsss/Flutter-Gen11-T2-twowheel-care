class Expense {
  final double amount;
  final String? note;

  Expense(this.amount, {this.note}) {
    if (amount < 0) throw ArgumentError('Expense amount cannot be negative');
  }
}
