import 'package:intl/intl.dart';

String rupiah(int value) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
).format(value);
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

// Contoh: 12 Des 2024, 12:03
String transactionTime(DateTime value) {
  final time = value.toLocal();
  return '${time.day} ${_months[time.month - 1]} ${time.year}, '
      '${DateFormat('HH:mm').format(time)}';
}
