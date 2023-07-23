class Booking {
  final String id;
  final String name;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final DateTime timestamp;
  final Map<String, dynamic> userData;

  Booking({
    required this.id,
    required this.name,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.timestamp,
    required this.userData,
  });

  String get bookingDate => userData['booking_date'];
  String get bookingTime => userData['booking_time'];
}